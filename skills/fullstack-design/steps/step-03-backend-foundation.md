# Step 3: §1 背景与目标 + §2 技术选型 + §3.1 模型设计

## 元信息

- agent: architect
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1

## Summary 配置

- output: `{WORKSPACE}/design/summaries/03-foundation.summary.md`
- must-include:
  - 技术栈列表（语言/框架/中间件/数据库，每项一行）
  - 接口风格约定（URL前缀/返回体结构/认证方式）
  - 实体清单（实体名+核心字段名列表，每个实体最多8个关键字段含类型）
  - 表清单（表名+主键+核心字段名列表含类型）
  - 实体间关系（一对多/多对多，一行一条）
  - 状态枚举（状态值+允许的转换路径摘要）
- must-exclude:
  - 架构选型理由与权衡分析
  - Mermaid图源码
  - §1背景与目标的正文内容
  - 完整的字段详细说明和约束描述
  - 建表SQL脚本
  - 索引定义细节
- max-length: 1000

## 参数

- input_files: [`{WORKSPACE}/design/01-input-summary.md`, `{DESIGN}/architecture-design.md`, `{REQ}/requirement.md`]
- output_file: `{WORKSPACE}/design/03-backend-foundation.md`
- reference_sections:
    - `references/design-backend-standard.md#§1-背景与目标`
    - `references/design-backend-standard.md#§2-技术选型`
    - `references/design-backend-standard.md#§3.1-模型设计`
    - `references/change-annotation-standard.md`
    - `references/flowcharts.md`
    - `references/erd-diagrams.md`
- domain_context: 基于输入摘要与架构文档，撰写后端设计文档的 §1 背景与目标、§2 技术选型和 §3.1 模型设计

## 执行指令

基于 01-input-summary.md 的结构化摘要（含 §3 边界与交互线索）撰写以下章节。架构相关内容（应用关系/模块设计/ER 总览/应用间时序）已由 architecture-design.md 承载，本步骤**引用架构文档、不重复**。当摘要信息不足以确定实体属性、状态流转、约束规则时，回查 `{REQ}/requirement.md` 对应需求项原文，以原文为准。

### Part 1：§1 背景与目标

**§1.1 背景**：从功能清单和非功能要求中提炼业务场景、痛点、价值。存量项目说明现状与变更驱动因素；新项目说明业务机会与建设目标。

**§1.2 目标**：功能目标（对应 P0/P1 项）、性能目标（若有）、质量目标、业务目标。

**§1.3 约束**：技术约束（从工程约束和外部依赖中提取）、业务约束（从需求规则和限制中提取）。

**§1.4 参考文档**：引用需求文档路径、项目上下文文档路径（若存在）、**architecture-design.md（应用关系/模块清单/ER 总览的权威源）**。

**§1.5 路径与配置类约定**：根据场景判定（存量/新项目），按 design-backend-standard.md 中的表格格式填写。存量项目写真实路径类型，禁止把臆造示例当作现网路径。

### Part 2：§2 技术选型

**§2 技术选型**：存量项目按项目上下文如实列出；新项目从常见选项中选择并说明理由。覆盖：数据库、缓存、消息队列、定时任务、HTTP 客户端、其他组件。

> **架构与模块设计不在本文档**：应用架构、应用内模块清单已前置至 architecture-design.md（§2 应用依赖、§5 应用内模块设计）。本文 §2 仅保留技术选型（纯技术栈），**在 §2 处保留一行显式导航**："本期应用架构见 architecture-design.md §2，模块清单见 §5，本文不重列。" §3.1/§3.2 引用模块名处统一以架构 §5 为准。

### Part 3：§3.1 模型设计

#### §3.1.1 领域模型

从功能清单和术语中识别：
- **实体（Entity）**：名称、职责、属性（名/类型/说明/必填）、行为、唯一标识
- **值对象（Value Object）**：名称、职责、属性、行为
- **聚合根（Aggregate Root）**：名称、职责、聚合边界、对外方法
- **领域服务（Domain Service）**：名称、职责、方法签名与业务逻辑说明

格式严格遵循 design-backend-standard.md 中 §3.1.1 的示例结构。

#### §3.1.2 数据模型

基于领域模型推导数据库表结构：
- 每张表：表名（snake_case）、字段定义、主键设计、索引设计
- **SQL 脚本**：建表脚本 + 修改脚本占位
- **表关系图**：Mermaid erDiagram，标注 1:1、1:N、M:N 关系（见 erd-diagrams.md 语法）
- 数据库类型从 §2 技术选型中获取
- **与架构文档对齐**：本节涉及的表须与 architecture-design.md §6 ER 总览的表归属一致；模块归属参照架构 §5
- **改动标注**：表标题标三态 `[新增]/[改造]/[复用]`；`[新增]` 全表免逐字段标，`[改造]` 表在变更字段注释位标 `[新增]/[改造]`；erDiagram 下方配「数据模型改动清单表」（仅收 DDL 变更，按 change-annotation-standard.md §4.4）

#### §3.1.3 状态机（若适用）

若功能清单中存在有明确状态流转的业务对象：状态定义、转换规则、Mermaid stateDiagram、校验逻辑。**改动的状态/转换在 label 加 `[新增]/[改造]` 文字前缀；状态机整体全新时不逐条标，仅在图下声明"本状态机为本期全新设计"**（按 change-annotation-standard.md §4.2）。若无，写"本期无状态机设计"。

### 产出格式

输出文件以 `## 1. 背景与目标` 开头，包含 §1.1~§1.5、§2（技术选型）、§3.1.1~§3.1.3 全部子章节。
缺失信息标注 `[需与产品确认]`。
