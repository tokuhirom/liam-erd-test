# liam-erd テストリポジトリ

このレポジトリでは [liam-erd](https://github.com/liam-hq/liam) を使用して PostgreSQL データベースから ER図（Entity Relationship Diagram）を生成するワークフローをテストします。

## 概要

1. Docker で PostgreSQL を起動
2. SQLファイルからスキーマを読み込み
3. `pg_dump` でスキーマをダンプ
4. liam-erd でER図をHTML形式で生成
5. ローカルサーバーで表示

## 必要な環境

- Docker
- Node.js / npm

## SYNOPSIS

```bash
rm -rf dist/ dump.sql && ./schema2dump.sh -i init.sql && ./run_liam_erd.sh
```

## スクリプト

### schema2dump.sh
スキーマSQLファイルをPostgreSQLのダンプ形式に変換するスクリプト。

**機能:**
- PostgreSQL コンテナの自動起動
- 複数のSQLファイルの読み込み対応
- スキーマのダンプ出力
- コンテナの自動クリーンアップ

**使用方法:**
```bash
# ヘルプを表示
./schema2dump.sh -h

# 単一ファイルを指定
./schema2dump.sh -i init.sql

# 複数ファイルを指定
./schema2dump.sh -i schema1.sql -i schema2.sql -i data.sql

# ポートと出力ファイルも指定
./schema2dump.sh -p 25432 -i init.sql -o my_dump.sql
```

**オプション:**
- `-p, --port PORT`: PostgreSQL ポート (デフォルト: 15432)
- `-i, --input FILE`: 入力SQLファイル（複数指定可能、必須）
- `-o, --output FILE`: 出力ダンプファイル (デフォルト: dump.sql)
- `-h, --help`: ヘルプ表示

### run_liam_erd.sh
liam-erd を使用してER図を生成し、ローカルサーバーで表示するスクリプト。

```bash
./run_liam_erd.sh
```

このスクリプトは以下を実行します：
1. `dump.sql` から liam-erd を使用してER図を生成
2. `http-server` で生成されたER図を表示

## 完全なワークフロー例

```bash
# 1. スキーマをダンプ形式に変換
./schema2dump.sh -i init.sql

# 2. ER図を生成して表示
./run_liam_erd.sh
```

ブラウザで `http://localhost:8080` にアクセスしてER図を確認できます。

## GitHub Pages での自動デプロイ

このリポジトリは GitHub Actions を使用して、自動的に ERD を生成し GitHub Pages にデプロイします。

### セットアップ

1. GitHub リポジトリの Settings → Pages で Source を "GitHub Actions" に設定
2. main ブランチにプッシュすると自動的にデプロイが実行されます

### アクセス

デプロイされた ERD は以下の URL でアクセスできます：
`https://<username>.github.io/<repository-name>/`

### 手動デプロイ

Actions タブから "Deploy ERD to GitHub Pages" ワークフローを手動で実行することも可能です。

## ファイル構成

- `init.sql`: サンプルのデータベーススキーマ（外部キー制約付き）
- `schema2dump.sh`: スキーマSQLをダンプ形式に変換するスクリプト
- `run_liam_erd.sh`: ER図生成・表示スクリプト
- `CLAUDE.md`: Claude Code 用の開発ガイドライン

