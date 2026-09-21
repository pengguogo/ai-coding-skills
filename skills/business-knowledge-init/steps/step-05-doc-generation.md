# Step 5: 按 doc-type 分批生成 4 份文档

## 元信息

- agent: document-generator
- checkpoint: checkpoints/step-05-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: doc-type
- instance-mode: fixed
- instance-source: 固定 4 个实例（overview-and-planning / process-and-use-cases / domain-and-orchestration / capability-and-appendices）
- context-budget: 3000
- complexity-estimate: { overview-and-planning: 800, process-and-use-cases: 2000, domain-and-orchestration: 1200, capability-and-appendices: 1000, default: 1000 }

## 参数

- input_files: [`{WORKSPACE}/biz/01-baseline.md`, `{WORKSPACE}/biz/02-panorama.md`, `{WORKSPACE}/biz/03-process.md`, `{WORKSPACE}/biz/04-domain.md`]
- input_files_subagent:
  - 实例 1（全景册）: [`{WORKSPACE}/biz/summaries/01-baseline.summary.md`, `{WORKSPACE}/biz/summaries/02-panorama.summary.md`]
  - 实例 2（流程册）: [`{WORKSPACE}/biz/summaries/01-baseline.summary.md`, `{WORKSPACE}/biz/summaries/02-panorama.summary.md`, `{WORKSPACE}/biz/03-process.md`]
  - 实例 3（领域册）: [`{WORKSPACE}/biz/summaries/01-baseline.summary.md`, `{WORKSPACE}/biz/summaries/03-process.summary.md`, `{WORKSPACE}/biz/04-domain.md`]
  - 实例 4（能力附录册）: [`{WORKSPACE}/biz/summaries/01-baseline.summary.md`, `{WORKSPACE}/biz/summaries/02-panorama.summary.md`, `{WORKSPACE}/biz/summaries/03-process.summary.md`, `{WORKSPACE}/biz/04-domain.md`]
- output_file: `{WORKSPACE}/biz/05-status-summary.md`
- output_file_per_instance:
  - 实例 1: `ocspec-<xxx>/knowledge/business/business-overview-and-planning.md`
  - 实例 2: `ocspec-<xxx>/knowledge/business/business-process-and-use-cases.md`
  - 实例 3: `ocspec-<xxx>/knowledge/business/business-domain-and-orchestration.md`
  - 实例 4: `ocspec-<xxx>/knowledge/business/business-capability-and-appendices.md`
- reference_sections:
  - 实例 1: `references/business-overview-and-planning-spec.md`
  - 实例 2: `references/business-process-and-use-cases-spec.md`
  - 实例 3: `references/business-domain-and-orchestration-spec.md`
  - 实例 4: `references/business-capability-and-appendices-spec.md`
- domain_context: |
    基于全景分析、流程建模和领域建模结果，严格按对应的 reference 规范生成标准化业务架构文档。
    四份文档共享同一套 S-*/DO-*/DE-* 编号体系，编号必须与上游中间产出完全一致。
    文档标题必须包含平台名称：`# {平台名称} — {文档主题}`。
    产出语言仅使用简体中文。

## 执行指令

### 实例 1：生成 business-overview-and-planning.md
按 business-overview-and-planning-spec.md 规范：
- §1 业务全景概述
- §2 业务群（BG）——每个 BG 独立一节
- §3 业务（B）与业务场景（S）——按 BG 分组
- §4 主业务价值流（Mermaid flowchart LR）
- §5 业务群关系图（Mermaid graph TB）
- §6 业务全景图（Mermaid mindmap）
- §7 业务规划（可选）

### 实例 2：生成 business-process-and-use-cases.md
按 business-process-and-use-cases-spec.md 规范：
- §1 核心参与者
- §2 核心用例图（Mermaid graph LR，按业务域分组）
- §3 主流程（端到端，Mermaid flowchart LR）
- §4 各场景业务流程（每个核心场景独立一节，含流程描述表+可变点+流程图）
- §5 业务用例概览（按参与者分组）
- §6 领域事件全景串联图（Mermaid graph TB，按场景分 subgraph）
- §7 参与者-用例关系图（Mermaid graph LR）

### 实例 3：生成 business-domain-and-orchestration.md
按 business-domain-and-orchestration-spec.md 规范：
- §1 领域子域（SD）概览（关系图+清单）
- §2 领域对象（DO）清单（按子域分组）
- §3 领域事件（DE）清单
- §4 流程-事件串联（串联表+串联图）
- §5 领域模型关系图（Mermaid erDiagram）

### 实例 4：生成 business-capability-and-appendices.md
按 business-capability-and-appendices-spec.md 规范：
- §0 业务能力地图（Mermaid graph TB）
- §1 业务能力清单（按 BG 分组）
- §2 场景-能力映射图（Mermaid graph LR，展示 S→BC 映射关系）
- §3 领域事件-技术实现映射（DE→技术）
- §4 术语表
- §5 附录（业务架构与应用架构编号对照）

### 关键约束
- 编号一致性：S-*/DO-*/DE-*/BG-*/B-*/SD-*/UC-*/VP-*/BC-* 必须与上游中间产出完全一致
- APP-*/AG-*/AC-* 只引用不定义，引用值来自 application 基线
- 分段写入：每段 ≤300 行
- Mermaid 图节点过多时分拆子图（≤30 节点/图）
- 不重新做分析或建模，直接使用 Step 1~4 的产出
- 不臆造不存在的内容
- 每个实例直接写入最终交付路径
- 文档标题必须包含平台名称
- 产出语言仅使用简体中文

### 大项目处理（S-* >= 15）
当场景数量 >= 15 时：
- 每份文档按 BG 分组分段写入
- 每个 BG 的内容写完后做增量编号校验（S-*/DO-*/DE-* 与上游一致）
- 每段 ≤300 行（已有约束）
- 不拆成多个实例（四份文档的编号体系必须连贯）
