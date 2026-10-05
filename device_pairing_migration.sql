-- Prerequisites: schema.sql (existing database), messages_migration.sql,
-- kid_accounts_migration.sql. Run this additive migration before enabling
-- Anonymous Sign-Ins in Supabase Auth. No service key is used in the browser.
begin;
create table if not exists public.kid_pairing_codes (
 id uuid primary key default gen_random_uuid(), swimmer_id uuid not null references public.swimmers(id) on delete cascade,
 created_by uuid not null references auth.users(id) on delete cascade,
 code_hash text unique not null, created_at timestamptz not null default now(), expires_at timestamptz not null,
 used_at timestamptz, used_by uuid references auth.users(id) on delete set null
);
create table if not exists public.kid_devices (
 user_id uuid primary key references auth.users(id) on delete cascade,
 swimmer_id uuid not null references public.swimmers(id) on delete cascade,
 device_name text not null check(char_length(device_name) between 1 and 60),
 connected_at timestamptz not null default now(), revoked_at timestamptz
);
create table if not exists public.kid_pairing_attempts (
 user_id uuid primary key references auth.users(id) on delete cascade,
 window_start timestamptz not null default now(), attempts integer not null default 0
);
create index if not exists kid_devices_swimmer_idx on public.kid_devices(swimmer_id);
create index if not exists kid_pairing_owner_idx on public.kid_pairing_codes(created_by,created_at);
alter table public.kid_pairing_codes enable row level security;
alter table public.kid_devices enable row level security;
alter table public.kid_pairing_attempts enable row level security;
revoke all on public.kid_pairing_codes,public.kid_pairing_attempts from anon,authenticated;
revoke all on public.kid_devices from anon,authenticated;
grant select on public.kid_devices to authenticated;
drop policy if exists kid_devices_read on public.kid_devices;
create policy kid_devices_read on public.kid_devices for select to authenticated using(user_id=auth.uid() or exists(select 1 from public.swimmers s where s.id=swimmer_id and public.is_family_owner(s.family_id)));

-- Deny parent privileges to anonymous sessions and linked kids even if
-- someone changes a guest's Auth identity or has old edit grants stored.
create or replace function public.is_family_owner(fid uuid) returns boolean language sql stable security definer set search_path=public as $$
 select not coalesce((auth.jwt()->>'is_anonymous')::boolean,false)
 and not exists(select 1 from kid_profile_links where user_id=auth.uid())
 and exists(select 1 from families where id=fid and owner_id=auth.uid())
$$;
create or replace function public.is_family_member(fid uuid) returns boolean language sql stable security definer set search_path=public as $$
 select is_family_owner(fid) or exists(select 1 from family_members m where m.family_id=fid and m.user_id=auth.uid()
 and not exists(select 1 from kid_devices d where d.user_id=auth.uid() and d.revoked_at is not null))
$$;
create or replace function public.can_view_swimmer(sid uuid) returns boolean language sql stable security definer set search_path=public as $$
 select not exists(select 1 from kid_devices d where d.user_id=auth.uid() and d.revoked_at is not null)
 and (not coalesce((auth.jwt()->>'is_anonymous')::boolean,false) or exists(select 1 from kid_devices d where d.user_id=auth.uid() and d.swimmer_id=sid and d.revoked_at is null))
 and exists(select 1 from swimmers s where s.id=sid
 and (not exists(select 1 from kid_profile_links k where k.user_id=auth.uid()) or exists(select 1 from kid_profile_links k where k.user_id=auth.uid() and k.swimmer_id=sid))
 and (is_family_owner(s.family_id) or exists(select 1 from access_grants g where g.swimmer_id=sid and g.user_id=auth.uid())))
$$;
create or replace function public.can_edit_swimmer(sid uuid) returns boolean language sql stable security definer set search_path=public as $$
 select not coalesce((auth.jwt()->>'is_anonymous')::boolean,false)
 and not exists(select 1 from kid_profile_links where user_id=auth.uid())
 and exists(select 1 from swimmers s where s.id=sid and (is_family_owner(s.family_id) or exists(select 1 from access_grants g where g.swimmer_id=sid and g.user_id=auth.uid() and g.permission='edit')))
$$;
drop policy if exists families_permanent_admin_only on public.families;
create policy families_permanent_admin_only on public.families as restrictive for insert to authenticated
 with check(not coalesce((auth.jwt()->>'is_anonymous')::boolean,false) and not exists(select 1 from kid_profile_links where user_id=auth.uid()));
-- Block invitation claims by anonymous or linked-child sessions.
drop policy if exists members_adult_insert_only on public.family_members;
create policy members_adult_insert_only on public.family_members as restrictive for insert to authenticated
 with check(not coalesce((auth.jwt()->>'is_anonymous')::boolean,false) and not exists(select 1 from kid_profile_links where user_id=auth.uid()));

