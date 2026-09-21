# Step 3: 逐场景流程建模与用例推导（template，按场景分批）

## 元信息

- agent: process-modeler
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: scenario
- instance-source: `{WORKSPACE}/biz/02-panorama.md#业务场景（S）清单`
- context-budget: 2500
- complexity-estimate: { simple: 500, medium: 1000, complex: 2000, default: 1000 }

## Summary 配置

- output: `{WORKSPACE}/biz/summaries/03-process.summary.md`
- must-include:
  - 核心参与者清单索引（参与者名+类型）
  - 各场景流程阶段索引（S-* 编号+阶段名+活动数）
  - 各场景流程活动索引（活动名+所属阶段+状态变更标记）
  - 跨场景触发关系索引（源场景+源活动+目标场景+触发方式）
  - UC 清单索引（编号+名称+关联 S-*）
  - VP 清单索引（编号+名称+所属活动）
- must-exclude:
  - 详细流程步骤描述
  - Mermaid 图源码
  - 可变点的分支详情
- max-length: 1200

## 参数

- input_files: [`{WORKSPACE}/biz/01-baseline.md`, `{WORKSPACE}/biz/02-panorama.md`]
- input_files_subagent: [`{WORKSPACE}/biz/summaries/01-baseline.summary.md`, `{WORKSPACE}/biz/summaries/02-panorama.summary.md`]
- output_file: `{WORKSPACE}/biz/03-process.md`
- output_file_per_instance: `{WORKSPACE}/biz/03-process-${instance-id}.md`
- domain_context: |
    基于代码基线逆向推导每个业务场景的流程线和用例。
    流程推导来源：从代码基线的状态机、枚举、方法调用链逆向推导。
    不得将技术实现步骤混入业务流程（如"调用 XXX 接口"不是业务步骤）。
    参与者必须覆盖内部用户、外部用户和外部系统（含外部合作方和外部平台）。

## 执行指令

对分配的**每个场景(S-*)**，按以下结构完整建模：

### 每个场景的子结构

#### 1. 本场景涉及的参与者
| 参与者 | 类型 | 在本场景中的角色 |
|--------|------|----------------|

#### 2. 流程描述表
| 阶段 | 活动 | 任务 | 步骤 | 状态变更 | 说明 |
|------|------|------|------|---------|------|

#### 3. 可变点（VP）
| VP 编号 | 名称 | 所属活动 | 分支描述 |
|---------|------|---------|---------|

#### 4. 流程图
使用 Mermaid flowchart TD 绘制该场景的详细流程，在关键节点标注状态变更点。

#### 5. 本场景的用例
| UC 编号 | 名称 | 参与者 | 说明 |
|---------|------|--------|------|

### 关键约束
- 流程层级：阶段 → 活动 → 任务 → 步骤（四级完整，不得省略任务和步骤层级）
- 流程中不包含技术实现步骤
- 每个 S-* 至少有一条主流程
- 状态变更列标注该步骤是否产生状态变更（供 Step 4 领域建模使用）
- 不处理未分配给本实例的场景
