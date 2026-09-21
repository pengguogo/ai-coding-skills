# Checkpoint: Step 6 汇总判定与终审交付

> **审查级别**：L2（全维度审查）— 结构、内容、上游一致性全面校验。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。
> **强制停止点**：这是终审的交付点。汇总全部待确认项，停下来等待用户确认。

## 审查时需打开的文件
- 产出文件：`{WORKSPACE}/review/review-log.md`（终审章节）
- 产出文件：`{WORKSPACE}/review/commit-suggestion.md`（若判定通过）
- 上游比对：`{WORKSPACE}/review/summaries/02-global-compliance.summary.md`
- 上游比对：`{WORKSPACE}/review/summaries/03-backend-review.summary.md`
- 上游比对：`{WORKSPACE}/review/summaries/04-frontend-review.summary.md`
- 上游比对：`{WORKSPACE}/review/summaries/05-impact-analysis.summary.md`

## 结构检查
- [ ] review-log.md 中包含终审章节（以"## 终审"开头）
- [ ] 终审章节包含：全局设计合规检查
- [ ] 终审章节包含：跨模块检查
- [ ] 终审章节包含：全局确认清单复核
- [ ] 终审章节包含：影响分析摘要
- [ ] 终审章节包含：终审发现
- [ ] 终审章节包含：汇总统计
- [ ] 终审章节包含：最终判定
- [ ] 终审章节包含：后续动作

## 内容检查
- [ ] 终审章节在 `<!-- APPEND_HERE -->` 标记前正确插入
- [ ] 已有的小节评审章节未被修改
- [ ] 评审元信息中的"当前状态"已更新为"已完成"
- [ ] 终审发现编号使用 RF-{序号} 格式
- [ ] 每个终审发现引用了具体检查项编号

## 待确认项清零检查（终稿强制）
- [ ] review-log.md 终审章节不包含 `[需人工确认]` 标记（已全部处理或升级为终审发现）
- [ ] review-log.md 终审章节不包含 `<!-- STATUS_REPORT -->` 块
- [ ] 评审元信息中的"当前状态"已更新

## 上游一致性校验（L2 特有）
- [ ] 汇总统计中"小节评审发现"数量与 review-log.md 各小节摘要的合计一致
- [ ] 汇总统计中"小节评审已修复"数量与 review-log.md 各小节修改记录的合计一致
- [ ] 汇总统计中"终审新发现"数量与 Step 2 Summary（全局合规发现数）+ Step 3 Summary（后端发现数）+ Step 4 Summary（前端发现数）+ Step 5 Summary（影响分析发现数）的合计一致
- [ ] 汇总统计中"未解决"数量 = 小节未解决 + 终审新发现
- [ ] 最终判定与汇总统计数据一致：
  - ✅ 通过：0 blocking 未解决 + important 未解决 ≤ 2
  - ⚠️ 有条件通过：0 blocking 未解决 + important 未解决 3~5
  - ❌ 不通过：存在 blocking 未解决，或 important 未解决 > 5
- [ ] 若判定为 ✅ 通过 或 ⚠️ 有条件通过，commit-suggestion.md 已生成
- [ ] 若判定为 ❌ 不通过，commit-suggestion.md 未生成
- [ ] 若判定为 ❌ 不通过，后续动作标注"触发增量复核"而非"重新触发终审"
- [ ] commit-suggestion.md（若存在）中的文件清单覆盖所有变更文件

## 待确认项提取
- 最终判定为 ⚠️ 有条件通过 时的未解决 important 问题
- 影响分析中状态为 ❌ 的维度
