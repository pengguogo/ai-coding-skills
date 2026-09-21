# Step 7: 生成应用内 code 时序 HTML

## 元信息

- execution-mode: subagent
- agent: code-sequence-analyzer
- input: Step 4 的用例详情（含"关联功能"识别）+ Step 1 的代码扫描基线 + `references/sequence-template.html`
- output: M 个 `knowledge/code/{app}/{class}/{功能中文名}_sequence.html`，并回填 Step 6 flow 页的关联链接

## 目的

business 层的 flow 页描述的是**应用间**时序（谁调谁、跨系统信息流/资金流）；code 层的 sequence 页描述的是**应用内**分层调用时序（Controller → Service → Micro/Event → Mapper/DB 的方法级实现），是 flow 页末尾"关联功能时序图（应用内）"下钻的目标。本步骤把用例背后的真实代码实现按"应用 + 类/功能"沉淀为可复用的 code 时序图。

## 核心原则

- **code↔用例为多对多**：一份 code 时序图按**代码实体（应用/类/功能）**组织，不按用例。同一功能被多个用例复用时只生成一份，被多个 flow 共同关联。例如"贷款开立流程编排"对应 `OpenFlowClImpl.process`，普通开立/子账户/一次发放/TopUp/重组多个用例共用同一份。
- **代码驱动（强制）**：分层调用链、类名、方法名、落库表必须来自真实代码扫描。源码未定位处标 `[待确认]`，实现不在工作区（如核心 CORE 侧、外部系统）标 `[逻辑视图]` 并说明依据（接口契约/规格文档）。
- **一个 flow 可关联多份 code**：如"一次开立发放"用例可关联"发放编排 + 父级开立编排 + 费用 + 保费"4 份 code 时序。

## 执行指令

### 1. 从用例详情归纳 code 功能单元

遍历 Step 4 各用例的"关联功能"，按**应用 + 承载类/流程**归并为 code 功能单元清单（去重）：

```
| code 功能单元 | 应用 | 承载类/入口 | 关联用例(多对多) | 分层链 |
|--------------|------|------------|-----------------|--------|
| 核心接口统一转发 | sample-api | CoreApsiService.getCore | UC-LOAN-01/02/07 | Service→getCore→HTTP |
| 贷款开立流程编排与落库 | core-service | OpenFlowClImpl.process | UC-LOAN-01/02/03/04/05 | Svc→Stria→Micro→Event→DB |
```

归并规则：同一类/流程的实现只生成一份；不同应用即使功能名相似也分开生成。

### 2. 逐 code 单元提取分层实现（代码驱动）

对每个 code 功能单元，从扫描基线提取：

| 字段 | 说明 | 来源 |
|------|------|------|
| 分层调用链 | 入口 → Service/Flow → Micro/Event → Mapper/DB，精确到方法名 | 类方法调用分析 |
| 方法功能描述 | 各关键方法职责 | 方法体/注释 |
| 逻辑分支 | if/switch/异常码分支 | 校验与分支逻辑 |
| 外部依赖 | 调用的其它应用/引擎/库（Caller/Provider/HTTP/MQ） | import/注入/RPC 声明 |
| 数据模型读写 | 各层落库/读取的真实表 + 访问模式(读/写/读写) | Repository/Mapper/SQL |
| 状态机（可选） | 有明确状态流转时补 stateDiagram-v2 | 状态字段流转 |
| 配置项 | ServiceCode/bean/参数/成功码 | 枚举/XML/常量 |

### 3. 按 sequence-template 填充占位符

| 占位符 | 数据来源 | 格式 |
|--------|----------|------|
| `{PAGE_TITLE}` | 应用 · 功能名 | "APSI · 核心接口统一转发 — 功能时序图（应用内）" |
| `{APP_TITLE}` | 应用全称 | "APSI(sample-api)" / "CORE(core-service)" |
| `{FUNC_NAME}` | 功能中文名 | "核心接口统一转发" |
| `{BADGE_TAGS}` | 功能时序标签 + 类/交易码 | `<span class="badge">功能时序 / 应用内 · APSI</span>...` |
| `{BACK_LINKS}` | 关联用例返回链接（**多对多**，见下） | 见"返回链接规则" |
| `{DEP_TAGS}` | 关键依赖标签 | `<span class="dep-tag db">DB:MB_ACCT(写)</span>` |
| `{FUNC_DESC_NOTE}` | 功能定位说明 + 代码路径 + 逻辑视图声明 | `<p>` 文本，含 `<code>全类名</code>` |
| `{SEQ_DIAGRAM_MERMAID}` | 分层调用链 | sequenceDiagram（含 alt/Note） |
| `{METHOD_ROWS}` | 方法功能描述行 | `<tr><td><code>方法</code></td><td>...</td></tr>` |
| `{BRANCH_ROWS}` | 逻辑分支行 | `<tr>...</tr>` |
| `{DEPENDENCY_ROWS}` | 外部依赖行 | `<tr>...</tr>`（类型用 dep-tag） |
| `{DM_ROWS}` | 数据模型读写行 | `<tr>...读/写/读写...</tr>` |
| `{STATE_MACHINE_BLOCK}` | 状态机（无则整块留空） | `<h2>状态机</h2><div class="diagram">...</div>` |
| `{CONFIG_ROWS}` | 配置项行 | `<tr>...</tr>` |
| `{CSS_PATH}` `{JS_PATH}` | 到 `{OCSPEC_ROOT}/common/` 的相对前缀 | code 页在 `knowledge/code/{app}/{class}/` 下，前缀 `../../../../common/` |

