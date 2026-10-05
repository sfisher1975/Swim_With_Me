-- Run in existing Swim_With_Me after family_signup_migration.sql and device_pairing_migration.sql.
-- Installing this function does not remove any members.
begin;
create or replace function public.remove_family_member(p_family_id uuid,p_user_id uuid)
returns void language plpgsql security definer set search_path=public as $$
declare f public.families; member_email text;
begin
 select * into f from public.families where id=p_family_id for update;
 if f.id is null or not public.is_family_owner(p_family_id) or coalesce((auth.jwt()->>'is_anonymous')::boolean,false) or exists(select 1 from public.kid_profile_links where user_id=auth.uid()) then raise exception 'Parent access required'; end if;
 if p_user_id=f.owner_id then raise exception 'The family owner cannot be removed'; end if;
 if not exists(select 1 from public.family_members where family_id=p_family_id and user_id=p_user_id) then raise exception 'Member is no longer in this family'; end if;
 delete from public.access_grants g using public.swimmers s where g.swimmer_id=s.id and s.family_id=p_family_id and g.user_id=p_user_id;
 delete from public.kid_profile_links k using public.swimmers s where k.swimmer_id=s.id and s.family_id=p_family_id and k.user_id=p_user_id;
 delete from public.kid_devices d using public.swimmers s where d.swimmer_id=s.id and s.family_id=p_family_id and d.user_id=p_user_id;
 delete from public.kid_pairing_codes c using public.swimmers s where c.swimmer_id=s.id and s.family_id=p_family_id and c.used_by=p_user_id;
 delete from public.race_messages m using public.swims race,public.swimmers s where m.swim_id=race.id and race.swimmer_id=s.id and s.family_id=p_family_id and m.sender_id=p_user_id;
 delete from public.family_members where family_id=p_family_id and user_id=p_user_id;
 delete from public.family_join_requests where family_id=p_family_id and user_id=p_user_id;
 -- Clear only this family’s saved signup code to prevent automatic re-request on sign-in.
 update auth.users u set raw_user_meta_data=coalesce(u.raw_user_meta_data,'{}'::jsonb)-'family_join_code' where u.id=p_user_id and exists(select 1 from public.family_join_codes c where c.family_id=p_family_id and c.code=u.raw_user_meta_data->>'family_join_code');
 select email into member_email from auth.users where id=p_user_id;
 delete from public.family_invites where family_id=p_family_id and lower(email)=lower(member_email);
end $$;
revoke all on function public.remove_family_member(uuid,uuid) from public,anon;
grant execute on function public.remove_family_member(uuid,uuid) to authenticated;
commit;
notify pgrst,'reload schema';
