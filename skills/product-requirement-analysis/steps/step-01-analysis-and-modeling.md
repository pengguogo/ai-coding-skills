# Step 1: 输入接收 + 知识库对照 + 5W1H 分析 + 需求项建模（template，按需求项分批）

## 元信息

- agent: requirement-modeler
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: requirement-item
- instance-source: `{WORKSPACE}/requirement/01-intake.md#功能列表`
- context-budget: 3000
- complexity-estimate: { simple: 400, medium: 1000, complex: 2500, default: 800 }
- grouping-strategy: |
    聚合优先：simple 需求项尽量聚合到同一实例；
    medium 需求项 2~3 个一组；complex 需求项独占一个实例。
    只有 1 组时不实例化，作为普通 static 步骤执行。

## 参数

- input_files: [`{WORKSPACE}/requirement/00-brainstorm.md`, `[用户提供的原始需求材料]`, `{KNOWLEDGE}/_workspace/product-req/00-kb-readiness.md`, `{KNOWLEDGE}/_workspace/product-req/00-product-intake.md`, `{KNOWLEDGE}/business/`, `{KNOWLEDGE}/application/`, `{KNOWLEDGE}/code/`, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- output_file: `{WORKSPACE}/requirement/01-modeling.md`
- output_file_per_instance: `{WORKSPACE}/requirement/01-modeling-${instance-id}.md`
- intake_output_file: `{WORKSPACE}/requirement/01-intake.md`
- fact_source_output_file: `{WORKSPACE}/requirement/01-fact-source.md`
- reference_files: [`references/knowledge-cross-reference-guide.md`, `references/5w1h-analysis-guide.md`, `references/requirement-analysis-standard.md#三-需求项模板`, `references/fact-source-standard.md`]

## 执行指令

**路径前置（Scheduler 强制）**：`intake_output_file`、`output_file` 等参数中的 `{WORKSPACE}` 必须在 Init 已解析为 `{BASE_DIR}/_workspace` 之后方可写入。原始材料（docx 等）的临时解析结果写入 `{WORKSPACE}/input/`，禁止写入工作区根 `_workspace/`。

**Step 0 前置（Scheduler 强制）**：须已存在 `{WORKSPACE}/requirement/00-brainstorm.md` 且 `BRAINSTORM_STATUS: approved`；否则 **Halt**。

本步骤分 3 个 Phase 顺序执行。Phase A 以 **brainstorm 结论为权威输入**，叠加知识库与历史需求对照；Phase B 为 5W1H；Phase C 为 template 分批建模。

**事实源纪律（贯穿全步骤，强制）**：本步骤所有产出须可回溯到来源。分级、锚点精度、强制挂溯源的条目类型、标记语义全部见 `references/fact-source-standard.md`（含产品版 §9），本文件不重述规则。核心红线四条：

- **数字型事实**（金额、时限、阈值、条数、超时、重试次数等）**仅允许 F1/F2**，禁止推断；无据则标 `[推断待确认]`
- **接口/消息名不得臆造**：声明「复用已有接口」时路径与方法须能在 `{CODE_KNOWLEDGE}` 检索到，检索不到即为臆造
- **知识库引用须带锚点**：精确到文件 + 章节/接口签名，只写目录名或文件名不合格
- **brainstorm 中的 `[AI推断]` 不得当作确定事实**：只有已认领升为 F2 的条目才是权威输入

### Phase A：接收材料、知识库对照与范围确认（写入 intake_output_file）

1. **读取 `00-brainstorm.md`**，将 §1～§5 已确认内容作为功能列表与验收口径的**首要依据**。
   **来源属性甄别（强制）**：只有标注 `[用户确认]`/`[材料原文]`/`[知识库]` 的条目可作权威输入；若仍存在未处理的 `[AI推断]` 条目 → **Halt**，回退 Step 0 Phase F 完成认领门（见 `fact-source-standard.md` §9.1）
2. 读取用户原始材料，与 brainstorm 交叉校验；冲突处标注 `[需与产品确认]`，**不得** silently 覆盖已 approved 的 brainstorm
3. 读取 `{KNOWLEDGE}/_workspace/product-req/00-kb-readiness.md`，确认 `KNOWLEDGE_READINESS` 等级
4. **知识库三层对照**（按 `references/knowledge-cross-reference-guide.md`）：
   - `KNOWLEDGE_READINESS` 非 `minimal` 时：按需读取 `business/`、`application/`、`code/`（解析 `{CODE_KNOWLEDGE}`）
   - `minimal` 时：跳过深度读取，§8 注明「知识库内容不足」
   - **锚点精度（强制）**：§8「来源文档」列须精确到 **文件 + 章节锚点**（如 `business/order-domain.md#订单状态机`）或 **接口签名**（如 `code/xx-svc/backend-project.md#POST /api/order/pay`）；只写目录名、只写文件名、或写「知识库中提到」均不合格，Step 2 门禁会判 `[事实源缺失]`
   - **引用即验证**：写入 §8 前须实际打开该锚点确认内容存在且相符；无法确认的写 `[知识库待补充]`，**不得**先写上再指望后续修正
5. **历史需求对照**（**只读**）：扫描 `{OCSPEC_ROOT}/requirements/`，结合 Pin 中 `RELATED_REQUIREMENT` 匹配相似历史需求；**禁止**写入或修改历史目录下任何文件。
   §9 相似点须**实际打开历史文档**核对后填写，锚点精确到章节；不接受仅凭目录名推定的「相似度」
6. 若 `CUSTOM_KNOWLEDGE_STATUS=present`：读 `{CUSTOM_KNOWLEDGE}/README.md` 及按需子目录，提取术语/制度/对接规范
7. 提取核心信息：业务目标、干系人/用户角色、功能列表、已知约束、范围外/明确不做（**优先取自 brainstorm §1～§5**）
8. 对功能列表中每项标注 simple/medium/complex 及依赖关系
9. 汇总待澄清清单；**不得重复 Step 0 已确认且已写入 brainstorm 的项**，除非与知识库对照发现新冲突
10. 不写需求文档正文，只做信息提取和结构化

产出结构：

```markdown
# 材料接收与范围确认

## 1. 业务目标
## 2. 干系人/用户角色（表格）
## 3. 功能列表（表格：序号/需求项名称/所属模块/优先级/复杂度/依赖需求项/简要说明）
## 4. 已知约束
## 5. 范围外/明确不做
## 6. 自定义知识补充（若 CUSTOM_KNOWLEDGE_STATUS=present；否则写「无」）
## 7. 知识库就绪度摘要（来自 00-kb-readiness.md：KNOWLEDGE_READINESS + 各层状态）
## 8. 与现有能力对照（表格：本次功能/已有能力/来源文档/关系/说明；含术语对齐与冲突预警）
## 9. 历史需求对照（表格：历史目录/相似度/关联说明/本次关系/章节锚点）
## 10. 待澄清清单
## 11. 事实源摘要（条目总数 + 各级别 F1~F5 分布 + F5 待降级条目数；明细见 01-fact-source.md）
```

**Phase A 建模约束**：功能列表中标注为「复用/疑似重复」的项，须在待澄清清单中至少有一条确认项。

### Phase A3：事实源登记（写入 fact_source_output_file）

> 在 Phase A 对照完成后执行。本 Phase 是 Step 2 门禁的**唯一输入基准**——登记不全会直接导致门禁判 `FAIL`。

1. 按 `fact-source-standard.md` §3.1 表结构建立事实源登记表，`FS-001` 起顺序编号
2. 逐条登记来源，锚点精度须满足 §3.2：
   - brainstorm 已认领条目 → F2，锚点写 `00-brainstorm.md#§N`（附原对话轮次）
   - 材料原文 → F1，锚点写章节号/表格行/页码
   - 知识库 → F3，锚点写 `business/x.md#章节` 或 `code/x/backend-project.md#接口签名`
   - 历史需求 → F4，锚点写目录 + 章节
3. 按 §2 标注级别；**级别不得虚标**（推断标成 F1/F2 在门禁中判严重问题）
4. `原文摘录` 列填来源中的原始表述（F1/F3 必填，≤ 60 字），供 Step 2 逐字核对
5. **数字型事实专项**：把材料/brainstorm 中出现的每一个数字单独登记一条，级别只能是 F1/F2；找不到出处的数字**不登记**，转入待澄清清单
6. **接口专项**：正文将声明「复用」的每个接口单独登记一条 F3，锚点为 code 知识库中的接口签名；检索不到的**不登记**，转为占位并标 `[推断待确认]`
7. `关联需求项` 列先填功能列表中的需求项名称；REQ 编号在 Step 3 终稿定稿后回填
8. `校验状态` 列统一填「待校验」，由 Step 2 更新

产出结构：

```markdown
# 事实源登记表

## 1. 登记表
（表格：事实源 ID / 事实内容 / 级别 / 来源文件 / 定位锚点 / 原文摘录 / 关联需求项 / 校验状态）

## 2. 级别分布统计
（F1~F5 各级别条目数）

## 3. 数字型事实清单（单列，便于 Step 2 做 100% 核验）
（表格：事实源 ID / 数字与单位 / 口径说明 / 来源锚点）

## 4. 接口引用清单（单列，便于 Step 2 做 100% 检索验证）
（表格：事实源 ID / 接口路径与方法 / code 知识库锚点 / 复用或新增）

## 5. F5 待降级条目
（表格：事实源 ID / 推断内容 / 降级处置：转待澄清 / 待用户认领）
```

**Phase A3 完成条件**：功能列表中每个需求项至少有 1 条关联事实源；所有数字与接口引用均已登记或转入待澄清。

### Phase B：5W1H 穿透分析（追加写入 intake_output_file）

基于 Phase A 的功能列表与 §8 知识库对照，按以下顺序分析，产出追加到 intake_output_file 中：

1. **Why（为什么）**：背景、痛点、价值；与 business 已有能力的关系（增量/替代）
2. **What（是什么）**：功能边界、输入输出、验收口径（Given-When-Then）；**排除** knowledge 已覆盖且本次标注为「复用」的重复描述
3. **Who（谁）**：角色与权限；与 application 系统边界中的参与者对齐
4. **When（何时）**：触发时机、SLA
5. **Where（何地）**：终端/渠道、集成环境；对照 application 部署拓扑
6. **How（如何）**：主流程概要、关键业务规则；与 code 层已有接口/模块的复用点

缺失信息标注 `[需与产品确认]`；知识库缺口标注 `[知识库待补充]`。不写需求文档正文，不做详细业务流程建模。

**Phase A + B 完成后，Scheduler 基于功能列表执行 template 分批逻辑，进入 Phase C。**

---

### Phase C：需求项拆解与业务流程建模（template 分批执行）

> **与 requirement-analysis 同标准（强制）**：Phase C 的 §2.1/§2.2 与各需求项 §3.2.1～§3.2.7、隐藏场景补强规则，与 `skills/requirement-analysis` Step 1 Phase C **完全一致**。`00-brainstorm.md` 仅提供已确认的范围与验收草案，**不得**因 brainstorm 已批准而省略用例图、三维度逻辑、节点描述表或业务流程图。

#### Part 1：需求内容清单与术语（仅第一个实例或未实例化时执行）

1. 从功能列表归纳独立需求项，按 requirement-analysis-standard.md 中 2.1 表格列填写需求内容清单
2. 编写 2.2 基本术语定义（**优先采用 business/custom 已有术语**）
3. 2.3 非功能性清单参考：引用标准中的类别表

#### Part 2：逐需求项业务流程建模

对分配的每个需求项，按以下结构撰写：

**3.1 需求概述**：一句话说清业务/系统结果；若为「扩展/复用」，注明关联的知识库模块或历史需求

**3.2.1 用例图**：Mermaid flowchart，标出参与者与系统边界内的用例。参与者从 Phase B 的角色清单中获取；系统边界须与 application 知识一致

**3.2.2 前置条件**：进入流程前必须满足的状态；无则写"无"

**3.2.3 触发事件及重要逻辑**：

【三维度逻辑强制规则】凡涉及前端交互的需求项，重要逻辑必须严格包含：
- 页面操作维度：入口位置、操作顺序、弹窗/抽屉/向导、禁用/置灰条件、必填与校验提示文案、提交/取消/保存行为
- 数据展示维度：字段清单（含标签与顺序）、默认值与只读规则、空态与加载态、分页/排序/筛选、提示展示方式
- 数据交互维度：接口或消息、请求参数与来源、响应字段、读写库/缓存、外部系统同步、幂等与重试、失败回滚

**复用已有接口时**：须引用 code 知识库中已有 API 路径与方法，不臆造新接口名。

**3.2.3.1 业务流程图**：流程步骤 ≥ 5 步或存在多分支时必须生成 Mermaid flowchart TD

**3.2.4 节点描述**：表格（节点编号、节点名称、责任对象、动作简述）。责任对象取值：前端、服务端、网关/中间件、外部系统

**3.2.5 后续动作**：正常结束后的状态变化、写库、消息、跳转、后置条件

**3.2.6 核心流转与数据一致性分析（可选）**：涉及资金或核心数据时建议填写；无则写"无"

**3.2.7 非功能性清单（可选）**：从 Phase B 的非功能线索中提取本需求项相关的指标

#### Part 2.5：溯源挂载（每个需求项建模完成后执行）

按 `fact-source-standard.md` §4 挂溯源，粒度如下：

| 内容类型 | 处理方式 |
|----------|---------|
| **数字型事实**（3.2.3 各维度、3.2.6、3.2.7 中的数字） | 正文就地挂 `[FS-00X]`；无对应事实源 → 挂 `[推断待确认]` |
| **关键业务规则**（校验规则、准入条件、计算口径、权限规则、状态流转条件） | 正文就地挂 `[FS-00X]` |
| 字段清单、接口/消息名、状态取值、外部系统名、角色 | 不在正文挂标记，回填到事实源表 `关联需求项` 列 |

**Part 2.5 硬约束**：

- 本需求项正文中出现的每一个数字，必须二选一——挂 `[FS-00X]` 或挂 `[推断待确认]`，**不允许裸数字**
- 声明「复用已有接口」的接口路径必须对应事实源表 §4 接口引用清单中一条已验证的 F3；**未验证的接口不得声明为复用**
- 材料与知识库均无出处的接口，写为占位（如 `POST /api/<待确认>`）并挂 `[推断待确认]`，**禁止**编造看起来合理的路径
- 复用/扩展关系的需求项，3.1 需求概述中引用的知识库模块或历史需求须带锚点

#### Part 3：隐藏场景补强

对每个需求项检查并回填到 3.2.3/3.2.4/3.2.6：
1. 边界：空值、极值、大批量、重复提交
2. 异常：超时、下游失败、部分成功、幂等与重试
3. 特殊：特定角色、特殊时间窗口、特殊业务状态
4. 集成：跨系统数据一致、回调、对账、补偿

**补强内容的溯源**：本 Part 产出多为 F5 推断。凡材料与知识库均无据的补强项，须挂 `[推断待确认]`，并在事实源表 §5「F5 待降级条目」中登记。**禁止**把补强出的边界值、超时值、重试次数写成确定事实。

### 关键约束

- 不引入材料未授权的新功能
- 不臆造知识库中不存在的模块/接口/流程；缺口用 `[知识库待补充]`
- **不臆造数字**：正文中不得出现无来源且未标记的金额、时限、阈值、条数、超时、重试次数
- **不臆造接口名**：未经检索验证的接口不得声明为「复用已有接口」
- **不虚标级别**：推断内容不得在事实源表中标为 F1/F2
- **不消费未认领推断**：brainstorm 中未处理的 `[AI推断]` 不得作为权威输入（须先 Halt 回退 Step 0 Phase F）
- **历史需求只读**：可参照 `{OCSPEC_ROOT}/requirements/<历史>/` 下文档增强 §9 对照；**禁止**复制历史正文、**禁止**修改历史文件、**禁止**将 `{BASE_DIR}` 指向历史目录；**禁止**默认「在历史需求基础上直接续写/实现」——仅当用户 prompt **明确指定**时方可偏离，否则 Halt 确认
- 不写文档信息和总体概述的最终版本
- 不产出可运行代码
- 不处理未分配给本实例的需求项
