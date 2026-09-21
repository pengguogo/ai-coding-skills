# Step 3: 成稿组装与评审自检 [强制停止]

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-03-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`, `{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/02-verify-report.md`]
- input_files_subagent: [`{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`, `{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/02-verify-report.md`]
- output_file: `{REQ}/requirement.md`
- reference_files: [`references/requirement-analysis-standard.md`, `references/review-checklist.md`, `references/fact-source-standard.md`]
- status_report_file: `{WORKSPACE}/requirement/03-status-report.md`
- upstream_compare: [`{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/02-verify-report.md`]

## 前置条件（Scheduler 强制）

- Step 2 已完成，`{WORKSPACE}/requirement/02-verify-report.md` 存在
- 报告中 `GATE_RESULT` 为 `PASS` 或 `CONDITIONAL`；为 `FAIL` 时**禁止**执行本步骤（见 step-02 §3 门禁处置）

## 执行指令

### 1. 输出路径自检

1. 确认 Init 已输出 `[路径解析]`，且 `{OCSPEC_ROOT}`、`{BASE_DIR}`、`{REQ}` 已解析（见 scheduler-protocol §1.0、§1.2.1）
2. 终稿必须写入 `{REQ}/requirement.md`（即 `{OCSPEC_ROOT}/requirements/<需求>_<日期>/requirement/requirement.md`）
3. **禁止**：工作区根 `_workspace/`、工作区根 `requirements/`、未在 §1.2.1 选定的并行 `ocspec-*` 目录
4. 若 `{output_file}` 不在 `{REQ}/` 下，修正后再落盘

### 2. 按顺序组装

按以下结构拼接中间产出。合并时必须剥离每个中间产出末尾的 `<!-- STATUS_REPORT -->` 块。

```
# [需求名称] — 需求规格说明书

## 1. 文档信息
### 1.1 基础信息（从 01-intake.md 提取）
> §1.1 基础信息表此处不写"原型图片索引"与"事实源索引"行；两行分别由后续 §6「图片归档与索引」、§5.5「事实源落标记与归档」在终稿落盘后回写追加。
### 1.2 修订历史（至少一行初稿）

## 2. 总体概述
### 2.1 需求内容清单（从 01-modeling.md 提取）
### 2.2 基本术语定义（从 01-modeling.md 提取）
### 2.3 非功能性清单参考（引用标准类别表）
### 2.4 平台信息总览（从 01-modeling.md / 01-intake.md 的 Where 平台归一化结果提取）

## 三、[需求项1名称]（从 01-modeling.md 提取）
### 3.1 需求概述
### 3.1.1 平台适用与差异（从 01-modeling.md 提取；涉及前端的需求项必含）
### 3.2 业务流程
...

## 四、[需求项2名称]（从 01-modeling.md 提取）
...
```

### 3. 全局一致性校验

- 术语一致性：需求项名称在 2.1 清单和各大标题中完全一致；术语在 2.2 定义和正文中使用一致；角色名称在用例图和节点描述中一致
- 节点追溯性：每个需求项的节点编号与触发逻辑步骤序号可对应；责任对象取值限定为：前端、服务端、网关/中间件、外部系统
- 需求覆盖：01-intake.md 功能列表中的每个需求项在正文中有对应的大标题章节；5W1H 中识别的每个角色在相关用例图中有体现
- **平台一致性**：§2.4 总览表中每个需求项的 `Applicable_Platforms` 与 §3.1.1 中实际记录的集合一致；`Shared_REQ_Trace` 在两处逐项匹配；待确认状态在两处同步；`Web_H5_Merge` 声明与实际平台列表一致
- **平台枚举合法**：所有 `Applicable_Platforms` 值只来自 `[Web, iOS, Android, HMOS, H5]`
- **多端完整度**：包含 HMOS 的需求项，§3.2 业务流程中页面操作、数据展示、数据交互与其他端同等完整
- **溯源完整性**：正文中每个 `[FS-00X]` 引用在 `01-fact-source.md` 中确实存在该 ID；正文无裸数字（每个数字均已挂 `[FS-00X]` 或 `[推断待确认]`）
- 格式规范：Mermaid 图表语法正确、表格列完整、全文 UTF-8

### 4. 评审自检

打开 `references/review-checklist.md`，逐项检查：需求完整性、Given-When-Then、5W1H、隐藏场景、核心流转与数据一致性、非功能。

### 5. 修正与落盘

- 发现不一致处：直接修正
- 无法自动修正的：标注 `[需与产品确认]`
- 写入正式路径

### 5.5 事实源落标记与归档（终稿落盘后执行）

> **执行时机硬约束**：本环节须在 §5 落盘之后——届时 REQ 编号已定稿，事实源表的 `关联需求项` 列才能回填最终编号。须在 §7 清零之前——清零需把事实源相关标记纳入扫描。
> **路径硬禁令**：创建 `sources/`、写 `fact-source.md` 一律用文件写入工具，**严禁 shell 拼接含 `{BASE_DIR}` 的路径**（中文 GBK 乱码风险，同 §6）。

1. **落标记**：读取 `{WORKSPACE}/requirement/02-verify-report.md` §7「待标记项汇总」，按其中每条的「位置 + 应打标记」，在已落盘的 `{REQ}/requirement.md` 对应位置补打 `[事实源存疑]` / `[事实源缺失]` / `[推断待确认]`。
   - **不得**擅自改写正文内容，只补标记
   - **不得**遗漏报告中列出的任何一条；遗漏视为绕过门禁
2. **回填编号**：从终稿读取每个需求项最终 REQ 编号，回填 `01-fact-source.md` 的 `关联需求项` 列；同时把 Step 2 的核验结论写入 `校验状态` 列（可信/存疑/缺失）。
3. **归档**：用工具创建 `{BASE_DIR}/sources/`（若 §6 已创建则复用），将回填后的事实源表写入 `{BASE_DIR}/sources/fact-source.md`。
4. **回写索引行**：在终稿 §1.1 基础信息表追加一行「事实源索引 | `../sources/fact-source.md`」。
5. **下游提示**：在归档的 `fact-source.md` 开头写明用途——供 `fullstack-design` 区分**硬约束**（F1/F2/F3 且校验状态为可信）与**待确认项**（存疑/缺失/推断），避免下游把推断当约束实现。

### 6. 图片归档与原始材料归集（存在已提取图片或可归集的原始 PRD 时执行）

> **执行时机硬约束**：本步骤**必须在 §5「修正与落盘」之后执行**——届时 `{REQ}/requirement.md` 终稿已写入磁盘，需求项 REQ 编号（REQ-001/002/...）已最终定稿，图片才能据此正确命名映射；本步骤**必须在 §7「待确认项清零」之前执行**——清零步骤需把图片相关标记纳入扫描。
> 临时图 `{WORKSPACE}/input/media/` 在本步骤完成前不得清理。
> **路径硬禁令（防中文 GBK 乱码）**：创建 `sources/media/` 目录、移动/重命名图片、写 README 一律用文件写入/移动工具完成，**严禁 shell `mkdir`/`New-Item`/`mv`/`Move-Item` 拼接含 `{BASE_DIR}` 的路径**（`{BASE_DIR}` 含中文时 shell 会按 GBK 乱码并丢失分隔符，在工作区根误建 `ocspec-乱码...` 目录）。归档前先核对 `sources/` 的父目录确为已解析的 `{BASE_DIR}`，不得在工作区根另建新 `ocspec-*`。

1. **读取终稿确定最终编号**：从已落盘的 `{REQ}/requirement.md` 读取每个需求项的最终 REQ 编号与章节标题（§三/§四/...），作为命名与索引引用的权威来源（**不再依赖 intake 中"初判"名称**）。
2. **编号映射**：把 intake「图片清单」每张图的信号 A "初判需求项名称" 映射到上一步读出的最终 REQ 编号；映射不上的图标记为"归不到 REQ"。
3. **创建归档目录**：用工具创建 `{BASE_DIR}/sources/media/`（与 `requirement/`、`design/` 同模式，由本步骤顺手创建；`sources/` 根放原始 PRD（见 §6.5），`media/` 放图片归档）。
4. **归档命名**（依据 standard §2.4 命名约定）：
   - 能归到某 REQ → `REQ-00X_序号_描述.<ext>`（REQ 编号取自步骤 1 终稿，序号为该需求项内出现顺序 01、02…）；
   - 无法识别 / 归不到 → `REQ-misc_描述.<ext>`。
   用工具把图片从 `{WORKSPACE}/input/media/` 移动并重命名到 `{BASE_DIR}/sources/media/`，中文名由工具落盘。
5. **写 README 索引**：`fs_write` 生成 `{BASE_DIR}/sources/media/README.md`，列：文件名 / 需求项 / 需求章节（步骤 1 读出的章节号与标题）/ 内容描述 / 设计阶段参考点。
6. **回写正文引用**：在已落盘的 `{REQ}/requirement.md` §1.1 基础信息表追加一行「原型图片索引 | `../sources/media/README.md`」（仅当存在归档时）；正文相关需求项按需引用具体图片（相对路径 `../sources/media/REQ-XXX_*.png`）。
6.5 **原始 PRD 归集（轻量收尾，工具移动；独立于有无图片均执行）**：把本需求 step-01 读取过的原始材料文件（可追溯到 intake「图片清单」来源文件 / step-01 input 记录的 docx/pdf/pptx/txt 等）用**文件移动工具**移动到 `{BASE_DIR}/sources/`（与 `media/` 同级）。
   - 仅移动可明确追溯到"本需求 step-01 输入"的原始文件；归属不明的不移动，在状态报告 concerns 上报，交人工判断。
   - **严禁 shell `mv`/`Move-Item` 拼接含 `{BASE_DIR}` 的路径**（中文 GBK 乱码风险，同上路径硬禁令）。
   - **不递归扫描、不触碰其他 `<需求>_<日期>/` 子目录内文件**，避免把别的需求材料卷入。
   - 移动前确认 BASE_DIR 已解析；移动失败保留原件并上报，不静默丢失。
   - `sources/` 下最终形态：根放原始 PRD 文档，`media/` 放图片归档。
7. **合理性校验（引用 standard §2.4，不在此重述规则）**：逐张核对信号 A/B —— 矛盾打 `[图片归属待人工确认]`，无法识别/提取打 `[图片待人工确认]`，存疑项使本次状态为 `DONE_WITH_CONCERNS` 并纳入待确认项。

**README 索引模板**（写 `{BASE_DIR}/sources/media/README.md` 时参照）：

```markdown
# 原型图片索引

> 来源：《xxx.docx》内嵌图片，提取于需求分析阶段。
> 用途：需求文档可视化佐证；方案设计阶段前端交互参考。

## 命名规则
{需求项ID}_{序号}_{页面/模块描述}.{ext}（无法识别/归不到需求项 → REQ-misc_描述）

## 索引表
| 文件名 | 需求项 | 需求章节 | 内容描述 | 设计阶段参考点 |
|--------|--------|----------|----------|----------------|
| REQ-001_01_登录页.png | REQ-001 | 三、用户登录/§3.2.3 页面操作维度 | 登录页布局：账号/密码/登录按钮 | 入口位置、字段清单 |
| REQ-misc_整体流程图_矢量.emf | — | — | EMF 矢量图（多数查看器不支持，无法识别） | 如需可转 PNG/SVG |
```

### 7. 待确认项清零检查（终稿强制）

扫描终稿全文，搜索下列残留标记。如有残留，状态必须为 `DONE_WITH_CONCERNS`：

`[需与产品确认]`、`[需人工确认]`、`[事实源存疑]`、`[事实源缺失]`、`[推断待确认]`、`[图片待人工确认]`、`[图片归属待人工确认]`、`<!-- STATUS_REPORT -->`

> `[FS-00X]` 是**正常溯源引用**，不属于待确认标记，**不纳入清零**。

状态报告写入 `{WORKSPACE}/requirement/03-status-report.md`，不写入终稿。
