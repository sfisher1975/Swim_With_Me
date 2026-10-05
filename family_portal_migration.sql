-- Helps the family owner identify accounts when assigning swimmer access.
-- Existing swimmer/message RLS policies still enforce all permissions.
create or replace function public.family_member_directory(p_family_id uuid)
returns table(user_id uuid,email text,display_name text,is_kid boolean)
language plpgsql security definer set search_path=public as $$
begin
 if not public.is_family_owner(p_family_id) then raise exception 'Parent access required'; end if;
 return query select m.user_id,u.email::text,
 coalesce(nullif(u.raw_user_meta_data->>'full_name',''),nullif(u.raw_user_meta_data->>'name',''),u.email)::text,
 exists(select 1 from public.kid_profile_links k where k.user_id=m.user_id)
 from public.family_members m join auth.users u on u.id=m.user_id where m.family_id=p_family_id;
end $$;
revoke all on function public.family_member_directory(uuid) from public,anon;
grant execute on function public.family_member_directory(uuid) to authenticated;
notify pgrst,'reload schema';
