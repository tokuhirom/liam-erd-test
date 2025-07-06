# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a test repository for experimenting with `liam-erd`, a tool for generating Entity Relationship Diagrams (ERDs) from PostgreSQL databases. The project demonstrates a complete workflow from database schema to visual ERD documentation, including automated deployment to GitHub Pages.

The project now supports multiple schema files and generates a comprehensive ERD gallery with an index page.

## Commands

### Quick Start
```bash
# Generate all ERDs and serve locally
./build.sh && npx http-server -c-1 out/
```

### Individual Commands

#### Build All ERDs
```bash
# Generate all ERDs with default PostgreSQL version
./build.sh

# Use PostgreSQL 17 for all ERDs
./build.sh -v 17-alpine

# Show help
./build.sh -h
```

This will:
1. Process all `src/input-*.sql` files
2. Convert each to PostgreSQL dump format (using specified version)
3. Generate ERDs using liam-erd
4. Create an index page at `out/index.html`

#### Schema to Dump Conversion (Individual)
```bash
# Convert a single schema file
./schema2dump.sh -i src/input-simple.sql -o dump.sql

# Multiple schema files
./schema2dump.sh -i schema1.sql -i schema2.sql -i data.sql

# Custom port and output
./schema2dump.sh -p 25432 -i src/input-ec.sql -o my_dump.sql

# Use PostgreSQL 17
./schema2dump.sh -v 17-alpine -i src/input-ec.sql

# Use specific PostgreSQL version
./schema2dump.sh -v 16.4 -i init.sql -o dump.sql

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
- `src/input-*.sql`: Input schema files
  - `input-ec.sql`: Comprehensive e-commerce schema with multiple PostgreSQL schemas (auth, ecommerce, analytics), various relationship types, and advanced features
  - `input-simple.sql`: Simple two-table schema demonstrating basic foreign key relationships
- `schema2dump.sh`: Script to convert schema SQL files to PostgreSQL dump format
  - Default port: 15432 (to avoid conflicts with common PostgreSQL installations)
  - Default PostgreSQL version: 15-alpine
  - Default output: dump.sql
  - Supports multiple input files
  - Supports different PostgreSQL versions via `-v` option
- `build.sh`: Batch processing script that generates ERDs for all schema files
  - Automatically detects `src/input-*.sql` files
  - Generates organized output in `out/` directory
  - Creates an index page for easy navigation
  - Supports PostgreSQL version selection via `-v` option
- `.github/workflows/deploy-erd.yml`: GitHub Actions workflow for automatic ERD deployment to GitHub Pages
  - Runs `build.sh` to generate all ERDs
  - Deploys `out/` directory to GitHub Pages

### Database Schema Examples

#### input-ec.sql (E-commerce)
- Multiple schemas: `public`, `auth`, `ecommerce`, `analytics`
- Various relationship types: 1:1, 1:N, N:N, self-referencing
- PostgreSQL features: UUIDs, indexes, views, materialized views, triggers, custom types, domains
- Comprehensive e-commerce example with users, products, orders, and analytics

#### input-simple.sql (Basic)
- Simple two-table structure (`foo` and `bar`)
- Basic foreign key relationship
- Minimal example for testing ERD generation

## Development Notes

- PostgreSQL container uses port 15432 by default (configurable via -p flag)
- Input schema files must follow the naming pattern `src/input-{name}.sql`
- The workflow requires input files to be specified explicitly (no default fallback)
- GitHub Pages deployment requires repository settings configuration (Settings → Pages → Source: GitHub Actions)
- The generated ERDs are accessible at `https://<username>.github.io/<repository-name>/` after deployment
- Each ERD is accessible at `https://<username>.github.io/<repository-name>/{name}/`

## CI/CD

The project includes GitHub Actions workflow that:
1. Triggers on push to main branch or manual dispatch
2. Runs `build.sh` to process all schema files
3. Generates ERDs for each `src/input-*.sql` file
4. Creates an index page with links to all ERDs
5. Deploys the `out/` directory to GitHub Pages automatically

## Adding New Schemas

To add a new schema:
1. Create a file named `src/input-{name}.sql` with your schema
2. Run `./build.sh` locally to test
3. Commit and push to trigger automatic deployment
4. The new ERD will be available at `/{name}/` on GitHub Pages