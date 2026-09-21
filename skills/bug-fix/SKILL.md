---
name: bug-fix
description: 通用 bug 修复技能。对照需求/设计基线与代码现状定位根因，按分级（L1/L2/L3）控制校验深度，小范围修复并最小编译验证。不处理需求/设计阶段缺陷，不读批量编码协议。通过 5 phase / 7 step 分步执行。触发词：修 bug、修复问题、排查问题、bug fix、bug 修复。
base-dir-scope: requirement
halt-policy: phase-end
---

# 通用 bug 修复

## 何时使用

修复已编码代码库中已观测到现象的缺陷（运行异常 / 逻辑错误 / 样式问题 / 数据问题 / 性能问题 / 回归问题）；根因可明确，也可由本技能排查后定位。

**前提**：缺陷所在源码已存在；该需求的设计/需求文档或 `knowledge/code` 基线已生成。

**不适用**（应转其他技能）：

| 场景 | 去向 |
|---|---|
| 需求本身写错/漏 | `requirement-analysis` / `product-requirement-analysis` |
| 设计方案错/接口设计错 | `fullstack-design`（必要时 `task-split`） |
| 尚未编码的新功能 | design → task-split → code 主流水线 |
| 修复需改对外接口/DDL/新模块/引入新依赖（越界） | 本技能识别后升级 `fullstack-design` + `task-split` |

> 一次运行修一个 bug；多个 bug 顺序多次触发，记录追加进同一 log。

> **BASE_DIR 归属**：bug 修复挂靠它所修功能对应的需求目录作 `{BASE_DIR}`，产出 `bug/` 子目录（与 `design/`、`task/` 平级），并以该需求 `{DESIGN}`/`{REQ}`/`{TASK}` 为预期行为基线。多需求时由协议 §1.2 在 Init 阶段 Halt 请用户指定归属。无设计文档时按「基线输入」退化到 knowledge 三层。本技能不创建新需求目录。

## 核心能力

- 对照**预期行为基线**（需求/设计文档，或退化知识库三层）与代码现状定位根因，使修复对齐设计意图而非主观发挥
- 定向根因定位：先判知识库布局再定向读、追调用链，根因精确到文件+行号
- 影响面冻结：方案层产「允许改动文件清单」，实施后逐仓 `git diff` 比对，超出即 WARN
- 单一复现/验证：静态因果自证（强制）+ 纯逻辑 bug 单测复现转绿（客观触发）+ 运行时类人工回归点
- 复用 `build-verifier` 最小编译、`code-reviewer` L3 回归审查

## 执行原则

