# Checkpoint: Step 1 复检范围与输入盘点

> **审查级别**：L1（轻量审查）— 只检查结构和内容维度。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。

## 审查时需打开的文件
- 产出文件：`{WORKSPACE}/knowledge-recheck/01-intake-and-scope.md`
- 上游比对：用户指定的需求文档或 `{REQ}/requirement.md`

## 结构检查
- [ ] 包含章节：复检模式
- [ ] 包含章节：输入清单
- [ ] 包含章节：需求项索引（表格，至少 1 行或明确说明「无需求文档」）
- [ ] 包含章节：流水线产出存在性
- [ ] 包含章节：知识库入口索引
- [ ] code-scope / hybrid 模式时包含：代码范围索引

## 内容检查
- [ ] 复检模式为 requirement-doc / code-scope / hybrid 之一
- [ ] 流水线产出存在性表中各行状态为 present / absent
- [ ] **完整覆盖**：需求项索引行数 = 需求文档 §2.1（或等价章节）全部条目数（逐条比对，不得遗漏）
- [ ] **完整覆盖**：§4.1 覆盖统计中需求项「是否 100%」= 是（requirement-doc / hybrid 模式）
- [ ] **完整覆盖**：code-scope / hybrid 时，代码范围索引行数 = 用户指定范围内全部待检路径/文件数；§4.1 代码范围「是否 100%」= 是
- [ ] 知识库三层入口索引分别列出 code、application、business 路径及状态（present/absent/empty）
- [ ] application / business 层即使 absent 也须有独立行，不得因 code 存在而省略
- [ ] 产出中**无**质检结论、**无**「建议执行 project-archive」类行动建议（属 Step 2/3）

## 待确认项提取
- 待确认清单中的每一条
- 状态报告中的 concerns / missing-context
- 需求文档路径无法确定时的 NEEDS_CONTEXT 说明
