-- Run after family_portal_migration.sql. No existing data is deleted.
create table if not exists public.family_join_codes(family_id uuid primary key references public.families(id) on delete cascade,code text unique not null);
create table if not exists public.family_join_requests(id uuid primary key default gen_random_uuid(),family_id uuid not null references public.families(id) on delete cascade,user_id uuid not null references auth.users(id) on delete cascade,display_name text not null,email text not null,status text not null default 'pending' check(status in ('pending','approved','declined')),created_at timestamptz not null default now(),unique(family_id,user_id));
alter table public.family_join_codes enable row level security;
alter table public.family_join_requests enable row level security;
drop policy if exists join_codes_read on public.family_join_codes;
create policy join_codes_read on public.family_join_codes for select to authenticated using(public.is_family_owner(family_id));
drop policy if exists join_requests_read on public.family_join_requests;
create policy join_requests_read on public.family_join_requests for select to authenticated using(public.is_family_owner(family_id) or user_id=auth.uid());
create or replace function public.create_family_join_code(p_family_id uuid) returns text language plpgsql security definer set search_path=public as $$
declare c text;
begin
 if not public.is_family_owner(p_family_id) or coalesce((auth.jwt()->>'is_anonymous')::boolean,false) then raise exception 'Parent access required'; end if;
 c:=replace(gen_random_uuid()::text,'-','');
 insert into public.family_join_codes values(p_family_id,c) on conflict(family_id) do update set code=excluded.code;
 return c;
end $$;
create or replace function public.request_family_access(p_code text,p_name text) returns void language plpgsql security definer set search_path=public as $$
declare fid uuid; em text;
begin
 if auth.uid() is null or coalesce((auth.jwt()->>'is_anonymous')::boolean,false) or exists(select 1 from public.kid_profile_links where user_id=auth.uid()) then raise exception 'Sign in with a family email account'; end if;
 select email into em from auth.users where id=auth.uid() and email_confirmed_at is not null;
 if em is null then raise exception 'Confirm your email first'; end if;
 if length(trim(p_name)) not between 1 and 80 then raise exception 'Enter your name'; end if;
 select family_id into fid from public.family_join_codes where code=lower(trim(p_code));
 if fid is null then raise exception 'Family code not found. Ask the parent for the current code'; end if;
 if public.is_family_member(fid) then raise exception 'Already connected to this family'; end if;
 if (select count(*) from public.family_join_requests where user_id=auth.uid() and status='pending')>=5 then raise exception 'You already have pending requests'; end if;
 insert into public.family_join_requests(family_id,user_id,display_name,email) values(fid,auth.uid(),trim(p_name),em) on conflict(family_id,user_id) do update set status='pending',display_name=excluded.display_name,email=excluded.email;
end $$;
create or replace function public.review_family_request(p_request_id uuid,p_approve boolean,p_swimmers uuid[]) returns void language plpgsql security definer set search_path=public as $$
declare r public.family_join_requests; sid uuid;
begin
 select * into r from public.family_join_requests where id=p_request_id for update;
 if r.id is null or not public.is_family_owner(r.family_id) or coalesce((auth.jwt()->>'is_anonymous')::boolean,false) then raise exception 'Parent access required'; end if;
 if r.status<>'pending' then raise exception 'This request was already reviewed'; end if;
 if p_approve then
  if coalesce(cardinality(p_swimmers),0)=0 then raise exception 'Select at least one swimmer'; end if;
  if exists(select 1 from unnest(p_swimmers) x where not exists(select 1 from public.swimmers s where s.id=x and s.family_id=r.family_id)) then raise exception 'Swimmer must belong to your family'; end if;
  if exists(select 1 from public.kid_profile_links where user_id=r.user_id) then raise exception 'Kid accounts cannot join as family adults'; end if;
  insert into public.family_members(family_id,user_id) values(r.family_id,r.user_id) on conflict do nothing;
  foreach sid in array p_swimmers loop
   insert into public.access_grants(swimmer_id,user_id,permission) values(sid,r.user_id,'view') on conflict(swimmer_id,user_id) do nothing;
  end loop;
 end if;
 update public.family_join_requests set status=case when p_approve then 'approved' else 'declined' end where id=r.id;
end $$;
revoke all on function public.create_family_join_code(uuid),public.request_family_access(text,text),public.review_family_request(uuid,boolean,uuid[]) from public,anon;
grant execute on function public.create_family_join_code(uuid),public.request_family_access(text,text),public.review_family_request(uuid,boolean,uuid[]) to authenticated;
grant select on public.family_join_codes,public.family_join_requests to authenticated;
notify pgrst,'reload schema';
