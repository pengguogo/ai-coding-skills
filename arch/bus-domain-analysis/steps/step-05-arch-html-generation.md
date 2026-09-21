# Step 5: 生成领域架构 HTML

## 元信息

- execution-mode: inline
- input: Step 2 的场景用例清单 + Step 3 的参与者数据模型 + `references/arch-template.html`
- output: `{domain}_arch.html`

## 执行指令

### 1. 读取模板

读取 `references/arch-template.html`，确认所有占位符。

### 2. 填充占位符

| 占位符 | 数据来源 | 格式 |
|--------|----------|------|
| `{DOMAIN_TITLE}` | domain 中文名 + 英文名 | "客户域 (customer)" |
| `{DOMAIN_EN}` | domain 英文 | "customer" |
| `{BADGE_TAGS}` | 项目 + 领域 + 来源 | `<span class="badge">项目名</span>` |
| `{BIZ_OVERVIEW}` | 业务全景描述 | HTML `<ul>` |
| `{ACTOR_TABLE_ROWS}` | Step 3 参与者列表 | `<tr>...</tr>` |
| `{UC_DIAGRAM_MERMAID}` | Step 2 用例图 Mermaid | flowchart LR |
| `{UC_DIAGRAM_CAPTION}` | 用例图标题 | "图 2-1 领域用例图" |
| `{UC_CATALOG_ROWS}` | Step 2 用例清单 | `<tr>...</tr>` |
| `{UC_CATALOG_LEGEND}` | 清单说明 | `<div class="legend">...</div>` |
| `{ENTITY_TABLE_ROWS}` | Step 3 实体汇总 | `<tr>...</tr>` |
| `{ER_DIAGRAM_MERMAID}` | Step 3 ER 图 | erDiagram |
| `{ER_CAPTION}` | ER 图标题 | "图 4-1 领域 ER 图" |
| `{FOOTER}` | 脚注 | 项目 + 领域 + 代码依据 |
| `{UC_SCENARIO_MAP}` | JS MAP | `{'UC-CODE-01':'场景一',...}` |
| `{BACK_LINK}` | 返回上级链接 | `../user_arch.html` |
| `{CSS_PATH}` | 到 `{OCSPEC_ROOT}/common/` 的相对前缀 | `../../../common/`（arch 页在 `knowledge/business/{domain}/` 下） |
| `{JS_PATH}` | 到 `{OCSPEC_ROOT}/common/` 的相对前缀 | `../../../common/`（arch 页在 `knowledge/business/{domain}/` 下） |

### 3. 关键 HTML 结构

参照 `references/arch-template.html`：
- CSS class 名保持一致
- 用例清单行含场景分组行（`class="grp"`）和可点击行
- 场景分组颜色：`g-purple`、`g-orange`、`g-cyan`
- 内嵌 JS 实现用例行点击跳转

### 4. 确认公共资源已落盘

全部产出统一引用 ocspec 根下、与 `knowledge/` 同级的 `{OCSPEC_ROOT}/common/`（`case.css`、`mermaid.min.js`）。该目录通常已由 Step 0 首次建库时落盘；若本次跳过 Step 0（直接梳理领域）而 `{OCSPEC_ROOT}/common/` 尚不存在，则将技能包自带的 `references/case.css`、`references/mermaid.min.js` 复制到该目录（全库唯一一份，已存在则跳过）。

### 5. 写入

路径：`{OCSPEC_ROOT}/knowledge/business/{domain}/{domain}_arch.html`
