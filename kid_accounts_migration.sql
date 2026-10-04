-- Run after messages_migration.sql in your EXISTING Swim With Me project.
begin;
create table if not exists public.kid_profile_links (
 user_id uuid primary key references auth.users(id) on delete cascade,
 swimmer_id uuid not null references public.swimmers(id) on delete cascade
);
alter table public.kid_profile_links enable row level security;
grant select,insert,update,delete on public.kid_profile_links to authenticated;
drop policy if exists kid_links_read on public.kid_profile_links;
create policy kid_links_read on public.kid_profile_links for select to authenticated using(user_id=auth.uid() or exists(select 1 from public.swimmers s where s.id=swimmer_id and public.is_family_owner(s.family_id)));
drop policy if exists kid_links_insert on public.kid_profile_links;
create policy kid_links_insert on public.kid_profile_links for insert to authenticated with check(exists(select 1 from public.swimmers s join public.family_members m on m.family_id=s.family_id and m.user_id=kid_profile_links.user_id where s.id=swimmer_id and public.is_family_owner(s.family_id)));
drop policy if exists kid_links_update on public.kid_profile_links;
create policy kid_links_update on public.kid_profile_links for update to authenticated using(exists(select 1 from public.swimmers s where s.id=swimmer_id and public.is_family_owner(s.family_id))) with check(exists(select 1 from public.swimmers s join public.family_members m on m.family_id=s.family_id and m.user_id=kid_profile_links.user_id where s.id=swimmer_id and public.is_family_owner(s.family_id)));
drop policy if exists kid_links_delete on public.kid_profile_links;
create policy kid_links_delete on public.kid_profile_links for delete to authenticated using(exists(select 1 from public.swimmers s where s.id=swimmer_id and public.is_family_owner(s.family_id)));
-- Linked child accounts only read their own swimmer and cannot edit swim records.
create or replace function public.can_view_swimmer(sid uuid) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from swimmers s where s.id=sid
 and (not exists(select 1 from kid_profile_links k where k.user_id=auth.uid()) or exists(select 1 from kid_profile_links k where k.user_id=auth.uid() and k.swimmer_id=sid))
 and (is_family_owner(s.family_id) or exists(select 1 from access_grants g where g.swimmer_id=sid and g.user_id=auth.uid())))
$$;
create or replace function public.can_edit_swimmer(sid uuid) returns boolean language sql stable security definer set search_path=public as $$
 select not exists(select 1 from kid_profile_links k where k.user_id=auth.uid())
 and exists(select 1 from swimmers s where s.id=sid and (is_family_owner(s.family_id) or exists(select 1 from access_grants g where g.swimmer_id=sid and g.user_id=auth.uid() and g.permission='edit')))
$$;
-- Kid sender names come from the linked swimmer, not a typed display name.
create or replace function public.stamp_race_message() returns trigger language plpgsql security definer set search_path=public as $$
declare linked_name text; linked_swimmer uuid; race_swimmer uuid;
begin
 new.sender_id := auth.uid(); new.created_at := now();
 select swimmer_id into linked_swimmer from public.kid_profile_links where user_id=auth.uid();
 if linked_swimmer is not null then
  select swimmer_id into race_swimmer from public.swims where id=new.swim_id;
  if race_swimmer is distinct from linked_swimmer then raise exception 'This race is not linked to your kid profile'; end if;
  select name into linked_name from public.swimmers where id=linked_swimmer;
  new.sender_name := left(linked_name,60);
 else new.sender_name := trim(new.sender_name);
 end if;
 new.body := trim(new.body); return new;
end $$;
commit;
notify pgrst, 'reload schema';
