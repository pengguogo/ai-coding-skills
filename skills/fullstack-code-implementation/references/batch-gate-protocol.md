# 编码评审批次门禁协议（batch-gate-protocol）

> **权威范围**：`fullstack-code-implementation` 技能的批次解析、小节评审融合、多轮人工停轮与产出物约定。
> **调度绑定**：当 SKILL.md 声明 `halt-policy: per-batch-mandatory` 时，Scheduler 与执行 Agent **必须**与本文件及 `commands/scheduler-protocol.md` **§12**（通用停轮语义）一并遵守。
> **非全局协议**：其他技能不加载本文件，除非其 SKILL 显式引用。

---

## 1. 步骤与文件对照

| Step | 步骤文件 | Checkpoint |
|------|----------|------------|
| 0 | `steps/step-00-parse-task-groups.md` | `checkpoints/step-00-checkpoint.md` |
| 1 | `steps/step-01-task-group-coding.md` | `checkpoints/step-01-checkpoint.md` |
| 2 | `steps/step-02-section-review.md` | `checkpoints/step-02-checkpoint.md` |
| 3 | `steps/step-03-halt-gate.md` | `checkpoints/step-03-checkpoint.md` |
| 4 | `steps/step-04-final-verify-and-gate.md` | `checkpoints/step-04-final.md` |

路径前缀：`skills/fullstack-code-implementation/`。

---

## 2. 中间产物路径（requirement scope）

| 产物 | 路径 |
|------|------|
| 批次清单 | `{WORKSPACE}/code/00-task-groups.md`（含 `#执行队列`） |
| 进度表 | `{WORKSPACE}/code/section-review-progress.tsv` |
| 编码日志 | `{WORKSPACE}/code/01-task-group-log-{batch_id}.md` |
| 小节评审 | `{WORKSPACE}/code/02-section-review-{batch_id}.md` |
| 停轮闸门 | `{WORKSPACE}/code/halt-gate.md` |
| 评审日志 | `{WORKSPACE}/review/review-log.md` |
| 终局报告 | `{WORKSPACE}/code/04-verify-and-gate-report.md` |

---

## 3. 同 session 强制规则（Cursor / 执行者=调度者）

1. **单轮单批次**：一次 user→assistant 回合内，最多完成 **一个** `batch_id` 的 **Step 1 → 2 → 3**；**禁止**同回复启动第二个 `batch_id` 的 Step 1 或改其业务代码。
2. **停轮为对话终止条件**：Step 3 完成后，本回合 **必须** 以 §9 交付报告结束；其后 **禁止** 编码类工具调用、下一批工作计划或「我继续做 BE-N」类表述。
3. **启动前读闸门**：开始任意 `batch_id` 的 Step 1 前，读 `section-review-progress.tsv` 与 `halt-gate.md`：
   - `halt-gate.md` 存在且 `user_confirmed=no` → **Halt**，仅答疑/修复当前 batch/重跑评审。
   - 上一非 skipped 批次 `user_confirmed != yes` 或 `gate_status != CLEARED` → **禁止** Step 1。
4. **违规判定**：同回复内既有 §9 交付报告（批次 A）又有批次 B 的编码/评审 → **严重违规**，须致歉并停止。
5. **禁止 Agent 自确认**：仅用户本轮明确「继续」「确认」「OK」等（§10）后，方可 `user_confirmed=yes` 并清除/更新 `halt-gate.md`。

---

## 4. 批次解析（Step 0）

1. **后端清单**：`## {N}.` → `BE-{N}`；子任务 `{N}.{M}` 归属该批；不得把 `N.M` 当独立批。
2. **前端清单**：`## 功能点 {N}:`（或前端 `## {N}.`）→ `FE-{N}`；`## 共享资源任务` → `FE-shared`。
3. **禁止**跨清单映射（不得把 FE-1 并入 BE-1）。
4. 写入 `00-task-groups.md` 与 `section-review-progress.tsv`（每行 `batch_id`，`gate_status` 初始 `PENDING`）。
5. **默认执行顺序**：全部 `BE-*` 升序 → 全部 `FE-*` 升序 → `FE-shared`；依赖表可重排，但 FE 不得早于其依赖的 BE。
6. 若 `review-log.md` 不存在，按 `fullstack-code-review` 的 `review-log-template.md` 创建。

---

## 5. 单批次执行顺序

对执行队列每个 `batch_id`（未 `skipped`）：

| 顺序 | 动作 | 步骤 | 说明 |
|------|------|------|------|
| 0 | 闸门检查 | inline | 读 TSV + `halt-gate.md`；未确认则 Halt（§3 第 3 款） |
| 1 | 编码 | Step 1 实例 | 仅本端：`BE-*` 后端；`FE-*` 前端 |
| 2 | L1 Check | Step 1 产出 | step-01-checkpoint |
| 3 | 小节评审 | Step 2 实例 | P0 + `code-reviewer` |
| 4 | L1.5 Check | Step 2 产出 | step-02-checkpoint |
| 5 | 停轮闸门 | Step 3 | `halt-gate.md` + §9 交付报告 |
| 6 | 强制 Halt | Scheduler | 本回合终止 |
| 7 | 用户确认 | 用户 | §10 |
| 8 | 下一批次 | 队列下一行 | `user_confirmed=yes` 且 `gate_status=CLEARED` |

