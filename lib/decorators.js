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