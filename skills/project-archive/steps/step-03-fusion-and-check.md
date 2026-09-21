# Step 3: 知识库融合更新 + 一致性校验 [强制停止]

## 元信息

- agent: knowledge-fuser
- checkpoint: checkpoints/step-03-final.md
- checkpoint-level: L2

## 参数

- source_files: [`{ARCHIVE}/code-archive.md`, `{ARCHIVE}/appliaction-archive.md`, `{ARCHIVE}/business-archive.md`]
- target_files: [`{KNOWLEDGE}/application/`, `{KNOWLEDGE}/business/`, `{CODE_KNOWLEDGE}/frontend-project.md`, `{CODE_KNOWLEDGE}/backend-project.md`, `{CODE_KNOWLEDGE}/backend-interface/` 或 `{CODE_KNOWLEDGE}/backend-interface.md`, `{CODE_KNOWLEDGE}/backend-database/` 或 `{CODE_KNOWLEDGE}/backend-database.md`, `{CODE_KNOWLEDGE}/backend-external-dependency.md`]
- compare_files: [`{TASK}/task-split.md`, `{DESIGN}/architecture-design.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`]
- output_file: `{WORKSPACE}/archive/03-fusion-and-consistency-report.md`
- reference_files: [`references/unified_archive_outputs_standard.md`, `references/backend_project_archive_standard.md`, `../code-knowledge-init/references/backend-knowledge-layout-compat.md`]

## 执行指令

本步骤分 2 个 Part 顺序执行。

### Part 1：知识库融合更新

归档三文件已落盘，按 5 步融合流程（读取→分析→定位→融合→校验）逐个更新知识库文档。

> **融合范围限制**：`target_files` 仅包含 `code/`、`application/`、`business/` 下由技能产出的文档。**严禁**向 `{CUSTOM_KNOWLEDGE}/` 写入或融合任何内容（见 scheduler-protocol §1.5.1）。

#### 1. 融合更新 knowledge/application/
- 源：`appliaction-archive.md`
- 增量内容逐条分析并归入现有文档的对应章节与表格位置

#### 2. 融合更新 knowledge/business/
- 源：`business-archive.md`
- 增量内容逐条分析并归入现有文档的对应章节与表格位置

#### 3. 融合更新 frontend-project.md
- 源：`code-archive.md` 前端章节
- 定位到模块、路由、组件、接口调用等章节并就地补充

#### 4. 融合更新 backend-project.md
- 源：`code-archive.md` 后端章节
- 定位到对应章节并就地补充

#### 5. 条件性融合更新后端知识文件

按 `backend_project_archive_standard.md` 中的后端知识库条件性更新检查清单；**写入前**按 `backend-knowledge-layout-compat.md` 判定目标子系统实际布局（目录 / 单文件 / 平铺分册），**沿用既有布局融合**，不强制迁移存量。

| 目标（按实际布局择一） | 触发条件 | 融合要点 |
|----------|---------|---------|
| `backend-interface/`（目录）或 `backend-interface.md`（存量单文件） | 新增接口/URL变更/入参出参变更/错误码变更/接口废弃 | 目录→`index.md` 或 `{module}.md` 表格行；单文件→对应章节/表格行；目录分册须同步 index 索引表 |
| `backend-database/`（目录）或 `backend-database.md`（存量单文件） | 新增表/字段变更/索引变更/表关系调整 | 目录→`index.md` 或 `{module}.md` 表章节；单文件→对应表章节；目录分册须同步 index 索引表 |
| `backend-external-dependency.md` | 新增外部系统/依赖版本变更/配置调整/依赖废弃 | 定位到外部依赖文档对应条目就地融合 |

执行规则：目标已存在+有变更→按**既有布局**融合；目标不存在+有变更→按 code-knowledge-init 当前规范**新建目录布局**；无变更→注明「本期未涉及」。目录与单文件并存→以目录为准融合，报告标注存量单文件 `[需人工确认是否废弃]`。

### Part 2：一致性校验

按 `unified_archive_outputs_standard.md` §5.2 一致性校验检查清单逐项执行。

#### 1. 归档正文一致性（§5.2.1）

打开三份归档文件与 task-split / 设计文档，逐项检查：
- code-archive 接口名/URL 与 task-split 一致
- code-archive 需求编号与设计文档一致
- appliaction-archive 调用链与 code-archive 接口一致
- business-archive 需求追溯矩阵覆盖全部需求项
- 三份归档文件之间模块名/术语一致

#### 2. 知识库更新完整性检查清单（§5.2.2）

确认 7 项知识库文件的更新结果，每项须明确记录：已更新 / 本期未涉及。

#### 3. 交叉一致性（§5.2.3）

- 已更新的知识库文档与三份归档正文无互斥表述
- frontend-project.md、backend-project.md 已体现本期功能增量

### 产出结构

```markdown
# 知识库融合 + 一致性校验报告

## 1. 融合概览

| 目标文件 | 状态 | 增量条数 | 备注 |
|----------|------|---------|------|

## 2. 归档正文一致性

| 检查项 | 结果 | 说明 |
|--------|------|------|

## 3. 知识库更新完整性

| 检查项 | 目标文件 | 检查结果 |
|--------|----------|---------|

## 4. 交叉一致性

| 检查项 | 结果 | 说明 |
|--------|------|------|

## 5. 矛盾与遗漏清单

| 序号 | 问题 | 涉及文件 | 影响范围 | 建议 |
|------|------|---------|---------|------|

## 6. 总结
```

### 关键约束

- 严禁将增量内容作为独立段落或附录直接追加到文档末尾
- **严禁**修改、写入或融合 `{CUSTOM_KNOWLEDGE}/` 下任何文件
- 必须重新打开所有文件逐项核对，不凭记忆
- 所有检查项须给出明确结果（✅/❌）
- 矛盾与遗漏须列入清单
