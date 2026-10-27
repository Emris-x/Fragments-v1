# FORGE — Make it real

FORGE is a mobile-first personal execution workspace for turning ideas into finished work.

## Live application
https://forge-workspace-emris-xs-projects.vercel.app

## Source
This repository currently lives at [Emris-x/Fragments-v1](https://github.com/Emris-x/Fragments-v1). The repository name is historical; the deployed product is FORGE.

## Features
- Responsive desktop and mobile workspace
- Projects, task lists, priorities, and progress tracking
- Supabase email/password authentication
- Cloud-synced projects and tasks across devices
- Row Level Security policies restrict each account to its own records
- PWA manifest and offline shell support

## Architecture
- Frontend: HTML, CSS, browser JavaScript
- Hosting: Vercel
- Auth and database: Supabase
- `/api/config` returns only the Supabase URL and publishable API key at runtime.
- Never place a Supabase service-role or secret key in browser code.

## Supabase setup
Required Vercel environment variables:
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Database migration: `supabase/migrations/202610280001_forge_schema.sql`.

## Local development
Run with Vercel's local development server so the `/api/config` function is available. Set the two environment variables above in your local environment first.
