# Step 8: HTML 报告生成

## 元信息

- execution-mode: inline
- checkpoint-level: L1

## 参数

- input: Step 5 分桶结果 + Step 6 方案 + Step 7 校验后修正
- reference: `references/report-template.html`
- output: 多份 HTML 报告（按场景 × 风险级别）

## 执行指令

### 1. 确定输出文件列表

按 Step 5 的分桶结果，每桶生成一个 HTML 文件：

```
upgrade/deadcode_{date}/analysis_high.html
upgrade/deadcode_{date}/analysis_medium.html
upgrade/deadcode_{date}/analysis_low.html
upgrade/redundant_{date}/analysis_high.html
upgrade/redundant_{date}/analysis_medium.html
upgrade/redundant_{date}/analysis_low.html
upgrade/duplicate_{date}/analysis_high.html
upgrade/duplicate_{date}/analysis_medium.html
upgrade/duplicate_{date}/analysis_low.html
```

若某桶为空（0 条发现），跳过该文件。

### 2. 按模板生成 HTML

使用 `references/report-template.html` 骨架，填充内容：

- **标题**：`{场景中文名} — 分析报告`（如"无效代码 — 分析报告"）
- **副标题**：风险等级 badge（high=红 / medium=黄 / low=绿）
- **汇总表**：本桶发现数量 + 严重度分布
- **发现明细**：逐条渲染（文件名+行号+代码片段+风险+方案）
- **方案区**：仅 high/medium 桶包含 before/after + 单测表

### 3. 写入

使用文件写入工具逐个生成 HTML 到 `ai-coding-skills/upgrade/{scene}_{date}/` 目录。

### 4. 输出摘要

```markdown
## HTML 报告生成完成

| 文件 | 发现数 | high | medium | low |
|------|--------|------|--------|-----|
| upgrade/deadcode_{date}/analysis_high.html | N | N | 0 | 0 |
| ... | ... | ... | ... | ... |

合计：{TOTAL} 条发现，{HTML_COUNT} 份报告
```

## 产出

- HTML 报告文件（`upgrade/{scene}_{date}/analysis_{riskLevel}.html`）
