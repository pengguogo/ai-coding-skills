---
name: product-requirement-analysis
description: 面向产品人员的需求分析：Intake 与拉取 ocspec 知识库、Step 0 功能向头脑风暴澄清需求，经事实源门禁校验后对照知识库成稿并同步 requirement.md。触发词：产品需求分析、产品版需求分析、带知识库需求分析、product requirement analysis。
base-dir-scope: requirement
---

# 产品需求分析

## 何时使用

- 产品人员需要分析需求、整理/标准化需求文档，且需**先拉取并对照知识库**
- 工作区尚未通过 `workspace-init` 初始化，但已有远程 ocspec 知识库仓库
- 用户提供简单背景或原始材料；在 **Step 0** 内完成拉库与功能向对话澄清后再成稿
- 产出边界：结构化 Markdown + Mermaid 图表，不产出可运行代码

## 与 requirement-analysis 的关系

| 能力 | requirement-analysis | product-requirement-analysis |
|------|---------------------|------------------------------|
| 5W1H 与需求项建模 | ✅ | ✅（Step 1 增强对照） |
| 事实源登记与门禁 | ✅（维度 1/2/6） | ✅（**全 6 维度**，Step 2） |
| 成稿组装与评审自检 | ✅ | ✅（同 Step 3 结构与 L2） |
| 读取 business/application/code 三层 | ❌ | ✅（Step 1 §8） |
| 知识库引用真伪验证 | ❌ | ✅（Step 2 维度 3） |
| 推断升格检测 | ❌ | ✅（Step 2 维度 4） |
| 历史需求对照 | ❌ | ✅（Step 1 §9 + Step 2 维度 5） |
| Intake + 拉库 + 头脑风暴 | ❌ | ✅（**Step 0 单步骤**） |
| 终稿同步知识库 + 过程清理 | ❌ | ✅（Step 4） |

## 核心能力

- **Step 0（合并）**：Intake → 知识库拉取 → Pin → Init → 功能向头脑风暴（**≤10 轮**）→ 推断认领门 → `00-brainstorm.md` approved
- **知识库门禁**：无 URL 且无确认则 Halt；禁止擅自新建 `ocspec-*`
- **事实源门禁（Step 2）**：全 6 维度独立校验（溯源真实性、无源断言、知识库真伪、推断升格、历史只读、内部一致性），结论 `PASS`/`CONDITIONAL`/`FAIL`；`FAIL` 阻止成稿
- **需求成稿**：同 `{REQ}/requirement.md` 结构与路径 + `sources/fact-source.md` 归档
- **Step 4**：强制同步提示 → 清理过程产出 → push 终稿与事实源归档

## 执行原则

