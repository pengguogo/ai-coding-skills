---
name: knowledge-recheck
description: 交付追溯审计（知识库复检）。以完整需求文档或指定代码范围为输入，对照 ocspec 知识库 knowledge/ 下 code、application、business 三层沉淀（及需求目录 design/task/archive 等），逐项完整覆盖检测（禁止抽样）知识同步完整性、未归档需求及分层缺口，输出结构化质检报告与归档/更新建议。通过 3 步分步执行。触发词：交付追溯审计、知识库复检、需求复检、知识库质检、knowledge recheck、archive readiness、知识库完整性检查。
base-dir-scope: requirement
---

# 交付追溯审计

## 何时使用

- 需求已实现或部分实现后，需核对**需求—设计—任务—代码—归档—知识库（code / application / business 三层）**是否闭环
- 输入为知识库/需求目录下的**完整需求文档**（如 `{REQ}/requirement.md` 或用户 @ 指定路径）
- 或输入为**指定代码范围**（仓库路径、模块、文件/目录列表），反查对应需求与知识库是否已更新
- 产出边界：Markdown 质检报告 + 行动建议，**不修改**需求、设计、代码或知识库正文

## 核心能力

- 识别复检范围（需求文档模式 / 代码范围模式）并建立**全部**需求项—功能点追溯索引（100% 覆盖）
- 对照 `{KNOWLEDGE}/` 下 **三层知识** 逐项检查（缺一不可）：
  - **code**（`{CODE_KNOWLEDGE}/`）：工程、接口、库表、前端工程等代码级沉淀
  - **application**（`{KNOWLEDGE}/application/`）：系统拓扑、应用域、组件与调用链
  - **business**（`{KNOWLEDGE}/business/`）：业务全景、流程用例、领域模型、能力附录
- 对照需求目录内 design、task、archive、review 等产出，判定流水线阶段完成度
- 输出未归档提示、**按层级标注**的知识库未更新功能清单及建议后续技能（如 `project-archive` 融合三层，或对应 `*-knowledge-init`）

## 执行原则

- **三层知识对照（强制）**：复检须**分别**打开并对照 `{CODE_KNOWLEDGE}/`、`{KNOWLEDGE}/application/`、`{KNOWLEDGE}/business/`；禁止仅检 code 层即给出整体结论；某层目录不存在或为空须在报告中 explicit 标注 `missing` 及建议动作（非 silent skip）
- **完整覆盖（强制）**：禁止抽样、抽检、随机抽查或以「代表性条目」省略；Step 1 需求项索引、代码范围索引须 **100% 穷尽**；Step 2 须对**每一条**需求项、**每一项**检查清单（CK/AK/BK/PR）、**每一个**代码范围条目逐行产出结论；追溯矩阵行数须与需求项数量一致（code-scope 模式还须与代码范围索引一致）；矩阵中 **code / app / biz** 三列均须逐行填写
- **只读质检**：不写入 `{KNOWLEDGE}/`、`{CUSTOM_KNOWLEDGE}/` 及业务仓库代码；仅写入 `{WORKSPACE}/knowledge-recheck/` 与 `{BASE_DIR}/knowledge-recheck/` 下报告
- **证据驱动**：每条发现须引用具体文件路径或章节；无法确认时标注 `[需人工确认]`
- **不臆造**：不假设已归档或未实现；以实际文件存在性与内容比对为准
- **优先级**：代码/接口/表结构等实现事实以 `{CODE_KNOWLEDGE}` 及源码为准；应用拓扑/组件以 `application/` 为准；业务流程/领域规则以 `business/` 为准；制度/术语补充以 `{CUSTOM_KNOWLEDGE}` 为准（若 `present`）；三层冲突时在报告中分列层级说明，不得混为一谈

## 知识库三层对照范围

