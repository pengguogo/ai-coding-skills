---
name: business-knowledge-init
description: 基于前后端代码扫描基线归纳生成业务领域知识。6 步分步执行，产出四份标准化业务架构文档。
  触发词：业务架构、业务领域知识、业务流程、用例图、领域对象(DO)与领域事件(DE)、梳理业务架构。
base-dir-scope: ocspec-root
---

# 业务架构知识生成器

## 目的

基于代码扫描基线逆向推导业务全景、流程编排和领域模型，统一团队对系统边界、流程和领域概念的认知。

## 何时使用

- 用户需要梳理系统的业务架构和业务全景
- 用户请求生成业务流程和用例说明
- 用户要求从代码里反推领域对象(DO)和领域事件(DE)
- 用户需要更新业务规划和领域模型文档
- 已完成 code-knowledge-init 与（可选的）application-knowledge-init，准备沉淀业务领域架构

## 核心能力

- 从代码和应用基线推导业务全景、流程、用例和领域模型
- 建立 S-*/DO-*/DE-* 业务编号体系并引用 APP-*/AG-*/AC-*
- 生成业务全景、流程用例、领域编排、能力附录四类文档
- 校验四份业务文档的编号、对象、事件和追溯关系一致性

## 执行原则

- **基线驱动（强制）**：所有内容必须有代码基线依据，不臆造不存在的业务规则和流程；缺失信息用 `[需人工确认]` 并列出待澄清问题
- **可从代码推断的内容不得占位**：枚举值、状态机等可推断内容不得以 `[需人工确认]` 占位
- **业务语义权威**：本技能产出的 S-*/DO-*/DE-* 是整个知识库的业务语义最终定稿
- **编号协作**：S-* 默认复用 application 已有编号；DO-* 本技能定义为权威；DE-* 本技能定义；APP-*/AG-*/AC-* 定义权归 application，本技能只引用不定义
- **业务纯净**：业务文档中禁止出现技术实现内容（HTTP 接口路径、数据库物理表名、网关路由配置）
- **逆向推导优先级**：枚举值与常量 > 状态机与状态流转 > 包/模块结构 > 注释与方法命名 > 代码逻辑推断

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/business-domain-knowledge-standard.md` | 主规范（索引与总则） |
| `references/business-overview-and-planning-spec.md` | 全景册专项规范 |
| `references/business-process-and-use-cases-spec.md` | 流程册专项规范 |
| `references/business-domain-and-orchestration-spec.md` | 领域册专项规范 |
| `references/business-capability-and-appendices-spec.md` | 能力附录册专项规范 |
| `references/business-domain-task-template.md` | 任务模板（大项目分批） |

## 路径与目录约定

- **权威来源**：`scheduler-protocol.md` §1（含 §1.6 **`ocspec-root` scope**）
- **终稿**：`{KNOWLEDGE}/business/` 下各文档
- **中间产物**：`{KNOWLEDGE}/_workspace/biz/`（及 `summaries/`）
- **禁止**工作区根 `knowledge/`、`{OCSPEC_ROOT}/_workspace/`、在已有 `ocspec-*` 时再建并行目录；无 ocspec 时 Init 可按 §1.2.2 兜底新建

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4，`base-dir-scope: ocspec-root`）
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

## 与其他技能的关系

- 上游：`code-knowledge-init` 提供代码扫描基线（`knowledge/code/`）
- 上游：`application-knowledge-init` 提供 APP-*/AG-*/AC-* 编号体系和 S-*/DO-* 初始定义
- 下游：`fullstack-design` 等后续技能依赖本技能的 S-*/DO-*/DE-* 编号体系
- 平行：`application-knowledge-init` 的 APP-*/AG-*/AC-* 编号体系，本技能只引用不定义
- 推荐执行顺序：`code-knowledge-init` → `application-knowledge-init` → **`business-knowledge-init`**（本技能依赖 application 的 APP-*/AG-*/AC-* 编号；若 application 基线不存在，Step 1 会标注 [建议先执行 application-knowledge-init]）

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: analysis

halt-after: false

- Step 1: steps/step-01-baseline-intake.md
- Step 2: steps/step-02-panorama-analysis.md

### Phase: modeling

halt-after: true

- Step 3: steps/step-03-process-modeling.md
- Step 4: steps/step-04-domain-modeling.md

### Phase: generation

halt-after: true

- Step 5: steps/step-05-doc-generation.md
- Step 6: steps/step-06-cross-doc-verification.md

---

## 交付物

- `ocspec-<xxx>/knowledge/business/business-overview-and-planning.md`
- `ocspec-<xxx>/knowledge/business/business-process-and-use-cases.md`
- `ocspec-<xxx>/knowledge/business/business-domain-and-orchestration.md`
- `ocspec-<xxx>/knowledge/business/business-capability-and-appendices.md`

## Summary 机制

步骤 1、2、3 的产出有下游依赖，需生成精简摘要供 subagent 模式使用。

使用规则：
- subagent 模式：下游步骤读 `input_files_subagent` 中的 Summary
- 同 session 模式：下游步骤读 `input_files` 中的完整产出

兜底规则：
- 若下游步骤返回 NEEDS_CONTEXT 且 missing-context 指向上游 Summary 省略的信息
- Scheduler 从完整产出中提取相关片段（≤1500 字），注入后重试一次

## 动态分批规则

步骤 3 为 template 类型（instance-by: scenario），按 scheduler-protocol.md §3.4 的 10 步流程自动执行动态实例化。按场景(S-*)数量和复杂度分批。

步骤 5 为 template 类型（instance-by: doc-type，instance-mode: fixed，固定 4 实例），跳过 scheduler-protocol.md §3.4 的第 1~5 步（动态分组），直接从第 6 步开始为每个实例注入分配信息。每个实例生成一份完整文档，直接写入最终交付路径。
