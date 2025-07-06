#!/bin/bash

# Default values
CONTAINER_NAME="postgres-erd-test"
POSTGRES_PASSWORD="pass"
POSTGRES_USER="postgres"
POSTGRES_DB="postgres"
POSTGRES_PORT="15432"  # Default to 15432 to avoid conflicts
INPUT_FILES=()
OUTPUT_FILE="dump.sql"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT         PostgreSQL port (default: 15432)"
    echo "  -i, --input FILE        Input SQL file (can be specified multiple times)"
    echo "  -o, --output FILE       Output dump file (default: dump.sql)"
    echo "  -h, --help             Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -i init.sql"
    echo "  $0 -p 25432 -i schema1.sql -i schema2.sql -o dumped_schema.sql"
    echo ""
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            POSTGRES_PORT="$2"
            shift 2
            ;;
        -i|--input)
            INPUT_FILES+=("$2")
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# If no input files specified, show usage
if [ ${#INPUT_FILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No input files specified${NC}"
    echo ""
    usage
fi

# Check if input files exist
for input_file in "${INPUT_FILES[@]}"; do
    if [ ! -f "$input_file" ]; then
        echo -e "${RED}Error: Input file '$input_file' not found${NC}"
        exit 1
    fi
done

echo "Starting PostgreSQL container..."

# Stop and remove existing container if it exists
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# Start PostgreSQL container in detached mode
docker run -d \
  --name $CONTAINER_NAME \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -p $POSTGRES_PORT:5432 \
  postgres:15-alpine

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
  if docker exec $CONTAINER_NAME pg_isready -U $POSTGRES_USER >/dev/null 2>&1; then
    echo -e "${GREEN}PostgreSQL is ready!${NC}"
    break
  fi
  echo -n "."
  sleep 1
done

if ! docker exec $CONTAINER_NAME pg_isready -U $POSTGRES_USER >/dev/null 2>&1; then
  echo -e "${RED}PostgreSQL failed to start${NC}"
  exit 1
fi

# Load schemas from input files
echo "Loading schemas..."
for input_file in "${INPUT_FILES[@]}"; do
  echo "Loading schema from $input_file..."
  docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d $POSTGRES_DB < "$input_file"
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Schema from $input_file loaded successfully!${NC}"
  else
    echo -e "${RED}Failed to load schema from $input_file${NC}"
    exit 1
  fi
done

echo -e "${GREEN}All schemas loaded successfully!${NC}"

# Dump schema to output file
echo "Dumping schema to $OUTPUT_FILE..."
docker exec $CONTAINER_NAME pg_dump --schema-only --file=/tmp/schema.sql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$POSTGRES_DB

# Copy the dump file from container to host
docker cp $CONTAINER_NAME:/tmp/schema.sql "./$OUTPUT_FILE"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Schema dumped successfully to $OUTPUT_FILE!${NC}"
else
  echo -e "${RED}Failed to dump schema${NC}"
  exit 1
fi

# Optional: Stop and remove container
echo "Cleaning up..."
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

echo -e "${GREEN}Process completed successfully!${NC}"