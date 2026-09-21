# Checkpoint: Agent-06 跨文档校验 + 交付

> **审查级别**：L2（完整审查）— 检查全部维度，含跨文件一致性。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。这是组装后的全局校验，任何失败项都应暂停供人工决策。
> **强制停止点**：这是唯一的交付点。汇总 pending-items.md 中全部待确认项，停下来等待用户确认。

## 审查时需打开的文件
- `{WORKSPACE}/biz/01-baseline.md`（比对基准）
- `ocspec-<xxx>/knowledge/business/business-overview-and-planning.md`
- `ocspec-<xxx>/knowledge/business/business-process-and-use-cases.md`
- `ocspec-<xxx>/knowledge/business/business-domain-and-orchestration.md`
- `ocspec-<xxx>/knowledge/business/business-capability-and-appendices.md`

## 产出路径与文件名
- [ ] 四份文件位于 `ocspec-<xxx>/knowledge/business/` 下
- [ ] 文件名符合约定（business-overview-and-planning.md / business-process-and-use-cases.md / business-domain-and-orchestration.md / business-capability-and-appendices.md）

## 产出语言
- [ ] 所有文档仅使用简体中文

## S-*/DO-*/DE-* 编号一致性
- [ ] S-* 编号在四份文档中完全一致
- [ ] DO-* 编号在四份文档中完全一致
- [ ] DE-* 编号在领域册和流程册中完全一致
- [ ] 编号全局唯一，无重复

## DE 闭环检查
- [ ] 领域册中每个 DE-* 在流程册的业务流程中有明确的触发源
- [ ] 不存在无触发源的"幽灵事件"
- [ ] 流程册中标注了状态变更的步骤都有对应的 DE

## 边界防越位检查
- [ ] 四份文档中无 HTTP 接口路径
- [ ] 四份文档中无数据库物理表名
- [ ] 四份文档中无网关路由配置
- [ ] 四份文档中无其他技术实现细节（如具体类名、方法签名）

## APP-*/AG-*/AC-* 不越位检查
- [ ] 能力附录册中引用的 APP-*/AG-*/AC-* 编号来自 application 基线
- [ ] 不存在自行定义的 APP-*/AG-*/AC-* 编号

## DO 推导完整性
- [ ] 代码基线中的 Entity/Domain 类都有对应 DO（与 01-baseline.md 比对）
- [ ] 异常处理记录、审批记录、结案记录、财务交易记录等状态变更产物有独立 DO
- [ ] DO 不包含数据库物理表名或字段名

## DE 推导完整性
- [ ] 流程中的状态变更点都有对应 DE
- [ ] 异常处理完成、审批通过/拒绝、零值结案等分支路径有独立 DE
- [ ] 不仅覆盖主路径

## 参与者完整性
- [ ] 核心参与者覆盖内部用户、外部用户和外部系统
- [ ] 外部合作方（如服务商、合作机构）作为独立参与者列出
- [ ] 外部平台（如影像平台、用户管理平台、监管平台）作为独立参与者列出

## S-* 与 application 基线对齐
- [ ] 若 application 基线存在，S-* 编号与其对齐
- [ ] 复用的 S-* 编号和语义不变
- [ ] 细化拆分的 S-* 有标注说明

## 图文一致性
- [ ] Mermaid 图节点 ID 与表格中的编号一致
- [ ] Mermaid 图表语法正确

## 表格列完整性
- [ ] 所有表格严格遵循规范中定义的表头，无漏列
- [ ] 无数据的列填「-」或「不适用」

## 待确认项清零检查（终稿强制）
- [ ] 四份文档全文不包含 `[需人工确认]` 标记
- [ ] 四份文档全文不包含 `[基线待补充]` 标记
- [ ] 四份文档全文不包含 `<!-- STATUS_REPORT -->` 块
- [ ] `pending-items.md` 中步骤 1~6 产生的待确认项全部为"✅ 已消解"状态

## 待确认项提取
- 四份文档中所有 `[需人工确认]` 和 `[基线待补充]` 标记（含位置）
- `pending-items.md` 中所有未消解的待确认项
- 上述审查中不可自动修正的 ❌ 项
- 状态报告中的 corrections-made、manual-review-needed 和 unresolved-items
