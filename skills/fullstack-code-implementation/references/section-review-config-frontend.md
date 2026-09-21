# 小节评审配置（前端）

> 供 Step 2 注入 `code-reviewer`（仅 **`FE-{N}` / `FE-shared`** 批次执行）。

## 检查项清单

| 参数 | 值 |
|------|-----|
| checklist_file | `skills/fullstack-code-review/references/p0/p0-frontend-checklist.md` |
| review_strategy | `full` |
| design_doc | `{DESIGN}/frontend-web.md`（PC Web 分端设计文件，经入口 `frontend-design.md` 定位） |

## 白名单修复规则（L1.5）

| # | 问题类型 | 修正动作 | 检查项 |
|---|---------|---------|--------|
| 1 | XSS 风险 | v-html → v-text 或 DOMPurify | FQ-DATA-04 |
| 2 | 缺少 loading 锁 | 补充 loading + disabled | FQ-RACE-03 |
| 3 | 缺少二次确认 | 补充 confirm/Modal.confirm | FQ-UX-02 |
| 4 | 硬编码敏感信息 | 替换为环境变量 | CC-SEC-01 |
| 5 | 缺少 AI-Generate 标记 | 补充注释标记 | CC-AI-01 |

## 设计章节定位

从 `00-task-groups.md` 前端主分类表读取 design 章节。

## 变更文件范围

仅审查 `01-task-group-log-FE-*.md` 中的前端(PC Web)变更；`BE-*`、`iOS-*`、`Android-*`、`HMOS-*`、`H5-*` 批次不执行本配置。
