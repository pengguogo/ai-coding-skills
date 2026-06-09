---
name: task-split
description: 在已通过 fullstack-design 产出 backend-design.md 与 frontend-design.md 之后，基于两份设计文档将本次需求拆分为可落地的开发任务清单（先后端、后前端），输出任务依赖关系与时序建议；需求文档用于 REQ 编号追溯与范围核对。产出 \`task/task-split.md\`（\`ocspec-<xxx>/requirements/<需求英文名>_<yyyymmdd>/task/task-split.md\`），供后续前后端代码实现使用。
---

# 任务拆分（task-split）

## 何时使用

- 用户要求**任务拆分 / 开发任务清单 / 前后端任务边界 / 任务依赖与执行顺序**时。
- **前置条件**：同一需求目录下已存在 **\`backend-design.md\` 与 \`frontend-design.md\`**（由 **\`fullstack-design\`** 先后端、后前端产出）。若仅有需求文档而无设计文档，应先执行 **\`fullstack-design\`** 完成两份设计，再执行本技能。
- 用户希望把设计落地为**可执行、可跟踪**的开发任务，并明确**任务级**前后端依赖与执行顺序时。

## 输入与依据（重要）

| 类型 | 说明 |
| --- | --- |
| **主依据（必需）** | **\`backend-design.md\`**：领域模型、接口、流程、数据与安全等后端设计结论。<br>**\`frontend-design.md\`**：页面/组件、交互、状态与调用关系等前端设计结论。拆分颗粒度与任务边界以两份设计为准。 |
| **追溯与范围（推荐）** | **需求文档**（如 \`requirement.md\`）：用于 REQ 编号对齐、验收范围核对、开放问题与产品确认项引用。 |
| **可选** | 知识库/项目规范（如 \`backend-project.md\`、\`frontend-project.md\`）：命名、分层、工程约束。 |

## 输出

- **主文件**：\`ocspec-<xxx>/requirements/<需求英文名>_<yyyymmdd>/task/task-split.md\`
- **内容结构**：遵循 \`references/task_split_standard.md\`，并使用 \`references/task_split_template.md\` 作为排版基线。
- **文档内章节顺序**：**先后端任务清单、后前端任务清单**（与 pipeline 及设计产出顺序一致）；并包含**任务依赖关系与时序建议**、开放问题。
- **下游**：供 \`fullstack-code-implementation\` 按任务与设计文档实施（由其基于 \`task/task-split.md\` 识别后端/前端任务并切换子技能编码）。

## 工作流程

1. **读取设计文档并提炼任务来源**
   - 通读 **\`backend-design.md\`**：提取领域对象、流程分支、对外能力、数据与外部依赖、非功能与安全要求，并列出可拆分为开发任务的工作包。
   - 通读 **\`frontend-design.md\`**：提取页面/模块、组件职责、路由与状态及对后端能力的调用关系。
   - 对照 **需求文档**（若存在）：为任务补充 **REQ 编号** 或标注待确认项，确保可追溯；发现设计与需求冲突时在「开放问题」中列出。

2. **确定颗粒度与边界**
   - 任务应小到可在一次迭代或清晰 PR 内完成，并明确**交付物**（页面/服务/脚本/配置等）与**验证方式**。
   - 前后端边界与交付范围以两份设计文档为准；任务描述写清实现范围与联调/验收要点。

3. **生成后端任务清单**
   - 按 \`task_split_standard.md\` 的后端结构输出编号任务（数据库、模块、集成、测试、文档等），并与后端设计中的模块与能力范围一一对应。

4. **生成前端任务清单**
   - 按标准输出编号任务（路由、组件、状态、联调等），并与前端设计中的页面/组件及数据流对应。

5. **任务依赖与执行顺序**
   - 输出**任务级**依赖关系：哪些后端/前端任务互为前置、哪些可并行、与数据模型或外部系统相关的硬依赖。
   - 给出建议执行顺序（含联调窗口）；必要时用简短文字或表格指向设计文档章节，便于任务与设计的对应。

6. **开放问题与风险**
   - 汇总设计中未闭合项、需产品/业务确认的问题，并标明阻塞的任务。

7. **落盘与自检**
   - 写入 \`task/task-split.md\`，检查清单可执行、编号连续、依赖可理解；自检清单见 \`references/task_split_standard.md\`。

## 规范与模板

- **标准**：\`references/task_split_standard.md\`
- **模板**：\`references/task_split_template.md\`

## 与其他技能的关系

- **上游**：\`requirement-analysis\` 提供需求基线；**\`fullstack-design\`** 产出 **\`backend-design.md\`** 与 **\`frontend-design.md\`** 作为拆分主依据（宜先后端、后前端）。
- **下游**：\`fullstack-code-implementation\` 按 \`task-split.md\` 与设计文档实施；归档类技能可在实现后汇总。