- Step 0 Phase A 缺材料/分支 → Halt；缺 URL 且无 CONFIRM → Halt
- Step 0 Phase C 完成后 **Init**，再 Resume Step 0 进入头脑风暴（Phase D～F）
- **推断不得伪装成事实**：Phase F 的 `[AI推断]` 条目须由用户认领或移入待澄清，才允许 approved
- Step 0 头脑风暴 approved 后进入 Step 1
- **事实源可回溯**：知识库引用锚点须精确到文件 + 章节/接口签名；数字型事实仅允许 F1/F2
- **接口不得臆造**：声明「复用已有接口」须能在 `{CODE_KNOWLEDGE}` 检索到
- **门禁不得绕过**：Step 2 结论为 `FAIL` 时禁止进入 Step 3
- Step 4：用户确认后 push；**提交前强制清理** `_workspace` 与 Pin 会话目录；**禁止误删** `sources/`

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/product-brainstorm-guide.md` | Step 0 Phase D～F 对话澄清 |
| `references/product-intake-guide.md` | Intake 与 Init 绑定 |
| `references/knowledge-requirement-sync-guide.md` | Step 4 同步与清理 |
| `references/knowledge-base-pull-guide.md` | Step 0 Phase B 拉库 |
| `references/knowledge-readiness-standard.md` | 就绪度评估 |
| `references/knowledge-cross-reference-guide.md` | Step 1 对照 |
| `references/fact-source-standard.md` | 事实源分级、锚点精度、双信号校验、门禁结论；§9 产品版专属（推断认领门、知识库引用真伪） |
| `references/requirement-analysis-standard.md` | 成稿结构 |

## Init 覆盖规则（本技能强制）

Init 在 Step 0 **Phase C 完成后、Phase D 之前**执行（非独立 Phase）。须读取 Pin 中 `OCSPEC_ROOT_PIN` 绑定 `{OCSPEC_ROOT}`；详见 SKILL 原文 §Init 与 `product-intake-guide.md`。

## 路径与目录约定

- **Pin**：`{KNOWLEDGE}/_workspace/product-req/`（Step 4 清理）
- **Brainstorm**：`{BASE_DIR}/_workspace/requirement/00-brainstorm.md`
- **事实源表（中间）**：`{BASE_DIR}/_workspace/requirement/01-fact-source.md`
- **门禁报告**：`{BASE_DIR}/_workspace/requirement/02-verify-report.md`
- **终稿**：`{BASE_DIR}/requirement/requirement.md`
- **事实源归档（持久）**：`{BASE_DIR}/sources/fact-source.md`（Step 3 §5.5 归档；**不属于** Step 4 清理范围）

## 执行入口

**你是 Scheduler。** 顺序：

1. 读取 `scheduler-protocol.md`
2. **Phase `intake-and-brainstorm`**：Step 0 → Halt（Resume 直至 brainstorm approved，含推断认领门）
3. **Phase `requirement-analysis`**：Step 1 → Step 2（门禁）→ Step 3 → Halt（审查终稿）
4. **Phase `kb-sync`**：Step 4 → Halt（同步提示 → 清理 → push）

---

## Phases

### Phase: intake-and-brainstorm

halt-after: true

- Step 0: steps/step-00-knowledge-base-pull.md

> Phase C（Pin）完成后 Scheduler 执行 Init，再 Resume Step 0 进入 Phase D（头脑风暴）。

### Phase: requirement-analysis

halt-after: true

- Step 1: steps/step-01-analysis-and-modeling.md
- Step 2: steps/step-02-fact-source-verify.md
- Step 3: steps/step-03-assemble.md

> **门禁语义**：Step 2 为事实源门禁，全 6 维度启用。`GATE_RESULT: FAIL` 时 Scheduler **禁止** `Next` 到 Step 3；回退目标按 FAIL 原因区分——推断认领未处理 → 回退 **Step 0 Phase F**，其余 → 回退 **Step 1**（见 `steps/step-02-fact-source-verify.md` §3）。

### Phase: kb-sync

halt-after: true

- Step 4: steps/step-04-kb-sync-and-cleanup.md

---

## 交付物

- Pin 与 `00-brainstorm.md`（Step 4 清理过程文件；终稿 push 入库）
- `{BASE_DIR}/requirement/requirement.md`
- `{BASE_DIR}/sources/fact-source.md`（事实源归档，随终稿一同 push）

## 动态分批规则

步骤 1 为 template 类型，规则同 `requirement-analysis`（Phase A → A3 事实源登记 → B → C 建模含溯源挂载）。

步骤 2 为 static 类型，**始终**委派 `requirement-verifier`；产品版**不启用**降级 inline 模式（知识库真伪与推断升格需大量检索，放主 session 会挤压上下文并降低核验质量）。

## Init 覆盖规则（完整）

Init 在读取 `scheduler-protocol.md` §1.2 后，**须额外执行**：

### OCSPEC_ROOT 绑定

1. 若 Pin 或 Step 0 控制台含 `OCSPEC_ROOT_PIN` → 直接采用为 `{OCSPEC_ROOT}`（高于 §1.2.1）
2. 否则按 §1.2.1 扫描

### BASE_DIR 绑定

1. 从 Pin 读取 `REQUIREMENT_SLUG` 与 `INTAKE_DATE`
2. slug 已提供：`{BASE_DIR}` = `{OCSPEC_ROOT}/requirements/<slug>_<date>/`
3. 未提供：按 §1.2 从材料推断

### Init 摘要额外字段

```markdown
OCSPEC_ROOT_PIN_USED: yes | no
REQUIREMENT_SLUG: <slug>
KNOWLEDGE_READINESS: ready | partial | minimal
```

## 下游交付物等价性（强制）

中间产物不得写入终稿。brainstorm 结论须消化进 Step 1 产出。终稿与 `requirement-analysis` 同结构，供 `fullstack-design` 无差别消费。

`sources/fact-source.md` 亦与 `requirement-analysis` 同结构，供下游区分**硬约束**（F1/F2/F3 且校验状态可信）与**待确认项**（存疑/缺失/推断）。终稿中的 `[FS-00X]` 溯源引用与 §1.1「事实源索引」行属正式交付内容，**不得**作为中间产物剥离。

## 与其他技能的关系

- **替代**：`workspace-init` + `requirement-analysis`（产品单独使用时）
- **下游**：`fullstack-design`
