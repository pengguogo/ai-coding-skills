# Step 1: 输入收集 + 编写 code-archive.md

## 元信息

- agent: archive-writer
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{REQ}/requirement.md`, `{DESIGN}/architecture-design.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{TASK}/task-split.md`, `{CODE_KNOWLEDGE}/backend-project.md`, `{CODE_KNOWLEDGE}/frontend-project.md`, `{KNOWLEDGE}/application/`, `{KNOWLEDGE}/business/`, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- output_file: `{ARCHIVE}/code-archive.md`
- analysis_output_file: `{WORKSPACE}/archive/01-input-summary.md`
- reference_files: [`references/unified_archive_outputs_standard.md`, `references/backend_project_archive_standard.md`, `references/frontend_project_archive_standard.md`]

## 执行指令

本步骤分 2 个 Part 顺序执行。

### Part 1：收集输入与上下文对齐（写入 analysis_output_file）

1. 读取需求文档，提取需求项、范围、优先级
2. 读取 `{DESIGN}/architecture-design.md`，提取应用清单、应用×功能点改造矩阵、应用内模块清单（§5），作为应用层归档与模块归属依据
3. 读取 `{DESIGN}/backend-design.md`，提取接口清单、数据模型变更、外部依赖
4. 读取 `{DESIGN}/frontend-design.md`，提取页面/路由/组件变更、状态管理
5. 读取 `{TASK}/task-split.md`，对齐后端/前端任务与接口映射
6. 读取知识库文件（backend-project.md、frontend-project.md 等），记录存在状态与现有内容摘要
7. 读取 `{KNOWLEDGE}/application/`、`{KNOWLEDGE}/business/` 既有沉淀
8. 若 `CUSTOM_KNOWLEDGE_STATUS=present`：只读引用 `{CUSTOM_KNOWLEDGE}/` 下相关文档作为归档对照；若 `absent` 则跳过，不 Halt
9. 若仓库中已有实际代码变更，提取新增/修改文件信息
10. 汇总待确认项

产出结构：

```markdown
# 归档输入摘要

## 1. 需求概览（需求项列表表格）
## 2. 后端实现要点（接口清单、数据模型变更、外部依赖）
## 3. 前端实现要点（页面/路由/组件变更、状态管理）
## 4. 知识库现状（已有文件清单、与本期设计的差异点）
## 5. 实际实现内容（新增/修改文件，若已编码）
## 6. 待确认清单
```

### Part 2：编写 code-archive.md

基于 Part 1 的输入摘要与设计/任务拆分文档，按 `unified_archive_outputs_standard.md` §1 的章节结构编写。

#### 必备章节

1. **归档信息**：需求目录、归档时间、覆盖范围、关联文档路径
2. **需求与范围摘要**：需求概述 + 需求项对照表
3. **实现路径（前后端）**：后端按模块/接口组列出，前端按功能点/路由列出
4. **接口与契约**：接口清单表 + 与知识库接口清单对照（按 compat 规范：目录 `backend-interface/` 或存量 `backend-interface.md`）
5. **数据与存储**：表结构/字段变更摘要 + 与数据模型对照（按 compat 规范：目录 `backend-database/` 或存量 `backend-database.md`）
6. **前端代码与工程侧**：目录/路由/组件变更摘要 + frontend-project.md 增量说明
7. **实际实现内容**：新增/修改文件表（若已编码）
8. **开放问题（实现侧）**

### 关键约束

- 字段深度参照 frontend_project_archive_standard.md 和 backend_project_archive_standard.md
- 所有结论须可追溯到需求/设计/task-split/知识库
- 无信息时写「无」或 `[需人工确认]`，禁止留空壳标题
