# 业务领域知识文档标准

本文档整合业务领域知识生成的总则与规范索引，定义 `knowledge/business/` 下四份主文档的生成原则与质量基线。各专项规范的完整模板、填表指南与生成约束见对应子文件。

---

## 1 文档目的与定位

`knowledge/business/` 下的四份主文档用于全景式描述系统的业务架构，包括业务场景、流程、用例以及领域模型。

**生成原则**：
- **业务语义权威**：本文档定义的 S-*, DO-*, DE-* 等是全局唯一的业务概念。
- **与应用架构互证**：本规范不写 HTTP/URL、网关或具体部署单元，纯粹从业务视角出发，但必须与应用架构保持映射一致。
- **结构化与可追溯**：所有流程和规则必须有据可查（代码反推或补充文档）。

**产出语言与格式约束**：本规范要求产出的所有 Markdown 文档**严格按照**各专项规范的**模板与结构**输出，且**仅使用中文（简体）**。

---

## 2 产出文件总览

| 产出文件 | 大类 | 专项规范 |
|----------|------|----------|
| `business-overview-and-planning.md` | 业务全景与规划 | [business-overview-and-planning-spec.md](business-overview-and-planning-spec.md) |
| `business-process-and-use-cases.md` | 业务流程与用例 | [business-process-and-use-cases-spec.md](business-process-and-use-cases-spec.md) |
| `business-domain-and-orchestration.md` | 领域建模与串联 | [business-domain-and-orchestration-spec.md](business-domain-and-orchestration-spec.md) |
| `business-capability-and-appendices.md` | 能力建模与附录 | [business-capability-and-appendices-spec.md](business-capability-and-appendices-spec.md) |
| `task.md`（可选） | 大篇幅任务拆解 | [business-domain-task-template.md](business-domain-task-template.md) |

各文件完整模板、内容标准与生成约束以对应专项规范为准。

---

## 3 通用生成约束

1. **文档标题必须包含平台名称**：所有产出文档的一级标题（`#`）必须采用 `# {平台名称} — {文档主题}` 的格式（如 `# 智能闪赔理赔平台 — 业务全景与规划`），其中 `{平台名称}` 从项目上下文或用户输入中获取，不得省略。
2. 业务文档中禁止出现 HTTP 接口路径、数据库物理表名、网关路由配置等技术实现内容。
3. 所有表格列必须与各专项规范完全一致，不得随意删减列。如果某列无数据，填「-」或「不适用」。
4. 产出语言仅使用简体中文。
5. `S-*` 的定义是全局权威，后续所有流程、领域模型和应用归属必须以此为准。

---

## 4 质量自检清单（生成后自检）

生成以上文档后，AI 必须对照以下清单进行自查：
1. **ID 一致性**：`S-*`, `DO-*`, `DE-*` 在四份文档的表格、文字和 Mermaid 图中是否完全一致？
2. **逻辑闭环**：`business-domain-and-orchestration.md` 中的领域事件（DE-*）是否都关联到了具体的流程阶段？是否存在没有触发源的"幽灵事件"？
3. **边界防越位**：文档中是否混入了技术细节（如 HTTP 接口名、数据库物理表名、网关路由配置）？（如果有，必须移出，这些属于应用架构）。
4. **表格完整性**：所有的表格是否严格遵循了各专项规范中定义的表头（没有漏列）？
5. **占位符处理**：是否将无法从基线或业务材料中推断的信息正确标记为了 `[需人工确认]`？

---

## 5 编号体系与跨技能仲裁

### 5.1 业务语义权威

本技能产出的 S-*、DO-*、DE-* 是整个知识库的业务语义最终定稿。

### 5.2 S-* 编号仲裁

- 由于 application 先于 business 执行，application 已基于代码基线定义了 S-* 编号
- 本技能默认复用 application 已有的 S-* 编号（保持编号和语义不变）
- 当发现 application 的 S-* 粒度过粗（一个 S-* 包含多个独立业务动作），允许在复用基础上细化拆分，并在全景册中标注拆分说明

### 5.3 DO-* 编号仲裁

- 本技能定义的 DO-* 是业务概念的权威定义
- `knowledge/application/` 下组件册中的 DO-* 必须与本技能保持一致
- DO 推导完整性：代码基线中每个独立的 Entity/Domain 类、聚合根、值对象都应有对应的 DO 编号；异常处理记录、审批记录、结案记录等状态变更产物也应独立建模

### 5.4 DE-* 推导完整性

- 流程册中每个标注了状态变更的步骤都应有对应的 DE
- 异常处理完成、审批通过/拒绝、零值结案等分支路径的状态变更也应产生独立的 DE，不得仅覆盖主路径

### 5.5 APP-*/AG-*/AC-* 不越位

这些编号的定义权归 `application-knowledge-init`，本技能在附录映射表中只引用不定义。

### 5.6 参与者完整性

核心参与者必须覆盖所有与系统交互的角色，包括内部用户、外部用户和外部系统。外部合作方（如服务商、合作机构）、外部平台（如影像平台、用户管理平台、监管平台）也应作为独立参与者列出。

---

## 6 更新策略

| 变更类型 | 更新范围 |
|---------|---------|
| 首次生成 | 补齐四份核心文档 |
| 新增业务场景 | `business-overview-and-planning.md`（新增 S-* 行）+ `business-process-and-use-cases.md`（补充对应流程与用例） |
| 领域模型变化 | `business-domain-and-orchestration.md` 对应 DO-*/DE-* 行及串联表 |
| 能力映射变化 | `business-capability-and-appendices.md` |
| 全量重建 | 用户明确要求，或业务边界发生重大变化时执行 |

---

## 附录：专项规范文档索引

| 规范内容 | 文档路径 |
|----------|----------|
| 业务全景与规划 | [business-overview-and-planning-spec.md](business-overview-and-planning-spec.md) |
| 业务流程与用例 | [business-process-and-use-cases-spec.md](business-process-and-use-cases-spec.md) |
| 领域建模与串联 | [business-domain-and-orchestration-spec.md](business-domain-and-orchestration-spec.md) |
| 能力建模与附录 | [business-capability-and-appendices-spec.md](business-capability-and-appendices-spec.md) |
| 任务规划模板 | [business-domain-task-template.md](business-domain-task-template.md) |
