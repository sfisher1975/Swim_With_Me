-- Swim With Me v1.22.12
-- Accept email invitations without depending on the invite_email_matches(auth.users) RLS helper.
-- Safe to run more than once.

create or replace function public.accept_my_family_invites()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_email text := lower(trim(coalesce(auth.jwt()->>'email','')));
  v_count integer := 0;
  r record;
begin
  if v_uid is null or v_email = '' then
    raise exception 'Sign in to accept this invitation';
  end if;

  for r in
    select distinct fi.family_id
    from public.family_invites fi
    where lower(trim(fi.email)) = v_email
  loop
    insert into public.family_members(family_id,user_id)
    values(r.family_id,v_uid)
    on conflict do nothing;
    v_count := v_count + 1;
  end loop;

  delete from public.family_invites fi
  where lower(trim(fi.email)) = v_email;

  return v_count;
end
$$;

revoke all on function public.accept_my_family_invites() from public, anon;
grant execute on function public.accept_my_family_invites() to authenticated;
notify pgrst, 'reload schema';
