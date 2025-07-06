# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a test repository for experimenting with `liam-erd`, a tool for generating Entity Relationship Diagrams (ERDs) from PostgreSQL databases. The project demonstrates a complete workflow from database schema to visual ERD documentation, including automated deployment to GitHub Pages.

## Commands

### Quick Start
```bash
# Generate ERD locally (removes old files, converts schema to dump, builds ERD, serves locally)
rm -rf dist/ dump.sql && ./schema2dump.sh -i init.sql && npx @liam-hq/cli erd build --input dump.sql --format postgres && npx http-server -c-1 dist/
```

### Individual Commands

#### Schema to Dump Conversion
```bash
# Basic usage (will show help if no files specified)
./schema2dump.sh -i init.sql

# Multiple schema files
./schema2dump.sh -i schema1.sql -i schema2.sql -i data.sql

# Custom port and output
./schema2dump.sh -p 25432 -i init.sql -o my_dump.sql

# Show help
./schema2dump.sh -h
```

#### ERD Generation and Viewing
```bash
# Generate ERD from dump file
npx @liam-hq/cli erd build --input dump.sql --format postgres

# Serve the generated ERD locally (with cache disabled)
npx http-server -c-1 dist/
```

The ERD will be accessible at http://localhost:8080

### Testing and Linting
- Run `npm run lint` or appropriate linting commands if available
- Run `npm run typecheck` or appropriate type checking commands if available

## Architecture

### Files
- `init.sql`: Comprehensive PostgreSQL schema with multiple schemas (auth, ecommerce, analytics), various relationship types, and PostgreSQL features
- `schema2dump.sh`: Script to convert schema SQL files to PostgreSQL dump format
  - Default port: 15432 (to avoid conflicts with common PostgreSQL installations)
  - Default output: dump.sql
  - Supports multiple input files
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