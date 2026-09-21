# Checkpoint: Step 2 单批次小节评审

> **审查级别**：L1.5
> **详细规则**：`references/section-review-verify.md`（仅 Step 2 章节）
> **协议**：`references/batch-gate-protocol.md` §8（不含 Halt Gate，见 `step-03-checkpoint.md`）

## 审查时需打开的文件

- `{WORKSPACE}/code/02-section-review-{batch_id}.md`
- `{WORKSPACE}/review/review-log.md`
- `{WORKSPACE}/code/section-review-progress.tsv`
- `{WORKSPACE}/code/01-task-group-log-{batch_id}.md`

## 检查项

- [ ] review-log 已追加 `## 小节评审 {batch_id}：…` 章节
- [ ] 审查范围、设计一致性、发现/小结齐全
- [ ] STATUS_REPORT 含 `review-verdict`（PASS / PASS_WITH_NOTES / FAIL）
- [ ] progress 中当前 `batch_id` 的 `review_status`、`review_verdict` 已更新
- [ ] **未**在本步将 `user_confirmed` 置为 `yes`（确认在 Step 3）

## 待确认项提取

- `[需人工处理]` / `[需全局确认]` 标记
- FAIL 且 blocking 未解决