- 知识库索引优先，禁止全量读
- 根因未定位（文件+行号+基线对照）不得改码
- 改前必经用户确认门禁；方案越界即升级，不在本技能内硬改
- 分级须附机械证据并向用户明示，用户可升档，缺证据 fallback L2，AI 不得自我降级

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/bug-triage-standard.md` | 分级判定 + 机械证据 + 类型路由 + 越界阈值 |
| `references/fix-plan-template.md` | 修复方案（fix-plan）字段骨架 |
| `references/regression-checklist.md` | L3 回归审查检查项（引用 fullstack-code-review p0 清单） |
| `references/bugfix-log-template.md` | bug-fix-log 记录模板 |

## 基线输入

bug 修复对照两类输入定位根因：**事实基线**（代码现状，来自 `{CODE_KNOWLEDGE}` + 仓库源码）+ **预期行为基线**（应该是什么样）。预期行为基线按可得性取用：

| 优先级 | 来源 | 说明 |
|---|---|---|
| 1（最强） | `{DESIGN}/` 设计文档（architecture/backend/frontend-design.md）+ `{REQ}/requirement.md` + `{TASK}/task-split.md` | 该需求已有设计/任务文档时，作为接口/时序/模型级权威对照 |
| 2（退化） | `{KNOWLEDGE}/business/` + `{KNOWLEDGE}/application/` | 无设计文档时，以领域规则/应用拓扑作领域级预期行为 |
| 3（最弱） | 仅 `{CODE_KNOWLEDGE}` + 源码 | 无任何应然基线，修复基于代码现状推断，须标注 `[无设计基线，须人工确认预期行为]` |

> bug 归属哪个需求即以该需求目录为 `{BASE_DIR}`，`{REQ}`/`{DESIGN}`/`{TASK}` 自然解析到位。

## 路径与目录约定

- **权威来源**：`{COMMANDS_ROOT}/scheduler-protocol.md` §1（含 §1.6）；`base-dir-scope: requirement`
- **BASE_DIR**：bug 所修功能归属的需求目录（协议 §1.2 解析）
- **持久产出**（需求目录下 `bug/`，与 `design/`、`task/` 平级）：
  - `{BASE_DIR}/bug/<id>-<slug>-fix-plan.md`：每个 bug 的完整修复方案留底（改前门禁依据）
  - `{BASE_DIR}/bug/bug-fix-log.md`：bug 修复台账索引（追加式，一行一个 bug）
- **中间产物**：统一在 `{WORKSPACE}/bugfix/` 下（inline 步骤直接写；`build-verifier` 写 `{WORKSPACE}/bugfix/build/`、`code-reviewer` 写 `{WORKSPACE}/bugfix/review/`）
- Init 须先输出 `[路径解析]`。
- **中间产物清理（覆盖通用协议 §9.1）**：用户回归验证通过后才清理——Step 7 交付时提示回归并保留中间产物，用户回「回归通过/可清理」才**仅清理 `{WORKSPACE}/bugfix/`**（`bug/` 持久保留，不整体删 `{WORKSPACE}`）；回「回归失败」则保留供复诊。延后理由：bug-fix 验证常待人工运行时回归才闭环，中间产物是复诊依据。

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4）：解析 `{BASE_DIR}`（多需求 Halt 请用户指定归属需求）、`{REQ}`/`{DESIGN}`/`{TASK}`/`{KNOWLEDGE}`/`{CODE_KNOWLEDGE}`
3. 确认用户已带入明确 bug 现象与涉及仓库；信息不足 → Step 1 产 NEED_INFO → Halt
4. 按下方 phases/steps 声明驱动执行

## 与其他技能的关系

- 复用 agent：Step 2 `bug-analyzer`、Step 5 `build-verifier`（仅编译）、Step 6 `code-reviewer`（L3，仅只读审查）
- L3 复用 `code-reviewer` agent，不触发 `fullstack-code-review` skill
- 越界时升级 `fullstack-design` + `task-split`

---

## Phases

### Phase: triage

halt-after: false

- Step 1: steps/step-01-intake-and-triage.md

### Phase: locate-and-plan

halt-after: true

- Step 2: steps/step-02-locate-and-impact.md
- Step 3: steps/step-03-fix-plan.md

### Phase: implement-verify

halt-after: false

- Step 4: steps/step-04-implement.md
- Step 5: steps/step-05-verify.md

### Phase: regression-guard

halt-after: false
precondition: Step 1 判级结果为 L3（非 L3 时整个 Phase 跳过）

- Step 6: steps/step-06-regression-guard.md

### Phase: record

halt-after: true

- Step 7: steps/step-07-record.md

---

## 交付物

- `{BASE_DIR}/bug/<id>-<slug>-fix-plan.md`（每个 bug 的完整修复方案留底，持久）
- `{BASE_DIR}/bug/bug-fix-log.md`（bug 修复台账，追加式）
- 业务仓库代码变更（含纯逻辑 bug 的最小单测）

## 门禁与分级

- 门禁 = 2 道：改前确认（Phase locate-and-plan 末）+ 最终交付（Phase record 末），均由 phase `halt-after` 实现
- 最终交付 Halt 后借同一 Halt 等用户回归结果再决定清理/复诊（见上清理说明），不新增 phase
- 分级只控校验深度：L1/L2 走 4 个 phase（regression-guard 因 precondition 不满足跳过）；L3 走全部 5 phase

## Summary 机制

Step 2 定位产出有下游依赖，须按 step 文件 Summary 配置生成摘要（根因 + 基线出处 + 影响面 + 纯逻辑标注）供下游使用。
