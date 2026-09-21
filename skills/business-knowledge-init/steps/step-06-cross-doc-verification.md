# Step 6: 跨文档校验 + 交付 [强制停止]

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-06-final.md
- checkpoint-level: L2

## 参数

- source_files:
  - `ocspec-<xxx>/knowledge/business/business-overview-and-planning.md`
  - `ocspec-<xxx>/knowledge/business/business-process-and-use-cases.md`
  - `ocspec-<xxx>/knowledge/business/business-domain-and-orchestration.md`
  - `ocspec-<xxx>/knowledge/business/business-capability-and-appendices.md`
- output_file: `{WORKSPACE}/biz/06-verification-report.md`
- assembly_template: skip（四份文档已在 Step 5 直接写入最终路径，本步骤仅执行校验）
- consistency_rules: |
    - S-*/DO-*/DE-* 编号在四份文档中完全一致且全局唯一
    - S-* 与 application 基线对齐（若存在）：复用的编号和语义不变，细化拆分的有标注说明
    - DO-* 与 application 侧一致（若存在）
    - APP-*/AG-*/AC-* 只引用不定义
    - DE-* 必须能在流程册的业务流程中找到触发源（闭环，无"幽灵事件"）
    - 流程册中标注了状态变更的步骤都有对应的 DE
    - 四份文档中无 HTTP 接口路径、数据库物理表名、网关路由配置等技术实现内容
    - 核心参与者覆盖内部用户、外部用户和外部系统（含外部合作方和外部平台）
    - DO 推导完整性：代码基线中的 Entity/Domain 类都有对应 DO
    - DE 推导完整性：异常处理完成、审批通过/拒绝等分支路径有独立 DE
    - Mermaid 图节点 ID 与表格中的编号一致
    - 所有表格严格遵循规范表头，无漏列
    - 四份文档的一级标题包含平台名称
    - 所有文档仅使用简体中文
- status_report_file: `{WORKSPACE}/biz/06-status-report.md`
- upstream_compare: [`{WORKSPACE}/biz/01-baseline.md`]

## 执行指令

本步骤跳过合并（四份文档已在 Step 5 直接写入最终路径），直接执行全局一致性校验。

### 1. 跨文档一致性校验
逐项检查四份已落盘文档之间的一致性：
- 编号一致性：S-*/DO-*/DE-* 在四份文档中完全一致且全局唯一
- S-* 与 application 基线对齐：复用的编号和语义不变
- DO-* 与 application 侧一致
- APP-*/AG-*/AC-* 只引用不定义
- DE 闭环：领域册中每个 DE-* 在流程册中有明确触发源
- 边界防越位：无 HTTP 接口路径、数据库物理表名、网关路由配置
- 参与者完整性：覆盖内部用户、外部用户和外部系统
- DO 推导完整性：对照 01-baseline.md 的 Entity/Domain 类清单
- DE 推导完整性：分支路径有独立 DE
- 图文一致性：Mermaid 图节点 ID 与表格编号一致
- 表格列完整性：所有表格严格遵循规范表头
- 产出语言：所有文档仅使用简体中文

### 2. 自动修正
- 可自动修正的不一致（编号大小写、格式差异）：直接修正四份文档
- 不可修正的：标注 [需人工确认]

### 3. 待确认项清零检查
扫描四份文档全文，搜索残留的 `[需人工确认]`、`[基线待补充]`、`<!-- STATUS_REPORT -->` 块。

### 关键约束
- 不新增内容，只做校验、修正格式
- 状态报告写入 status_report_file，不写入交付文档
- 交付文档中不得包含任何 STATUS_REPORT 块
- 用户确认后，由 Scheduler 统一清理 `{WORKSPACE}` 目录（见 scheduler-protocol §9.1）
