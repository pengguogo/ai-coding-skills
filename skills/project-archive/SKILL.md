---
name: project-archive
description: 端到端统一归档（独立技能）：在同一需求上下文中一次性覆盖前端与后端，结合需求、设计、任务拆分与 ocspec 知识库，在 archive 根目录产出 code-archive.md、appliaction-archive.md、businsess-archive.md；落盘后须更新 knowledge/application、knowledge/businsess，并增量更新 knowledge/code 项目名 下 frontend-project.md、backend-project.md（写入本次新增功能）。不依赖 frontend-project-archive 或 backend-project-archive。产出可检索、可评审的 Markdown 正文与表格，不以图片替代正文。知识库更新（含 frontend-project.md、backend-project.md）须将增量内容逐条分析后融合到现有文档对应章节位置，不得作为独立段落或附录直接追加到文档末尾。
---

# 项目统一归档（端到端 · 独立）

## 定位

- **\`project-archive\` 是独立的端到端归档技能**：在一次执行中完成**业务层、应用层、代码/接口层**的归档，并覆盖**前端与后端**的实现追溯、契约与工程侧增量。
- **不依赖** \`frontend-project-archive\`、\`backend-project-archive\`。二者为可选的单端工作流；若团队采用本技能做需求收尾归档，**无需**先跑单端归档。若仓库中已存在历史 \`interface-detail\`、单端归档目录等，可作为**补充材料引用**，非前置条件。

## 何时使用

在需求、设计（**\`fullstack-design\`** 产出的 **\`backend-design.md\`** / **\`frontend-design.md\`**）、任务拆分（\`task-split\`，产出 \`task/task-split.md\`）已具备，且需要**一次性产出**本次需求在 \`archive/\` 根目录下的 **code-archive.md、appliaction-archive.md、businsess-archive.md**（正文级 Markdown）并完成与知识库同步时使用。

## 产出物性质（强制）

1. 上述归档文件均为 **UTF-8 Markdown**，包含**具体章节与可填写表格**，不是封面、不是截图说明、不是“待补图”占位。
2. 所有结论应能追溯到：需求文档、设计文档、\`task/task-split.md\`、以及 \`ocspec-<xxx>/knowledge/code/<项目名>/\` 中的条目。
3. 不确定项统一标注 \`[需人工确认]\`。

## 前置条件

1. 需求目录：\`ocspec-<xxx>/requirements/<需求英文名>_<yyyymmdd>/\`
2. 推荐齐备：
   - 需求：\`.../requirement/\` 下需求文档
   - 设计：\`.../design/frontend-design.md\`、\`.../design/backend-design.md\`（由 **\`fullstack-design\`** 先后端、后前端产出）
   - 任务拆分：\`.../task/task-split.md\`
3. 知识库（必需）：\`ocspec-<xxx>/knowledge/code/<项目名>/\`（至少能定位 \`frontend-project.md\`、\`backend-project.md\`；后端另参考 \`backend-database.md\`、\`backend-external-dependency.md\`、\`backend-interface.md\`）
4. 应用层/业务层知识（与 \`appliaction-archive\` / \`businsess-archive\` 配套）：\`ocspec-<xxx>/knowledge/application/\`、\`ocspec-<xxx>/knowledge/businsess/\`（目录或文件结构由团队约定；不存在则创建，用于与归档正文对齐的增量沉淀）

## 输出与保存位置

目录：\`ocspec-<xxx>/requirements/<需求英文名>_<yyyymmdd>/archive/\`

生成（目录不存在则创建）：

- \`code-archive.md\`
- \`appliaction-archive.md\`
- \`businsess-archive.md\`

**结构原则**：正文章节、表格字段以 \`references/unified_archive_outputs_standard.md\` 为准。\`code-archive.md\` 中前后端条目在字段深度上可对照同目录 **\`frontend_project_archive_standard.md\`**、**\`backend_project_archive_standard.md\`**（本技能包内置参考，**非**其他技能的执行前置）。

**知识库同步（强制，且须在归档正文产出之后执行）**：

归档三文件（\`code-archive.md\`、\`appliaction-archive.md\`、\`businsess-archive.md\`）**写完并落盘后**，必须继续完成知识库更新（详见工作流程步骤 5），**缺一不可**。更新时**必须**按 \`references/unified_archive_outputs_standard.md\`「知识库融合更新标准流程」中定义的 **5 步流程**（① 读取 → ② 分析 → ③ 定位 → ④ 融合 → ⑤ 校验）执行，**严禁**将增量内容作为独立段落、附录或新章节直接追加到文档末尾。

更新范围：
1. \`knowledge/application/\` — 根据 \`appliaction-archive.md\` 融合更新
2. \`knowledge/businsess/\` — 根据 \`businsess-archive.md\` 融合更新
3. \`knowledge/code/<项目名>/frontend-project.md\` — 前端增量就地融合
4. \`knowledge/code/<项目名>/backend-project.md\` — 后端增量就地融合
5. \`knowledge/code/<项目名>/\` 下 \`backend-interface.md\`、\`backend-database.md\`、\`backend-external-dependency.md\` — 按 \`references/backend_project_archive_standard.md\` 中的**条件性检查清单**逐项检查，有变更则融合更新

## 工作流程

### 步骤 1：收集输入

1. 读取需求文档：需求项、范围、优先级、流程。
2. 读取 \`frontend-design.md\` / \`backend-design.md\`：架构、模块、接口与数据要点。
3. 读取 \`task/task-split.md\`：**先后端、后前端**的任务与接口映射（与 \`task-split\` 技能约定一致）。
4. 读取知识库：对齐技术栈、目录、接口清单分册、库表与外部依赖口径；读取 \`ocspec-<xxx>/knowledge/application/\`、\`ocspec-<xxx>/knowledge/businsess/\` 既有沉淀（若存在），避免与本期结论矛盾。
5. **可选**：若仓库或需求目录下已有**历史**接口细化说明、单端归档遗留文件，仅作事实引用并入相应章节（不虚构、不强制依赖其存在）。

### 步骤 2：编写 \`code-archive.md\`

直接依据需求、设计、\`task/task-split.md\` 与 \`knowledge/code\` 编写，合并以下**可写入正文**的内容（字段与表格深度见 \`unified_archive_outputs_standard.md\` 及内置参考）：

- 归档元数据、需求与实现路径摘要、关联路径表。
- **后端**：接口契约表（URL/方法/入参出参/错误/幂等/事务要点摘要）；数据模型变更（表/字段/索引）；与 \`backend-interface\` 的对照；若存在可引用的 **interface-detail** 类文件，在 \`code-archive.md\` 中给出**清单与追溯**（不强制全文粘贴，但必须能定位）。
- **前端**：实现路径、目录/路由/组件变更摘要；与 \`frontend-project.md\` 增量点的对应（若本次未更新前端 project 则写明原因）。

### 步骤 3：编写 \`appliaction-archive.md\`

应用层视角：**主写文字与流程**，把「前端页面/状态 → 后端接口 → 数据/外部依赖」写清楚；可附 Mermaid 序列图（可选），但**必须有同级文字说明**。编写时**读取**既有 \`ocspec-<xxx>/knowledge/application/\`，避免与历史结论矛盾。

### 步骤 4：编写 \`businsess-archive.md\`

业务层视角：目标、范围、角色、业务流程、规则、与需求条目对照表；前后端职责边界分节描述；开放问题列表。编写时**读取**既有 \`ocspec-<xxx>/knowledge/businsess/\`（路径以仓库为准）。

### 步骤 5：更新知识库（\`application\` / \`businsess\` / \`code\` 下全部相关文档）——**在步骤 2～4 产出文件落盘之后执行**

> **核心原则：结构保持 + 就地融合**
>
> 更新知识库时**不得**将增量内容作为独立段落或附录直接追加到文档末尾。**必须**按 \`references/unified_archive_outputs_standard.md\`「知识库融合更新标准流程」中的 **5 步流程**（读取→分析→定位→融合→校验）执行。

1. **融合更新** \`ocspec-<xxx>/knowledge/application/\`：读取既有应用层知识文档，将 **\`appliaction-archive.md\`** 中的本期增量（页面、调用链、接口关系等）逐条分析并归入现有文档的对应章节与表格位置，保持文档原有结构不变。
2. **融合更新** \`ocspec-<xxx>/knowledge/businsess/\`：读取既有业务层知识文档，将 **\`businsess-archive.md\`** 中的本期增量（流程、规则、角色边界等）逐条分析并归入现有文档的对应章节与表格位置，保持文档原有结构不变。
3. **融合更新** \`ocspec-<xxx>/knowledge/code/<项目名>/frontend-project.md\`：读取既有前端项目文档，将**本次新增/变更的前端功能与工程信息**逐条定位到文档中对应的模块、路由、组件、接口调用等章节并就地补充（与 \`code-archive.md\`、实现一致）。
4. **融合更新** \`ocspec-<xxx>/knowledge/code/<项目名>/backend-project.md\`：读取既有后端项目文档，将**本次新增/变更的后端能力**（接口、模块、数据与外部依赖等）逐条定位到文档中对应章节并就地补充（同上）。
5. **条件性融合更新** \`ocspec-<xxx>/knowledge/code/<项目名>/\` 下其他后端知识文件——根据本期 \`code-archive.md\` 中的变更内容，按 \`references/backend_project_archive_standard.md\` 中的**后端知识库条件性更新检查清单**逐行检查 \`backend-interface.md\`、\`backend-database.md\`、\`backend-external-dependency.md\` 是否需要更新，若涉及则按 5 步融合流程执行。

### 步骤 6：一致性校验

按 \`references/unified_archive_outputs_standard.md\`「一致性校验检查清单」（5.2 节）逐项执行，包括：

1. **归档正文一致性**（5.2.1）：三份归档文件与 \`task/task-split.md\` / 设计文档无矛盾。
2. **知识库更新完整性检查清单**（5.2.2）：7 项知识库文件逐项确认更新结果。
3. **交叉一致性**（5.2.3）：所有已更新的知识库文档与归档正文无互斥表述。

## 参考规范

- **统一归档输出模板**：\`references/unified_archive_outputs_standard.md\`
- **code-archive 字段补充（内置）**：\`references/frontend_project_archive_standard.md\`、\`references/backend_project_archive_standard.md\`