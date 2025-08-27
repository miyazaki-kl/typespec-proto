import "@typespec/http";
import "./lib";

using Http;

@service(#{ title: "Payment Processing Service" })
namespace PaymentService;

// 基本的なスカラー型
@pattern("^[0-9]{16}$", "Must be 16 digits")
scalar CreditCardNumber extends string;

@pattern("^(0[1-9]|1[0-2])/[0-9]{2}$", "Must be MM/YY format")
scalar ExpiryDate extends string;

@pattern("^[0-9]{3,4}$", "Must be 3 or 4 digits")
scalar CVV extends string;

@minLength(1)
@maxLength(100)
scalar Address extends string;

@minLength(1)
@maxLength(50)
scalar Name extends string;

@minValue(1)
scalar Amount extends int32;

// 支払い方法の列挙型
enum PaymentMethod {
  creditCard: "credit_card",
  cashOnDelivery: "cash_on_delivery"
}

// 支払い状態
enum PaymentStatus {
  pending: "pending",
  processing: "processing", 
  completed: "completed",
  failed: "failed",
  cancelled: "cancelled"
}

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

// 共通の支払い情報
model PaymentBase {
  orderId: string;
  amount: Amount;
  currency: string = "JPY";
  
  // 配送先情報
  customerName: Name;
  shippingAddress: Address;
  phoneNumber?: string;
  email?: string;
}

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

// 支払いレスポンス
model PaymentResponse {
  paymentId: string;
  orderId: string;
  status: PaymentStatus;
  amount: Amount;
  paymentMethod: PaymentMethod;
  transactionId?: string;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
}

// エラーモデル
@error
model PaymentError {
  code: int32;
  message: string;
  field?: string;
  details?: string;
}

// 支払い確認レスポンス
model PaymentConfirmation {
  paymentId: string;
  status: PaymentStatus;
  message: string;
  estimatedDeliveryDate?: plainDate;
}

// REST APIインターフェース
@route("/payments")
@tag("Payments")
interface Payments {
  /** 支払い処理を開始 */
  @post
  processPayment(@body request: PaymentRequest): PaymentResponse | PaymentError;

  /** 支払い状態を確認 */
  @get
  getPayment(@path paymentId: string): PaymentResponse | PaymentError;

  /** 支払いをキャンセル */
  @route("{paymentId}/cancel")
  @post
  cancelPayment(@path paymentId: string): PaymentConfirmation | PaymentError;

  /** 支払い完了確認 */
  @route("{paymentId}/confirm")
  @post
  confirmPayment(@path paymentId: string): PaymentConfirmation | PaymentError;
}