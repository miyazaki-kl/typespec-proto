import "./decorators.js";

// カスタムデコレーター定義
extern dec conditionalRequired(target: unknown, condition: valueof string);
extern dec businessRule(target: unknown, description: valueof string);
extern dec dependsOn(target: unknown, dependency: valueof string);