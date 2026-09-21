# Checkpoint: Step 4 实施修复

> **审查级别**：L1（结构 + 内容）。重新打开产出文件逐项核对，不凭记忆。

## 审查时需打开的文件
- 产出：`{WORKSPACE}/bugfix/04-implement-diff.md`
- 单测结果（纯逻辑 bug）：`{WORKSPACE}/bugfix/unit-test-result.md`
- 上游：`{BASE_DIR}/bug/<id>-<slug>-fix-plan.md`

## 结构检查
- [ ] 含：实际改动清单 / 逐仓 git diff 比对 /（纯逻辑 bug）单测复现段

## 内容检查
- [ ] 所有改动处标注 `@AI-Generate`
- [ ] 纯逻辑 bug 且有测试框架：已新增/修改单测，`unit-test-result.md` 显示改前失败→改后转绿；缺失即 FAIL
- [ ] 纯逻辑 bug 但无测试框架：已记 `[无测试基建]`（不 FAIL）
- [ ] 逐仓 git diff 已执行：repo_paths 每个仓库都有 diff 结果
- [ ] 复合键 (仓库, 路径) 实际改动 ⊆ 允许清单；超出已记 WARN + 待确认
- [ ] 单测由 inline 步骤执行（非经 build-verifier）
- [ ] 改动说明推理正文无绝对路径、无写死仓库名（diff 真实路径豁免）

## 待确认项提取
- 改动超出允许清单的超出项 / 状态报告 concerns
