#!/bin/sh
npx @liam-hq/cli erd build --input dump.sql --format postgres
npx http-server -c 0 dist/