| 层级 | 路径 | 典型文档 | 复检关注点 |
|------|------|---------|-----------|
| 代码 | `{CODE_KNOWLEDGE}/` | backend-project；接口/库表为目录（`backend-interface/`、`backend-database/`）或存量单文件（`backend-interface.md`、`backend-database.md`）；frontend-project 等 | 接口、模块、表结构、工程结构是否与需求/代码一致 |
| 应用 | `{KNOWLEDGE}/application/` | application-system-architecture、applications-and-domains、application-components 等 | 应用/系统边界、调用链、组件是否与实现一致 |
| 业务 | `{KNOWLEDGE}/business/` | business-overview、process-and-use-cases、domain-and-orchestration、capability-and-appendices 等 | 业务流程、领域模型、规则是否与需求一致 |

Init 须解析 `{KNOWLEDGE}`、`{CODE_KNOWLEDGE}`；Step 2 **必须**分别读取 application/、business/ 下 Markdown 终稿（若目录存在）。接口/库表路径判定见 `../code-knowledge-init/references/backend-knowledge-layout-compat.md`（兼容目录与存量单文件）。

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/knowledge-quality-report-standard.md` | 质检报告结构与判定口径 |
| `references/knowledge-coverage-checklist.md` | knowledge/ 各层完整性检查项 |
| `references/pipeline-readiness-checklist.md` | 需求目录内流水线产出与归档就绪检查项 |

## 路径与目录约定

- **权威来源**：`{COMMANDS_ROOT}/scheduler-protocol.md` §1（含 §1.6）；`base-dir-scope: requirement`
- **工作目录**：Init 解析 `{BASE_DIR}`；须解析 `{OCSPEC_ROOT}`、`{KNOWLEDGE}`、`{CODE_KNOWLEDGE}`，并扫描 `{KNOWLEDGE}/application/`、`{KNOWLEDGE}/business/` 是否存在及文档清单
- **中间产物**：仅 `{WORKSPACE}/knowledge-recheck/`
- **终稿**：`{BASE_DIR}/knowledge-recheck/knowledge-quality-report.md`（若 Init 无法确定 `{BASE_DIR}`，终稿写入 `{WORKSPACE}/knowledge-recheck/knowledge-quality-report.md` 并在报告中说明）
- **自定义知识（可选）**：`{CUSTOM_KNOWLEDGE}`；`absent` 时跳过，不 Halt
- Init 须先输出 `[路径解析]`；**禁止**工作区根 `_workspace/`、根 `knowledge/`

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4）：解析 `{OCSPEC_ROOT}`、`{BASE_DIR}`、`{KNOWLEDGE}`、`{CODE_KNOWLEDGE}`、`CUSTOM_KNOWLEDGE_STATUS`
3. 确认用户输入模式（需求文档 / 代码范围）；若两者均未提供，优先使用 `{REQ}/requirement.md`；仍无法确定 → **Halt** 询问
4. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

## 与其他技能的关系

- **上游**：（可选）`requirement-analysis` 产出需求文档；`fullstack-code-implementation` 产出代码变更；任意阶段均可单独触发本技能
- **下游建议**：报告提示未归档 → `project-archive`；**按缺口层级**提示：`code` → `code-knowledge-init` 或 archive 融合 code；`application` → `application-knowledge-init` 或 archive 融合 application；`business` → `business-knowledge-init` 或 archive 融合 business

> 本技能为**横切质检**，不改变主流水线顺序；可重复执行用于迭代验收。

---

## Phases

### Phase: knowledge-recheck

halt-after: true

- Step 1: steps/step-01-intake-and-scope.md
- Step 2: steps/step-02-knowledge-gap-analysis.md
- Step 3: steps/step-03-assemble-report.md

---

## 交付物

- `{BASE_DIR}/knowledge-recheck/knowledge-quality-report.md`（交付追溯审计报告，含未归档与知识库更新建议）
- `{WORKSPACE}/knowledge-recheck/` 下步骤中间产出（用户确认交付后可随 `{WORKSPACE}` 清理）

## Summary 机制

Step 1、Step 2 产出均有下游依赖，须按各 step 文件中的 Summary 配置生成摘要供 Step 3 使用。
