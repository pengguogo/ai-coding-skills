---
name: requirement-analysis
description: 将原始需求整理为符合团队标准的 Markdown 需求文档，并用 5W1H、事实源门禁与评审清单支撑澄清与评审。通过 3 步分步执行。适用于任意技术栈；在用户要分析需求、整理需求文档或需求评审时使用。触发词：需求分析、需求整理、需求评审、requirement analysis。
base-dir-scope: requirement
---

# 需求分析

## 何时使用

- 用户需要分析需求、整理/标准化需求文档、需求评审/澄清
- 用户提供原始材料（Word、PDF、文本、会议纪要、聊天摘录等）要求输出结构化需求
- 产出边界：结构化 Markdown + Mermaid 图表，不产出可运行代码

## 核心能力

- 将原始材料整理为标准化 Markdown 需求文档
- 使用 5W1H、三维度逻辑和 Given-When-Then 建模需求项
- 补强异常流、边界条件、权限校验等隐藏场景
- 按评审清单完成完整性、非功能和跨系统协同自检
- 发现/提取/识别/理解材料内图片（独立图 + docx/pptx/pdf 内嵌图），归档到 `sources/media/` 并生成索引
- 图片↔需求项双信号合理性校验（归属存疑/无法识别打标记并纳入清零）
- **事实源登记与分级**（F1~F5）：关键条目与数字型事实登记来源锚点，落 `sources/fact-source.md` 供下游区分硬约束与待确认项
- **事实源门禁**（Step 2）：独立 agent 做正向溯源核验 + 反向无源断言检测，结论 `PASS`/`CONDITIONAL`/`FAIL`；`FAIL` 阻止成稿

## 执行原则

- 以用户提供的材料为据，不臆造材料中未出现的功能；缺失信息用 `[需与产品确认]` 并列出待澄清问题
- 术语、优先级、需求项 ID 在全文保持一致
- 节点描述中的责任对象（前端/服务端/网关·中间件/外部系统）须与 `requirement-analysis-standard.md` 约定一致
- **三维度逻辑强制**：凡涉及前端交互的需求项，触发事件及重要逻辑必须包含页面操作维度、数据展示维度、数据交互维度
- **图片不得漏看**：材料内所有图片必须逐张识别并记录信号 A（位置）/信号 B（内容锚点）
- **事实源可回溯**：关键条目须能定位到来源锚点；规则见 `fact-source-standard.md`
- **数字不得臆造**：金额、时限、阈值、条数、超时、重试次数等仅允许 F1/F2 来源；无据则标 `[推断待确认]`，正文不允许裸数字
- **推断不得伪装成事实**：F5 推断进正文前必须降级（标记或由用户认领升 F2）
- **门禁不得绕过**：Step 2 结论为 `FAIL` 时禁止进入成稿组装

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/requirement-analysis-standard.md` | 成稿结构：文档信息、总体概述、各需求项的需求概述与业务流程 |
| `references/5w1h-analysis-guide.md` | 5W1H 分析法：Why/What/Who/When/Where/How 的问题与示例 |
| `references/review-checklist.md` | 评审与自检：完整性、Given-When-Then、隐藏场景、非功能等检查项 |
| `references/fact-source-standard.md` | 事实源分级（F1~F5）、锚点精度、双信号校验、标记语义、校验强度与门禁结论 |

## 路径与目录约定

- **ocspec 根**：`{OCSPEC_ROOT}` = 工作区根下 `ocspec-*` 目录（机械扫描解析）；多个候选时用户在对话中指定；无候选时 Init 按 §1.2.2 兜底新建。**无需修改本 SKILL**（见 scheduler-protocol §1.2.1～§1.2.2）。
- **需求目录**：`{OCSPEC_ROOT}/requirements/<需求英文名>_<yyyymmdd>/` = `{BASE_DIR}`。
- **中间产物**：仅允许 `{BASE_DIR}/_workspace/`；**禁止**工作区根 `_workspace/`。
- **终稿**：`{BASE_DIR}/requirement/requirement.md`。
- **图片临时点**：`{WORKSPACE}/input/media/`（提取/解包临时区，归档后随 `_workspace/` 清理）。
- **图片归档点**：`{BASE_DIR}/sources/media/`（持久；与 `requirement/`、`design/` 同模式由 step-03 顺手创建；终稿以相对路径 `../sources/media/README.md` 索引引用）。
- **原始 PRD 归集点**：`{BASE_DIR}/sources/`（根；step-03 §6.5 收拢本需求原始材料）。
- **事实源归档点**：`{BASE_DIR}/sources/fact-source.md`（持久；step-03 §5.5 归档；终稿以 `../sources/fact-source.md` 索引引用）。
- **自定义知识（可选）**：`{CUSTOM_KNOWLEDGE}` = `{KNOWLEDGE}/custom/`；`CUSTOM_KNOWLEDGE_STATUS=absent` 时跳过，不 Halt（见 scheduler-protocol §1.5.1）。
- Init 阶段须先输出 `[路径解析]` 摘要（scheduler-protocol §1.4），再执行任何写文件步骤。
- 路径布局快速对照见 scheduler-protocol **§1.6**（不再维护独立 reference 文件）。

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init：先 §1.2.1 **机械扫描** `ocspec-*`（扫描非空则**必须用已有候选**，禁止兜底新建）→ 解析 `{OCSPEC_ROOT}` → `{BASE_DIR}` → `{WORKSPACE}`（§1.0~§1.4）
3. **目录名格式校验**：若选中的 `{BASE_DIR}` 目录名不匹配 `*_yyyymmdd` 格式（如含版本号、无日期后缀），则视为用户材料投放文件夹——新建 `<需求名>_<当前日期>/`，用工具把该文件夹内容移入，以新目录为 `{BASE_DIR}`。
4. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

## 与其他技能的关系

- 上游：（可选）`prototype-derivation` 提供原型推导物料；（可选）`{CUSTOM_KNOWLEDGE}/` 提供团队自定义业务知识补充
- 下游：`fullstack-design` 依赖 `requirement/requirement.md` 作为设计输入

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: requirement-analysis

halt-after: true

- Step 1: steps/step-01-analysis-and-modeling.md
- Step 2: steps/step-02-fact-source-verify.md
- Step 3: steps/step-03-assemble.md

> **门禁语义**：Step 2 为事实源门禁。`GATE_RESULT: FAIL` 时 Scheduler **禁止** `Next` 到 Step 3，须回退 Step 1 修正后重跑 Step 2（见 `steps/step-02-fact-source-verify.md` §3）。

---

## 交付物

- `requirement/requirement.md`（完整的标准需求文档）
- `sources/fact-source.md`（事实源登记表，供下游区分硬约束与待确认项）

## 动态分批规则

步骤 1 为 template 类型，内部分 Phase A（输入接收）、Phase A3（事实源登记）、Phase B（5W1H 分析）和 Phase C（需求项建模）四阶段。Phase A+A3+B 先产出输入摘要、事实源表和分析结果，Phase C 基于功能列表做 template 分批建模。

步骤 2 为 static 类型，默认委派 `requirement-verifier`；需求项 ≤ 2 且事实源条目 ≤ 15 且无图片时降级为 inline 执行（见 step-02 §1）。