### 4. 返回链接规则（多对多）

`{BACK_LINKS}`：列出所有关联用例，**第一个用 `←` 箭头，其余用 `|` 分隔**：

```html
<a class="back-link" href="{到flow的相对路径}/UC-XXXX-01_flow.html">← UC-XXXX-01 用例名</a>
<span class="back-sep">|</span> <a class="back-link" href=".../UC-XXXX-02_flow.html">UC-XXXX-02 用例名</a>
```

- 单一用例时省略 `.nav-hint` 提示语与 `back-sep`，仅一个 `← 返回用例时序图 UC-XXXX`。
- 从 code 页到 flow 页的相对路径：code 页在 `knowledge/code/{app}/{class}/`，flow 页在 `knowledge/business/{domain}/{场景}/`，前缀为 `../../../business/{domain}/{场景}/`。

### 5. Mermaid 防渲染错误（强制）

sequenceDiagram / 表格代码块内**禁止出现裸尖括号泛型**（如 `BaseVo<T>`）——浏览器 HTML 解析器会把 `<T>` 当标签剥离，破坏图。改用 `BaseVo[T]`；在普通 HTML 表格文本中用实体转义 `&lt;T&gt;`。

### 6. 多表落库步骤逐表说明（强制）

时序图中凡是**一步写入/更新多张表**的步骤（如 `INSERT 协议/主账户/利率分户/结算/余额/还款计划`），必须在该步骤消息内用 `<br/>` 换行，**逐表补充「表名：简要作用」**，禁止只留笼统的中文短语或只列表名不说作用。

- 格式：在原消息末尾接 `<br/>表名A：作用<br/>表名B：作用…`，与 INSERT/UPDATE 动作同一条消息内展开。
- **不使用 `Note`**（会带背景色块、割裂时序），直接写进箭头消息文本。
- 作用一句话点明该表承载什么（含关键字段/枚举值），例如：

```
EV->>DB: INSERT 协议/主账户/利率分户/结算/余额/还款计划<br/>MB_AGREEMENT+MB_AGREEMENT_LOAN：贷款协议与合同要素<br/>MB_ACCT：贷款主账户(标识/状态/到期日)<br/>MB_ACCT_INT_DETAIL：利率分户(执行利率/结息周期)<br/>MB_ACCT_BALANCE：账户余额初始化(PRI 本金)<br/>MB_ACCT_SCHEDULE：分期还款计划
```

- 单表步骤已在消息内点名单表（如 `INSERT MB_TRAN_HIST(DRW)`）时，可只补一句作用，无需换行罗列。
- 表名/作用须与「数据模型」表一致，未定位的表标 `[待确认]`。

### 6. 回填 flow 页关联链接

生成 code 页后，回到 Step 6 产出的对应 flow 页，把"关联功能时序图（应用内）"区块的占位改为真实链接（一个 flow 可含多条）：

```html
<h2>关联功能时序图（应用内）</h2>
<div class="nav-hint">{APP层} → {CORE层}（应用内分层调用时序）。</div>
<div class="nav-links">
  <a class="nav-link" href="../../../code/{app}/{class}/{功能}_sequence.html">{app} · {功能} &#8594;</a>
</div>
```

从 flow 页到 code 页的相对路径：flow 页在 `knowledge/business/{domain}/{场景}/`，前缀为 `../../../code/{app}/{class}/`。

### 7. 落盘路径

`{OCSPEC_ROOT}/knowledge/code/{app}/{class}/{功能中文名}_sequence.html`

- `{app}`：应用/仓库名（如 `sample-api`、`core-service`、`policy-service`）
- `{class}`：承载类或功能簇名（如 `CoreApsiService`、`OpenFlowCl`、`AcctDrwMicro`）
- 公共资源复用 ocspec 根下、与 `knowledge/` 同级的 `{OCSPEC_ROOT}/common/`，code 页经 `../../../../common/` 引用，无需额外落盘。

## 校验

- 每个 flow 页的"关联功能时序图"链接目标文件均存在
- 每个 code 页的返回链接目标 flow 文件均存在
- code↔用例多对多关系双向可达
- 分层链、类名、表名有代码依据，无据处标 `[待确认]`/`[逻辑视图]`