**禁止**：未确认连续多批；同回合多 `batch_id`；同实例混做 BE+FE。

---

## 6. 步骤元信息（本技能）

| 字段 | 典型值 | 含义 |
|------|--------|------|
| `gate-mode` | `per-instance` | 每 template 实例一轮门禁 |
| `halt-after` | `true` | Step 3 完成后必须 Halt |
| `user-confirm-required` | `true` | 下一 `batch_id` 前须用户确认 |
| `checkpoint-level` | `L1.5` | Step 2 评审 / Step 3 停轮 |

Step 1/2 的 template **不得**一次 Exec 跑完所有 `batch_id`；每批完成 Step 1→2→3 后须 Halt。

---

## 7. 状态机衔接（与 scheduler-protocol §3）

```
闸门检查 → Step 1 → L1 → Step 2 → L1.5(02) → Step 3 → L1.5(03) + Halt(§9)
→ 用户确认(§10) → 下一 batch Step 1 …
→ 队列完成 → Step 4 → L2 → Halt(final-gate)
```

`Next` 不得跳过 Step 3 进入下一 `batch_id` 的 Step 1。

---

## 8. Step 2 小节评审检查（L1.5）

详见 `checkpoints/step-02-checkpoint.md`、`references/section-review-verify.md`（Step 2 节）。

要点：

- `review-log.md` 追加 `## 小节评审 {batch_id}：…`
- `02-section-review-{batch_id}.md` 含合法 `review-verdict`
- progress 更新 `review_status` / `review_verdict`；**勿**提前 `user_confirmed=yes`

FAIL 且 blocking 未解决 → 交付报告标注不得进入下一批次（除非用户显式带遗留继续）。

---

## 9. 批次交付报告（Step 3 输出）

每个批次 Step 3 **必须**输出（不得省略等待确认）：

```markdown
---
[交付报告] fullstack-code-implementation · 批次 {batch_id} · {名称}（{side}）

## 本批次产出
- 编码日志：{WORKSPACE}/code/01-task-group-log-{batch_id}.md
- 小节评审：{WORKSPACE}/code/02-section-review-{batch_id}.md
- 评审记录：{WORKSPACE}/review/review-log.md（已追加 {batch_id} 章节）

## 审查结论
- 编码 Checkpoint（L1）：{X/Y 通过}
- 小节评审（L1.5）：{verdict} — blocking {a}/{fixed}/{unfixed}，important {b}
- 是否可进入下一批次：{是 / 否}（下一 batch_id：{下一行}）

## 待确认项
（按 scheduler-protocol §8.2 分类）

**请确认本批次实现与评审结果。确认后回复「继续」方可开始下一批次编码。**
```

> §9 块须为本回合 assistant **最后一段**可见正文；其后仅允许 `<!-- HALT_GATE: batch_id=… user_confirmed=no -->`。

---

## 10. 用户确认与恢复执行

| 用户回复 | Scheduler 行为 |
|----------|----------------|
| 「继续」「确认」「OK」 | `user_confirmed=yes`、`gate_status=CLEARED`；清除/更新 `halt-gate.md` → 下一 `batch_id` Step 1 |
| 「重做」「重新实现 BE-2」 | Retry 当前 batch Step 1 |
| 「修复评审问题」 | 用户修代码后 Retry Step 2 |
| 「跳过 BE-2」 | progress `skipped`；**仍须**确认后下一批 |
| 未确认 / 仅讨论 | 保持 Halt；**禁止**自置 `user_confirmed=yes` |
| 终止全流程 | 输出进度摘要后结束 |

**违规**：未确认执行下一 batch Step 1；同回合完成多个 batch Step 1（§3 第 1 款）。

---

## 11. 与 fullstack-code-review 的关系

- **小节评审**（本技能 Step 2）：按 `batch_id` 写 `review-log.md`；复用 P0 清单；可白名单修复；**不**调用 review 技能 SKILL。
- **终审**（用户单独触发 review 技能）：全部批次确认且 Step 4 通过后；已通过小节用 `supplement` 跳过 P0。

---

## 12. Halt Gate 文件（Step 3）

每批次 Step 3 写入 `{WORKSPACE}/code/halt-gate.md`：

```markdown
# Halt Gate

| 字段 | 值 |
|------|-----|
| awaiting_batch_id | {刚完成的 batch_id} |
| next_batch_id | {队列下一行，无则 NONE} |
| user_confirmed | no |
| gate_status | AWAITING_USER |
| halted_at | {ISO8601} |

<!-- HALT_GATE: batch_id={batch_id} user_confirmed=no -->
```

**Step 3 必检**：见 `checkpoints/step-03-checkpoint.md`。

**Step 1 前置**：`halt-gate.md` 且 `user_confirmed=no` → 禁止 Step 1；TSV 上一非 skipped 行须已确认。

**用户确认后**：当前行 `user_confirmed=yes`、`gate_status=CLEARED`；`halt-gate.md` 删除或标注已清除 → 方可 `next_batch_id` Step 1。
