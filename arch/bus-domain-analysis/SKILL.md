---
name: bus-domain-analysis
description: |
  基于代码扫描，参照 references/ 目录下的 HTML 模板格式，
  为用户指定业务领域生成标准 HTML 业务架构文档包（领域架构总览 + 用例时序图）。
  触发词：业务架构HTML、生成业务知识页、业务领域HTML文档、业务知识库生成、梳理业务领域。
---

# 业务领域知识 HTML 生成器

## 何时使用

- **首次对一个工作区做业务梳理**：需要先生成系统级业务架构总览 `business_arch.html`（母图/导航），再逐领域下钻
- 用户指定一个业务领域，需要从代码反向推导并生成标准化的 HTML 业务架构文档
- 需要输出与 `references/` 模板同格式结构的业务知识页
- 用户需要用例图(mermaid) + 用例时序图 + 数据模型 ER 图的可视化业务文档
- 已有代码仓库，需将其业务逻辑梳理为结构化知识库

## 核心能力

- **系统级业务架构总览（前置）**：扫描工作区**全部非知识库应用仓库**，按模板生成 `business_arch.html`（分层架构 + 领域全景 + 端到端数据流 + 领域×仓库矩阵 + 待确认项）与 `domain-backlog.md` 领域梳理清单；**生成后强制停止等待用户确认**
- **纵向领域总览批量生成（确认后）**：用户确认系统总览或明确提出要求后，先为全部纵向业务生命周期领域逐一生成与贷款领域相同结构的 `{domain}_arch.html`（业务全景、参与者、用例图、代码驱动的用例目录、实体汇总、ER 图）；**再次强制停止等待用户指定领域和正式场景，才允许生成应用间时序和 code 时序**
- 根据业务领域名称自动扫描代码，识别模块边界
- 将代码功能点按场景聚合，建立用例层级结构并分配编号
- 生成包含用例图、参与者、用例清单、数据模型的领域架构总览 HTML
- 为每个用例生成含用例规约、应用间时序图、信息流/资金流、数据模型串联的详情 HTML
- 为用例背后的真实代码实现生成**应用内分层 code 时序图**（Controller→Service→Micro/Event→Mapper/DB），作为 flow 页"关联功能时序图"的下钻目标；code↔用例为多对多复用
- 在 arch 页内嵌 JS 实现"点击用例行 → 跳转对应 flow 页"的导航
- 首次建库时将技能包自带的公共资源（`case.css`、`mermaid.min.js`）落盘到 ocspec 根下、与 `knowledge/` 同级的 `{OCSPEC_ROOT}/common/`（全库唯一一份），所有页面按深度相对引用

## 执行原则

- **总览先行 + 门禁（强制）**：首次梳理某工作区时，**必须先执行 Step 0 生成 `business_arch.html` 系统级总览，产出后强制停止、等待用户明确确认并指定领域，才可进入单领域梳理（Step 1+）**。若 `business_arch.html` 已存在，询问用户是重做还是直接梳理领域。
- **格式严格参照（强制）**：输出目录结构、文件命名、HTML 内容格式严格参照 `references/overview-template.html`（总览）、`references/arch-template.html`（领域）与 `references/flow-template.html` 的设计
- **代码驱动（强制）**：所有业务内容必须有代码扫描依据，不可臆造不存在的功能。缺失信息用 `[需人工确认：{具体问题}]` 标注
- **总览场景与领域详情一致（强制）**：图 1 中已存在 `{domain}/{domain}_arch.html` 的可跳转领域方块，其场景标签必须以该详情页的正式场景标题为唯一来源，逐项一致；方块内禁止出现“含 N 个场景 / N 个用例 / 领域总览含……”等数量性描述。尚无详情页时可暂列代码归纳的子能力；详情页生成或场景调整后，必须同步回写图 1 并复核。
- **Mermaid 渲染（强制）**：用例图用 `flowchart LR`，时序图用 `sequenceDiagram`，ER 图用 `erDiagram`，均启用 `theme:'dark'`
- **占位符统一**：模板中所有插入点使用 `{UPPER_CASE}` 格式
- **场景中文目录**：场景子目录使用中文名称（如 `客户建档`、`合规筛查`）

### 占位符使用纪律（强制）

