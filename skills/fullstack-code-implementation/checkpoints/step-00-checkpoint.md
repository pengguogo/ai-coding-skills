# Checkpoint: Step 0 解析评审批次

> **审查级别**：L1（结构 + 内容）

## 审查时需打开的文件

- `{WORKSPACE}/code/00-task-groups.md`
- `{WORKSPACE}/code/section-review-progress.tsv`

## 检查项

- [ ] 含「后端主分类表」，每行 `batch_id` 为 `BE-{N}`
- [ ] 含「前端主分类表」，每行 `batch_id` 为 `FE-{N}` 或 `FE-shared`
- [ ] 含「执行队列」，`seq` 连续；**无**「前端映射到 BE-N」合并表
- [ ] `section-review-progress.tsv` 行数 = 执行队列批次数
- [ ] 解析摘要中后端/前端主分类数量与两表一致

## 待确认项提取

- 依赖重排说明中的 `[需人工确认]`
- STATUS_REPORT concerns / missing-context
