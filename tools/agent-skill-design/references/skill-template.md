# SKILL.md 模板

> 复制此模板，替换所有 `{...}` 占位符后，即可得到目标技能的 SKILL.md。

---

```markdown
---
name: "{skill-name}"
description: |
  {一句话概述技能功能}。{说明适用场景与触发条件}。
  触发词：{触发词1}、{触发词2}、{触发词3}。
---

# {技能中文标题}

## 何时使用

- {场景1}
- {场景2}
- {场景3}

## 核心能力

- {能力1}
- {能力2}
- {能力3}
- {能力4}

## 执行原则

- **{原则名1}**：{说明}
- **{原则名2}**：{说明}
- **{原则名3}**：{说明}

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/{模板文件名}` | {模板用途说明} |

## 路径与产出约定

- **{产出类型}输出位置**：{路径}
- **{产出类型}命名规则**：`{命名模式}`
  - {示例1}
  - {示例2}
  - {兜底规则}

## 执行入口

按以下步骤顺序执行：

---

## Phases

### Phase: {阶段1英文名}

- Step 1: steps/step-01-{step1-name}.md
- Step 2: steps/step-02-{step2-name}.md

### Phase: {阶段2英文名}

- Step 3: steps/step-03-{step3-name}.md

### Phase: {阶段3英文名}

- Step N: steps/step-0N-{stepN-name}.md

---

## 交付物

- `{产出文件名}`（{产出位置}）

## Agent 职责矩阵

| 步骤 | 执行方式 | 做什么 |
|------|----------|--------|
| Step 1 {步骤名} | inline | {简要描述} |
| Step 2 {步骤名} | subagent: `{agent-name}` | {简要描述} |
| ... | ... | ... |
```

---

## 占位符速查表

| 占位符 | 含义 | 示例 |
|--------|------|------|
| `{skill-name}` | 技能唯一标识（kebab-case） | `sql-impact-analyzer` |
| `{技能中文标题}` | 技能展示标题 | `数据变更影响分析` |
| `{触发词}` | 中文/英文触发短语 | `数订正分析`、`data impact analysis` |
| `{阶段N英文名}` | Phase 英文标识 | `analysis`、`verification`、`output` |
| `{agent-name}` | 子代理引用名 | `context-gatherer`、`general-task-execution` |
| `{产出文件名}` | 最终交付文件名 | `{场景}_data_impact_analysis.html` |
