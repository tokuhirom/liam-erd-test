# liam-erd テストリポジトリ

このレポジトリでは [liam-erd](https://github.com/liam-hq/liam) を使用して PostgreSQL データベースから ER図（Entity Relationship Diagram）を生成するワークフローをテストします。

## 概要

1. Docker で PostgreSQL を起動
2. SQLファイルからスキーマを読み込み
3. `pg_dump` でスキーマをダンプ
4. liam-erd でER図をHTML形式で生成
5. GitHub Pages で自動公開

## 必要な環境

- Docker
- Node.js / npm

## プロジェクト構成

```
.
├── src/
│   ├── input-ec.sql      # Eコマーススキーマ（複雑な例）
│   └── input-simple.sql  # シンプルなスキーマ（基本例）
├── schema2dump.sh         # スキーマをダンプ形式に変換
├── build.sh              # 全ERDを一括生成
└── out/                  # 生成されたERD（GitHub Pages用）
    ├── index.html        # ERD一覧
    ├── ec/               # Eコマース ERD
    └── simple/           # シンプル ERD
```

## クイックスタート

### 全ERDを一括生成

```bash
./build.sh
```

これにより、`src/input-*.sql` のすべてのスキーマから ERD が生成され、`out/` ディレクトリに配置されます。

### 個別のERD生成

```bash
# スキーマをダンプ形式に変換
./schema2dump.sh -i src/input-simple.sql -o dump.sql

# ERDを生成
npx @liam-hq/cli erd build --input dump.sql --format postgres

# ローカルで確認
npx http-server -c-1 dist/
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

# PostgreSQL 17を使用
./schema2dump.sh -v 17-alpine -i init.sql

# 特定のバージョンを使用
./schema2dump.sh -v 16.4 -i schema1.sql -o dump.sql
```

**オプション:**
- `-p, --port PORT`: PostgreSQL ポート (デフォルト: 15432)
- `-v, --version VERSION`: PostgreSQL バージョン (デフォルト: 15-alpine)
- `-i, --input FILE`: 入力SQLファイル（複数指定可能、必須）
- `-o, --output FILE`: 出力ダンプファイル (デフォルト: dump.sql)
- `-h, --help`: ヘルプ表示

### build.sh
すべての `src/input-*.sql` ファイルから ERD を一括生成するスクリプト。

```bash
# デフォルトのPostgreSQLバージョンで実行
./build.sh

# PostgreSQL 17を使用
./build.sh -v 17-alpine

# ヘルプを表示
./build.sh -h
```

**機能:**
- `src/input-*.sql` ファイルを自動検出
- 各スキーマを PostgreSQL ダンプ形式に変換
- liam-erd で ERD を生成
- `out/` ディレクトリに整理して配置
- インデックスページ (`out/index.html`) を自動生成

**オプション:**
- `-v, --version VERSION`: PostgreSQL バージョン (デフォルト: schema2dump.sh の設定を使用)
- `-h, --help`: ヘルプ表示

## 新しいスキーマの追加

1. `src/input-{name}.sql` という名前でスキーマファイルを作成
2. `./build.sh` を実行
3. `out/{name}/` に ERD が生成される

## ローカルでの確認

```bash
# ERDを生成
./build.sh

# ローカルサーバーで確認
npx http-server -c-1 out/
```

ブラウザで `http://localhost:8080` にアクセスして ERD 一覧を確認できます。

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

- `src/input-*.sql`: 入力スキーマファイル
  - `input-ec.sql`: Eコマーススキーマ（複雑な例）
  - `input-simple.sql`: シンプルなスキーマ（基本例）
- `schema2dump.sh`: スキーマSQLをダンプ形式に変換するスクリプト
- `build.sh`: 全ERDを一括生成するスクリプト
- `CLAUDE.md`: Claude Code 用の開発ガイドライン
- `.github/workflows/deploy-erd.yml`: GitHub Actions ワークフロー
- `out/`: 生成されたERD（GitHub Pagesで公開）

