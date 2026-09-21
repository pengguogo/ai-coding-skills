# Checkpoint: Agent-05 按 doc-type 分批生成 4 份文档

> **审查级别**：L1（轻量审查）— 只检查结构和内容维度，一致性和完整性延迟到步骤 6 的 L2 审查。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。

## 审查时需打开的文件
- `ocspec-<xxx>/knowledge/business/business-overview-and-planning.md`
- `ocspec-<xxx>/knowledge/business/business-process-and-use-cases.md`
- `ocspec-<xxx>/knowledge/business/business-domain-and-orchestration.md`
- `ocspec-<xxx>/knowledge/business/business-capability-and-appendices.md`

## 结构检查 — business-overview-and-planning.md
- [ ] 章节结构严格遵循 `references/business-overview-and-planning-spec.md`
- [ ] 包含 BG/B/S 层级拆解
- [ ] S-* 编号对齐说明存在（复用/细化拆分）

## 结构检查 — business-process-and-use-cases.md
- [ ] 章节结构严格遵循 `references/business-process-and-use-cases-spec.md`
- [ ] 包含业务流程（阶段/活动/任务/步骤）
- [ ] 包含可变点（VP-*）
- [ ] 包含业务用例（UC-*）
- [ ] 包含核心参与者清单

## 结构检查 — business-domain-and-orchestration.md
- [ ] 章节结构严格遵循 `references/business-domain-and-orchestration-spec.md`
- [ ] 包含子域（SD-*）划分
- [ ] 包含领域对象（DO-*）清单
- [ ] 包含领域事件（DE-*）清单
- [ ] 包含领域模型关系图（Mermaid erDiagram）
- [ ] 包含流程-事件串联表

## 结构检查 — business-capability-and-appendices.md
- [ ] 章节结构严格遵循 `references/business-capability-and-appendices-spec.md`
- [ ] 包含业务能力清单（BC-*）
- [ ] §2 场景-能力映射图正确表达 S→BC 映射
- [ ] 包含与应用架构编号对照表（附录 A，S→APP / SD→AG 粗粒度编号对照）

## 内容检查 — 跨文档编号一致性（快速抽查）
- [ ] 全景册中的 S-* 编号在流程册中存在
- [ ] 领域册中的 DO-* 编号在能力附录册中存在
- [ ] 领域册中的 DE-* 在流程册的流程中有触发源
- [ ] 编号与上游中间产出一致（S-*/DO-*/DE-* 与 Step 1~4 产出比对）

## 内容检查 — 格式规范
- [ ] 四份文档的一级标题包含平台名称
- [ ] 所有表格列与 references/ 规范一致，无缺列
- [ ] Mermaid 图语法正确（无明显语法错误）
- [ ] Mermaid 图节点 ID 与表格编号一致
- [ ] 产出语言为简体中文
- [ ] 无单次写入超过 300 行的痕迹（文件结构连贯）

## 内容检查 — 边界防越位（快速抽查）
- [ ] 无 HTTP 接口路径
- [ ] 无数据库物理表名
- [ ] APP-*/AG-*/AC-* 只引用不定义

## 待确认项提取
审查完成后，从产出中提取以下内容作为待确认项：
- 产出正文中所有 `[需人工确认]` 标记
- 状态报告中的 concerns / missing-context
