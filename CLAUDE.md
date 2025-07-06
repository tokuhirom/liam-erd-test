# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a test repository for experimenting with `liam-erd`, a tool for generating Entity Relationship Diagrams (ERDs) from PostgreSQL databases. The project demonstrates a complete workflow from database schema to visual ERD documentation, including automated deployment to GitHub Pages.

## Commands

### Quick Start
```bash
# Generate ERD locally (removes old files, dumps schema, builds ERD, serves locally)
rm -rf dist/ dump.sql && ./run_pg_dump.sh -i init.sql && ./run_liam_erd.sh
```

### Individual Commands

#### Database Schema Dump
```bash
# Basic usage (uses init.sql by default - will show help if no files specified)
./run_pg_dump.sh -i init.sql

# Multiple schema files
./run_pg_dump.sh -i schema1.sql -i schema2.sql -i data.sql

# Custom port and output
./run_pg_dump.sh -p 25432 -i init.sql -o my_dump.sql

# Show help
./run_pg_dump.sh -h
```

#### ERD Generation
```bash
# Generate ERD and serve locally
./run_liam_erd.sh
```

This will:
1. Use `@liam-hq/cli` to build ERD from dump.sql
2. Serve the generated files at http://localhost:8080

### Testing and Linting
- Run `npm run lint` or appropriate linting commands if available
- Run `npm run typecheck` or appropriate type checking commands if available

## Architecture

### Files
- `init.sql`: Comprehensive PostgreSQL schema with multiple schemas (auth, ecommerce, analytics), various relationship types, and PostgreSQL features
- `run_pg_dump.sh`: Automated script for PostgreSQL container management and schema dumping
  - Default port: 15432 (to avoid conflicts with common PostgreSQL installations)
  - Default output: dump.sql
  - Supports multiple input files
- `run_liam_erd.sh`: ERD generation and local serving script
- `.github/workflows/deploy-erd.yml`: GitHub Actions workflow for automatic ERD deployment to GitHub Pages

### Database Schema Structure
The `init.sql` file contains:
- Multiple schemas: `public`, `auth`, `ecommerce`, `analytics`
- Various relationship types: 1:1, 1:N, N:N, self-referencing
- PostgreSQL features: UUIDs, indexes, views, materialized views, triggers, custom types, domains
- Comprehensive e-commerce example with users, products, orders, and analytics

## Development Notes

- PostgreSQL container uses port 15432 by default (configurable via -p flag)
- The workflow requires input files to be specified explicitly (no default fallback)
- GitHub Pages deployment requires repository settings configuration (Settings → Pages → Source: GitHub Actions)
- The generated ERD is accessible at `https://<username>.github.io/<repository-name>/` after deployment

## CI/CD

The project includes GitHub Actions workflow that:
1. Triggers on push to main branch or manual dispatch
2. Spins up PostgreSQL container
3. Loads schema and generates dump
4. Builds ERD using liam-erd
5. Deploys to GitHub Pages automatically