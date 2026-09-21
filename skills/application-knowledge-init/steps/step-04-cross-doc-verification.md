# Step 4: 跨文档校验 + 交付 [强制停止]

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-04-final.md
- checkpoint-level: L2

## 参数

- source_files:
  - `ocspec-<xxx>/knowledge/application/application-system-architecture.md`
  - `ocspec-<xxx>/knowledge/application/applications-and-domains.md`
  - `ocspec-<xxx>/knowledge/application/application-components.md`
- output_file: `{WORKSPACE}/app/04-verification-report.md`
- assembly_template: 无（本步骤不做合并，三份文档已在 Step 3 直接写入最终路径，仅执行校验）
- consistency_rules: |
    - APP-*/AG-*/AC-*/S-*/DO-* 编号在三份文档中完全一致
    - APP 编号从 APP-01 连续递增无跳号，先后端再前端
    - AG 前端细分：前端应用按终端形态拆分为独立 AG，不存在合并
    - Mermaid 图节点 ID 与表格中的编号一致
    - Mermaid 图单张节点数合理，超过时已分拆子图
    - 集成点的提供方/消费方在系统架构册和应用主数据册中一致
    - 前端 APP 与后端能力映射在主数据册和组件册中一致
    - 前后端集成表在系统架构册和主数据册中一致
    - 端到端时序图从前端入口开始绘制，覆盖核心业务链路
    - 无基线的外部服务只标注名称和调用方式，未推断内部结构
    - S-*/DO-* 与 business 基线一致（若存在）
    - 所有表格严格遵循规范表头，无漏列
    - 所有文档仅使用简体中文
- status_report_file: `{WORKSPACE}/app/04-status-report.md`
- upstream_compare: [`{WORKSPACE}/app/01-scope.md`]

## 执行指令

本步骤跳过合并（三份文档已在 Step 3 直接写入最终路径），直接执行全局一致性校验。

### 1. 跨文档一致性校验
逐项检查三份已落盘文档之间的一致性：
- 编号一致性：同一 APP/AG/AC 在三份文档中的编号和名称完全一致
- APP 编号连续性：从 APP-01 开始连续递增，无跳号
- AG 前端细分：前端应用按终端形态拆分为独立 AG
- 图文一致性：Mermaid 图中的节点 ID 与表格中的编号一致
- Mermaid 图规模：单张图节点数合理，超过时已分拆子图
- 集成点一致性：系统架构册的集成点与主数据册的依赖矩阵一致
- 前后端集成可追溯性：前后端集成表在系统架构册和主数据册中一致
- 时序图覆盖：端到端时序图覆盖核心业务链路，从前端入口开始
- 前端应用总览：主数据册 §5 覆盖所有前端 APP
- 覆盖完整性：对照 01-scope.md 的子系统清单，检查每个子系统在三份文档中均有体现
- 表格列完整性：所有表格严格遵循规范表头，无漏列
- 产出语言：所有文档仅使用简体中文

### 2. 自动修正
- 可自动修正的不一致（编号大小写、格式差异）：直接修正三份文档
- 不可修正的：标注 [需人工确认]

### 3. 待确认项清零检查
扫描三份文档全文，搜索残留的 `[需人工确认]`、`[基线待补充]`、`<!-- STATUS_REPORT -->` 块。

### 关键约束
- 不新增内容，只做校验、修正格式
- 状态报告写入 status_report_file，不写入交付文档
- 交付文档中不得包含任何 STATUS_REPORT 块
- 用户确认后，由 Scheduler 统一清理 `{WORKSPACE}` 目录（见 scheduler-protocol §9.1）
