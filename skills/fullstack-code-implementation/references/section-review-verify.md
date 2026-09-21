# 小节评审与停轮闸门检查说明

> Step 2 用 `checkpoints/step-02-checkpoint.md` + 下文「Step 2」节。
> Step 3 用 `checkpoints/step-03-checkpoint.md` + 下文「Step 3」节。

## Step 2：小节评审（L1.5）

审查文件：

- `{WORKSPACE}/code/02-section-review-{batch_id}.md`
- `{WORKSPACE}/review/review-log.md`
- `{WORKSPACE}/code/section-review-progress.tsv`
- `{WORKSPACE}/code/01-task-group-log-{batch_id}.md`

检查要点：review-log 章节、P0 发现、review-verdict、progress 中 `review_status` / `review_verdict` 已更新；**尚未** `user_confirmed=yes`。

## Step 3：停轮闸门

审查文件：

- `{WORKSPACE}/code/halt-gate.md`
- 本回合 batch-gate-protocol §9 交付报告

检查要点：`AWAITING_USER`、`user_confirmed=no`、HALT_GATE 注释、回合末无下一 batch 编码。

## 待确认项（两步合并提取）

- `[需人工处理]` / `[需全局确认]`
- FAIL 且 blocking 未解决
- STATUS_REPORT concerns
