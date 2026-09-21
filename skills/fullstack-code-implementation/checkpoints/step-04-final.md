# Checkpoint: Step 4 终局自检 + 编译/构建闸门

> **审查级别**：L2（全维度）
> **强制停止点**：终局交付，等待用户确认

## 审查时需打开的文件

- `{WORKSPACE}/code/04-verify-and-gate-report.md`
- `{WORKSPACE}/code/section-review-progress.tsv`
- `{WORKSPACE}/code/00-task-groups.md`
- `{WORKSPACE}/review/review-log.md`
- `{TASK}/task-split.md`

## 批次进度

- [ ] 报告含按执行队列的批次进度表
- [ ] 每个非 skipped 批次 `user_confirmed=yes`，`review_verdict` 为 PASS 或 PASS_WITH_NOTES
- [ ] 与 `section-review-progress.tsv` 一致

## 全量覆盖与自检

- [ ] 全量任务覆盖对照 task-split.md
- [ ] 全量自检摘要覆盖主要规范维度

## 编译/构建闸门

- [ ] 后端编译命令、结果、产物检查已记录
- [ ] 前端 lint/typecheck/build 已记录
- [ ] iOS 编译闸门已记录（若有 iOS 批次）
- [ ] Android 编译闸门已记录（若有 Android 批次）
- [ ] HMOS 编译闸门已记录（若有 HMOS 批次）
- [ ] FAIL 项有摘要与分类
- [ ] 总结含是否建议触发 `fullstack-code-review` 终审

## 待确认项提取

- 闸门 FAIL 原因
- BLOCKED 批次列表
- STATUS_REPORT concerns
