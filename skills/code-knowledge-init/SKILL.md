---
name: code-knowledge-init
description: 统一执行代码知识还原与初始化：识别目标代码库的前端/后端/一体化/移动端/跨端属性，并生成对应的 knowledge/code 文档产出。5 步分步执行。
  触发词：代码知识还原、初始化代码知识、生成项目文档、分析代码库、code knowledge、初始化 knowledge/code。
base-dir-scope: ocspec-root
---

# 代码知识还原

## 目的

从源码和构建配置中提取结构化信息，生成标准化代码知识文档，作为知识流水线的起点。

## 何时使用

- 用户要求初始化或还原代码知识库
- 用户要求生成项目级代码知识文档
- 用户只说"分析这个项目""生成项目说明""生成 code knowledge""初始化 knowledge/code"
- 用户未明确指定只做前端还是后端，需要先识别项目属性再决定产出
- 用户明确指定前端或后端，但仍需要统一按标准扫描并生成文档

**不适用场景**：纯配置项目（无业务源码）、无源码的二进制依赖分析、仅需业务架构或应用架构总览（应使用 application-knowledge-init 或 business-knowledge-init）。

## 核心能力

- 识别目标代码库的前端、后端或一体化属性
- 扫描技术栈、目录结构、模块、接口、数据模型和外部依赖
- 生成标准化 `knowledge/code/` 文档与 `scan-plan.md`
- 支持全量扫描、增量扫描和多目标分批/并行扫描

## 执行原则

- **源码驱动（强制）**：不臆造输入中不存在的模块、接口、目录、配置项或版本信息
- **项目实际为准**：与通用规范冲突时显式标注差异；若仓库已有更强项目约束，优先遵循项目约束
- **不确定标注**：无法确认的信息标记 [需人工确认]；可从代码推断的内容不得以此占位
- **全量列出**：不得省略，不得以"等"代替完整列表
- **扫描流程合规**：严格遵循 unified-scan-task-template.md 定义的扫描注册表和执行流程

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/unified-scan-task-template.md` | 通用扫描流程：注册表、策略决策、门禁规则、scan-plan 格式 |
| `references/backend/project-spec/backend-module.md` | 后端项目设计：目录结构、模块划分、核心业务流程 |
| `references/backend/project-spec/backend-database.md` | 后端数据模型：表结构、ER 图、字段规范 |
| `references/backend/project-spec/backend-interface.md` | 后端接口清单：Controller 扫描、接口表格规范 |
| `references/backend/project-spec/backend-external-dependency.md` | 后端外部依赖：业务系统、第三方服务、基础设施 |
| `references/frontend/project_init_standard.md` | 前端文档结构、接口清单、目录结构、技术栈与开发约束细则 |
| `script/*.ps1` | 扫描脚本（由注册表按技术栈匹配调用） |

## 路径与目录约定

- **权威来源**：`scheduler-protocol.md` §1（含 §1.6 **`ocspec-root` scope**）
- **Init 机械门禁（§1.2.1）**：必须先 `Get-ChildItem ... -like 'ocspec-*'` 并记录 `OCSPEC_SCAN_RAW`。**扫描结果非空 → 必须用已有候选，严禁兜底新建**。仅当扫描输出**为空**时方可 §1.2.2（使用协议规定的兜底目录名）。
- `{BASE_DIR}` = `{OCSPEC_ROOT}`；`{WORKSPACE}` = `{KNOWLEDGE}/_workspace/`（**非** `{OCSPEC_ROOT}/_workspace/`）
- **终稿**：`{CODE_KNOWLEDGE}/`（Init 后由 Scheduler 注入，勿写死 `ocspec-<xxx>`）
- **中间产物**：`{WORKSPACE}/code/`（及 `summaries/`）
- **禁止**：在已有 `ocspec-*` 时再建并行目录、用项目名拼 `ocspec-<仓库名>`、工作区根 `knowledge/` 或根 `_workspace/`（无 ocspec 时的唯一新建见 §1.2.2）

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. **Init（不可跳过）**：
   - 在工作区根执行：`Get-ChildItem -LiteralPath '<工作区根>' -Directory | Where-Object { $_.Name -like 'ocspec-*' } | Select-Object -ExpandProperty Name`
   - 若输出非空 → `{OCSPEC_ROOT}` = 该候选路径，**禁止**兜底新建或其它并行 `ocspec-*`
   - 仅当输出为空 → 方可 §1.2.2 兜底新建
   - 输出 `[路径解析]`（含 `OCSPEC_SCAN_RAW`）后，再替换步骤中的 `{变量}`
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

## 与其他技能的关系

- 上游：无。本技能是知识流水线的起点，直接从源码和构建配置提取信息
- 下游：application-knowledge-init 和 business-knowledge-init 依赖本技能产出的代码基线
- 职责分界：本技能产出的"核心业务流程"是代码级调用链（入口层→编排层→领域层→数据层），business-knowledge-init 产出的是业务级流程（阶段→活动→任务→步骤）

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

**下游消费说明**：

| 交付物 | 下游必需章节 | 消费方 |
|--------|-------------|--------|
| `backend-project.md` | §3.1 核心业务流程（代码级调用链）、§3.2 业务模块、§2 项目目录结构（含 §2.1 分层归类） | `application-knowledge-init`（基于 §2 和 §3.2 推导 AG-*/APP-*）、`business-knowledge-init`（基于 §3.1 推导业务级流程） |
| `backend-interface/` | 入口 `index.md`（§2.0 单文件全文 或 §2.3 分册索引）；分册详见 `{module}.md` | `application-knowledge-init`（前后端集成表）、`business-knowledge-init`（业务场景 S-* 追溯） |
| `backend-database/` | 入口 `index.md`（§2.0 单文件全文 或 §2.3 分册索引）；分册详见 `{module}.md`、`er-diagram.md` | `business-knowledge-init`（领域对象 DO-* 推导） |

