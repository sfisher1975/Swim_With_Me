-- Swim With Me v1.22.7
-- Allow multiple invitations to the same email address for the same family.
-- Each press of Send Invitation may create a fresh family_invites row.

alter table public.family_invites
  drop constraint if exists family_invites_family_id_email_key;

-- Keep lookups by family/email efficient after removing the unique constraint.
create index if not exists family_invites_family_email_idx
  on public.family_invites (family_id, lower(email));
