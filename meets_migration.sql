-- Run once in the existing Swim With Me Supabase project. Safe to rerun.
-- Atomically remove a meet, optionally deleting its linked swim results.
create or replace function public.delete_swim_meet(p_meet_id uuid,p_delete_times boolean default false)
returns integer language plpgsql security invoker set search_path=public as $$
declare sid uuid; result_ids uuid[]; removed integer:=0;
begin
 select swimmer_id into sid from public.meets where id=p_meet_id for update;
 if sid is null then raise exception 'Meet not found or access denied'; end if;
 if not public.can_edit_swimmer(sid) then raise exception 'You cannot delete this meet'; end if;
 perform 1 from public.meet_events where meet_id=p_meet_id for update;
 select array_agg(distinct swim_id) filter(where swim_id is not null) into result_ids from public.meet_events where meet_id=p_meet_id;
 if p_delete_times and result_ids is not null then
  if exists(select 1 from public.meet_events where swim_id=any(result_ids) and meet_id<>p_meet_id) then
   raise exception 'A result is linked to another meet. Keep times or remove that link first';
  end if;
  if exists(select 1 from public.swims where id=any(result_ids) and swimmer_id<>sid) then
   raise exception 'A result belongs to another swimmer';
  end if;
  delete from public.swims where id=any(result_ids) and swimmer_id=sid;
  get diagnostics removed=row_count;
 end if;
 delete from public.meets where id=p_meet_id;
 if not found then raise exception 'Meet could not be deleted'; end if;
 return removed;
end $$;
revoke all on function public.delete_swim_meet(uuid,boolean) from public,anon;
grant execute on function public.delete_swim_meet(uuid,boolean) to authenticated;
notify pgrst,'reload schema';
