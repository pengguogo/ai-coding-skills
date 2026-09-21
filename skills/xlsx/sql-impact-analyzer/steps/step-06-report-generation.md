# Step 6: HTML 报告生成

## 元信息

- execution-mode: inline

## 参数

- input: Step 1-4 的产出（经 Step 5 校验通过）
- output_file: `{场景}_data_impact_analysis.html`（工作区根目录）
- reference: `references/report-template.html`

## 执行指令

将 Step 1-4 的结果按 `references/report-template.html` 的 HTML 模板结构组装为最终报告。

### 报告结构

```
<h1>数订正影响分析报告</h1>
<p class="subtitle">生成日期 | 涉及模块</p>

一、SQL 订正内容概览（表格 + SQL 代码块）
---分隔线---
二、逐条影响分析
  SQL-1：{表名}（{中文含义}）
    - 字段含义（field-table）
    - 影响分析（impact-table：整合后置功能 + 事实源 + 触发条件 + 影响结论）
    - 关键说明（note 块，若有）
  ---分隔线---
  SQL-2：...
---分隔线---
三、风险点汇总（risk-table）
```

### 核心变更：impact-table 整合表

**不再**分离"后置功能表"和"事实源列表"为两个独立区块。使用单一 `.impact-table` 表格，每行包含：

| 列 | 内容 | 说明 |
|----|------|------|
| 后置功能 | 功能名称 + 类型 + 事实源 | 功能名称为主标题，下方 `<div class="source-cell">` 展示完整文件路径和行号 |
| 触发条件 | SQL 条件或代码判断逻辑 | 用 `<code>` 包裹条件原文，下方接 `—` 补充说明 |
| 影响结论 | 本次修改对该功能的具体影响 | 用颜色标签标识：✅ 安全(safe-tag) / ⚠️ 需关注(warn-tag) / ❌ 危险(danger-tag) |

### impact-table 单行 HTML 结构

```html
<tr>
    <td>
        {功能名称}（{EOD/在线/会计}）
        <div class="source-cell"><code>{仓库名/模块/.../文件名}</code> 第{行号}行</div>
    </td>
    <td class="trigger-cell">
        <code>{触发条件原文}</code><br>
        — {补充解释}
    </td>
    <td class="conclusion-cell">
        <span class="safe-tag">✅ {具体安全结论}</span>
    </td>
</tr>
```

### 影响结论标签规则

| 标签 | CSS Class | 含义 | 使用场景 |
|------|-----------|------|---------|
| ✅ | `.safe-tag` | 修改后该功能不受影响或影响符合预期 | 功能因条件不再匹配而跳过本记录 |
| ⚠️ | `.warn-tag` | 修改后行为有变化，需人工确认 | 走入不同分支、金额计算输入变化 |
| ❌ | `.danger-tag` | 修改后会导致错误或异常 | 被 EOD 覆盖、金额计算错误、出单异常 |

### 样式规则

严格使用 `references/report-template.html` 中定义的 CSS class：

| 元素 | CSS Class | 用途 |
|------|-----------|------|
| SQL 代码块 | `.sql-block` | 暗色背景等宽字体 |
| SQL 关键字 | `.keyword` | 蓝色高亮 |
| SQL 字符串 | `.string` | 绿色高亮 |
| SQL 函数 | `.function` | 黄色高亮 |
| 字段含义表 | `.field-table` | 首列加粗蓝色 |
| 影响分析表 | `.impact-table` | 整合后的核心表格 |
| 事实源行 | `.source-cell` | 小字灰色 + code 标签 |
| 触发条件列 | `.trigger-cell` | code 格式化条件原文 |
| 影响结论列 | `.conclusion-cell` | 加粗 + 颜色标签 |
| 风险表 | `.risk-table` | 首列加粗 |
| P0 标签 | `.risk-p0` | 红色 #dc2626 |
| P1 标签 | `.risk-p1` | 橙色 #d97706 |
| P2 标签 | `.risk-p2` | 蓝色 #2563eb |
| 关键说明 | `.note` | 黄色左边框提示块 |
| 分隔线 | `.divider` | 虚线分隔 |

### SQL 语法高亮规则

在 `.sql-block` 中手动为 SQL 添加 span 标记：
- `UPDATE`、`SET`、`WHERE`、`AND`、`OR`、`INSERT`、`DELETE`、`SELECT`、`FROM`、`JOIN`、`ON`、`BETWEEN`、`IN` → `<span class="keyword">`
- 单引号包裹的字符串值 → `<span class="string">`
- `DATE_FORMAT`、`NOW`、`COUNT`、`SUM` 等函数名 → `<span class="function">`

### 文件命名

使用 Step 1 确定的场景名：`{场景}_data_impact_analysis.html`

### subtitle 信息

- 生成日期：当天日期，格式 YYYY-MM-DD
- 涉及模块：从 Step 2 代码追踪结果中提取涉及的业务模块名

### 输出方式

使用 `fsWrite` 工具写入工作区根目录。HTML 必须是完整的、可直接浏览器打开的独立文件。

## 产出

- `{场景}_data_impact_analysis.html`
