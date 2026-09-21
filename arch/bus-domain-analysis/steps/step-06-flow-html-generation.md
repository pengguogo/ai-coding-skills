# Step 6: 生成用例时序 HTML

## 元信息

- execution-mode: inline
- input: Step 4 的每个用例详情 + `references/flow-template.html`
- output: N 个 `{场景中文名}/UC-{DOMAIN_CODE}-{NN}_flow.html`

## 执行指令

### 1. 读取模板

读取 `references/flow-template.html`。

### 2. 逐用例填充占位符

| 占位符 | 数据来源 | 格式 |
|--------|----------|------|
| `{UC_ID}` | 用例编号 | "UC-CUST-01" |
| `{UC_NAME}` | 用例名称 | "CIF 客户创建" |
| `{PAGE_TITLE}` | {UC_ID} {UC_NAME} 用例时序图 | title |
| `{BADGE_TAGS}` | 类型 + 场景 + 跨应用 | `<span class="badge">` |
| `{UC_TAG_CLASS}` | 标签样式 | tag-core / tag-sec |
| `{UC_TAG_TEXT}` | 标签文字 | "核心" / "合规" / "KYC" |
| `{UC_PARTICIPANTS}` | 参与者描述 | 文本 |
| `{UC_INTERFACE}` | 接口描述 | HTML 含 `<code>` |
| `{UC_PRECONDITION}` | 前置条件 | 文本 |
| `{UC_POSTCONDITION}` | 后置条件 | 文本 |
| `{UC_MAIN_FLOW}` | 主成功流程 | `<ol><li>...</li></ol>` |
| `{UC_ALT_FLOW}` | 备选流程（可选） | `<ul>` |
| `{UC_EXCEPTION_FLOW}` | 异常流程（可选） | `<ul>` |
| `{UC_BUSINESS_RULES}` | 业务规则 | `<span class="rule">R1</span>` |
| `{SEQ_DIAGRAM_MERMAID}` | 应用间时序图 | sequenceDiagram |
| `{INFO_FLOW}` | 信息流 | 文本 |
| `{FUND_FLOW}` | 资金流 | 文本或"无" |
| `{DM_LEGEND}` | 数据模型说明 | 文本 |
| `{DM_TABLE_ROWS}` | 数据模型串联行 | `<tr>` |
| `{RELATED_LINKS}` | 关联功能时序链接（**本步先留占位，由 Step 7 生成 code 时序后回填**） | `<a>` |
| `{BACK_LINK}` | 返回总览链接 | `../{domain}_arch.html` |
| `{SCENE_NAME}` | 场景中文名 | "客户建档" |
| `{CSS_PATH}` | 到 `{OCSPEC_ROOT}/common/` 的相对前缀 | `../../../../common/`（flow 页在 `knowledge/business/{domain}/{场景}/` 下） |
| `{JS_PATH}` | 到 `{OCSPEC_ROOT}/common/` 的相对前缀 | `../../../../common/`（flow 页在 `knowledge/business/{domain}/{场景}/` 下） |

> 公共资源 `case.css`、`mermaid.min.js` 统一放在 ocspec 根下、与 `knowledge/` 同级的 `{OCSPEC_ROOT}/common/`（Step 0/Step 5 已落盘），flow 页经 `../../../../common/` 引用，无需重复复制。

### 3. 写入

路径：`{OCSPEC_ROOT}/knowledge/business/{domain}/{场景}/UC-{CODE}-{NN}_flow.html`
