# Step 7: 前端组装与自检 [强制停止]

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-07-frontend-final.md
- checkpoint-level: L2

## 参数

- source_files: [`{WORKSPACE}/design/06-frontend-analysis.md`, `{WORKSPACE}/design/06-frontend-design.md`, `{WORKSPACE}/design/06-frontend-design-*.md`]
- output_file: `{DESIGN}/frontend-design.md`
- entry_file: `{DESIGN}/frontend-design.md`
- platform_design_files:
    - `Web` → `{DESIGN}/frontend-web.md`
    - `iOS` → `{DESIGN}/frontend-ios.md`
    - `Android` → `{DESIGN}/frontend-android.md`
    - `HMOS` → `{DESIGN}/frontend-hmos.md`
    - `H5` → `{DESIGN}/frontend-h5.md`
- assembly_template: |
    入口文件 `frontend-design.md`：固定为索引文件，含各分端访问章节（见执行指令 §1）。
    分端设计文件 `frontend-<platform>.md`：由对应目标端实例内容（06-frontend-design-*.md）组装而成。
- consistency_rules: |
    - 接口覆盖完整性：backend-design.md §3.2 中所有对外接口均有对应
    - 入参字段逐一对齐：与 backend-design.md 完全一致
    - 出参字段逐一对齐：与 backend-design.md 完全一致，嵌套展开到叶子
    - 每个接口标注了来源（来源：backend-design.md §x.x）
    - TS interface 字段名、类型、可选性与后端出参/入参表逐一对应
    - 不存在后端未定义的接口（未覆盖的标注 [需后端设计补充]）
    - 新增/改造字段以 [新增]/[改造] 标记
- status_report_file: `{WORKSPACE}/design/07-status-report.md`
- upstream_compare: [`{WORKSPACE}/design/06-frontend-analysis.md`, `{DESIGN}/backend-design.md`]

## 执行指令

### 1. 生成入口索引文件 `frontend-design.md`（固定产出）

无论本次覆盖几个目标端，都必须产出入口文件 `{DESIGN}/frontend-design.md`。入口文件是供 `task-split` 引用前端设计的**唯一入口**，本身**不承载**具体分端设计正文，仅为索引：说明各分端设计文件的访问方式、引用工程与使用条件。
合并时必须剥离中间产出末尾的 `<!-- STATUS_REPORT -->` 块。

入口文件须为 PC Web、iOS、Android、HMOS、H5 **五个目标端各设置一个独立访问章节**。按以下模板生成：

```markdown
# [需求名称] — 前端技术方案设计（入口索引）

> 本文件为前端设计的固定入口（索引）。各目标端的详细设计写入各自独立的分端设计文件，
> 请按下方对应章节访问。`task-split` 与编码侧均以本文件为入口，经各端章节定位到分端设计文件。

## 分端设计文件总览

| 目标端 | 分端设计文件 | 本次是否生成 | 对应工程 | 目标端来源 |
|--------|-------------|-------------|----------|-----------|
| PC Web | `frontend-web.md` | 是/否 | [Web/管理后台工程名或路径] | §3.1.1 / 工程推断 / 默认 / 人工确认 |
| iOS | `frontend-ios.md` | 是/否 | [iOS 工程名或路径] | §3.1.1 / 工程推断 / 默认 / 人工确认 |
| Android | `frontend-android.md` | 是/否 | [Android 工程名或路径] | §3.1.1 / 工程推断 / 默认 / 人工确认 |
| HMOS（鸿蒙） | `frontend-hmos.md` | 是/否 | [鸿蒙工程名或路径] | §3.1.1 / 工程推断 / 默认 / 人工确认 |
| H5 | `frontend-h5.md` | 是/否 | [H5 工程名或路径] | §3.1.1 / 工程推断 / 默认 / 人工确认 |

## PC Web

- **分端设计文件**：`frontend-web.md`（与本文件同目录 `design/` 下）
- **引用工程**：[对应 Web/管理后台工程名或路径]
- **使用条件**：当本次交付涉及管理后台 / PC Web 页面工程时使用本文件；纯移动端（iOS/Android/HMOS/H5）交付时不使用。
- **本次状态**：[已生成 `frontend-web.md` / 本次未生成该端分端设计文件]

## iOS

- **分端设计文件**：`frontend-ios.md`（与本文件同目录 `design/` 下）
- **引用工程**：[对应 iOS 原生工程名或路径]
- **使用条件**：当本次交付涉及 iOS 原生工程时使用本文件；无 iOS 交付时不使用。
- **本次状态**：[已生成 `frontend-ios.md` / 本次未生成该端分端设计文件]

## Android

- **分端设计文件**：`frontend-android.md`（与本文件同目录 `design/` 下）
- **引用工程**：[对应 Android 原生工程名或路径]
- **使用条件**：当本次交付涉及 Android 原生工程时使用本文件；无 Android 交付时不使用。
- **本次状态**：[已生成 `frontend-android.md` / 本次未生成该端分端设计文件]

## HMOS（鸿蒙）

- **分端设计文件**：`frontend-hmos.md`（与本文件同目录 `design/` 下）
- **引用工程**：[对应鸿蒙工程名或路径]
- **使用条件**：当本次交付涉及鸿蒙原生工程时使用本文件；无鸿蒙交付时不使用。
- **本次状态**：[已生成 `frontend-hmos.md` / 本次未生成该端分端设计文件]

## H5

- **分端设计文件**：`frontend-h5.md`（与本文件同目录 `design/` 下）
- **引用工程**：[对应 H5 工程名或路径]
- **使用条件**：当本次交付涉及移动端浏览器 / App 内嵌 WebView 的 H5 工程时使用本文件；无 H5 交付时不使用。
- **本次状态**：[已生成 `frontend-h5.md` / 本次未生成该端分端设计文件]
```

