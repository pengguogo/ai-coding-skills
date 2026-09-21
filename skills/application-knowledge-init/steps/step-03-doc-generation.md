# Step 3: 按 doc-type 分批生成 3 份文档

## 元信息

- agent: document-generator
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: doc-type
- instance-mode: fixed
- instance-source: 固定 3 个实例（system-architecture / apps-and-domains / app-components）
- context-budget: 3000
- complexity-estimate: { system-architecture: 1200, apps-and-domains: 800, app-components: 1500, default: 1000 }

## 参数

- input_files: [`{WORKSPACE}/app/01-scope.md`, `{WORKSPACE}/app/02-topology.md`]
- input_files_subagent: [`{WORKSPACE}/app/summaries/01-scope.summary.md`, `{WORKSPACE}/app/summaries/02-topology.summary.md`]
- output_file: `{WORKSPACE}/app/03-status-summary.md`
- output_file_per_instance:
  - 实例 1: `ocspec-<xxx>/knowledge/application/application-system-architecture.md`
  - 实例 2: `ocspec-<xxx>/knowledge/application/applications-and-domains.md`
  - 实例 3: `ocspec-<xxx>/knowledge/application/application-components.md`
- reference_sections:
  - 实例 1: `references/application-system-architecture-spec.md`
  - 实例 2: `references/applications-and-domains-spec.md`
  - 实例 3: `references/application-components-spec.md`
- domain_context: |
    基于拓扑分析结果，严格按对应的 reference 规范生成标准化应用架构文档。
    三份文档共享同一套 APP-*/AG-*/AC-* 编号体系，编号必须与 02-topology.md 完全一致。

## 执行指令

### 实例 1：生成 application-system-architecture.md
按 application-system-architecture-spec.md 规范：
- §1 系统全景（系统边界+子系统总览+顶层架构分层图）
- §2 端到端调用链（文字+Mermaid sequenceDiagram，从前端入口开始）
- §3 跨系统集成点（外部+内部+前后端集成表）
- §4 部署架构概要
- §6 多体系并行/双链架构对比（可选，仅当存在多套并行技术体系时输出）

### 实例 2：生成 applications-and-domains.md
按 applications-and-domains-spec.md 规范：
- §0 应用组全景图
- §1 应用组（AG）台账
- §2 可部署应用（APP）台账
- §3 应用间依赖矩阵（APP > 15 时改为关键依赖清单）
- §5 前端应用与后端能力总览

### 实例 3：生成 application-components.md
按 application-components-spec.md 规范：
- §0 组件全景图
- §1~N 各 APP 组件清单（AC 编号+名称+职责+依赖）
- DO 清单（编号+名称+所属 AC）
- 场景-组件映射（S→AC）：按场景列承载 AC（S-*/AC-* 取自 02-topology；多体系并行用多列，单体系单列；无承载填「-」）
- 前端应用组件概要

### 关键约束
- 编号一致性：APP-*/AG-*/AC-*/S-*/DO-* 必须与 02-topology.md 完全一致
- 场景-组件映射表只交叉引用 S-*/AC-*，不新增编号；S-* 不假设连续，以 02-topology 实际清单为准
- 分段写入：每段 ≤300 行
- Mermaid 图节点过多时分拆子图（≤30 节点/图）
- 不重新做架构分析，直接使用 Step 2 的编号和拓扑
- 不臆造不存在的内容
- 每个实例直接写入最终交付路径
