# Step 5: §4~§6 稳定性/风险/开放问题 + 后端组装与自检 [强制停止]

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-05-backend-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/design/01-input-summary.md`, `{WORKSPACE}/design/03-backend-foundation.md`, `{WORKSPACE}/design/04-function-design.md`, `{DESIGN}/architecture-design.md`]
- input_files_subagent: [`{WORKSPACE}/design/01-input-summary.md`, `{WORKSPACE}/design/summaries/03-foundation.summary.md`, `{WORKSPACE}/design/summaries/04-function.summary.md`, `{WORKSPACE}/design/summaries/02-architecture.summary.md`]
- output_file: `{DESIGN}/backend-design.md`
- status_report_file: `{WORKSPACE}/design/05-status-report.md`
- upstream_compare: [`{WORKSPACE}/design/01-input-summary.md`, `{DESIGN}/architecture-design.md`, `{REQ}/requirement.md`]
- reference_sections:
    - `references/design-backend-standard.md#§4-稳定性安全评估`
    - `references/design-backend-standard.md#§5-§6`

## 执行指令

本步骤分 2 个 Part 顺序执行。

### Part 1：撰写 §4 稳定性与安全评估 + §5 风险评估 + §6 开放问题

基于 04-function-design.md 的接口和外部依赖信息撰写。撰写 §4 稳定性与 §5 风险时，须同时参考 01-input-summary.md §3 边界与交互线索，使稳定性与风险评估覆盖各功能已识别的边界场景与外部依赖。

#### §4.1 系统稳定性

**§4.1.1 限流**：从 04-function-design.md 的对外接口中提取接口清单，**逐个对外接口给出是否限流的判定**——限流接口写明限流维度（接口/用户/IP）、阈值、算法、限流后处理；不限流接口写明判定理由。

**§4.1.2 降级熔断**：从 04-function-design.md 的依赖接口中提取依赖系统，**逐个外部依赖**给出降级策略（触发条件、降级处理、备用方案）、熔断机制（失败率阈值、时间窗口、恢复策略）。

#### §4.2 业务稳定性

**§4.2.1 日志监控告警**：日志策略、监控指标、告警规则与方式。

**§4.2.2 核对告警**（若适用）：不适用则写"本期无核对告警需求"。

#### §5 风险评估

**§5.1 技术风险**：数据一致性风险、性能风险、外部系统依赖风险、安全性风险、可扩展性风险。每条风险必须含触发条件、影响范围、可落地的应对措施、责任边界四要素。

**§5.2 业务风险**：业务规则配置错误风险、业务流程风险、数据权限风险。每条风险必须含触发条件、影响范围、可落地的应对措施、责任边界四要素。

#### §6 开放问题

合并以下来源的未决项：
- 01-input-summary.md 中的待确认清单
- 04-function-design.md 中的关键设计决策（若有待定项）
- 设计过程中发现的新问题

每条开放问题包含：问题描述、影响范围、待决策内容。

### Part 2：组装完整后端设计文档

将中间产出合并为完整文档。合并时必须剥离每个文件末尾的 `<!-- STATUS_REPORT -->` 块。

#### 组装顺序

```
# [需求名称] — 后端技术方案设计

[03 的 §1~§2 内容] → ## 1. 背景与目标 + ## 2. 技术选型（含模块清单导航至架构 §5）
[03 的 §3.1 内容] → ## 3. 详细设计 / ### 3.1 模型设计
[04 内容]         → ### 3.2 功能设计
[Part 1 产出]     → ## 4. 稳定性&安全评估 + ## 5. 风险评估 + ## 6. 开放问题
```

注意：01-input-summary.md 中的输入分析部分（场景判定、功能清单等）不写入终稿，仅作为工作基础。后端终稿不含独立的架构/模块章（§2 仅技术选型 + 引用架构文档），应用架构与模块清单的权威源为 architecture-design.md。

#### 全局一致性校验

- §3.1/§3.2 模块名与 architecture-design.md §5 应用内模块设计一致
- 实体名称在 §3.1.1 和 §3.1.2 中一一对应
- 表名在 §3.1.2 和 §3.2 的"数据库"小节中一致；且与 architecture-design.md §6 ER 总览的表归属无矛盾
- 接口 URL 与 §1.5 路径约定一致
- 每个对外接口有入参表格和出参表格（不得仅给 JSON 示例）
- 时序图参与者与 architecture-design.md §5 应用内模块设计一致
- 需求文档中的所有 P0/P1 需求项在 §3.2 中有对应功能设计
- **接口来源可追溯**：§3.2 中每个"依赖接口"必须可追溯到本文档内已定义的对外接口、01-input-summary.md 外部依赖表或需求文档明确提及的已有接口；无法确认存在的接口必须标注 `[需人工确认]`

#### 待确认项清零检查（终稿强制）

扫描终稿全文，搜索残留的 `[需与产品确认]`、`[需人工确认]`、`<!-- STATUS_REPORT -->` 块。如有残留，状态必须为 DONE_WITH_CONCERNS。

### 关键约束

- 状态报告写入 {WORKSPACE}/design/05-status-report.md，不写入 {DESIGN}/backend-design.md
- 终稿中不得包含任何 STATUS_REPORT 块
- 将 STATUS_REPORT 按 §11 格式写入 status_report_file 指定路径，供 Scheduler 状态机决策