create or replace function public.create_kid_pairing_code(p_swimmer_id uuid)
returns jsonb language plpgsql security definer set search_path=public,extensions as $$
declare fid uuid; raw_code text;
begin
 select family_id into fid from public.swimmers where id=p_swimmer_id for update;
 if fid is null or not public.is_family_owner(fid) then raise exception 'Parent access required'; end if;
 if (select count(*) from public.kid_pairing_codes where created_by=auth.uid() and created_at>now()-interval '10 minutes')>=20 then raise exception 'Please wait before creating more codes'; end if;
 -- One current code per swimmer. Old displayed codes stop working immediately.
 update public.kid_pairing_codes set expires_at=now() where swimmer_id=p_swimmer_id and used_at is null and expires_at>now();
 raw_code:=upper(encode(gen_random_bytes(8),'hex'));
 insert into public.kid_pairing_codes(swimmer_id,created_by,code_hash,expires_at) values(p_swimmer_id,auth.uid(),encode(digest(raw_code,'sha256'),'hex'),now()+interval '10 minutes');
 return jsonb_build_object('code',raw_code,'expires_at',now()+interval '10 minutes');
end $$;

create or replace function public.redeem_kid_pairing_code(p_code text,p_device_name text)
returns jsonb language plpgsql security definer set search_path=public,extensions as $$
declare code_row public.kid_pairing_codes%rowtype; uid uuid:=auth.uid(); normalized text; tries integer; fid uuid;
begin
 if uid is null or not coalesce((auth.jwt()->>'is_anonymous')::boolean,false) then raise exception 'Use a new swimmer device session'; end if;
 -- Lock the identity so simultaneous attempts cannot pair one device twice.
 perform 1 from auth.users where id=uid for update;
 if exists(select 1 from public.kid_profile_links where user_id=uid) then return jsonb_build_object('ok',false,'message','This session is already linked. Reconnect with a new device session.'); end if;
 insert into public.kid_pairing_attempts(user_id) values(uid) on conflict(user_id) do nothing;
 update public.kid_pairing_attempts set attempts=case when window_start<now()-interval '10 minutes' then 1 else attempts+1 end,
 window_start=case when window_start<now()-interval '10 minutes' then now() else window_start end where user_id=uid returning attempts into tries;
 if tries>5 then return jsonb_build_object('ok',false,'message','Too many attempts. Wait 10 minutes and try again.'); end if;
 normalized:=upper(regexp_replace(coalesce(p_code,''),'[[:space:]-]','','g'));
 if normalized !~ '^[0-9A-F]{16}$' then return jsonb_build_object('ok',false,'message','Check the code and try again.'); end if;
 select * into code_row from public.kid_pairing_codes where code_hash=encode(digest(normalized,'sha256'),'hex') for update;
 if code_row.id is null or code_row.used_at is not null or code_row.expires_at<=now() then return jsonb_build_object('ok',false,'message','Code is invalid, expired or already used. Ask your parent for a new code.'); end if;
 select family_id into fid from public.swimmers where id=code_row.swimmer_id for update;
 if not exists(select 1 from public.families where id=fid and owner_id=code_row.created_by) then return jsonb_build_object('ok',false,'message','Ask your parent for a new code.'); end if;
 if (select count(*) from public.kid_devices where swimmer_id=code_row.swimmer_id and revoked_at is null)>=10 then return jsonb_build_object('ok',false,'message','Ask your parent to disconnect an old device first.'); end if;
 insert into public.family_members(family_id,user_id) values(fid,uid);
 insert into public.access_grants(swimmer_id,user_id,permission) values(code_row.swimmer_id,uid,'view');
 insert into public.kid_profile_links(user_id,swimmer_id) values(uid,code_row.swimmer_id);
 insert into public.kid_devices(user_id,swimmer_id,device_name) values(uid,code_row.swimmer_id,left(coalesce(nullif(trim(p_device_name),''),'Swimmer phone'),60));
 update public.kid_pairing_codes set used_at=now(),used_by=uid where id=code_row.id;
 return jsonb_build_object('ok',true,'swimmer_id',code_row.swimmer_id);
end $$;

create or replace function public.disconnect_kid_device(p_user_id uuid)
returns void language plpgsql security definer set search_path=public as $$
declare sid uuid; fid uuid;
begin
 select swimmer_id into sid from public.kid_devices where user_id=p_user_id for update;
 select family_id into fid from public.swimmers where id=sid;
 if fid is null or not public.is_family_owner(fid) then raise exception 'Parent access required'; end if;
 update public.kid_devices set revoked_at=now() where user_id=p_user_id;
 delete from public.access_grants where user_id=p_user_id;
 delete from public.family_members where user_id=p_user_id;
 -- Keep the kid link to prevent a revoked session becoming an adult session.
end $$;
revoke all on function public.create_kid_pairing_code(uuid),public.redeem_kid_pairing_code(text,text),public.disconnect_kid_device(uuid) from public,anon;
grant execute on function public.create_kid_pairing_code(uuid),public.redeem_kid_pairing_code(text,text),public.disconnect_kid_device(uuid) to authenticated;
commit;
notify pgrst,'reload schema';
