# Step 3: 成稿组装与评审自检 [强制停止]

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-03-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/requirement/00-brainstorm.md`, `{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`, `{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/02-verify-report.md`]
- input_files_subagent: [`{WORKSPACE}/requirement/00-brainstorm.md`, `{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`, `{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/02-verify-report.md`]
- output_file: `{REQ}/requirement.md`
- reference_files: [`references/requirement-analysis-standard.md`, `references/review-checklist.md`, `references/fact-source-standard.md`]
- status_report_file: `{WORKSPACE}/requirement/03-status-report.md`
- upstream_compare: [`{WORKSPACE}/requirement/00-brainstorm.md`, `{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/02-verify-report.md`]

## 前置条件（Scheduler 强制）

- Step 2 已完成，`{WORKSPACE}/requirement/02-verify-report.md` 存在
- 报告中 `GATE_RESULT` 为 `PASS` 或 `CONDITIONAL`；为 `FAIL` 时**禁止**执行本步骤（见 `steps/step-02-fact-source-verify.md` §3）

## 执行指令

### 1. 输出路径自检

1. 确认 Init 已输出 `[路径解析]`，且 `{OCSPEC_ROOT}`、`{BASE_DIR}`、`{REQ}` 已解析（见 scheduler-protocol §1.0、§1.2.1）
2. 终稿必须写入 `{REQ}/requirement.md`（即 `{OCSPEC_ROOT}/requirements/<需求>_<日期>/requirement/requirement.md`）
3. **禁止**：工作区根 `_workspace/`、工作区根 `requirements/`、未在 §1.2.1 选定的并行 `ocspec-*` 目录
4. 若 `{output_file}` 不在 `{REQ}/` 下，修正后再落盘

### 2. 按顺序组装

**下游等价性（强制）**：终稿 `{REQ}/requirement.md` 须与 `requirement-analysis` 产出**同结构、同粒度**，供 `fullstack-design` / `task-split` 直接消费。组装规则与 `skills/requirement-analysis/steps/step-03-assemble.md` §2 **一致**。

**禁止写入终稿**（仅作中间产物或 status report）：

- `00-brainstorm.md` 全文或独立章节
- `01-intake.md` §7～§11（知识库就绪度、对照表、历史需求表、待澄清清单、事实源摘要）的**整章复制**——其中已确认信息须**融入** §1/§2/需求项正文
- `01-fact-source.md` 全文（事实源表归档到 `sources/`，不写入终稿正文）
- `02-verify-report.md` 全文或独立章节（校验报告是过程产物）
- `<!-- STATUS_REPORT -->`、`[知识库待补充]`（终稿前须清零或转为正式表述）

> 例外：`[FS-00X]` 溯源引用与 §1.1 的「事实源索引」行**须**保留在终稿。

按以下结构拼接中间产出。合并时必须剥离每个中间产出末尾的 `<!-- STATUS_REPORT -->` 块。
```
# [需求名称] — 需求规格说明书

## 1. 文档信息
### 1.1 基础信息（从 01-intake.md 提取）
> §1.1 基础信息表此处不写"事实源索引"行；该行由后续 §5.5「事实源落标记与归档」在终稿落盘后回写追加。
### 1.2 修订历史（至少一行初稿）

## 2. 总体概述
### 2.1 需求内容清单（从 01-modeling.md 提取）
### 2.2 基本术语定义（从 01-modeling.md 提取）
### 2.3 非功能性清单参考（引用标准类别表）

## 三、[需求项1名称]（从 01-modeling.md 提取）
### 3.1 需求概述
### 3.2 业务流程
...

## 四、[需求项2名称]（从 01-modeling.md 提取）
...
```

### 3. 全局一致性校验

- 术语一致性：需求项名称在 2.1 清单和各大标题中完全一致；术语在 2.2 定义和正文中使用一致；角色名称在用例图和节点描述中一致
- **Brainstorm 一致性**（产品版）：`00-brainstorm.md` §4 功能清单与 §2.1 需求内容清单一致；§5 验收口径在正文 Given-When-Then 或流程中有落点
- **知识库对照一致性**（产品版）：01-intake.md §8 标注「复用/扩展」的项，在正文中须体现为增量描述而非重复新建；§8「疑似重复」项须在待确认项或正文中有所回应
- **历史需求一致性**（产品版）：01-intake.md §9 标注「迭代」关系的项，3.1 需求概述须**文字说明**与历史需求的关系（摘要级，非复制历史正文）
- **历史需求只读**：终稿仅写入 `{REQ}/requirement.md`（本次新目录）；**禁止**修改 `{OCSPEC_ROOT}/requirements/<历史>/` 下任何文件；**禁止**大段复制历史 `requirement.md` 内容；除非用户 prompt **明确指定**续写历史文件
- 节点追溯性：每个需求项的节点编号与触发逻辑步骤序号可对应；责任对象取值限定为：前端、服务端、网关/中间件、外部系统
- 需求覆盖：01-intake.md 功能列表中的每个需求项在正文中有对应的大标题章节；5W1H 中识别的每个角色在相关用例图中有体现
- **溯源完整性**：正文中每个 `[FS-00X]` 引用在 `01-fact-source.md` 中确实存在该 ID；正文无裸数字（每个数字均已挂 `[FS-00X]` 或待确认标记）
- **推断隔离**：`00-brainstorm.md` 中未认领的 `[AI推断]` 条目未进入正文（若发现则移除或转为待确认项）
- 格式规范：Mermaid 图表语法正确、表格列完整、全文 UTF-8

### 4. 评审自检

打开 `references/review-checklist.md`，逐项检查：需求完整性、Given-When-Then、5W1H、隐藏场景、核心流转与数据一致性、非功能。

### 5. 修正与落盘

- 发现不一致处：直接修正
- 无法自动修正的：标注 `[需与产品确认]`
- 写入正式路径

### 5.5 事实源落标记与归档（终稿落盘后执行）

> **执行时机硬约束**：本环节须在 §5 落盘之后——届时 REQ 编号已定稿，事实源表的 `关联需求项` 列才能回填最终编号。须在 §6 清零之前——清零需把事实源相关标记纳入扫描。
> **路径硬禁令**：创建 `sources/`、写 `fact-source.md` 一律用文件写入工具，**严禁 shell 拼接含 `{BASE_DIR}` 的路径**（`{BASE_DIR}` 含中文时 shell 会按 GBK 乱码并在工作区根误建目录）。

1. **落标记**：读取 `{WORKSPACE}/requirement/02-verify-report.md` §7「待标记项汇总」，按其中每条的「位置 + 应打标记」，在已落盘的 `{REQ}/requirement.md` 对应位置补打 `[事实源存疑]` / `[事实源缺失]` / `[推断待确认]`。
   - **不得**擅自改写正文内容，只补标记
   - **不得**遗漏报告中列出的任何一条；遗漏视为绕过门禁
2. **回填编号**：从终稿读取每个需求项最终 REQ 编号，回填 `01-fact-source.md` 的 `关联需求项` 列；同时把 Step 2 的核验结论写入 `校验状态` 列（可信/存疑/缺失）。
3. **归档**：用工具创建 `{BASE_DIR}/sources/`，将回填后的事实源表写入 `{BASE_DIR}/sources/fact-source.md`。
4. **回写索引行**：在终稿 §1.1 基础信息表追加一行「事实源索引 | `../sources/fact-source.md`」。
5. **下游提示**：在归档的 `fact-source.md` 开头写明用途——供 `fullstack-design` 区分**硬约束**（F1/F2/F3 且校验状态为可信）与**待确认项**（存疑/缺失/推断），避免下游把推断当约束实现。
6. **知识库缺口交接**：把 Step 2 报告中判定为 `[知识库待补充]` 的主题（区别于 `[事实源缺失]`）汇总到状态报告，供 **Step 4** 同步知识库时参考。

### 6. 待确认项清零检查（终稿强制）

扫描终稿全文，搜索下列残留标记。如有残留，状态必须为 `DONE_WITH_CONCERNS`：

`[需与产品确认]`、`[需人工确认]`、`[知识库待补充]`、`[事实源存疑]`、`[事实源缺失]`、`[推断待确认]`、`<!-- STATUS_REPORT -->`

> `[FS-00X]` 是**正常溯源引用**，不属于待确认标记，**不纳入清零**。

状态报告写入 `{WORKSPACE}/requirement/03-status-report.md`，不写入终稿。

### 7. 与 Step 4 的衔接（产品版强制）

- 本步骤 **不得** 删除 `{BASE_DIR}/_workspace/`（过程产出清理由 **Step 4** 在用户确认同步意图后统一执行）
- 本步骤 **不得** 删除 `{BASE_DIR}/sources/`（该目录是持久产出，随终稿一同保留与同步）
- Step 3 交付 Halt 后，Scheduler **必须** 进入 Phase `kb-sync`（Step 4），**强制提示**是否将终稿同步至知识库仓库
