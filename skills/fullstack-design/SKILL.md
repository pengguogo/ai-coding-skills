---
name: fullstack-design
description: 前后端技术方案设计：在同一执行会话内按顺序完成架构设计（design/architecture-design.md）、后端设计（design/backend-design.md）与前端设计（design/frontend-design.md 入口索引 + 各目标端分端设计文件）。通过 7 步分步执行降低单次上下文压力，确保在不同编辑器和模型下产出一致。用户要编写架构/后端/前端设计、技术方案、应用间关系与改造矩阵、接口与时序/领域模型、前端架构与组件设计、PRD 驱动的前端方案等时使用。不产出可运行代码。触发词：fullstack design、前后端设计、技术方案设计、架构设计、后端设计、前端设计。
base-dir-scope: requirement
---

# 前后端技术方案设计

## 何时使用

- 用户需要一次完成本需求的架构 + 后端 + 前端技术方案设计
- 用户请求架构设计、应用间关系与依赖、应用×功能点改造矩阵、应用内模块设计
- 用户请求后端设计文档、技术方案、接口设计、时序图、领域模型、流程图
- 用户请求前端架构、模块划分、状态管理、组件接口、前端技术方案、PRD 驱动的前端设计（含 PC Web、iOS、Android、HMOS、H5 多目标端）
- 产出边界：结构化 Markdown + Mermaid 图表，不产出可运行代码

## 核心能力

- 基于需求成稿生成架构、后端与前端技术方案
- 完成架构设计（应用清单、应用间依赖、改造矩阵、应用内模块、概览级 ER 与时序）
- 完成后端数据建模、接口、时序和流程设计
- 完成前端架构、功能点、组件、路由和状态管理设计（含 PC Web、iOS 原生、Android 原生、鸿蒙 HMOS、H5 五类目标端）
- 前端设计采用「入口索引 + 分端设计文件」结构：`frontend-design.md` 为固定入口索引，各目标端设计写入独立分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）
- 校验需求追溯和前后端接口一致性

## 执行原则

