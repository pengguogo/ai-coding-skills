# Step 6: 回归防护（L3）

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-06-checkpoint.md
- checkpoint-level: L1.5

## 参数

- code_files: `[Step 4 实际改动的业务代码文件清单]`
- design_section: `{BASE_DIR}/bug/<id>-<slug>-fix-plan.md#修复方案`
- checklist: `references/regression-checklist.md`
- review_strategy: full
- output_file: `{WORKSPACE}/bugfix/review/06-code-review.md`
- task_group_id: `<id>`（BUG-<yyyymmdd>-<NN>）
- whitelist_rules: null
- instructions: 见下

## 执行指令

本步属 Phase regression-guard（precondition: 级别 = L3）。非 L3 时整个 Phase 由 Scheduler 跳过，本步不执行。

L3 时注入 `code-reviewer` 角色定义执行，强调：

1. 不传 `whitelist_rules` → 自动退化为只读审查（不改业务代码）。
2. `review_strategy: full`，对本次改动做完整回归审查。
3. `design_section` 指向 `<id>-<slug>-fix-plan.md#修复方案`（本次改动的契约基线）。`checklist` 用 `regression-checklist.md`（按 bug_type 选后端/前端子集）。
4. 设计一致性核对仅核对「实际改动是否符合修复方案意图」，不得因修复方案未列接口/模型/时序细节而判设计偏差。
5. 反向引用检查：列出根因调用链上下游是否有同源缺陷未一并修复。

> 路径说明：`output_file` 落 `{WORKSPACE}/bugfix/review/` 是 bug-fix 的命名空间（与其他技能的 `{WORKSPACE}/review/` 隔离，便于交付后只清理 `{WORKSPACE}/bugfix/`），属本技能注入的合规路径，不触发 §1.6 WARN。

## STATUS_REPORT

由 code-reviewer 产出（`review-verdict`：PASS | PASS_WITH_NOTES | FAIL）。FAIL → 记入待确认项。