知识库终稿中**仅允许两类待定标签**：`[待确认]`（工作区代码内存在但细节未定位）和外部边界的直接结论陈述（如"当前工作区外部边界"）。使用规则：

1. **打标签前必须完成最低限度检索**——在标注 `[待确认]` 之前，至少执行以下通用检索且均未命中，才允许占位：
   - 按交易码/ServiceCode 在核心仓库搜索对应实现类（如接入层引用了某 `ServiceCode` 的转发封装类，必须去核心侧搜同编号实现类）
   - 按表名搜索 Entity 类（`@Table`/`@TableKey`/`@Entity`）、Repository 接口或 DDL/初始化 SQL
   - 按流程 ID 搜索流程编排参数文件（如流程引擎节点定义 SQL、BPMN/工作流定义文件）
   - 按事件/消息模型类名搜索订阅方（EventBus/MQ Consumer/Listener）
2. **三类处理标准**：
   - **类别 A（可收敛）**：上述检索能命中具体类名/表名/SQL文件——**直接写出实处**，不留标签
   - **类别 B（代码事实为终态结论）**：代码里确实是 TODO/空实现/已注释/功能不存在——**直接陈述结论**（如"代码中为 TODO 空实现""当前代码基线未承载该功能"），不加 `[待确认]`
   - **类别 C（工作区外部边界）**：系统/组件不在本工作区代码仓库内——**直接写"当前工作区外部边界"**，不加方括号标签
3. **禁用"推导过程"措辞（强制）**：终稿正文**禁止**出现"已扫描确认""已确认""经排查确认""已核实""非未查全"等推导叙事语言。所有结论直接陈述，读者不需要知道结论是怎么得来的。

### 防猜测命名（强制）

功能/框架/模块归属描述**必须来自代码中实际的类名、包名、`import` 语句或配置声明**。禁止凭记忆、命名相似度或文档印象赋予非代码来源的名称。如果调用链末端的具体类名未定位到，写"具体实现类未在工作区定位"，不要用猜测的框架名填充。

### 多路由入口表达（强制）