**存量兼容**：下游读取/融合时须同时支持目录布局与存量单文件（`backend-interface.md`、`backend-database.md`），规则见 `references/backend-knowledge-layout-compat.md`。新扫描产出仅目录布局；存量迁移由增量/全量 `code-knowledge-init` 触发，archive 等步骤不强制迁移。
| `backend-external-dependency.md` | 外部系统调用清单 | `application-knowledge-init`（跨系统集成点） |
| `frontend-project.md` | §四 接口调用清单、§三 业务功能模块（含路由结构） | `application-knowledge-init`（前后端串联分析） |

---

## Phases

### Phase: identification

halt-after: false

- Step 1: steps/step-01-scan-target.md
- Step 2: steps/step-02-tech-detect.md

### Phase: backend-generation

halt-after: false
precondition: Step 2 识别结果包含后端特征（后端项目或一体化项目）

- Step 3: steps/step-03-backend-scan.md

### Phase: frontend-generation

halt-after: false
precondition: Step 2 识别结果包含前端特征（现代 Web / 传统一体化前端 / Android 客户端 / 鸿蒙客户端 / iOS 客户端 / 跨端或小程序）

- Step 4: steps/step-04-frontend-scan.md

### Phase: delivery

halt-after: true

- Step 5: steps/step-05-self-check.md

---

## 交付物

- `{CODE_KNOWLEDGE}/backend-project.md`
- `{CODE_KNOWLEDGE}/backend-database/`（入口 `index.md`；§2.0 单文件全文 或 §2.3 分册索引 + `{module}.md`）
- `{CODE_KNOWLEDGE}/backend-interface/`（入口 `index.md`；§2.0 单文件全文 或 §2.3 分册索引 + `{module}.md`）
- `{CODE_KNOWLEDGE}/backend-external-dependency.md`
- `{CODE_KNOWLEDGE}/frontend-project.md`
- `{CODE_KNOWLEDGE}/scan-plan.md`（扫描元数据，保留）

产出格式：UTF-8 Markdown，仅使用简体中文，结构与字段严格遵循 references/ 下对应规范。

## Summary 机制

步骤 1、2 的产出有下游依赖，需生成精简摘要供 subagent 模式使用。

使用规则：
- subagent 模式：下游步骤读 input_files_subagent 中的 Summary
- 同 session 模式：下游步骤读 input_files 中的完整产出

兜底规则：
- 若下游步骤返回 NEEDS_CONTEXT 且 missing-context 指向上游 Summary 省略的信息
- Scheduler 从完整产出中提取相关片段（≤1500 字），注入后重试一次

## 动态分批规则

步骤 3 为 template 类型（instance-by: doc-type，instance-mode: fixed，固定 4 实例），跳过 scheduler-protocol.md §3.4 的第 1~5 步（动态分组），直接从第 6 步开始为每个实例注入分配信息。

每个实例执行独立的扫描+文档生成流程，直接写入最终交付路径。

## 多目标并行策略

用户可选择多个扫描目标（逗号分隔），每个目标独立走完整的 Step 1→5 流程：
- 2-3 个目标：可委托子代理并行执行，产出目录独立不冲突
- 4 个及以上：按 2-3 个一批分批并行
- 单个目标内部步骤仍为顺序执行

## 步骤执行条件（precondition 机制）

采用与 fullstack-design 相同的 precondition 机制（而非自创"条件跳过规则"），由 Scheduler 在 Phase 入口检查 precondition 是否满足：

- Phase: backend-generation 的 precondition：Step 2 识别结果包含后端特征
  - 纯前端项目 → precondition 不满足 → 跳过整个 Phase（Step 3 不执行）
  - 后端项目或一体化项目 → precondition 满足 → 执行 Step 3
- Phase: frontend-generation 的 precondition：Step 2 识别结果包含前端特征
  - 纯后端项目 → precondition 不满足 → 跳过整个 Phase（Step 4 不执行）
  - 现代 Web、传统一体化前端、Android/鸿蒙/iOS 客户端、跨端或小程序 → precondition 满足 → 执行 Step 4
- Phase: delivery 无 precondition → 始终执行 Step 5

这与 fullstack-design 的 `precondition: design/backend-design.md 必须已存在` 是同一机制，不需要在 scheduler-protocol 中新增"条件跳过"扩展。

## 增量扫描规则

当产出目录中已存在 scan-plan.md 时，Step 2 须判断是否执行增量扫描：

增量变更判断标准（来自原始 SKILL.md 步骤 5）：
- 构建配置变更 → 重新执行技术栈探测（Step 2 全量）。须按项目类型检查对应文件：后端 `pom.xml`/`build.gradle*`；Web/跨端 `package.json` 及锁文件；Android `build.gradle(.kts)`/`libs.versions.toml`；鸿蒙 `oh-package.json5`/`build-profile.json5`；iOS `Podfile.lock`/`Package.resolved`/Xcode 工程；Flutter `pubspec.yaml`/`pubspec.lock`
- 文件数量变更（探针命中文件数与 scan-plan.md 记录偏差 > 20%）→ 重新执行该扫描项
- 文件内容变更（若可获取 `git diff --name-only {last_scan_commit}`）→ 仅重新扫描变更文件所属的扫描项
- 无法判断时 → 全量重新执行

增量模式下：
- scan-plan.md 的 YAML front matter 中 scan_type 设为 incremental，previous_scan 填上次 scan-plan.md 路径
- Step 3/4 仅重新执行有变化的扫描项，保留未变化项的历史状态
- Step 5 校验时对比增量前后的产出差异
