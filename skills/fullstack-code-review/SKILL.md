---
name: fullstack-code-review
description: 前后端/移动端代码终审。基于设计文档和检查项清单，对全量代码变更做全局设计合规、模块级审查和影响分析，产出终审结论和 commit 建议。读取小节评审结果跳过已覆盖的 P0 级检查项。触发词：代码评审、终审、code review、全局审查、提交前审查。
base-dir-scope: requirement
---

# 前后端/移动端代码终审

## 何时使用

### 终审触发条件
- 全部编码任务完成，所有 task-split 主分类/功能点的代码已提交
- 用户请求"终审"、"全局审查"、"提交前审查"

## 核心能力

- 基于设计文档和检查项执行全局设计合规审查
- 按后端模块、前端功能点、Android 模块、iOS 模块分批完成代码终审
- 分析数据、接口、流程和用户体验的跨模块影响
- 追加评审日志，并在通过时生成 commit 建议

## 执行原则

- **设计驱动**：所有审查以 `backend-design.md` 和前端入口索引 `frontend-design.md`（经其定位各分端设计文件 `frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）为基线，不臆造审查标准
- **分层加载**：按步骤按需加载检查项，不一次性加载全量规范
- **增量追加**：审查结果追加到 `{WORKSPACE}/review/review-log.md`，不覆盖已有内容
- **代码修改边界**：终审不修改代码，仅输出发现和建议
- **不确定标注**：低确信度发现标注 `[需人工确认]`，跨模块问题标注 `[需全局确认]`

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/p0/p0-backend-checklist.md` | 后端 P0 检查项 |
| `references/p0/p0-frontend-checklist.md` | 前端 P0 检查项 |
| `references/p0/p0-android-checklist.md` | Android P0 检查项 |
| `references/common/cross-cutting-review.md` | 横切关注点检查项 |
| `references/backend/backend-review-checklist.md` | 后端审查检查项 |
| `references/backend/business-quality-checklist.md` | 后端业务质量检查项 |
| `references/frontend/frontend-review-checklist.md` | 前端审查检查项 |
| `references/frontend/frontend-quality-checklist.md` | 前端业务质量检查项 |
| `references/android/android-review-checklist.md` | Android 审查检查项 |
| `references/android/android-quality-checklist.md` | Android 业务质量检查项 |
| `references/p0/p0-ios-checklist.md` | iOS P0 检查项 |
| `references/ios/ios-review-checklist.md` | iOS 审查检查项 |
| `references/ios/ios-quality-checklist.md` | iOS 业务质量检查项 |
| `references/common/impact-analysis-checklist.md` | 影响分析检查项（含 IA-MOBILE 移动端维度） |
| `references/common/review-log-template.md` | review-log 模板 |
| `references/common/commit-suggestion-template.md` | commit 建议模板 |

## 路径与目录约定

- **权威来源**：`{COMMANDS_ROOT}/scheduler-protocol.md` §1（含 §1.6）；`base-dir-scope: requirement`
- **工作目录**：与编码阶段同一 `{BASE_DIR}`
- **中间产物**：仅 `{BASE_DIR}/_workspace/review/`（评审日志、commit 建议、步骤摘要）
- **输入只读**：`{DESIGN}/`、`{TASK}/`、`{REQ}/`；代码变更在 `repos.txt` 仓库内审查
- **不修改代码**：仅写 review 目录下 Markdown；Init 须先输出 `[路径解析]`

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4）：复用当前需求的 `{BASE_DIR}`
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

**读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 后，按下方步骤声明开始执行。**

## 与其他技能的关系

- **上游**：`task-split` 提供任务清单（`task/task-split.md`）
- **下游**：`project-archive` 依赖终审通过结论
- **小节评审**：在 `fullstack-code-implementation` 各批次完成后执行（Step 2），由 `code-reviewer` 按 P0 审查；门禁见 `references/batch-gate-protocol.md`（停轮语义见 `scheduler-protocol.md` §12）

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: review

halt-after: true

- Step 1: steps/step-01-review-context.md
- Step 2: steps/step-02-global-compliance.md
- Step 3: steps/step-03-backend-review.md
- Step 3b: steps/step-03b-android-review.md  # 与 Step 3/4 无数据依赖，可并行；仅当存在 Android 模块时执行，否则跳过
- Step 3c: steps/step-03c-ios-review.md  # 与 Step 3/3b/4 无数据依赖，可并行；仅当存在 iOS 模块时执行，否则跳过
- Step 4: steps/step-04-frontend-review.md  # Step 3 与 Step 4 无数据依赖，Scheduler 可并行执行
- Step 5: steps/step-05-impact-analysis.md
- Step 6: steps/step-06-summary-delivery.md

### Phase: incremental-recheck

halt-after: true
entry-condition: review-log.md 最终判定 = ❌ 不通过，且用户触发"增量复核"/"recheck"
repeatable: true
max-repeats: 3  # 超过 3 轮仍不通过，强制要求人工介入

- Step 7: steps/step-07-incremental-recheck.md
- → 复核通过后重新执行 Step 6（汇总判定与终审交付）

---

## 交付物

- `{WORKSPACE}/review/review-log.md`（终审章节 + 增量复核章节追加到已有的评审日志中）
- `{WORKSPACE}/review/commit-suggestion.md`（仅终审通过时生成）

## Summary 机制

Step 1~5（含 Step 3b、Step 3c）的产出均有下游依赖，需生成结构化摘要供 Step 6 使用。

各步骤 Summary 配置见各 step 文件中的"Summary 配置"章节。

使用规则：
- subagent 模式：下游步骤读 Summary 路径
- 同 session 模式：下游步骤读完整产出路径

## 动态分批规则

Step 3、Step 3b、Step 3c 和 Step 4 为 template dynamic 类型，Scheduler 按 `scheduler-protocol.md §3.4` 的 10 步流程自动执行动态实例化。Step 3 按后端模块分批，Step 3b 按 Android 模块分批，Step 3c 按 iOS 模块分批，Step 4 按前端功能点分批。各实例的 Summary 由 Scheduler 按 merge-rule 合并。

> **Step 3b / Step 3c 条件执行**：仅当 `01-review-context.md` 对应的「Android 模块清单」/「iOS 模块清单」非空时实例化；本需求无对应端时，Scheduler 跳过该 Step，不产生产出与 Summary。

## 增量复核机制

Phase 2（incremental-recheck）在终审不通过时由用户手动触发，支持循环执行（最多 3 轮）：
1. Step 7 复核旧发现 + 修复文件 P0 快扫
2. 复核通过 → 重新执行 Step 6 生成最终交付物
3. 复核不通过 → 等待下一轮修复后再次触发
4. 超过 3 轮仍不通过 → 强制要求人工介入，不再自动复核
