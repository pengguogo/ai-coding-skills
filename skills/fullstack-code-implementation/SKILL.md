---
name: fullstack-code-implementation
description: 前后端编码合并技能。后端清单每个 ## N. 为一批 BE-N，前端清单每个功能点/主分类为一批 FE-N；按执行队列单端实现后小节评审并强制停轮确认。触发词：代码实现、编码实现、fullstack code、前后端编码。
base-dir-scope: requirement
halt-policy: per-batch-mandatory
max-batches-per-turn: 1
requires-user-confirm-between: batch_id
scheduler-gate-protocol: references/batch-gate-protocol.md
---

# 前后端代码实现

## 停轮协议（最高优先级）

> `scheduler-protocol.md` **§12** + `references/batch-gate-protocol.md` **§3、§9**

- 一次 user→assistant 回合内，最多完成 **一个** `batch_id` 的 **Step 1 → 2 → 3**，然后 **必须停止**。
- Step 3 输出批次交付报告（batch-gate-protocol §9）后 **不得**同回合启动下一 batch 的 Step 1。
- 用户未回复「继续」前，**禁止**将 `user_confirmed` 置为 `yes`。

## 何时使用

- `task/task-split.md` 与设计文档已齐备
- 需按各自清单主分类分批编码、评审、停轮确认

## 核心能力

- 后端 `## N.` → `BE-{N}`；前端(PC Web)功能点 → `FE-{N}` / `FE-shared`；iOS 功能点 → `iOS-{N}`；Android 功能点 → `Android-{N}`；HMOS 功能点 → `HMOS-{N}`；H5 功能点 → `H5-{N}`
- 各端批次的设计来源指向对应分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`，经入口索引 `frontend-design.md` 定位），而非 `frontend-design.md` 内嵌章节
- 执行队列默认：全部 `BE-*` → 全部 `FE-*` → 全部 `iOS-*` → 全部 `Android-*` → 全部 `HMOS-*` → 全部 `H5-*`
- 每批次：Step 1 编码 → Step 2 小节评审 → Step 3 停轮确认
- 全部批次完成后：Step 4 编译/构建终局闸门

## 执行入口

1. 读取 `scheduler-protocol.md`（§12）与 `references/batch-gate-protocol.md`
2. Init；检查 `halt-gate.md`（batch-gate-protocol §12；`user_confirmed=no` 时不得新开 Step 1）
3. 按下方 phases 与 batch-gate-protocol §1 步骤对照执行

## 与其他技能的关系

- 上游：`fullstack-design`、`task-split`
- 评审：复用 `fullstack-code-review` 的 P0 与 review-log；终审单独触发
- 下游：`project-archive`

---

## Phases

### Phase: task-batch-loop

precondition: `halt-gate.md` 存在且 `user_confirmed=no` → 不得进入 Step 1

- Step 0: `steps/step-00-parse-task-groups.md`
- Step 1: `steps/step-01-task-group-coding.md`（template，`instance-by: task-batch`）
- Step 2: `steps/step-02-section-review.md`（L1.5）
- Step 3: `steps/step-03-halt-gate.md`（inline，`halt-after: true`，**本回合在此结束**）

### Phase: final-gate

precondition: 执行队列非 skipped 批次均 `user_confirmed=yes` 且 `gate_status=CLEARED`

halt-after: true

- Step 4: `steps/step-04-final-verify-and-gate.md`

---

## 交付物

- 仓库代码变更（按 `batch_id`）
- `{WORKSPACE}/review/review-log.md`
- `{WORKSPACE}/code/section-review-progress.tsv`
- `{WORKSPACE}/code/halt-gate.md`
- `{WORKSPACE}/code/04-verify-and-gate-report.md`

## 动态分批

- Step 1/2/3 共享同一 template 实例（一个 `batch_id`）
- 每 user→assistant 回合仅一个实例
