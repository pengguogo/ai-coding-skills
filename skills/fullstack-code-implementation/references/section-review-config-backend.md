# 小节评审配置（后端）

> 供 Step 2 小节评审步骤注入 `code-reviewer`。检查项来源：`skills/fullstack-code-review/references/p0/p0-backend-checklist.md`。

## 检查项清单

| 参数 | 值 |
|------|-----|
| checklist_file | `skills/fullstack-code-review/references/p0/p0-backend-checklist.md` |
| review_strategy | `full`（小节评审始终全量 P0） |
| design_doc | `{DESIGN}/backend-design.md` |

## 白名单修复规则（L1.5）

传入 `whitelist_rules` 时启用自动修复，否则只读审查：

| # | 问题类型 | 修正动作 | 检查项 |
|---|---------|---------|--------|
| 1 | SQL 参数绑定 | `${}` → `#{}` | BE-SEC-01 |
| 2 | 缺少 rollbackFor | 补充 `rollbackFor = Exception.class` | BQ-TX-03 |
| 3 | 缺少 AI-Generate 标记 | 补充 `@AI-Generate` 注解/注释 | CC-AI-01 |
| 4 | 缺少超时配置 | 补充 timeout 参数 | BQ-RETRY-01 |
| 5 | 硬编码敏感信息 | 替换为配置引用 `${xxx}` | CC-SEC-01 / BE-CFG-02 |

## 设计章节定位

仅用于 **`BE-{N}`** 批次。设计章节从 `00-task-groups.md` 后端主分类表读取；常见映射：

| 主分类类型 | design_section 示例 |
|-----------|---------------------|
| 数据库设计 | `backend-design.md` 数据模型/DDL 章节 |
| 功能模块 | 对应模块的接口 + 领域模型章节 |
| 定时任务/集成 | 对应专项设计章节 |

## 变更文件范围

仅审查本批次 `01-task-group-log-BE-{N}.md` 中的后端变更文件，不得审查 `FE-*` 批次文件。
