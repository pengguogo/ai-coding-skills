# Step 2: 单批次小节评审（L1.5）

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1.5
- type: template
- instance-by: task-batch
- instance-source: `{WORKSPACE}/code/00-task-groups.md#执行队列`
- gate-mode: per-instance

## 参数

- input_files: [`{WORKSPACE}/code/01-task-group-log-${instance-id}.md`, `{WORKSPACE}/code/00-task-groups.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-web.md`, `{DESIGN}/frontend-ios.md`, `{DESIGN}/frontend-android.md`, `{DESIGN}/frontend-hmos.md`, `{DESIGN}/frontend-h5.md`]
- output_file: `{WORKSPACE}/code/02-section-review-execution-log.md`
- output_file_per_instance: `{WORKSPACE}/code/02-section-review-${instance-id}.md`
- review_log_file: `{WORKSPACE}/review/review-log.md`
- progress_file: `{WORKSPACE}/code/section-review-progress.tsv`
- backend_review_config: `references/section-review-config-backend.md`
- frontend_review_config: `references/section-review-config-frontend.md`
- iOS_review_config: `references/section-review-config-iOS.md`
- android_review_config: `references/section-review-config-Android.md`
- hmos_review_config: `references/section-review-config-HMOS.md`
- h5_review_config: `references/section-review-config-H5.md`
- p0_backend_checklist: `skills/fullstack-code-review/references/p0/p0-backend-checklist.md`
- p0_frontend_checklist: `skills/fullstack-code-review/references/p0/p0-frontend-checklist.md`
- p0_android_checklist: `skills/fullstack-code-review/references/p0/p0-android-checklist.md`
- p0_ios_checklist: `skills/fullstack-code-review/references/p0/p0-ios-checklist.md`
- review_log_template: `skills/fullstack-code-review/references/common/review-log-template.md`
- max_fix_rounds: 2

## 执行指令

对当前批次 `${instance-id}` 的**本端变更**做小节评审。`task_group_id` = `category_id`；review-log 标题用完整 `batch_id`。

### 1. 确定审查范围

从 `01-task-group-log-${instance-id}.md` 取变更文件；**仅本端**（`BE-*` 不扫前端，`FE-*` 不扫后端）。

### 2. 后端批次（`BE-{N}`）

`code-reviewer` + `p0_backend_checklist` + `review_strategy: full` + 后端白名单。

### 3. 前端批次（`FE-{N}` / `FE-shared`）

`code-reviewer` + `p0_frontend_checklist` + 前端白名单。

### 4. iOS 批次（`iOS-{N}`）

`code-reviewer` + `iOS_review_config` 中指定的检查清单（`p0_ios_checklist`）+ iOS 白名单修复规则。

### 5. Android 批次（`Android-{N}`）

`code-reviewer` + `android_review_config` 中指定的检查清单（`p0_android_checklist`）+ Android 白名单修复规则。

### 6. HMOS 批次（`HMOS-{N}`）

`code-reviewer` + `hmos_review_config` 中指定的检查清单 + HMOS 白名单修复规则。设计对照 `frontend-hmos.md`。

### 7. H5 批次（`H5-{N}`）

`code-reviewer` + `h5_review_config` 中指定的检查清单 + H5 白名单修复规则。设计对照 `frontend-h5.md`。

### 8. 追加 review-log

`## 小节评审 ${instance-id}：{名称}（{side}）`；发现编号 `R{category_id}-{序号}`。

### 9. 更新 progress

更新当前行 `review_status` / `review_verdict`；**勿**改 `user_confirmed` 或 `gate_status=CLEARED`。

### 移交 Step 3

L1.5 通过后**必须**进入 `step-03-halt-gate.md`（同 `batch_id`）。**禁止**本步输出批次交付报告（batch-gate-protocol §9）；**禁止**同回合启动下一 batch 的 Step 1。

### 关键约束

- 仅审查本批次、本端文件。
- 评审日志增量追加，不覆盖历史章节。
