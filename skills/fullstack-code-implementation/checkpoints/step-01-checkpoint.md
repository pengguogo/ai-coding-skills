# Checkpoint: Step 1 单批次编码

> **审查级别**：L1（结构 + 内容）

## 审查时需打开的文件

- `{WORKSPACE}/code/01-task-group-log-{batch_id}.md`（当前 template 实例）

## 检查项

- [ ] 标题含 `batch_id`（如 BE-2、FE-1）与 `side`
- [ ] `BE-*` 仅含后端子任务；`FE-*` 仅含前端任务
- [ ] 无跨 `batch_id` 任务
- [ ] 每条任务有 Done / Failed 与涉及文件
- [ ] 文件清单路径在仓库中存在
- [ ] AI 生成代码已标注 AI-Generate

## 待确认项提取

- Failed 任务原因
- STATUS_REPORT concerns
