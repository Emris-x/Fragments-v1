-- FORGE initial schema: per-user projects and tasks with row-level security.
-- Safe to apply to a dedicated FORGE Supabase project only.

create extension if not exists pgcrypto;

create table if not exists public.forge_projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 60),
  description text not null default '' check (char_length(description) <= 240),
  category text not null default 'Software'
    check (category in ('Software','Learning','Business','Research','Personal')),
  icon text not null default '◈',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.forge_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  project_id uuid not null references public.forge_projects(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 100),
  priority text not null default 'Medium' check (priority in ('Low','Medium','High')),
  is_done boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists forge_projects_user_created_idx
  on public.forge_projects (user_id, created_at desc);
create index if not exists forge_tasks_user_project_created_idx
  on public.forge_tasks (user_id, project_id, created_at desc);
create index if not exists forge_tasks_user_done_idx
  on public.forge_tasks (user_id, is_done);

alter table public.forge_projects enable row level security;
alter table public.forge_tasks enable row level security;

drop policy if exists "Users can read their own FORGE projects" on public.forge_projects;
create policy "Users can read their own FORGE projects"
  on public.forge_projects for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can create their own FORGE projects" on public.forge_projects;
create policy "Users can create their own FORGE projects"
  on public.forge_projects for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own FORGE projects" on public.forge_projects;
create policy "Users can update their own FORGE projects"
  on public.forge_projects for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own FORGE projects" on public.forge_projects;
create policy "Users can delete their own FORGE projects"
  on public.forge_projects for delete to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can read their own FORGE tasks" on public.forge_tasks;
create policy "Users can read their own FORGE tasks"
  on public.forge_tasks for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can create their own FORGE tasks" on public.forge_tasks;
create policy "Users can create their own FORGE tasks"
  on public.forge_tasks for insert to authenticated
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.forge_projects p
      where p.id = project_id and p.user_id = auth.uid()
    )
  );

drop policy if exists "Users can update their own FORGE tasks" on public.forge_tasks;
create policy "Users can update their own FORGE tasks"
  on public.forge_tasks for update to authenticated
  using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.forge_projects p
      where p.id = project_id and p.user_id = auth.uid()
    )
  );

drop policy if exists "Users can delete their own FORGE tasks" on public.forge_tasks;
create policy "Users can delete their own FORGE tasks"
  on public.forge_tasks for delete to authenticated
  using (auth.uid() = user_id);

grant select, insert, update, delete on public.forge_projects to authenticated;
grant select, insert, update, delete on public.forge_tasks to authenticated;

create or replace function public.forge_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists forge_projects_touch_updated_at on public.forge_projects;
create trigger forge_projects_touch_updated_at
  before update on public.forge_projects
  for each row execute function public.forge_touch_updated_at();

drop trigger if exists forge_tasks_touch_updated_at on public.forge_tasks;
create trigger forge_tasks_touch_updated_at
  before update on public.forge_tasks
  for each row execute function public.forge_touch_updated_at();
