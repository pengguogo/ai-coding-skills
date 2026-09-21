# Checkpoint: Step 3 停轮闸门（Halt Gate）

> **审查级别**：L1.5（门禁完整性）
> **协议**：`references/batch-gate-protocol.md` §9、§12；停轮语义见 `scheduler-protocol.md` §12

## 审查时需打开的文件

- `{WORKSPACE}/code/halt-gate.md`
- `{WORKSPACE}/code/section-review-progress.tsv`
- 本回合 assistant 可见回复（batch-gate-protocol §9 交付报告）

## 检查项

- [ ] `halt-gate.md` 已写入，`awaiting_batch_id` 与刚完成的 batch 一致
- [ ] `user_confirmed=no`，`gate_status=AWAITING_USER`
- [ ] 文件末尾含 `<!-- HALT_GATE: batch_id=… user_confirmed=no -->`
- [ ] progress 当前行 `gate_status=AWAITING_USER`，**未**误改 `user_confirmed=yes`
- [ ] §9 批次交付报告已输出，且为本回合**最后正文**
- [ ] 本回合**无**下一 batch 的业务代码工具调用

## 待确认项提取

- STATUS_REPORT `status: HALT` 时的 concerns
