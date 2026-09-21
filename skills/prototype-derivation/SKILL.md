---
name: prototype-derivation
description: 从设计原型（Axure 导出 HTML、Figma 导出或同类静态包）推导结构化需求追溯物：模块映射、规则摘录、冲突矩阵与交付正式规格前的交接说明。通过 4 步分步执行降低单次上下文压力，确保在不同编辑器和模型下产出一致。在用户需要分析原型、在写 REQ/PRD 之前先做推导稿、或要求将 HTML 规则追溯到需求时使用。触发词：原型推导、分析原型、推导需求、原型到需求、Axure 分析、原型摘录、prototype derivation。
base-dir-scope: requirement
---

# 原型 → 需求推导

本技能聚焦**分析与推导过程**（索引表、推导明细、冲突日志等）。一旦进入从推导结果撰写并落盘正式需求文档的阶段，**必须**完整使用 `requirement-analysis` 技能包。

## 何时使用

- 存在静态原型包（如 Axure：`start.html`、各页 HTML、`document.js` / 站点图）
- 需要从原型区块追溯到后续需求项/用例 ID
- 多页或多段文案描述同一行为，存在静默冲突风险
- 规则落在文本组件、表格等默认可见区域

## 核心能力

- 盘点原型来源、页面角色与可追溯区块
- 从可见 HTML/原型内容摘录规则并保留来源索引
- 检测跨页规则冲突、记录决策和笔误处理
- 产出交接给 `requirement-analysis` 的推导稿

## 执行原则

- 以用户提供的原型材料为据，**不臆造**材料中未出现的功能；缺失信息用 `[需与产品确认]` 并列出待澄清问题
- 术语、模块命名在全文保持一致
- **HTML 可见性**规则贯穿全流程：`display:none` / `visibility:hidden` 节点一律跳过
- **严禁修改项目代码**：本技能仅用于从原型推导分析需求，**禁止以任何形式（写入、替换、追加、删除、重命名）修改项目源码、配置文件、构建脚本或任何非本技能指定交付物路径下的文件；所有产出仅允许写入本技能指定的中间目录（`_workspace/prototype/`）与最终交付物（`requirement/prototype-derivation.md`）

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/prototype-derivation-reference.md` | Axure HTML 结构、来源盘点清单、文本/表格摘录要点、冲突日志模板、推导索引表模板、交接说明模板、笔误处理、非 Axure 原型处理、与 requirement-analysis 衔接说明 |

## 路径与目录约定

- **权威来源**：`{COMMANDS_ROOT}/scheduler-protocol.md` §1（含 §1.6）；`base-dir-scope: requirement`
- **终稿**：`{REQ}/prototype-derivation.md`
- **中间产物**：仅 `{WORKSPACE}/prototype/`；原型 HTML 等临时材料可放 `{WORKSPACE}/input/`
- Init 须先输出 `[路径解析]`；**禁止**工作区根 `_workspace/`、根 `requirements/`

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 完成 Init（§1.0~§1.4）：新建或复用 `{BASE_DIR}`（与后续 `requirement-analysis` 宜为同一需求目录）
3. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

**读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 后，按下方步骤声明开始执行。**

## 与其他技能的关系

- **本技能**：止于推导与可追溯交付物（索引、明细、冲突日志、交接说明）
- **下游**：`requirement-analysis` 接收推导产出作为输入，产出正式需求文档

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

---

## Phases

### Phase: prototype-derivation

halt-after: true

- Step 1: steps/step-01-source-inventory.md
- Step 2: steps/step-02-rule-extraction.md
- Step 3: steps/step-03-conflict-detection.md
- Step 4: steps/step-04-handover.md

---

## 交付物

- `requirement/prototype-derivation.md`（推导索引表 + 推导明细 + 冲突日志 + 交接说明）

## 反模式

- 未经用户说明就写入特定仓库路径或内部工单链接
- 因「某页看起来更新」就跳过冲突行——除非产品已确认
- 把推导稿（追溯、摘录）与权威规格（签字范围、完整非功能）混为一谈
- 从 `display:none` / `visibility:hidden` 节点抽取条文并写入需求
- **修改项目代码**：以任何形式（写入、替换、追加、删除、重命名）改动项目源码、配置、构建脚本或任何非本技能交付物路径下的文件