- **需求成稿对照（强制）**：设计须严格以 `requirement/requirement.md` 为范围与验收基准。禁止在需求中无依据地扩展功能；若需新增/变更范围，须标注 `[超出当前需求成稿]` 并说明待产品确认。
- **可追溯**：设计须可追溯到需求（REQ 编号或章节对应）；材料不足处标注 `[需与产品确认]`。
- **存量项目**：与现状对齐，突出增量与变更。
- **新项目**：可完整描述目标架构与选型理由。
- **前端需求驱动**：前端设计的功能点来源于需求文档的用户交互，不是后端接口列表。涉及后端接口时才查阅 `backend-design.md` 对齐。
- **接口一致性**：前端阶段中凡涉及后端接口的表述，须与 `backend-design.md` 一致，禁止臆造冲突的接口定义。
- **严禁臆造接口（强制）**：后端设计中所有对外接口和依赖接口必须有明确的需求或设计来源。不得凭推测列出项目中不存在的接口 URL 或接口定义。若业务逻辑需要某接口但无法从输入材料中确认其存在，必须标注 `[需人工确认：该接口在现有系统中是否存在]` 并说明假设依据。
- **边界完整性强制**：功能设计须对照输入摘要 §3 边界与交互线索逐条落实——每条线索给出处理落点，确无相关场景的给出判定理由（不得仅写"无"）；边界设计深度须达 design-backend-standard 对应章节要求（错误码、阈值、策略具体可执行）。

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/design-architecture-standard.md` | 架构设计正文标准（应用间关系/改造矩阵/应用内模块/概览级 ER 与时序） |
| `references/design-backend-standard.md` | 后端正文标准（§1~§6 章节结构、路径约定、编写规范） |
| `references/sequence-diagrams.md` | 时序图规范 |
| `references/flowcharts.md` | 流程图规范 |
| `references/erd-diagrams.md` | ER 图规范 |
| `references/design_frontend_standard.md` | PC Web 分端设计标准（产出 `frontend-web.md`） |
| `references/design_ios_standard.md` | iOS 分端设计标准（产出 `frontend-ios.md`） |
| `references/design_android_standard.md` | Android 分端设计标准（产出 `frontend-android.md`） |
| `references/design_hmos_standard.md` | 鸿蒙 HMOS 分端设计标准（产出 `frontend-hmos.md`） |
| `references/design_h5_standard.md` | H5 分端设计标准（产出 `frontend-h5.md`） |
| `references/design_template.md` | 前端排版模板（架构文档复用 design-architecture-standard，不另设 template） |

## 路径与目录约定

- **权威来源**：`{COMMANDS_ROOT}/scheduler-protocol.md` §1（含 §1.6）；`base-dir-scope: requirement`
- **需求目录**：`{OCSPEC_ROOT}/requirements/<需求>_<yyyymmdd>/` = `{BASE_DIR}`（与 `requirement-analysis` 同一目录，不新建）
- **终稿**：`{DESIGN}/architecture-design.md`、`{DESIGN}/backend-design.md`；前端入口 `{DESIGN}/frontend-design.md`（索引）+ 分端设计文件 `{DESIGN}/frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`（仅生成本次涉及的目标端）
- **中间产物**：仅 `{WORKSPACE}/design/`；输入需求 `{REQ}/requirement.md`
- Init 须先输出 `[路径解析]`；**禁止**工作区根 `_workspace/`、`requirements/`

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4）：在同一 `{BASE_DIR}` 下工作
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

**读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 后，按下方步骤声明开始执行。**

## 与其他技能的关系

- 上游：`requirement-analysis` 或 `product-requirement-analysis` 提供 `{REQ}/requirement.md` 需求基线（**同路径、同结构，下游无差别**）
- 下游：`task-split` 依赖架构、后端、前端设计文档；`fullstack-code-implementation` 基于 task-split 编码

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: architecture

halt-after: true

- Step 1: steps/step-01-input-analysis.md
- Step 2: steps/step-02-architecture.md

### Phase: backend

halt-after: true
precondition: `design/architecture-design.md` 必须已存在

- Step 3: steps/step-03-backend-foundation.md
- Step 4: steps/step-04-function-design.md
- Step 5: steps/step-05-backend-assembly.md

### Phase: frontend

halt-after: true
precondition: `design/backend-design.md` 必须已存在 且 `design/architecture-design.md` 必须已存在

- Step 6: steps/step-06-frontend-design.md
- Step 7: steps/step-07-frontend-assembly.md

> precondition 为 SKILL 级约定式入口校验（scheduler-protocol 状态机未正式定义该关键字），各 phase 入口由 Scheduler 人读校验对应终稿是否已产出。
> 三个 phase 各 halt-after：架构（用户确认应用划分与改造矩阵）→ 后端（确认）→ 前端（确认）。各 halt 用户向确认引导：
> - 架构 halt：请确认应用划分与各应用改造范围（矩阵）是否正确，后续后端/前端将以此为锚。
> - 后端 halt：请确认后端技术方案、模型与功能设计是否符合预期。
> - 前端 halt：请确认前端方案（各目标端）与前后端接口对齐是否符合预期。

---

## 交付物

- `design/architecture-design.md`（phase architecture 交付）
- `design/backend-design.md`（phase backend 交付）
- `design/frontend-design.md`（phase frontend 交付，固定入口索引文件）
- `design/frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`（phase frontend 交付，按本次涉及的目标端生成对应分端设计文件）

> **模块设计迁移说明**：应用内模块清单已从后端文档迁移至架构文档 `architecture-design.md §5`，作为模块清单唯一权威源；后端文档 §2 仅保留技术选型并导航引用架构 §5，task-split / code-review / project-archive 等下游对"模块划分"的对照统一以架构 §5 为准。

## Summary 机制

步骤 2 架构文档、步骤 3 backend-foundation、步骤 4 function-design 的产出有下游依赖，需生成精简摘要供 subagent 模式使用：
- 步骤 2 架构文档 → `summaries/02-architecture.summary.md`（含应用清单 + 改造矩阵精简版 + **应用内模块清单**，供 function-design 参与者命名/backend 模块校验读取）
- 步骤 3 backend-foundation → `summaries/03-foundation.summary.md`（技术栈/实体/表清单等，已移除模块清单）
- 步骤 4 function-design → `summaries/04-function.summary.md`

使用规则：
- subagent 模式（Kiro / Claude Code / Cursor）：下游步骤读 `input_files_subagent` 中的 Summary 路径
- 同 session 模式（其他编辑器）：下游步骤读 `input_files` 中的完整产出路径

## 动态分批规则

步骤 4 和步骤 6 为 template 类型，Scheduler 按 `scheduler-protocol.md §4.4` 的 10 步流程自动执行动态实例化。

步骤 6 特殊处理：该步骤内部分 Phase A（分析）和 Phase B（设计）两阶段。Phase A 先产出分析摘要和功能点清单（含目标端识别），Phase B 基于功能点清单按目标端分组做 template 分批设计，每个实例只服务单一目标端。Scheduler 在 Phase A 完成后读取 `analysis_output_file` 中的功能点清单作为 `instance-source` 执行分批逻辑。
