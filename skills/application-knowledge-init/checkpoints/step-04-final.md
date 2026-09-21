# Checkpoint: Agent-04 跨文档校验 + 交付

> **审查级别**：L2（完整审查）— 检查全部维度，含跨文件一致性。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。这是组装后的全局校验，任何失败项都应暂停供人工决策。
> **强制停止点**：这是唯一的交付点。汇总 pending-items.md 中全部待确认项，停下来等待用户确认。

## 审查时需打开的文件
- `{WORKSPACE}/app/01-scope.md`（比对基准）
- `ocspec-<xxx>/knowledge/application/application-system-architecture.md`
- `ocspec-<xxx>/knowledge/application/applications-and-domains.md`
- `ocspec-<xxx>/knowledge/application/application-components.md`

## 产出路径与文件名
- [ ] 三份文件位于 `ocspec-<xxx>/knowledge/application/` 下
- [ ] 文件名符合约定（application-system-architecture.md / applications-and-domains.md / application-components.md）

## 产出语言
- [ ] 所有文档仅使用简体中文

## APP-*/AG-*/AC-* 编号一致性
- [ ] APP-* 编号在三份文档中完全一致
- [ ] AG-* 编号在三份文档中完全一致
- [ ] AC-* 编号在 applications-and-domains.md 和 application-components.md 中一致
- [ ] APP 编号从 APP-01 开始连续递增，无跳号
- [ ] APP 编号顺序为先后端再前端，按 AG 分组顺序排列

## AG 前端细分
- [ ] 前端应用按终端形态拆分为独立的 AG
- [ ] 不存在将所有前端合并为一个 AG 的情况

## 图文一致性
- [ ] 系统架构册顶层架构图的 subgraph 标注了 AG 编号
- [ ] 系统架构册 Mermaid 图节点 ID 与表格 ID 一致
- [ ] 主数据册应用组全景图中的 APP 与 APP 台账一致
- [ ] 组件册组件全景图中的 AC 与 AC 表格一致

## Mermaid 图规模
- [ ] 单张 Mermaid 图节点数控制在合理规模，超过时已分拆子图
- [ ] Mermaid 图表语法正确

## 基线追溯完整性
- [ ] 所有子系统有基线路径追溯（与 01-scope.md 中的子系统清单比对）
- [ ] 外部服务标注"无本地基线"
- [ ] 代码模块路径真实存在于扫描基线中

## S-* 编号一致性
- [ ] 若 business 基线存在，S-* 编号与业务基线一致
- [ ] S-* 粒度与代码基线中的包/模块粒度对齐

## DO-* 编号一致性
- [ ] 若 business 基线存在，DO-* 编号与业务基线一致
- [ ] 若 business 基线存在，application-components.md 中有"对应业务侧 DO-*"列

## 前后端集成可追溯性
- [ ] 系统架构册 §3 前后端集成表的 API 路径族来自前端代码基线
- [ ] 后端能力语义有后端基线或架构上下文支撑
- [ ] 无虚构路径或能力映射

## 时序图覆盖
- [ ] 端到端时序图覆盖所有核心业务链路
- [ ] 时序图从前端入口开始绘制
- [ ] 新旧架构并行时关键链路分别绘制

## 前端应用总览
- [ ] 主数据册 §5 覆盖所有前端 APP
- [ ] 路径族摘要与系统架构册 §3 明细一致

## 表格列完整性
- [ ] 所有表格严格遵循规范中定义的表头，无漏列
- [ ] 无数据的列填「-」或「不适用」

## 待确认项清零检查（终稿强制）
- [ ] 三份文档全文不包含 `[需人工确认]` 标记
- [ ] 三份文档全文不包含 `[基线待补充]` 标记
- [ ] 三份文档全文不包含 `<!-- STATUS_REPORT -->` 块
- [ ] `pending-items.md` 中步骤 1~4 产生的待确认项全部为"✅ 已消解"状态

## 待确认项提取
- 三份文档中所有 `[需人工确认]` 和 `[基线待补充]` 标记（含位置）
- `pending-items.md` 中所有未消解的待确认项
- 上述审查中不可自动修正的 ❌ 项
- 状态报告中的 corrections-made、manual-review-needed 和 unresolved-items
