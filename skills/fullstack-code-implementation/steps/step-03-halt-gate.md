# Step 3: 停轮闸门（Halt Gate，inline）

## 元信息

- agent: backend-coder
- execution-mode: inline
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1.5
- type: static
- halt-after: true

## 参数

- input_files: [`{WORKSPACE}/code/02-section-review-${batch_id}.md`, `{WORKSPACE}/code/section-review-progress.tsv`, `{WORKSPACE}/code/00-task-groups.md#执行队列`]
- output_file: `{WORKSPACE}/code/halt-gate.md`
- progress_file: `{WORKSPACE}/code/section-review-progress.tsv`
- batch_id: 当前刚完成 Step 2 的 `${instance-id}`（如 `BE-1`）

## 执行指令

每个 batch 在 Step 1→2 之后的**最后一步**。完成后 **必须终止本 user→assistant 回合**。

### 1. 写 halt-gate.md

按 `references/batch-gate-protocol.md` §12：

- `awaiting_batch_id` = 当前 `${batch_id}`
- `next_batch_id` = 执行队列下一行（无则 `NONE`）
- `user_confirmed` = `no`
- `gate_status` = `AWAITING_USER`
- 末尾：`<!-- HALT_GATE: batch_id={batch_id} user_confirmed=no -->`

### 2. 更新 progress TSV

当前行：`gate_status=AWAITING_USER`；**勿**将 `user_confirmed` 改为 `yes`。

### 3. 输出批次交付报告（`batch-gate-protocol.md` §9，本回合最后正文）

含产出路径、L1/L1.5 结论、是否可进下一批次、固定确认话术。

### 4. 终止自检

- [ ] `halt-gate.md` 已写入
- [ ] §9 交付报告已输出且末尾有 HALT_GATE 注释
- [ ] 本回合无下一 batch 业务代码工具调用

### STATUS_REPORT

```markdown
---
<!-- STATUS_REPORT -->
status: HALT
concerns: []
---
```
