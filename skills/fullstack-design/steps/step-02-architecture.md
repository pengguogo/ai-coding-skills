# Step 2: 架构设计（应用间关系 + 应用内模块 + 概览级 ER/时序）[强制停止]

## 元信息

- agent: architect
- checkpoint: checkpoints/step-02-architecture-final.md
- checkpoint-level: L2

## Summary 配置

- output: `{WORKSPACE}/design/summaries/02-architecture.summary.md`
- must-include:
  - 应用清单（应用名+定位+是否涉及改造）
  - 应用×功能点改造矩阵的精简版（应用→功能点 ID 列表）
  - 应用内模块清单（应用名 › 模块名+一句话职责+既有/新增/调整）——**供 function-design 时序图参与者命名校验**
  - 涉及变更的表清单（表名+所属应用+新增/改造）
- must-exclude:
  - Mermaid 图源码
  - 依赖关系图与时序图正文
- max-length: 1000

## 参数

- input_files: [`{WORKSPACE}/design/01-input-summary.md`, `{KNOWLEDGE}/application/`（若存在）, `{CODE_KNOWLEDGE}/backend-project.md`（若存在）]
- output_file: `{DESIGN}/architecture-design.md`
- status_report_file: `{WORKSPACE}/design/02-status-report.md`
- upstream_compare: [`{WORKSPACE}/design/01-input-summary.md`, `{REQ}/requirement.md`]
- reference_sections:
    - `references/design-architecture-standard.md`
    - `references/flowcharts.md`
    - `references/erd-diagrams.md`
    - `references/sequence-diagrams.md`
- domain_context: 架构设计/应用间——基于输入摘要与项目应用拓扑，撰写应用间架构设计与改造影响分析，并落应用内模块设计（模块级）

## 执行指令

> 基于 01-input-summary.md（应用清单 + 功能清单 + 外部依赖）与项目应用拓扑撰写架构设计文档。应用拓扑优先取 `{KNOWLEDGE}/application/`（applications-and-domains.md 应用主数据、application-system-architecture.md 调用拓扑），其次 `backend-project.md`，再次从需求跨系统描述推断。多应用拓扑识别以 application 知识库为准。

按 `design-architecture-standard.md` 的章节结构撰写以下七章节，**严格遵守粒度边界（应用级/模块级/表级，不下钻类/方法/字段）**：

### 1. 应用清单与定位
列应用清单：应用名 + 定位 + 本次是否涉及改造 + 来源。单应用只列 1 行并标注「单应用需求」。

### 2. 应用间依赖关系图
Mermaid flowchart，标调用方向/方式（HTTP/MQ/RPC）。单应用无依赖时显式标注。

### 3. 应用 × 功能点改造矩阵
- 多应用：行=应用、列=功能点，格子标 [新增]/[改造]/[复用] + 一句话改了什么对象/行为
- 单应用：退化为「应用职责说明」，注明「单应用需求」
- 矩阵列须覆盖 01-input-summary 功能清单全部功能点；每个功能点至少落一个应用；**拒绝「相应改造/适配调整」类套话**

### 4. 各应用职责与边界
逐应用说明职责与边界（应用级，**不下钻模块**）。

### 5. 应用内模块设计
每个「涉及改造」的应用列本期涉及模块：模块名 + 一句话职责 + 既有/新增/调整。模块 ≥ 4 个时用 Mermaid flowchart 展示依赖。
**模块名作为下游 function-design 时序图参与者命名的权威源；粒度止于模块级（package/service），不下钻类/方法。**

### 6. ER 模型变更总览
表级：表名 + 所属应用 + 新增/改造 + 一句话变更摘要。**不展开字段、不写建表 SQL**（留后端 §3.1.2）。单应用退化为本应用表变更总览。

### 7. 应用间关键交互时序
应用级泳道，跨应用主干调用链。**不出现 Controller/Service/Mapper 等应用内部参与者**（留后端 §3.2）。单应用无应用间交互时显式标注或退化为应用内主干流程概览，**禁止复制后端单功能时序**。

### 产出格式

- 输出文件以 `## 1. 应用清单与定位` 开头，含 §1~§7 全部章节。
- 改动标注可套用 `change-annotation-standard.md`（若已落地；未落地则跳过，不引用、不报错）。
- 缺失信息标注 `[需与产品确认]`。
- 末尾附加 STATUS_REPORT，状态码须按 scheduler-protocol §11 使用 `OK / WARN / NEED_INFO / BLOCKED`（concerns / missing-context / blocker 字段对应填写）。

### 关键约束

- 仅产出概览级应用关系、改造矩阵、应用内模块设计（模块级）、表级 ER 总览、应用级时序；**不下钻**字段级数据模型与方法级接口（那是后端 function-design / backend-foundation 的职责）。
- 应用名/模块名/表名/功能点 ID 以本文档为权威源，后端/前端对齐。
