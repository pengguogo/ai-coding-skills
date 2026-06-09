# 应用架构知识文档标准

本文档整合应用架构知识生成的总则与规范索引，定义 \`knowledge/application/\` 下三份主文档的生成原则与质量基线。各专项规范的完整模板、填表指南与生成约束见对应子文件。

---

## 1 文档目的与定位

\`knowledge/application/\` 下的三份主文档用于全景式描述系统的应用架构，包括系统拓扑、依赖关系、应用清单及组件能力。

**生成原则**：
- 基于**实际代码扫描基线**生成，禁止臆造未实现的目标架构。
- **结构化、可追溯**：所有的应用、组件、接口必须能追溯到具体的代码模块或扫描文档。
- **标注不确定项**：无法根据基线推断的部分使用 \`[需人工确认]\` 占位。
- **支持多子系统聚合**：对于包含 8+ 子系统的大型项目，采用"全局视图 + 局部视图"的分层结构，避免信息过载。

**产出语言与格式约束**：本规范要求产出的所有 Markdown 文档**严格按照**各专项规范的**模板与结构**输出，且**仅使用中文（简体）**。

---

## 2 产出文件总览

| 产出文件 | 大类 | 专项规范 |
|----------|------|----------|
| \`application-system-architecture.md\` | 系统架构与调用拓扑 | [application-system-architecture-spec.md](application-system-architecture-spec.md) |
| \`applications-and-domains.md\` | 应用与领域主数据 | [applications-and-domains-spec.md](applications-and-domains-spec.md) |
| \`application-components.md\` | 应用组件与能力 | [application-components-spec.md](application-components-spec.md) |
| \`task.md\`（可选） | 大篇幅任务拆解 | [application-architecture-task-template.md](application-architecture-task-template.md) |

各文件完整模板、内容标准与生成约束以对应专项规范为准。

---

## 3 通用生成约束

1. **文档标题必须包含平台名称**：所有产出文档的一级标题（\`#\`）必须采用 \`# {平台名称} — {文档主题}\` 的格式（如 \`# 智能闪赔理赔平台 — 应用组件清单\`），其中 \`{平台名称}\` 从项目上下文或用户输入中获取，不得省略。
2. Mermaid 图表必须符合标准语义（分层、调用、时序），避免生成包含超过 30 个节点的单张超大图表导致渲染失败。
3. 所有表格列必须与各专项规范完全一致，不得随意删减列。如果某列无数据，填「-」或「不适用」。
4. 真相源路径必须真实引用所有参与聚合的子系统基线，严禁编造不存在的 markdown 文件。
5. 产出语言仅使用简体中文。

---

## 4 质量自检清单（生成后自检）

生成以上文档后，AI 必须对照以下清单进行自查：
1. **ID 与命名空间一致性**：\`APP-*\`, \`AG-*\`, \`AC-*\` 在表格、文字描述和 Mermaid 图中是否完全一致？在多子系统项目中，是否采用了清晰的命名前缀避免冲突？
2. **防信息过载**：全局 Mermaid 图表是否控制在合理规模（建议单图不超过20-30个节点）？是否正确使用了子图(subgraph)或拆分了视图？
3. **集成点明确**：跨子系统的依赖（如 API、MQ、共享库）是否在表格或图中清晰体现？
4. **基线追溯完整性**：所有的应用和子系统是否都附带了真实的基线路径（如 \`ocspec-<xxx>/knowledge/code/子系统A/...\`）？
5. **表格列完整性**：所有的表格是否严格遵循了各专项规范中定义的表头（没有漏列）？
6. **不代替业务**：是否避免了在应用架构文档中直接定义业务域事件（DE-*），而是正确使用了映射？
7. **前后端集成可追溯**：系统架构册 §4.3 前后端集成表中的 API 路径族是否来自前端代码基线？主数据册 §5 前端应用总览是否覆盖所有前端 APP？

---

## 附录：专项规范文档索引

| 规范内容 | 文档路径 |
|----------|----------|
| 系统架构与调用拓扑 | [application-system-architecture-spec.md](application-system-architecture-spec.md) |
| 应用与领域主数据 | [applications-and-domains-spec.md](applications-and-domains-spec.md) |
| 应用组件与能力 | [application-components-spec.md](application-components-spec.md) |
| 任务规划模板 | [application-architecture-task-template.md](application-architecture-task-template.md) |