# typespec-proto

TypeSpecからJavaコードを直接生成するプロジェクト

## プロジェクト概要

TypeSpec定義ファイルから公式の`@typespec/http-client-java`エミッターを使用してJavaコードを生成します。

## プロジェクト構造

```
typespec-proto/
├── package.json                 # TypeSpec依存関係管理
├── tspconfig.yaml              # TypeSpec設定
├── .gitignore
├── src/
│   └── models/
│       └── example.tsp         # TypeSpec定義ファイル
├── examples/
│   ├── basic-types.tsp         # プリミティブ型、配列、マップ
│   ├── api-models.tsp          # REST APIモデル例
│   └── complex-models.tsp      # ネストされた型、継承
└── output/
    └── java/                   # 生成されたJavaコード
```

## 実装計画

### 1. プロジェクトセットアップ
- package.json作成
  - @typespec/compiler依存関係
  - @typespec/http-client-java依存関係
  - コンパイルスクリプト追加
- tspconfig.yaml作成
  - Javaエミッター設定
  - 出力ディレクトリ設定
  - Javaパッケージ名設定
- .gitignore作成

### 2. TypeSpec定義ファイル作成
- **src/models/example.tsp**: 基本的なモデル定義
- **examples/basic-types.tsp**: プリミティブ型、配列、マップの例
- **examples/api-models.tsp**: REST APIモデルの例
- **examples/complex-models.tsp**: ネストされた型、継承の例

### 3. コンパイル設定
- tspconfig.yamlでJavaエミッター設定
- package.jsonにコンパイルスクリプト追加
- 出力ディレクトリ設定

## 使用コマンド

```bash
# 依存関係インストール
npm install

# TypeSpecからJavaコードを生成
npm run compile
# または
npx tsp compile . --emit=@typespec/http-client-java
```

## 必要な依存関係

- Node.js 20以上
- @typespec/compiler
- @typespec/http-client-java
- Java 17以上（生成コードの実行環境として）