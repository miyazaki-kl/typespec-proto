# TypeSpec カスタムデコレーター実装ガイド

このドキュメントでは、TypeSpecでカスタムデコレーターを作成し、複数カラム間の条件付きバリデーションをドキュメント化する方法を説明します。

## 概要

TypeSpecでは、JavaScriptで実装したカスタムデコレーターを作成できます。これにより：

- **ビジネスルールの明示的な記述**
- **条件付きバリデーションロジックのドキュメント化**
- **OpenAPI出力時の無視（メタデータとして保存）**
- **将来的なカスタムエミッターでの活用**

## プロジェクト構造

```
typespec-proto/
├── lib/                          # カスタムデコレーターライブラリ
│   ├── decorators.js             # JavaScript実装
│   ├── main.tsp                  # TypeSpec定義
│   └── package.json              # ライブラリ設定
├── payment-api.tsp               # 使用例（支払いAPI）
├── payment-tspconfig.yaml        # 専用コンパイル設定
└── tsp-output/
    └── payment-schema/
        └── openapi.yaml          # 生成されたOpenAPIスキーマ
```

## カスタムデコレーターの実装

### 1. JavaScript実装 (`lib/decorators.js`)

```javascript
// カスタムデコレーターの実装
export function $conditionalRequired(context, target, condition) {
  // メタデータをプログラムに保存
  const existing = context.program.stateMap("conditionalRequired").get(target);
  const conditions = existing ? [...existing, condition] : [condition];
  context.program.stateMap("conditionalRequired").set(target, conditions);
}

export function $businessRule(context, target, description) {
  // ビジネスルールをメタデータとして保存
  context.program.stateMap("businessRule").set(target, description);
}

export function $dependsOn(context, target, dependency) {
  // フィールド間の依存関係を保存
  const existing = context.program.stateMap("dependsOn").get(target);
  const dependencies = existing ? [...existing, dependency] : [dependency];
  context.program.stateMap("dependsOn").set(target, dependencies);
}
```

**重要なポイント**:
- 関数名は `$` プレフィックスが必要
- `context.program.stateMap()` でメタデータを保存
- 複数の条件や依存関係も配列で管理可能

### 2. TypeSpec定義 (`lib/main.tsp`)

```typescript
import "./decorators.js";

// カスタムデコレーター定義
extern dec conditionalRequired(target: unknown, condition: valueof string);
extern dec businessRule(target: unknown, description: valueof string);
extern dec dependsOn(target: unknown, dependency: valueof string);
```

**重要なポイント**:
- `extern dec` で外部実装を示す
- `valueof string` で文字列リテラル値を受け取る
- `target: unknown` で任意のTypeSpec要素に適用可能

### 3. ライブラリ設定 (`lib/package.json`)

```json
{
  "name": "typespec-custom-decorators",
  "version": "1.0.0",
  "type": "module",
  "tspMain": "main.tsp",
  "exports": {
    ".": {
      "tsp": "./main.tsp"
    }
  }
}
```

## 使用例：支払いAPI

### 条件付きバリデーションの実装

```typescript
// クレジットカード払いモデル
@businessRule("クレジットカード払いの場合、カード番号、有効期限、CVVが必須")
model CreditCardPayment {
  paymentMethod: PaymentMethod.creditCard;
  
  // クレカ情報（必須）
  @conditionalRequired("paymentMethod === 'credit_card'")
  cardNumber: CreditCardNumber;
  
  @conditionalRequired("paymentMethod === 'credit_card'")
  @dependsOn("cardNumber")
  expiryDate: ExpiryDate;
  
  @conditionalRequired("paymentMethod === 'credit_card'")
  @dependsOn("cardNumber")
  cvv: CVV;
  
  @conditionalRequired("paymentMethod === 'credit_card'")
  cardHolderName: Name;
}

// 代引き払いモデル
@businessRule("代引きの場合はカード情報は不要")
model CashOnDeliveryPayment {
  paymentMethod: PaymentMethod.cashOnDelivery;
  // カード情報は不要
}
```

### Union型による条件分岐

```typescript
// 支払いリクエスト（Union型で条件分岐）
union PaymentRequest {
  creditCard: {
    ...PaymentBase;
    ...CreditCardPayment;
  },
  cashOnDelivery: {
    ...PaymentBase;
    ...CashOnDeliveryPayment;
  }
}
```

## 生成されるOpenAPIスキーマ

Union型により、OpenAPIでは `anyOf` を使用した条件分岐が生成されます：

```yaml
PaymentRequest:
  anyOf:
    - type: object
      properties:
        paymentMethod:
          enum: ["credit_card"]
        cardNumber:
          $ref: '#/components/schemas/CreditCardNumber'
        # カード情報が必須
      required:
        - paymentMethod
        - cardNumber
        - expiryDate
        - cvv
        - cardHolderName
    - type: object
      properties:
        paymentMethod:
          enum: ["cash_on_delivery"]
        # カード情報は含まれない
      required:
        - paymentMethod
```

## コンパイルと実行

### 1. セットアップ

```bash
npm install
```

### 2. コンパイル

```bash
# 支払いAPI単体をコンパイル
npx tsp compile payment-api.tsp --config payment-tspconfig.yaml

# 全体をコンパイル
npx tsp compile .
```

### 3. 生成されたスキーマの確認

```bash
# 支払いAPI専用スキーマ
cat tsp-output/payment-schema/openapi.yaml

# 全体スキーマ（現在はmain.tspの内容）
cat tsp-output/schema/openapi.yaml
```

## カスタムデコレーターの利点

### 1. **ドキュメンテーション**
- ビジネスルールをコード内に明示的に記述
- 複雑な条件付きロジックを可読性高く表現
- チーム間でのルール共有が容易

### 2. **メタデータ保存**
- TypeSpecコンパイル時にメタデータとして保存
- OpenAPI出力では無視される（ノイズにならない）
- 将来的にカスタムツールで活用可能

### 3. **型安全性**
- TypeScript/TypeSpecの型システムを活用
- コンパイル時にデコレーター使用の妥当性チェック
- IDEでの補完やエラー表示

## 実際の活用シーン

### 1. **フォームバリデーション**
```typescript
@conditionalRequired("isCompany === true")
companyName?: string;

@conditionalRequired("age < 18")
parentConsent?: boolean;
```

### 2. **API設計ルール**
```typescript
@businessRule("管理者のみがユーザーロールを変更可能")
@conditionalRequired("currentUserRole === 'admin'")
newUserRole?: UserRole;
```

### 3. **複雑な依存関係**
```typescript
@dependsOn("phoneNumber")
@conditionalRequired("phoneNumber !== null")
phoneVerified?: boolean;
```

## 制限事項

1. **実行時バリデーション不可**: これらのデコレーターは実行時のバリデーションは行わない
2. **OpenAPI制約**: 標準のOpenAPIエミッターでは条件付きバリデーションを完全には表現できない
3. **カスタムエミッター必須**: 実際の活用には専用のエミッター開発が必要

## まとめ

TypeSpecのカスタムデコレーターにより：

- **Union型** で技術的な条件分岐を実現
- **カスタムデコレーター** でビジネスルールを明示
- **OpenAPI生成** で標準的なAPI仕様を出力
- **将来拡張性** でカスタムツール開発の基盤を構築

この組み合わせにより、型安全で保守性の高いAPI設計が可能になります。