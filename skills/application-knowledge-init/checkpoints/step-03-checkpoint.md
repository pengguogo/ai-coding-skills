# Checkpoint: Agent-03 按 doc-type 分批生成 3 份文档

> **审查级别**：L1（轻量审查）— 只检查结构和内容维度，一致性和完整性延迟到步骤 4 的 L2 审查。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。

## 审查时需打开的文件
- `ocspec-<xxx>/knowledge/application/application-system-architecture.md`
- `ocspec-<xxx>/knowledge/application/applications-and-domains.md`
- `ocspec-<xxx>/knowledge/application/application-components.md`

## 结构检查 — application-system-architecture.md
- [ ] 包含章节：§1 系统全景
- [ ] 包含章节：§2 端到端调用链（至少 1 条链路，含 Mermaid sequenceDiagram）
- [ ] 包含章节：§3 跨系统集成点（含外部系统、内部系统间、前后端集成）
- [ ] 包含章节：§4 部署架构概要
- [ ] （可选）若系统存在多套并行体系：包含 §6 多体系并行/双链架构对比章节，且每条链路标注承载 APP-*

## 结构检查 — applications-and-domains.md
- [ ] 包含章节：§0 应用组全景图（含 Mermaid graph TB）
- [ ] 包含章节：§1 应用组（AG）台账
- [ ] 包含章节：§2 可部署应用（APP）台账
- [ ] 包含章节：§3 应用间依赖矩阵
- [ ] 包含章节：§5 前端应用与后端能力总览

## 结构检查 — application-components.md
- [ ] 包含章节：§0 组件全景图
- [ ] 包含章节：§1~N 各 APP 组件清单（至少 1 个 APP）
- [ ] 包含章节：DO 清单
- [ ] 包含章节：场景-组件映射（S→AC）表
- [ ] 包含章节：前端应用组件概要

## 内容检查 — 跨文档编号一致性（快速抽查）
- [ ] application-system-architecture.md 中的 APP-* 编号在 applications-and-domains.md 的 APP 台账中存在
- [ ] application-components.md 中的 AC-* 编号所属 APP 在 APP 台账中存在
- [ ] 三份文档中的编号与 02-topology.md 完全一致
- [ ] 场景-组件映射表中每个 S-* 可在 02-topology.md / applications-and-domains.md 的 S 清单中找到
- [ ] 场景-组件映射表中每个 AC-* 可在本册 §1~N 组件清单中找到，无未定义编号

## 内容检查 — 格式规范
- [ ] 所有表格列与 references/ 规范一致，无缺列
- [ ] Mermaid 图语法正确（无明显语法错误）
- [ ] 产出语言为简体中文
- [ ] 无单次写入超过 300 行的痕迹（文件结构连贯）

## 待确认项提取
审查完成后，从产出中提取以下内容作为待确认项：
- 产出正文中所有 `[需人工确认]` 和 `[基线待补充]` 标记
- 状态报告中的 concerns / missing-context
