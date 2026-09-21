# bug-fix 回归审查检查项（L3）

供 Step 6 作为 `code-reviewer` 的 `checklist` 输入。检查项引用体系既有 P0 清单并裁剪。

## 检查项来源

| bug_type | 引用清单 | 项数 |
|---|---|---|
| 后端逻辑 / 数据库 / 并发 | `../../fullstack-code-review/references/p0/p0-backend-checklist.md` | 通用 5 + 后端 13 |
| 前端逻辑 / 前端纯样式 | `../../fullstack-code-review/references/p0/p0-frontend-checklist.md` | 通用 5 + 前端 9 |
| 前后端联动 | 两份均用，去重通用 5 项 | 合并 |

## 裁剪规则

bug-fix 以修复方案（fix-plan.md）为本次改动契约，非完整设计文档，故**排除**设计一致性项 `CC-DESIGN-01/02/04`。其余 P0 项（安全 / 架构 / 事务 / 并发 / 幂等等）全部保留——这些是 bug 修复最易引入回归的维度。

## 使用方式

- `review_strategy: full`，按 bug_type 选用后端/前端子集
- 发现编号 `RBUG-<yyyymmdd>-<NN>-N`，低确信度标 `[需人工确认]`

## 反向引用检查（bug-fix 补充）

除清单项外，code-reviewer 须列出根因调用链上下游关联点，核对是否有同源缺陷未一并修复（如同一工具方法被多处调用，仅改一处）。
