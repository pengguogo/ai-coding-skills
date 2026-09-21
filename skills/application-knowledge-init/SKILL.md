---
name: application-knowledge-init
description: 基于前后端代码扫描基线归纳生成应用架构知识。4 步分步执行，产出三份标准化文档。
  触发词：应用架构、系统架构图、应用组件全景、架构知识生成、梳理应用架构。
base-dir-scope: ocspec-root
---

# 应用架构知识生成器

## 目的

基于代码扫描基线归纳存量系统拓扑，统一团队应用层面的架构认知。

## 何时使用

- 用户需要梳理整个系统的应用架构
- 用户请求生成应用架构全景图
- 用户要求更新应用架构知识文档
- 用户需要分析模块调用关系和架构文档
- 超大型项目的顶层应用架构汇总

## 核心能力

- 从 `knowledge/code/` 基线推导应用拓扑与系统架构
- 建立 APP-*/AG-*/AC-* 应用编号体系并对齐业务编号
- 生成应用架构、应用主数据、应用组件三类知识文档
- 校验图、表、文本中的编号和调用关系一致性

## 执行原则

- **基线驱动（强制）**：所有内容必须有代码基线依据，不臆造 AG/APP/AC 及调用关系
- **编号一致**：APP-*/AG-*/AC-*/S-*/DO-* 编号在图、表、文本中绝对一致
- **编号协作**：S-*/DO-* 若 business 基线存在则直接引用，不另起编号；APP-*/AG-*/AC-* 定义权归本技能
- **外部服务边界**：无代码基线的外部服务只标注名称与调用方式，不推断内部结构

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/application-architecture-standard.md` | 主规范（索引与总则） |
| `references/application-system-architecture-spec.md` | 系统架构册专项规范 |
| `references/applications-and-domains-spec.md` | 应用主数据册专项规范 |
| `references/application-components-spec.md` | 应用组件册专项规范 |
| `references/application-architecture-task-template.md` | 任务模板（大项目分批） |

## 路径与目录约定

- **权威来源**：`scheduler-protocol.md` §1（含 §1.6 **`ocspec-root` scope**）
- **终稿**：`{KNOWLEDGE}/application/` 下各文档
- **中间产物**：`{KNOWLEDGE}/_workspace/app/`（及 `summaries/`）
- **禁止**工作区根 `knowledge/`、`{OCSPEC_ROOT}/_workspace/`、在已有 `ocspec-*` 时再建并行目录；无 ocspec 时 Init 可按 §1.2.2 兜底新建

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4，`base-dir-scope: ocspec-root`）
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

## 与其他技能的关系

- 上游：`code-knowledge-init` 提供代码扫描基线（`knowledge/code/`）
- 下游：`business-knowledge-init` 依赖本技能的 APP-*/AG-*/AC-* 编号体系
- 平行：`business-knowledge-init` 的 S-*/DO-* 编号体系，本技能需对齐引用
- 推荐执行顺序：`code-knowledge-init` → **`application-knowledge-init`** → `business-knowledge-init`（business 依赖 application 的 APP-*/AG-*/AC-* 编号）

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: main

halt-after: true

- Step 1: steps/step-01-scope-analysis.md
- Step 2: steps/step-02-topology-analysis.md
- Step 3: steps/step-03-doc-generation.md
- Step 4: steps/step-04-cross-doc-verification.md

---

## 交付物

- `ocspec-<xxx>/knowledge/application/application-system-architecture.md`
- `ocspec-<xxx>/knowledge/application/applications-and-domains.md`
- `ocspec-<xxx>/knowledge/application/application-components.md`

## Summary 机制

步骤 1、2 的产出有下游依赖，需生成精简摘要供 subagent 模式使用。

使用规则：
- subagent 模式：下游步骤读 `input_files_subagent` 中的 Summary
- 同 session 模式：下游步骤读 `input_files` 中的完整产出

兜底规则：
- 若下游步骤返回 NEEDS_CONTEXT 且 missing-context 指向上游 Summary 省略的信息
- Scheduler 从完整产出中提取相关片段（≤1500 字），注入后重试一次

## 动态分批规则

步骤 3 为 template 类型（instance-by: doc-type，instance-mode: fixed，固定 3 实例），跳过 scheduler-protocol.md §3.4 的第 1~5 步（动态分组），直接从第 6 步开始为每个实例注入分配信息。

每个实例生成一份完整文档（含全景图），直接写入最终交付路径。
