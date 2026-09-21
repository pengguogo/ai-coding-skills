---
name: task-split
description: 在已通过 fullstack-design 产出 architecture-design.md、backend-design.md 与 frontend-design.md 之后，基于设计文档将本次需求拆分为可落地的开发任务清单（先后端、后前端），输出任务依赖关系。通过 2 步分步执行降低单次上下文压力，确保在不同编辑器和模型下产出一致。触发词：任务拆分、开发任务清单、前后端任务边界、任务依赖、task split。
base-dir-scope: requirement
---

# 任务拆分

## 何时使用

- 用户要求任务拆分 / 开发任务清单 / 前后端任务边界 / 任务依赖与执行顺序
- 前置条件：同一需求目录下已存在 `architecture-design.md`、`backend-design.md` 与前端入口索引 `frontend-design.md`（均由 `fullstack-design` 产出）；前端分端设计文件（`frontend-web.md` 等）经入口索引各端访问章节定位
- 若仅有需求文档而无设计文档，应先执行 `fullstack-design` 完成架构、后端、前端设计，再执行本技能

## 核心能力

- 解析后端与前端设计，生成可落地开发任务清单
- 按模块、技术层次、功能点和组件边界拆分任务
- 以 `frontend-design.md` 入口索引为唯一入口，经各端访问章节定位到分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）
- 对每个已生成分端设计文件的目标端拆分任务清单，并**标注该批次所属目标端**（PC Web / iOS / Android / HMOS / H5）；未生成分端设计文件的目标端跳过拆分
- 功能点标题用 `## 功能点 N:`，供编码侧解析为对应批次（`FE-{N}` / `iOS-{N}` / `Android-{N}` / `HMOS-{N}` / `H5-{N}`）
- 推导后端优先、前端跟进的任务依赖和执行顺序
- 对齐 REQ 编号并识别设计不一致或开放问题

## 执行原则

- 任务条目、流程分支、页面/组件边界均以设计文档为准；模块划分以 architecture-design.md §5 为权威源
- 需求文档用于 REQ 编号对齐、验收范围核对；若设计与需求不一致，在「开放问题」中列出
- 文档内章节顺序：先后端任务清单、后前端任务清单（与 pipeline 及设计产出顺序一致）
- 不确定项必须进入"开放问题"，不默认为已确认

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/task_split_standard.md` | 任务拆分标准：章节结构、清单规范、任务依赖与顺序 |
| `references/task_split_template.md` | task-split.md 排版模板 |

## 路径与目录约定

- **权威来源**：`{COMMANDS_ROOT}/scheduler-protocol.md` §1（含 §1.6）；`base-dir-scope: requirement`
- **终稿**：`{TASK}/task-split.md`
- **中间产物**：仅 `{WORKSPACE}/task/`；输入 `{DESIGN}/architecture-design.md`、`{DESIGN}/backend-design.md`、前端入口 `frontend-design.md` 及其索引的分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`），可选 `{REQ}/requirement.md`
- Init 须先输出 `[路径解析]`；**禁止**工作区根 `task/`、根 `_workspace/`

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4）：复用当前需求的 `{BASE_DIR}`
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

**读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 后，按下方步骤声明开始执行。**

## 与其他技能的关系

- 上游：`requirement-analysis` 提供需求基线；`fullstack-design` 产出 `architecture-design.md`、`backend-design.md`、前端入口索引 `frontend-design.md` 及各分端设计文件作为拆分主依据
- 下游：`fullstack-code-implementation` 按 `task-split.md` 与设计文档实施编码

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: task-split

halt-after: true

- Step 1: steps/step-01-backend-tasks.md
- Step 2: steps/step-02-frontend-and-assembly.md

---

## 交付物

- `task/task-split.md`（后端任务清单 + 前端(PC Web)任务清单 + iOS/Android/HMOS/H5 任务清单（各端仅当对应分端设计文件存在时）+ 依赖关系 + 开放问题）
