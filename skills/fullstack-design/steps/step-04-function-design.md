# Step 4: §3.2 功能设计（template，按功能分批）

## 元信息

- agent: function-designer
- checkpoint: checkpoints/step-04-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: feature
- instance-source: `{WORKSPACE}/design/01-input-summary.md#功能清单`
- context-budget: 3000
- complexity-estimate: { simple: 400, medium: 1000, complex: 2500, default: 800 }
- grouping-strategy: |
    聚合优先：simple 功能尽量聚合到同一实例（一个实例可容纳 5~7 个 simple 功能）；
    medium 功能 2~3 个一组；complex 功能独占一个实例。
    只有 1 组时不实例化，作为普通 static 步骤执行。

## Summary 配置

- output: `{WORKSPACE}/design/summaries/04-function.summary.md`
- must-include:
  - 接口索引表（功能名+HTTP方法+URL+入参数量+出参数量）
  - 外部依赖索引（系统名称+调用方式+涉及功能）
  - 关键设计决策列表（涉及幂等/异步/缓存的接口）
  - 跨功能调用索引
- must-exclude:
  - 完整的入参出参表格
  - 时序图Mermaid源码
  - 异常处理详情
  - 配置和数据库/缓存操作细节
- max-length: 800

## 参数

- input_files: [`{WORKSPACE}/design/01-input-summary.md`, `{WORKSPACE}/design/03-backend-foundation.md`, `{DESIGN}/architecture-design.md`, `{REQ}/requirement.md`]
- input_files_subagent: [`{WORKSPACE}/design/01-input-summary.md`, `{WORKSPACE}/design/summaries/03-foundation.summary.md`, `{WORKSPACE}/design/summaries/02-architecture.summary.md`]
- output_file: `{WORKSPACE}/design/04-function-design.md`
- output_file_per_instance: `{WORKSPACE}/design/04-function-design-${instance-id}.md`
- reference_sections:
    - `references/design-backend-standard.md#§3.2-功能设计`
    - `references/change-annotation-standard.md`
    - `references/sequence-diagrams.md`
- domain_context: 为分配的功能撰写完整的后端功能设计

## 执行指令

> 设计每个功能前，先对照 `01-input-summary.md` §3 中该功能对应需求项的「三维度要点」「边界与异常线索」「状态流转」，使设计覆盖需求已识别的全部场景。若 §3 线索不足以确定细节：同 session 模式回查 `{REQ}/requirement.md` 对应需求项原文；subagent 模式按需读取 `{REQ}/requirement.md` 中该需求项对应片段（仅该需求项，不整篇加载）。摘要与原文不一致时以 requirement.md 原文为准。

对分配的**每个功能**，按以下结构完整撰写，不得省略任何子章节：

### 每个功能的子结构

#### 1. 功能时序图
- Mermaid sequenceDiagram，Controller → Service → Domain → Mapper/外部系统
- 包含成功和失败分支
- 改动交互用 `rect`（新增绿 `rgb(232,245,233)`/改造黄 `rgb(255,255,224)`）区块包裹 + 首条 Note 以 `[新增]/[改造]` 开头说明改了什么；rect 不得跨 alt/opt/loop 边界；整图全改时按 §2 退化规则免逐段标、附一句全改声明（按 change-annotation-standard.md §4.1，禁用 `<span style="color:red">` 红字）
- 参与者命名与 architecture-design.md §5 应用内模块设计一致

#### 2. 对外接口
- **三态标签**：接口标题标 `[新增]/[改造]/[复用]` 之一；`[改造]` 附改造点说明、`[复用]` 标现网出处（按 change-annotation-standard.md §3）
- URL（HTTP 方法 + 完整路径）
- **入参表格**：字段名 | 类型 | 必填 | 说明（必须用表格，不能只给 JSON 示例）
- **出参表格**：字段名 | 类型 | 说明（必须用表格，嵌套对象展开到叶子）

#### 3. 依赖接口
接口提供方、URL、请求参数、响应结果、调用场景、异常处理。依赖接口标题同样标 `[新增]/[改造]/[复用]`。不涉及写"无"。

**禁止臆造接口**：依赖接口必须来源于以下之一，否则不得列出：
- 03-backend-foundation.md 或本步骤其他功能中已定义的对外接口
- 01-input-summary.md 外部依赖表中明确列出的外部系统能力
- 需求文档中明确提及的已有系统接口

若业务逻辑需要调用某接口但无法从上述来源确认其存在，必须标注 `[需人工确认：该接口在现有系统中是否存在]`，并在备注中说明假设依据。三态无法确定时**只标 `[需人工确认]`**，不要先硬选 `[复用]`/`[新增]` 再叠加确认标记（两者互斥）。

#### 4. 幂等与一致性设计
结合 §3 线索与输入摘要中的「核心流转与数据一致性」要求，明确说明：
- **系统幂等与业务幂等**：幂等键是什么？防重机制是什么？
- **事务一致性**：本地事务边界，或分布式事务方案（如 TCC/Saga/异步补偿等）。

若本功能不涉及（如纯查询、无写操作、无外部调用），须说明判定理由（不得仅写"无"）。

#### 5. 异常处理与重试补偿
- 对照 §3 该需求项的边界与异常线索，逐条列出已评估的异常/边界场景及对应的重试/阻断/丢弃策略与补偿对账机制。
- 若需求涉及外部调用或核心流转，必须说明失败补偿与对账机制。

若某线索评估后判定不适用，须在本节写明理由（不得仅写"无"）。

#### 6. 配置 + 数据库/缓存/文件/定时/消息（按需）
不涉及写"无"。

### 关键约束

- 接口字段必须与 03-backend-foundation.md 中 §3.1 的表清单对应
- 时序图参与者必须与 architecture-design.md §5 应用内模块设计一致
- 不处理未分配给本实例的功能
- **严禁臆造接口**：所有对外接口和依赖接口必须有明确的需求或设计来源。不得凭推测列出项目中不存在的接口。若设计中需要某接口但无法确认其存在，必须标注 `[需人工确认]` 并说明假设依据
