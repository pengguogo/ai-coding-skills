---
name: project-archive
description: 端到端统一归档（独立技能）：在同一需求上下文中一次性覆盖前端与后端，结合需求、设计、任务拆分与 ocspec 知识库，在 archive 根目录产出 code-archive.md、appliaction-archive.md、business-archive.md；落盘后须更新 knowledge/application、knowledge/business，并增量更新 knowledge/code 项目名下 frontend-project.md、backend-project.md。通过 3 步分步执行。触发词：项目归档、统一归档、需求归档、archive、知识库更新。
base-dir-scope: requirement
---

# 项目统一归档（端到端 · 独立）

## 何时使用

- 需求实现完成，需要把本次前后端的实现内容统一汇总到 `archive/` 并更新知识库时
- 前置条件：需求文档、设计文档、任务拆分已齐备
- 不依赖 `frontend-project-archive` 或 `backend-project-archive`

## 核心能力

- 统一生成代码、应用、业务三类归档文档
- 将归档结论融合更新到 `knowledge/code`、`knowledge/application`、`knowledge/business`
- 建立需求、设计、任务拆分、实现和知识库之间的追溯关系
- 校验归档正文、知识库更新和三份归档之间的一致性

## 执行原则

- **产出为正文**：UTF-8 Markdown，包含具体章节与可填写表格，不以图片替代正文
- **可追溯**：所有结论能对应到需求/设计/task-split/知识库
- **知识库融合**：归档落盘后必须按 5 步融合流程更新知识库，严禁简单追加到文档末尾
- **不确定项**：统一标注 `[需人工确认]`

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/unified_archive_outputs_standard.md` | 统一归档输出模板 |
| `references/frontend_project_archive_standard.md` | code-archive 前端章节字段深度参考 |
| `references/backend_project_archive_standard.md` | code-archive 后端章节字段深度参考 |

## 路径与目录约定

- **权威来源**：`{COMMANDS_ROOT}/scheduler-protocol.md` §1（含 §1.6）；`base-dir-scope: requirement`
- **归档终稿**：`{ARCHIVE}/code-archive.md`、`appliaction-archive.md`、`business-archive.md`
- **知识库更新**：`{KNOWLEDGE}/code/`、`application/`、`business/`（融合写入，非简单追加）
- **中间产物**：`{WORKSPACE}/archive/`（及融合校验报告）
- Init 须先输出 `[路径解析]`；**禁止**工作区根 `archive/`、根 `knowledge/`

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4）：复用当前需求的 `{BASE_DIR}`
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

## 与其他技能的关系

- 上游：`fullstack-design` 产出设计文档；`task-split` 产出任务清单；`fullstack-code-implementation` 产出代码变更
- 下游：无（流水线终点）

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: archive-and-sync

halt-after: true

- Step 1: steps/step-01-code-archive.md
- Step 2: steps/step-02-app-biz-archive.md
- Step 3: steps/step-03-fusion-and-check.md

---

## 交付物

- `archive/code-archive.md`（代码、接口、数据与前后端实现追溯）
- `archive/appliaction-archive.md`（应用层调用链与协同）
- `archive/business-archive.md`（业务目标、流程、规则与职责边界）
- 知识库融合更新完成 + 一致性校验报告