- 每个访问章节须填写：访问方式（分端文件名 + 所在目录）、引用工程、使用条件（何时用 / 何时不用）。
- 已生成分端设计文件的端：「本次状态」写「已生成 `frontend-<platform>.md`」；未生成的端：明确标注「本次未生成该端分端设计文件」。

### 2. 组装各分端设计文件（按目标端路由）

将 Step 6 各实例产出（`06-frontend-design*.md`）按其标注的 `目标端` 分别组装为对应分端设计文件：

- `目标端 = Web` 的实例 → `{DESIGN}/frontend-web.md`
- `目标端 = iOS` 的实例 → `{DESIGN}/frontend-ios.md`
- `目标端 = Android` 的实例 → `{DESIGN}/frontend-android.md`
- `目标端 = HMOS` 的实例 → `{DESIGN}/frontend-hmos.md`
- `目标端 = H5` 的实例 → `{DESIGN}/frontend-h5.md`

组装规则：

- 仅为本次实际存在功能点的目标端生成分端设计文件；未涉及的端不生成空文件（其状态在入口文件中标注为「本次未生成」）。
- 每个分端设计文件按对应端设计标准的文件标题与章节结构组织；功能点标题保持 `### 功能点 N：{名称}`，供 `task-split` 与编码侧解析为对应批次（`FE-{N}` / `iOS-{N}` / `Android-{N}` / `HMOS-{N}` / `H5-{N}`）。
- 合并时必须剥离中间产出末尾的 `<!-- STATUS_REPORT -->` 块。

### 3. 接口对齐自检（强制，逐项通过）

> 自检对象为**各分端设计文件**（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）中涉及接口的功能点；入口文件 `frontend-design.md` 不承载接口正文，不参与本项自检。

| 序号 | 检查项 | 通过标准 |
|------|--------|---------|
| 1 | 接口覆盖完整性 | backend-design.md §3.2 中所有对外接口均有对应 |
| 2 | 入参字段逐一对齐 | 与 backend-design.md 完全一致 |
| 3 | 出参字段逐一对齐 | 与 backend-design.md 完全一致，嵌套展开到叶子 |
| 4 | 来源标注 | 每个接口标注了来源 |
| 5 | TS interface 一致 | 字段名、类型、可选性一一对应 |
| 6 | 新增/改造标注 | 有 `[新增]`/`[改造]` 标记 |
| 7 | 无臆造接口 | 不存在后端未定义的接口 |

### 4. 待确认项清零检查（终稿强制）

扫描入口文件与全部已生成分端设计文件，搜索残留的 `[需与产品确认]`、`[需人工确认]`、`[需后端设计补充]`、`<!-- STATUS_REPORT -->` 块。
如有残留，状态必须为 DONE_WITH_CONCERNS。

### 5. 入口与分端一致性自检

- [ ] 入口文件 `frontend-design.md` 已生成，且为 PC Web、iOS、Android、HMOS、H5 五端各设置访问章节。
- [ ] 每个访问章节标注了访问方式、引用工程与使用条件。
- [ ] 每个已生成分端设计文件在入口对应章节标注为「已生成」；未生成的端标注为「本次未生成」。
- [ ] 入口文件不含分端设计正文（仅索引）。
- [ ] 各分端设计文件文件名与约定一致（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）。

### 6. 上游平台追踪一致性自检

- [ ] 若需求 `§3.1.1` 声明了 `Applicable_Platforms`，则本次已生成的分端设计文件集合是其子集或相等（不多出上游未声明的端）。
- [ ] 若需求 `§3.1.1` 声明了某平台但本次未生成对应分端设计文件，在入口索引该端章节标注了原因（如"本次仅处理 iOS 端，其他端待后续执行"）。
- [ ] 若 `Web_H5_Merge = 是`，则不存在 `frontend-h5.md`，且 `frontend-web.md` 包含 H5 场景适配内容。
- [ ] 若存在 `Shared_REQ_Trace`，各分端设计文件中对应功能点的 REQ 追踪与上游 §3.1.1 一致。
- [ ] 若存在 `Common_Acceptance_Criteria`，各端设计的验收方案未与其矛盾。
- [ ] 若存在 `Platform_Difference`，各端设计的方案体现了上游声明的差异点。
- [ ] 入口索引"本次状态"与上游声明和实际文件三者一致。
- [ ] 若上游无 §3.1.1（旧格式需求），本项自检跳过（不报错）。

### 关键约束

- 状态报告写入 {WORKSPACE}/design/07-status-report.md，不写入 {DESIGN}/frontend-design.md 或任何分端设计文件
- 入口文件与分端设计文件中均不得包含任何 STATUS_REPORT 块
- 将 STATUS_REPORT 按 §11 格式写入 status_report_file 指定路径，供 Scheduler 状态机决策
