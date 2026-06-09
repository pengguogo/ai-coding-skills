# 后端接口与数据追溯（\`code-archive\` 字段参考）

> **定位**：本文件为 **\`project-archive\`** 技能包**内置参考**，用于 **\`code-archive.md\`** 中后端相关章节（接口清单、库表、\`backend-interface\` 对照、可选的 interface-detail 追溯等）的结构与深度。**不依赖** \`backend-project-archive\` 技能。下文「interface-detail 目录」等约定可作为**团队可选实践**；若与 \`backend-project-archive\` 包内 \`project_archive_standard.md\` 同源，可由团队择机同步更新。

---

# 项目归档标准（参考）

本文件为 \`project-archive\` 内置参考的**正文入口**；规范可与团队 \`sdd_standard/backend/project_archive_standard.md\` 等保持同源。

- 当外部规范更新时，建议同步更新本参考文件（按项目约定）。

## 核心约束（摘要）

- **（可选）单端归档输出目录**（仅当团队单独跑 \`backend-project-archive\` 时）：\`ocspec-<xxx>\\requirements\\<需求英文名>_<yyyymmdd>\\archive\\backend-project-archive/<change-id>/\`
- **归档内容**（单端技能场景）：可覆盖需求分析→任务→设计→规格→实现阶段相关 Markdown（及必要附件），不限定固定文件名
- **接口详细设计补充**（团队可选；\`project-archive\` 至少在 \`code-archive.md\` 中给出接口契约与追溯，不限定必须落独立文件）：
  - 常见目录（示例）：\`.../archive/backend-project-archive/<change-id>/interface-detail/\` 或团队约定路径
  - 文件：\`{Controller类名}-interface-detail.md\`
  - 已存在则追加，不存在则新建
  - 每条接口建议包含：接口 URL、入参、出参、接口说明、异常处理、时序图、依赖数据、依赖组件、事务性设计、幂等性设计
- **归档时机**（单端技能场景）：需求分析已完成、实现完成、测试通过、评审通过、文档已更新、变更验证通过
- **不包含**：不要要求提交归档变更（不输出 git add/commit/push 步骤）
- **project-spec 同步（条件性 — 必须逐项检查）**：若本期变更包含会影响 \`knowledge/code\` 下后端项目文档内容的情况，则在 \`project-archive\` 执行时同步更新相应文档。更新方式须遵循 \`unified_archive_outputs_standard.md\` 中「知识库融合更新标准流程」定义的 **5 步流程**（读取→分析→定位→融合→校验），**不得**将增量内容作为独立段落或附录直接追加到文档末尾。

  **后端知识库条件性更新检查清单**：

  | 目标文件 | 触发条件（本期存在以下任一变更即须更新） | 融合要点 |
  |----------|------------------------------------------|----------|
  | **\`backend-project.md\`** | ① 模块/目录结构变更 ② 技术栈变更 ③ 任何后端能力新增/变更 | 定位到模块说明、技术栈、能力清单等对应章节就地融合 |
  | **\`backend-interface.md\`** | ① 新增接口 ② 接口 URL/方法/入参出参变更 ③ 错误码变更 ④ 接口废弃 | 定位到接口清单对应分册/表格行就地融合 |
  | **\`backend-database.md\`** | ① 新增表 ② 字段新增/修改/删除 ③ 索引变更 ④ 表关系调整 | 定位到数据模型文档对应表章节就地融合 |
  | **\`backend-external-dependency.md\`** | ① 新增外部系统对接 ② 依赖版本变更 ③ 依赖配置调整 ④ 外部依赖废弃 | 定位到外部依赖文档对应条目就地融合 |

  **执行规则**：
  - 文件**已存在** + 本期有对应变更 → 按 5 步融合流程执行。
  - 文件**不存在** + 本期有对应变更 → 按 \`code-knowledge-init\` 内置规范**新建**。
  - 本期**无对应变更** → 在校验时注明「本期未涉及，无需更新」。