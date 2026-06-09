---
name: code-knowledge-init
description: 统一执行代码知识还原与初始化：识别目标代码库的前端/后端/一体化属性，并生成对应的 \`knowledge/code\` 文档产出。适用于初始化代码知识、还原项目知识、生成项目文档、分析代码库等场景。
---

# 代码知识还原

## 何时使用

- 用户要求初始化或还原代码知识库。
- 用户要求生成项目级代码知识文档。
- 用户只说"分析这个项目""生成项目说明""生成 code knowledge""初始化 knowledge/code"。
- 用户未明确指定只做前端还是后端，需要先识别项目属性再决定产出。
- 用户明确指定前端或后端，但仍需要统一按标准扫描并生成文档。

**不适用场景**：纯配置项目（无业务源码）、无源码的二进制依赖分析、仅需业务架构或应用架构总览（应使用 \`application-knowledge-init\` 或 \`business-knowledge-init\`）。

## 规范来源

| 参考文件 | 用途 |
|----------|------|
| \`references/frontend/project_init_standard.md\` | 前端文档结构、接口清单、目录结构、技术栈与开发约束细则 |
| \`references/backend/project-spec/backend-module.md\` | 后端项目设计：目录结构、模块划分、核心业务流程 |
| \`references/backend/project-spec/backend-database.md\` | 后端数据模型：表结构、ER 图、字段规范 |
| \`references/backend/project-spec/backend-interface.md\` | 后端接口清单：Controller 扫描、接口表格规范 |
| \`references/backend/project-spec/backend-external-dependency.md\` | 后端外部依赖：业务系统、第三方服务、基础设施 |
| \`references/unified-scan-task-template.md\` | 通用扫描流程：注册表、策略决策、门禁规则、scan-plan 格式 |
| \`script/*.ps1\` | 扫描脚本（由注册表按技术栈匹配调用）：controller-scan、dubbo-scan、entity-scan、model-scan、mapper-xml-scan |

产出为 **UTF-8 Markdown**。字段与章节结构以对应 \`references/\` 规范为准；扫描流程以 \`unified-scan-task-template.md\` 为准。

## 执行原则

- 不臆造输入中不存在的模块、接口、目录、配置项或版本信息。
- 以项目实际结构为准；与通用规范冲突时显式标注差异。若仓库已有更强项目约束，优先遵循项目约束。
- 无法确认的信息标记 \`[需人工确认]\`；可从代码推断的内容不得以此占位（分级规则见 \`unified-scan-task-template.md §4\`）。

---

## 执行流程

### 步骤 1：确定扫描目标

**目标**：明确本次要分析的工程根，避免把多个独立工程混成一个项目。

**动作**：

1. 优先使用用户明确指定的仓库根、模块根或子工程根。
2. 若用户未指定，扫描当前工作区根下的所有一级目录，识别包含 \`pom.xml\` / \`build.gradle*\` / \`build.xml\` / \`package.json\` 的目录作为候选代码库，列出清单并询问用户选择。
3. **多选支持**：用户可选择一个或多个目标（逗号分隔），每个目标独立走完整的步骤 2→6 流程。
4. **并行策略**：2-3 个目标时可委托子代理并行执行，产出目录独立不冲突；4 个及以上按 2-3 个一批分批并行。单个目标内部步骤仍为顺序执行。
5. 若是 monorepo 或多模块仓库，先识别当前任务真正对应的工程根，不得将子模块误判为独立工程。

**检查点**：
- 候选代码库清单必须来自实际目录扫描，不得凭印象列举。
- 用户选择后，每个目标的扫描结果独立产出，不得混合。
- 若存在多个候选工程且无法判断归属，应列出候选并标注 \`[需人工确认]\`。

---

### 步骤 2：识别项目属性

**目标**：判断目标工程属于前端、后端、前后端未分离（一体化），还是前后端分离场景下的单端工程。

**动作**：

1. 识别现代前端特征：\`package.json\`、前端构建工具（Webpack/Vite/Rollup 等）、页面与组件目录、前端框架依赖（Vue/React/Angular 等）。
2. 识别传统前端特征（无 \`package.json\` 的一体化项目）：模板引擎文件（\`.jsp\`、\`.ftl\`、\`.html\`、\`.vm\`、Thymeleaf \`.html\` 等）、静态资源目录（\`webapp/\`、\`static/\`、\`resources/static/\`、\`resources/templates/\` 等）、内嵌 JavaScript/CSS 文件、前端资源引用（\`<script>\`、\`<link>\` 标签）。
3. 识别后端特征：\`pom.xml\`、\`build.gradle*\`、\`build.xml\`、\`src/main/java\`、\`application*.yml\`、后端分层目录等。
4. 判断一体化 vs 分离：同一工程同时承载页面与接口且没有清晰独立的前后端工程边界时为一体化项目；仓库中存在独立前端工程根与独立后端工程根时为分离项目，仅对当前目标工程执行对应一端产出。
5. 读取 XML 格式构建配置文件（\`pom.xml\`、\`build.xml\`）时，须先过滤注释再解析，避免编码问题。

**检查点**：
- 前端项目只进入前端路径；后端项目只进入后端路径（包含 Ant 构建项目）；一体化项目同时进入前后端路径。
- 一体化项目必须同时产出前后端文档；不因缺少 \`package.json\` 而跳过前端文档生成；不将分离项目误判为一体化项目。

---

### 步骤 3：技术栈探测与文件统计

**目标**：基于项目实际技术栈和规模，为扫描策略选择提供数据基础。

**动作**：

1. 读取构建配置提取语言、框架、ORM 信息（如 pom.xml 中的 spring-boot-starter-web、dubbo、mybatis-plus 等依赖）。
2. 用 grepSearch 按 \`references/unified-scan-task-template.md\` 注册表中的识别标记统计目标文件数量（文件探针）。
3. 查询注册表匹配可用扫描器。

**检查点**：
- 技术栈信息必须来自实际构建配置文件，不得凭印象判断。

---

### 步骤 4：扫描策略选择与 scan-plan 生成

**目标**：基于步骤 3 的统计数据选择最优扫描策略，生成可执行的扫描计划。

**动作**：

1. 按 \`unified-scan-task-template.md §2\` 扫描执行流程的步骤 A-C 生成 scan-plan（注册表子集确定 → 逐行探针 → 同源合并与策略选择，详见该文档）。
2. 在产出目录生成 \`scan-plan.md\`（格式见 \`unified-scan-task-template.md §2 步骤 C\`）。
3. 脚本执行前须检测当前环境是否支持 PowerShell（\`pwsh --version\`）：支持则直接执行 \`.ps1\` 脚本；不支持则将脚本逻辑转换为等价的 Bash（优先）或 Python 脚本后执行，转换后须保持相同的输出格式。
4. 脚本执行失败时：排查原因重试（最多 2 轮）；仍失败则切换为 AI 直接扫描（grepSearch + readCode），产出标准不变，须通过 §2 步骤 E 全部合理性检查。
5. **大型项目策略**（目标文件总数 > 200 或模块数 > 20）：按 \`unified-scan-task-template.md §2 步骤 D\` 大型项目策略执行。
6. 前端路径统一走 AI 直接扫描，无需脚本。

**检查点**：
- 策略选择必须基于实际文件统计，不得凭印象判断。
- 所有策略均须执行完整性围栏校验（见 \`unified-scan-task-template.md\`）。
- 生成 \`backend-interface.md\`、\`backend-database.md\`、\`backend-external-dependency.md\` 时，必须严格遵循 \`unified-scan-task-template.md\` 定义的通用扫描流程，其中所有红线（§2 步骤 A-E、§5）同等生效。

---

### 步骤 5：执行扫描与文档生成

**目标**：按识别结果和扫描计划生成对应代码知识文档。

**动作**：

1. **执行 scan-plan**：按 scan-plan.md 逐项执行扫描，每完成一项回写状态和实际产出数。执行完毕后运行 §2 步骤 E 合理性检查，不通过的项按修复策略处理（见 \`unified-scan-task-template.md §2 步骤 E\`）。
2. **后端路径**：生成或更新 \`backend-project.md\`、\`backend-database.md\`、\`backend-external-dependency.md\` 与 \`backend-interface.md\`。对于 Maven/Gradle 多模块项目，\`backend-project.md\` 中须包含模块依赖图（Mermaid graph TB）。
3. **后端文档生成顺序**：必须先生成 \`backend-interface.md\` 和 \`backend-database.md\`（含脚本扫描），再生成 \`backend-project.md\`。这样 \`backend-project.md\` 的模块划分（§3.1 核心业务流程、§3.2 业务模块）可直接引用接口扫描和数据模型扫描的结果。若因执行顺序原因 \`backend-project.md\` 先于接口/数据模型文档生成，须在后续补充校验一致性。
4. **前端路径**：生成或更新 \`frontend-project.md\`。
5. **一体化路径**：在同一项目目录下同时生成前端与后端产出。对于无 \`package.json\` 的传统一体化项目，前端文档按 \`references/frontend/project_init_standard.md\` 中的"传统一体化项目适配"规则生成。
6. **增量场景**：若已有产出，根据用户意图执行全量或部分更新。增量场景下，读取已有 scan-plan.md 对比变更，仅重新执行有变化的扫描项，保留未变化项的历史状态。增量变更判断标准：
   - 构建配置变更（pom.xml/build.gradle 依赖项变化）→ 重新执行技术栈探测（步骤 3）
   - 文件数量变更（探针命中文件数与 scan-plan.md 记录偏差 > 20%）→ 重新执行该扫描项
   - 文件内容变更（若可获取 \`git diff --name-only {last_scan_commit}\`）→ 仅重新扫描变更文件所属的扫描项
   - 无法判断时 → 全量重新执行

**检查点**：
- 输出范围与项目识别结果一致。
- 一体化项目必须同时覆盖前后端。
- 分离项目不得强行补齐不属于当前工程的一端文档。

---

### 步骤 6：生成后自检与路径校验

**目标**：确保文档可用、结构正确、事实可追溯，且产出路径正确。

**输出路径自检（在写文件前必须执行）**：

1. **定位知识库仓库**：在工作区中查找 \`ocspec-<xxx>/\` 根目录（\`ocspec-\` 开头的文件夹，内含 \`knowledge/\` 子目录）。
2. **确认目标路径**：产出路径必须为 \`ocspec-<xxx>/knowledge/code/<项目名>/\`。**禁止**在工作区根目录或其他位置新建 \`knowledge/\` 文件夹。
3. **首次创建检查**：若目标目录不存在，属于正常情况（首次初始化），在知识库仓库内创建即可。

**内容自检动作**：

1. 检查产出路径与文件名是否符合约定。
2. 检查产出语言是否为简体中文。
3. 检查模块、接口、目录、配置、版本等信息是否来自实际代码与配置。
4. 检查不确定项是否明确标注 \`[需人工确认]\`。
5. 检查 \`*-scan-result.md\` 中间文件已删除，不残留在产出目录中（scan-plan.md 保留作为扫描元数据）。
6. 检查核心业务流程是否基于全量代码扫描产出，覆盖了项目中通过入口层扫描识别到的所有业务流程，而非仅举例或列出部分流程。
7. 检查每条核心业务流程是否附带了 Mermaid 时序图或流程图。
8. 检查入口层完整性自检是否已执行（根包扫描、启动类追踪、配置文件追踪），且核心业务流程已覆盖入口层中的所有入口类；未覆盖的入口须补充流程或标注为"非业务入口"并说明理由。（"入口层"指 \`backend-project.md\` 规范中的 §2.1/§2.4 章节）
9. 不得在文档末尾添加任何降级说明。

**检查点**：
- 文档结构与对应 \`references/\` 规范一致。
- 没有遗漏必须产出的文档类型。
- 没有臆造不存在的模块、接口、配置项或版本信息。
- 核心业务流程数量与实际扫描到的业务流程数量一致，无遗漏。
- 入口层完整性自检已执行，核心业务流程已覆盖入口层中的所有入口类。

---

## 输出与交付物

- **产出目录**：\`ocspec-<xxx>/knowledge/code/<项目名>/\`
- **前端交付物**：\`frontend-project.md\`
- **后端交付物**：\`backend-project.md\`、\`backend-database.md\`、\`backend-external-dependency.md\`、\`backend-interface.md\`
- **产出格式**：UTF-8 Markdown，仅使用简体中文，结构与字段严格遵循 \`references/\` 下对应规范。
- **更新策略**：首次生成或用户要求全量时补齐全部文档；已存在产出时按用户要求执行全量或部分更新。

**下游消费说明**：

| 交付物 | 下游必需章节 | 消费方 |
|--------|-------------|--------|
| \`backend-project.md\` | §3.1 核心业务流程（代码级调用链）、§3.2 业务模块、§2 项目目录结构（含 §2.1 分层归类） | \`application-knowledge-init\`（基于 §2 项目目录结构和 §3.2 模块名推导 AG-*/APP-*）、\`business-knowledge-init\`（基于 §3.1 代码级调用链推导业务级流程） |
| \`backend-interface.md\` | 全部接口清单（按功能模块 × Controller 组织） | \`application-knowledge-init\`（前后端集成表）、\`business-knowledge-init\`（业务场景 S-* 追溯） |
| \`backend-database.md\` | §1.1 表结构设计（全量表清单）、§2.2 表关系（ER 图） | \`business-knowledge-init\`（领域对象 DO-* 推导） |
| \`backend-external-dependency.md\` | 外部系统调用清单 | \`application-knowledge-init\`（跨系统集成点） |
| \`frontend-project.md\` | §四 接口调用清单、§三 业务功能模块（含路由结构） | \`application-knowledge-init\`（前后端串联分析） |

## 与其他技能的关系

- **上游**：无。本技能是知识流水线的起点，直接从源码和构建配置提取信息。
- **下游**：\`application-knowledge-init\` 和 \`business-knowledge-init\` 依赖本技能产出的代码基线。\`application-knowledge-init\` 基于 \`backend-project.md\` 的工程结构和模块名推导应用组（AG-*）与可部署应用（APP-*）；\`business-knowledge-init\` 基于核心业务流程和实体清单推导业务场景（S-*）与领域对象（DO-*）。
- **职责分界——"核心业务流程"**：本技能在 \`backend-project.md\` §3.1 中产出的"核心业务流程"是**代码级调用链**（入口层 → 编排层 → 领域层 → 数据层的方法调用时序），用于描述代码如何执行。\`business-knowledge-init\` 产出的"业务流程"是**业务级流程**（阶段 → 活动 → 任务 → 步骤的业务语义编排），用于描述业务如何运转。前者是后者的推导输入，两者粒度和视角不同，不构成重复。