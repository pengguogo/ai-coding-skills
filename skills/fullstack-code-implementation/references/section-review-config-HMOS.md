# 小节评审配置（HMOS 鸿蒙）

> 供 Step 2 小节评审步骤注入 `code-reviewer`（仅 **`HMOS-{N}`** 批次执行）。

## 检查项清单

| 参数 | 值 |
|------|-----|
| checklist_file | `skills/fullstack-code-review/references/p0/p0-frontend-checklist.md`（临时基线：ArkTS 为声明式 TS，通用前端 P0 项适用；鸿蒙原生专项在专用 P0 清单落地前，以通用编码规范 CC-* 项与本配置白名单补充） |
| review_strategy | `full`（小节评审始终全量 P0） |
| design_doc | `{DESIGN}/frontend-hmos.md`（鸿蒙分端设计文件，经入口 `frontend-design.md` 定位） |

## 白名单修复规则（L1.5）

传入 `whitelist_rules` 时启用自动修复，否则只读审查：

| # | 问题类型 | 修正动作 | 检查项 |
|---|---------|---------|--------|
| 1 | 缺少 AI-Generate 标记 | 补充 `// AI-Generate` 注释 | CC-AI-01 |
| 2 | 主线程耗时操作 | 移至 TaskPool/Worker 或异步 Promise | 性能项 |
| 3 | 资源/订阅未释放 | 在 `aboutToDisappear` 取消订阅/定时器 | 生命周期项 |
| 4 | 硬编码敏感信息 | 替换为安全存储/配置引用 | CC-SEC-01 |

## 设计章节定位

从 `00-task-groups.md` HMOS 主分类表读取 design 文件（`frontend-hmos.md`）与功能点。

## 变更文件范围

仅审查 `01-task-group-log-HMOS-{N}.md` 中的鸿蒙变更文件；`BE-*`、`FE-*`、`iOS-*`、`Android-*`、`H5-*` 批次不执行本配置。
