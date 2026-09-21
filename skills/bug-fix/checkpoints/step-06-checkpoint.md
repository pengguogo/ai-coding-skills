# Checkpoint: Step 6 回归防护（L3）

> **审查级别**：L1.5（按本 checkpoint 与 code-reviewer 约定核对）。

## 适用条件
- 仅 L3 执行。非 L3 时 Phase regression-guard 因 precondition 不满足整体跳过，本 checkpoint 不执行。

## 审查时需打开的文件
- 产出：`{WORKSPACE}/bugfix/review/06-code-review.md`
- 上游：`{BASE_DIR}/bug/<id>-<slug>-fix-plan.md#修复方案`、`04-implement-diff.md`

## 内容检查
- [ ] code-reviewer 判定非 FAIL（PASS / PASS_WITH_NOTES）；FAIL 记入待确认项
- [ ] review_strategy 为 `full`
- [ ] 未传 whitelist_rules（只读审查，未改业务代码）
- [ ] design_section 指向真实存在的 `<id>-<slug>-fix-plan.md#修复方案`
- [ ] checklist 来自 `regression-checklist.md`（按 bug_type 选子集）
- [ ] 反向引用检查已列出根因调用链上下游同源缺陷核对，无遗漏

## 待确认项提取
- blocking / important 发现 / `[需人工确认]` 标记项
