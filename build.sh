#!/bin/bash

# src/input-{NAME}.sql を順番に処理する｡
# schema2dump.sh で src/dump-{NAME}.sql に書き込む｡
# liam ERD で out/{NAME}/ に出力する
# out/index.html に一覧を出す
# このファイルは github actions から実行され､out/ が github pages で見えるようになる｡

set -e

# Default values
POSTGRES_VERSION=""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -v, --version VERSION   PostgreSQL version to use (default: 15-alpine)"
    echo "  -h, --help             Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     # Use default PostgreSQL version"
    echo "  $0 -v 17-alpine        # Use PostgreSQL 17"
    echo "  $0 --version 16.4      # Use specific PostgreSQL version"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            POSTGRES_VERSION="$2"
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

# Prepare schema2dump.sh arguments
SCHEMA_ARGS=""
if [ -n "$POSTGRES_VERSION" ]; then
    SCHEMA_ARGS="-v $POSTGRES_VERSION"
    echo -e "${BLUE}Using PostgreSQL version: $POSTGRES_VERSION${NC}"
fi

echo -e "${BLUE}Starting build process...${NC}"

# Create output directory
mkdir -p out
mkdir -p src

# Process each input-*.sql file
for input_file in src/input-*.sql; do
    if [ ! -f "$input_file" ]; then
        echo -e "${RED}No input files found in src/${NC}"
        exit 1
    fi
    
    # Extract name from filename (e.g., input-ec.sql -> ec)
    basename=$(basename "$input_file")
    name=${basename#input-}
    name=${name%.sql}
    
    echo -e "${BLUE}Processing $name...${NC}"
    
    # Convert schema to dump
    dump_file="src/dump-${name}.sql"
    echo "  Converting schema to dump..."
    ./schema2dump.sh $SCHEMA_ARGS -i "$input_file" -o "$dump_file"
    
    # Generate ERD
    output_dir="out/${name}"
    mkdir -p "$output_dir"
    echo "  Generating ERD..."
    cd "$output_dir"
    npx @liam-hq/cli erd build --input "../../$dump_file" --format postgres
    # Move generated files from dist/ to current directory
    if [ -d "dist" ]; then
        mv dist/* . 2>/dev/null || true
        mv dist/.* . 2>/dev/null || true
        rm -rf dist
    fi
    cd ../..
    
    echo -e "${GREEN}  ✓ Completed $name${NC}"
done

# Generate index.html
echo -e "${BLUE}Generating index.html...${NC}"
cat > out/index.html <<'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>liam-erd Examples</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .erd-list {
            list-style: none;
            padding: 0;
        }
        .erd-item {
            margin: 15px 0;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .erd-item:hover {
            background-color: #e9ecef;
        }
        .erd-link {
            text-decoration: none;
            color: #3498db;
            font-size: 18px;
            font-weight: 500;
            display: block;
        }
        .erd-link:hover {
            color: #2c88cc;
        }
        .description {
            color: #666;
            font-size: 14px;
            margin-top: 5px;
        }
        .footer {
            margin-top: 40px;
            text-align: center;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>liam-erd Examples</h1>
        <p>以下のER図が生成されています：</p>
        <ul class="erd-list">
EOF

# Add links for each generated ERD
for input_file in src/input-*.sql; do
    if [ -f "$input_file" ]; then
        basename=$(basename "$input_file")
        name=${basename#input-}
        name=${name%.sql}
        
        # Create description based on name
        case "$name" in
            "ec")
                description="Eコマースシステムの包括的なスキーマ（複数スキーマ、様々なリレーション）"
                ;;
            "simple")
                description="シンプルな2テーブル構成（外部キー制約の基本例）"
                ;;
            "schema-example")
                description="複数スキーマを使用したシンプルな例（人事・プロジェクト管理）"
                ;;
            "issue2345")
                description="reproducing code for https://github.com/liam-hq/liam/issues/2345"
                ;;
            *)
                description="データベーススキーマ"
                ;;
        esac
        
        cat >> out/index.html <<EOF
            <li class="erd-item">
                <a href="${name}/index.html" class="erd-link">${name}</a>
                <div class="description">${description}</div>
            </li>
EOF
    fi
done

cat >> out/index.html <<'EOF'
        </ul>
        <div class="footer">
            <p>Generated with <a href="https://github.com/liam-hq/liam">liam-erd</a></p>
        </div>
    </div>
</body>
</html>
EOF

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "Output directory: ${BLUE}out/${NC}"
