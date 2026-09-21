# 小节评审配置（H5）

> 供 Step 2 小节评审步骤注入 `code-reviewer`（仅 **`H5-{N}`** 批次执行）。

## 检查项清单

| 参数 | 值 |
|------|-----|
| checklist_file | `skills/fullstack-code-review/references/p0/p0-frontend-checklist.md`（H5 为 Web 技术栈，前端 P0 清单直接适用） |
| review_strategy | `full` |
| design_doc | `{DESIGN}/frontend-h5.md`（H5 分端设计文件，经入口 `frontend-design.md` 定位） |

## 白名单修复规则（L1.5）

| # | 问题类型 | 修正动作 | 检查项 |
|---|---------|---------|--------|
| 1 | XSS 风险 | v-html → v-text 或 DOMPurify | FQ-DATA-04 |
| 2 | 缺少 loading 锁 | 补充 loading + disabled | FQ-RACE-03 |
| 3 | 缺少二次确认 | 补充 confirm/Dialog 确认 | FQ-UX-02 |
| 4 | 硬编码敏感信息 | 替换为环境变量 | CC-SEC-01 |
| 5 | 缺少 AI-Generate 标记 | 补充注释标记 | CC-AI-01 |

## 设计章节定位

从 `00-task-groups.md` H5 主分类表读取 design 文件（`frontend-h5.md`）与功能点。

## 变更文件范围

仅审查 `01-task-group-log-H5-{N}.md` 中的 H5 变更文件；`BE-*`、`FE-*`、`iOS-*`、`Android-*`、`HMOS-*` 批次不执行本配置。