一个接入层入口按条件（如交易类型/产品/渠道标志等）分流到多个核心交易码或实现类时，数据模型/依赖/外部依赖表格**允许并列写出所有实际路由目标**（如同时列出 3 个类名），不强行合并为一条调用链，也不要只写"等"。时序图中用 `alt/else` 标注分支路由。

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/overview-template.html` | **系统级业务架构总览 HTML 模板（business_arch.html）** |
| `references/domain-overview-template.html` | **纵向领域仅总览模板（{domain}_arch.html；不生成用例/时序/code）** |
| `references/arch-template.html` | 单领域下钻后的完整架构总览模板（{domain}_arch.html） |
| `references/flow-template.html` | 用例时序图 HTML 模板（UC-{DOMAIN}-{NN}_flow.html） |
| `references/sequence-template.html` | 应用内 code 时序图 HTML 模板（{功能}_sequence.html） |
| `references/case.css` | 公共样式表（技能包自带，首次建库落盘到 `{OCSPEC_ROOT}/common/`） |
| `references/mermaid.min.js` | Mermaid 渲染引擎（技能包自带，首次建库落盘到 `{OCSPEC_ROOT}/common/`） |

## 路径与产出约定

- **产出根目录**：`{OCSPEC_ROOT}/knowledge/business/{domain}/`
- **架构总览命名**：`{domain}_arch.html`
  - 示例：`customer_arch.html`、`account_arch.html`
- **用例时序图命名**：`{场景中文名}/UC-{DOMAIN_CODE}-{NN}_flow.html`
  - 示例：`客户建档/UC-CUST-01_flow.html`
  - NN 为两位数字编号，从 01 开始全局递增
- **领域目录命名**：`{domain}` 使用英文小写，取业务领域英文名，如 `customer`、`account`、`product`
- **DOMAIN_CODE 命名**：大写英文缩写，4 字符，如 `CUST`、`ACCT`、`PROD`、`INST`、`CIF`
  - 无法确定时，取 domain 英文前 4 字符大写
  - 用户可在输入时指定

## 执行入口

按以下步骤顺序执行。**两级门禁**：首次梳理工作区时先执行 Phase overview 的 Step 0 生成系统级总览 `business_arch.html`，产出后必须停止并等待用户确认；确认后执行 Step 0.5，为全部纵向业务生命周期领域生成仅总览的 `{domain}_arch.html`，再一次停止。只有用户明确指定“领域 + 已列出的正式场景”后，才可进入 Step 1+ 生成用例、应用间时序和 code 时序。若总览已存在，按用户指令选择重做 Step 0、执行 Step 0.5 或进入已确认的场景下钻。

---

## Phases

### Phase: overview（前置 · 首次梳理工作区时执行，产出后强制停止等待确认）

- Step 0: steps/step-00-overview-generation.md

### Phase: vertical-domain-overview（用户确认系统总览后，批量生成纵向领域仅总览并再次停止）

- Step 0.5: steps/step-00.5-vertical-domain-overview-generation.md

### Phase: intake（用户明确指定领域 + 正式场景后，进入单场景下钻）

- Step 1: steps/step-01-domain-intake.md

### Phase: analysis

- Step 2: steps/step-02-scenario-identification.md
- Step 3: steps/step-03-actor-data-model.md
- Step 4: steps/step-04-use-case-detail.md

### Phase: generation

- Step 5: steps/step-05-arch-html-generation.md
- Step 6: steps/step-06-flow-html-generation.md
- Step 7: steps/step-07-code-sequence-generation.md

### Phase: verification

- Step 8: steps/step-08-cross-verification.md

---

## 交付物

- `business_arch.html`（**系统级业务架构总览**：分层架构 + 领域全景 + 端到端数据流 + 生命周期 + 领域×仓库矩阵 + 各仓库领域清单 + 待确认项）＋ `domain-backlog.md`（领域梳理清单）—— Step 0 产出
- `{domain}_arch.html`（**纵向领域仅总览**：业务全景、参与者、用例图、代码驱动的用例目录、实体汇总与 ER 图；**不含用例时序/code 时序及跳转**）—— Step 0.5 产出，生成后必须等待确认
- `{domain}_arch.html`（单领域下钻后的完整架构总览，含业务全景、用例图、用例清单、数据模型）
- `{场景中文名}/UC-{DOMAIN_CODE}-{NN}_flow.html`（每个用例一个时序图页，含用例规约、应用间时序图、信息流/资金流、数据模型串联、关联功能链接）
- `knowledge/code/{app}/{class}/{功能中文名}_sequence.html`（应用内分层 code 时序图，被多个 flow 页关联复用）
- 共 1 + N + M 个 HTML 文件（N = 用例数，M = code 功能单元数，M 因复用通常 < N）

## Agent 职责矩阵

| 步骤 | 执行方式 | 做什么 |
|------|----------|--------|
| Step 0 整体业务架构总览 | subagent: `code-scanner`（全仓）+ inline | 扫描工作区全部非知识库应用仓库，按 overview-template 生成 business_arch.html + domain-backlog.md；**产出后强制停止，等待用户确认** |
| Step 0.5 纵向领域仅总览 | subagent: `code-scanner`（按领域）+ inline | 为所有纵向业务生命周期领域生成贷款页结构的 `{domain}_arch.html`（含 UC 目录和 ER 图），同步图 1 和 backlog；**不生成用例时序/code 时序或跳转，产出后再次强制停止** |
| Step 1 领域识别与代码扫描 | subagent: `code-scanner` | 在用户指定领域与正式场景后，划定下钻范围，收集模块、入口类、ServiceCode |
| Step 2 场景与用例识别 | inline | 基于扫描结果按功能聚合场景，识别用例，分配 UC 编号 |
| Step 3 参与者与数据模型 | subagent: `data-model-analyzer` | 识别参与者(actor)，分析数据实体与 ER 关系 |
| Step 4 用例详情分析 | subagent: `use-case-detail-analyzer` | 逐用例提取规约、应用间时序、数据模型关联 |
| Step 5 生成架构 HTML | inline | 按 arch-template 填充生成 {domain}_arch.html |
| Step 6 生成用例时序 HTML | inline | 按 flow-template 逐用例生成详情页（应用间时序） |
| Step 7 生成 code 时序 HTML | subagent: `code-sequence-analyzer` | 按 sequence-template 生成应用内分层时序（code↔用例多对多），回填 flow 关联链接 |
| Step 8 跨文档一致性校验 | subagent: `cross-verifier` | 校验 arch/flow/code 三层引用一致性、链接有效性 |
