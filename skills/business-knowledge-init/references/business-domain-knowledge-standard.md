# 业务领域知识文档标准

本文档整合业务领域知识生成的总则与规范索引，定义 \`knowledge/business/\` 下四份主文档的生成原则与质量基线。各专项规范的完整模板、填表指南与生成约束见对应子文件。

---

## 1 文档目的与定位

\`knowledge/business/\` 下的四份主文档用于全景式描述系统的业务架构，包括业务场景、流程、用例以及领域模型。

**生成原则**：
- **业务语义权威**：本文档定义的 S-*, DO-*, DE-* 等是全局唯一的业务概念。
- **与应用架构互证**：本规范不写 HTTP/URL、网关或具体部署单元，纯粹从业务视角出发，但必须与应用架构保持映射一致。
- **结构化与可追溯**：所有流程和规则必须有据可查（代码反推或补充文档）。

**产出语言与格式约束**：本规范要求产出的所有 Markdown 文档**严格按照**各专项规范的**模板与结构**输出，且**仅使用中文（简体）**。

---

## 2 产出文件总览

| 产出文件 | 大类 | 专项规范 |
|----------|------|----------|
| \`business-overview-and-planning.md\` | 业务全景与规划 | [business-overview-and-planning-spec.md](business-overview-and-planning-spec.md) |
| \`business-process-and-use-cases.md\` | 业务流程与用例 | [business-process-and-use-cases-spec.md](business-process-and-use-cases-spec.md) |
| \`business-domain-and-orchestration.md\` | 领域建模与串联 | [business-domain-and-orchestration-spec.md](business-domain-and-orchestration-spec.md) |
| \`business-capability-and-appendices.md\` | 能力建模与附录 | [business-capability-and-appendices-spec.md](business-capability-and-appendices-spec.md) |
| \`task.md\`（可选） | 大篇幅任务拆解 | [business-domain-task-template.md](business-domain-task-template.md) |

各文件完整模板、内容标准与生成约束以对应专项规范为准。

---

## 3 通用生成约束

1. **文档标题必须包含平台名称**：所有产出文档的一级标题（\`#\`）必须采用 \`# {平台名称} — {文档主题}\` 的格式（如 \`# 智能闪赔理赔平台 — 业务全景与规划\`），其中 \`{平台名称}\` 从项目上下文或用户输入中获取，不得省略。
2. 业务文档中禁止出现 HTTP 接口路径、数据库物理表名、网关路由配置等技术实现内容。
3. 所有表格列必须与各专项规范完全一致，不得随意删减列。如果某列无数据，填「-」或「不适用」。
4. 产出语言仅使用简体中文。
5. \`S-*\` 的定义是全局权威，后续所有流程、领域模型和应用归属必须以此为准。

---

## 4 质量自检清单（生成后自检）

生成以上文档后，AI 必须对照以下清单进行自查：
1. **ID 一致性**：\`S-*\`, \`DO-*\`, \`DE-*\` 在四份文档的表格、文字和 Mermaid 图中是否完全一致？
2. **逻辑闭环**：\`business-domain-and-orchestration.md\` 中的领域事件（DE-*）是否都关联到了具体的流程阶段？是否存在没有触发源的"幽灵事件"？
3. **边界防越位**：文档中是否混入了技术细节（如 HTTP 接口名、数据库物理表名、网关路由配置）？（如果有，必须移出，这些属于应用架构）。
4. **表格完整性**：所有的表格是否严格遵循了各专项规范中定义的表头（没有漏列）？
5. **占位符处理**：是否将无法从基线或业务材料中推断的信息正确标记为了 \`[需人工确认]\`？

---

## 附录：专项规范文档索引

| 规范内容 | 文档路径 |
|----------|----------|
| 业务全景与规划 | [business-overview-and-planning-spec.md](business-overview-and-planning-spec.md) |
| 业务流程与用例 | [business-process-and-use-cases-spec.md](business-process-and-use-cases-spec.md) |
| 领域建模与串联 | [business-domain-and-orchestration-spec.md](business-domain-and-orchestration-spec.md) |
| 能力建模与附录 | [business-capability-and-appendices-spec.md](business-capability-and-appendices-spec.md) |
| 任务规划模板 | [business-domain-task-template.md](business-domain-task-template.md) |