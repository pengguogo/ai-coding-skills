# Step 2: 前端任务拆分 + 依赖编排与落盘组装 [强制停止]

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-02-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/task/01-backend-tasks.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-web.md`, `{DESIGN}/frontend-ios.md`, `{DESIGN}/frontend-android.md`, `{DESIGN}/frontend-hmos.md`, `{DESIGN}/frontend-h5.md`]
- input_files_subagent: [`{WORKSPACE}/task/01-backend-tasks.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-web.md`, `{DESIGN}/frontend-ios.md`, `{DESIGN}/frontend-android.md`, `{DESIGN}/frontend-hmos.md`, `{DESIGN}/frontend-h5.md`]
- output_file: `{TASK}/task-split.md`
- reference_files: [`references/task_split_standard.md`, `references/task_split_template.md`]
- status_report_file: `{WORKSPACE}/task/02-status-report.md`
- upstream_compare: [`{WORKSPACE}/task/01-backend-tasks.md`]

## 执行指令

本步骤分多个 Part 顺序执行。

**入口访问约定（强制）**：前端设计以入口索引 `{DESIGN}/frontend-design.md` 为唯一入口，先读入口文件各端访问章节的「本次状态」，判定哪些目标端已生成分端设计文件；仅对已生成分端设计文件的目标端执行对应 Part，并在拆分结果中**标注该批次所属目标端**。目标端与分端设计文件、任务清单章节、编码侧批次的对应关系：

| 目标端 | 分端设计文件 | 任务清单章节 | 功能点标题 | 编码侧批次 |
|--------|-------------|-------------|-----------|-----------|
| PC Web | `frontend-web.md` | `## 前端任务清单` | `## 功能点 N:` | `FE-{N}` |
| iOS | `frontend-ios.md` | `## iOS 任务清单` | `## 功能点 N:` | `iOS-{N}` |
| Android | `frontend-android.md` | `## Android 任务清单` | `## 功能点 N:` | `Android-{N}` |
| HMOS（鸿蒙） | `frontend-hmos.md` | `## HMOS 任务清单` | `## 功能点 N:` | `HMOS-{N}` |
| H5 | `frontend-h5.md` | `## H5 任务清单` | `## 功能点 N:` | `H5-{N}` |

### Part 1：前端（PC Web）任务拆分

**仅当入口索引显示 `frontend-web.md` 已生成时执行本 Part；否则跳过。**

基于 01-backend-tasks.md 的前端工作包和 `frontend-web.md`，按 task_split_standard.md §2~§3 的前端任务拆分标准生成前端（PC Web）任务清单。

#### 1. 任务拆分原则

- 适中粒度：每个任务聚焦一个独立的功能模块或组件，完成后可独立验证
- 单一职责：每个任务只完成一个明确的功能点
- 可测试：每个任务完成后有明确的验证标准
- 与 `frontend-web.md` 一致

#### 2. 任务组织

- 按功能点分组：每个功能点独立组织任务
- 任务数量自适应：根据功能点复杂度自动识别所需任务数量
- 实现顺序：数据准备 → 结构搭建 → 逻辑实现 → 交互完善
- 按优先级排序：核心功能优先

#### 3. 任务拆分步骤

1. 在 `frontend-web.md` 中识别页面/模块与对后端能力的调用
2. 识别所有功能点（对照需求 REQ 编号做追溯标注）
3. 评估功能点复杂度（数据、组件、逻辑、交互复杂度）
4. 分析代码复用（可复用的组件、类型、服务）
5. 拆分具体任务
6. 检查依赖关系，标注并行任务和关键路径

#### 4. 任务格式

每个任务包含：
- 任务标题（以动词开头）
- File：文件路径
- Work：具体工作项列表
- Purpose：任务目的
- Leverage：可复用资源（可选）
- Requirements：需求编号（可选）

### Part 1.5：Android 任务拆分（条件执行）

**仅当入口索引显示 `frontend-android.md` 已生成时执行本 Part；否则跳过，不产出 Android 任务清单。**

基于分端设计文件 `frontend-android.md`，按 `task_split_standard.md` §7 的 Android 任务拆分标准生成 Android 任务清单。

1. 识别每个 `### 功能点 N：{名称}`，对照 REQ 编号追溯
2. 评估复杂度（数据、数据层、状态、界面、交互）
3. 分析代码复用（现有网络层封装、基类、通用 View/组件、工具类）
4. 按实现顺序拆分：数据与接口准备 → 数据层（Repository/Room）→ ViewModel/状态 → 界面（Activity/Fragment/Compose）→ 交互与异常处理
5. 检查依赖，标注对后端接口（`BE-{M}`）的硬依赖

**标题格式（强制）**：章节标题 `## Android 任务清单`；功能点标题 `## 功能点 N: {标题}`（供编码侧解析为 `Android-{N}`）；共享任务 `## 共享资源任务`。File 路径须落在 Android 仓库实际目录下。

### Part 1.6：iOS 任务拆分（条件执行）

**仅当入口索引显示 `frontend-ios.md` 已生成时执行本 Part；否则跳过，不产出 iOS 任务清单。**

基于分端设计文件 `frontend-ios.md`，按 `task_split_standard.md` §8 的 iOS 任务拆分标准生成 iOS 任务清单。

1. 识别每个 `### 功能点 N：{名称}`，对照 REQ 编号追溯
2. 评估复杂度（数据、数据层、状态、界面、交互）
3. 分析代码复用（现有网络层封装、基类、通用 View、Category/Extension、工具类）
4. 按实现顺序拆分：数据与接口准备 → 数据层（Repository/CoreData）→ ViewModel/Presenter/状态 → 界面（ViewController/SwiftUI View）→ 交互与异常处理
5. 检查依赖，标注对后端接口（`BE-{M}`）的硬依赖

**标题格式（强制）**：章节标题 `## iOS 任务清单`；功能点标题 `## 功能点 N: {标题}`（供编码侧解析为 `iOS-{N}`）；共享任务 `## 共享资源任务`。File 路径须落在 iOS 仓库实际目录下。

### Part 1.7：HMOS（鸿蒙）任务拆分（条件执行）

**仅当入口索引显示 `frontend-hmos.md` 已生成时执行本 Part；否则跳过，不产出 HMOS 任务清单。**

基于分端设计文件 `frontend-hmos.md`，按 `task_split_standard.md` §9 的 HMOS 任务拆分标准生成 HMOS 任务清单。

1. 识别每个 `### 功能点 N：{名称}`，对照 REQ 编号追溯
2. 评估复杂度（数据、数据层、状态、界面、交互）
3. 分析代码复用（现有网络层封装、公共 Component、工具类）
4. 按实现顺序拆分：数据与接口准备 → 数据层（Repository/Preferences/RelationalStore）→ ViewModel/状态 → 界面（Page/@Component）→ 交互与异常处理
5. 检查依赖，标注对后端接口（`BE-{M}`）的硬依赖

**标题格式（强制）**：章节标题 `## HMOS 任务清单`；功能点标题 `## 功能点 N: {标题}`（供编码侧解析为 `HMOS-{N}`）；共享任务 `## 共享资源任务`。File 路径须落在鸿蒙仓库实际目录下。

### Part 1.8：H5 任务拆分（条件执行）

**仅当入口索引显示 `frontend-h5.md` 已生成时执行本 Part；否则跳过，不产出 H5 任务清单。**

基于分端设计文件 `frontend-h5.md`，按 `task_split_standard.md` §10 的 H5 任务拆分标准生成 H5 任务清单。

1. 识别每个 `### 功能点 N：{名称}`，对照 REQ 编号追溯
2. 评估复杂度（数据、组件、状态、交互、移动端适配）
3. 分析代码复用（HTTP 封装、JSBridge 封装、通用组件、适配/手势工具）
4. 按实现顺序拆分：数据与接口准备 → 组件结构 → 状态管理 → 交互流程 → 移动端适配与异常处理
5. 检查依赖，标注对后端接口（`BE-{M}`）的硬依赖

**标题格式（强制）**：章节标题 `## H5 任务清单`；功能点标题 `## 功能点 N: {标题}`（供编码侧解析为 `H5-{N}`）；共享任务 `## 共享资源任务`。File 路径须落在 H5 仓库实际目录下。

### Part 2：依赖编排

基于后端、前端（PC Web）、iOS、Android、HMOS、H5 任务清单，生成任务级依赖表：

| 任务（编号/标题） | 类型（后端/前端/iOS/Android/HMOS/H5） | 前置任务 | 阻塞/外部依赖 | 设计文件与章节（可选） |
|---|---|---|---|---|

- 标注哪些任务互为前置、哪些可并行
- 标注与数据模型或外部系统相关的硬依赖
- iOS/Android/HMOS/H5 任务若依赖后端接口，须将对应 `BE-{M}` 列为前置
- 「设计文件与章节」列填对应分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）与功能点

### Part 3：组装落盘

将全部内容合并为完整的任务拆分文档。合并时必须剥离每个文件末尾的 `<!-- STATUS_REPORT -->` 块。

#### 输出路径自检

1. 在工作区中查找 `ocspec-<xxx>/` 根目录
2. 确认目标路径为 `ocspec-<xxx>/requirements/<需求英文名>_<yyyymmdd>/task/task-split.md`
3. 禁止在工作区根目录或其他位置新建 `task/` 文件夹

#### 按 task_split_template.md 的章节顺序组织

```
# [需求名称] — 任务拆分

## 1. 本次任务拆分概览
（从 01-backend-tasks.md 提取概览信息）

## 2. 后端任务清单
（从 01-backend-tasks.md 提取，按模块/技术层次分区）

## 3. 前端任务拆分原则与粒度约定
（从 Part 1 提取原则部分）

## 4. 前端任务清单
（从 Part 1 提取，按功能点分组）

## 5. iOS 任务清单
（**仅当 Part 1.6 执行时输出**；从 Part 1.6 提取，标题用 `## 功能点 N:`）

## 6. Android 任务清单
（**仅当 Part 1.5 执行时输出**；从 Part 1.5 提取，标题用 `## 功能点 N:`）

## 7. HMOS 任务清单
（**仅当 Part 1.7 执行时输出**；从 Part 1.7 提取，标题用 `## 功能点 N:`）

## 8. H5 任务清单
（**仅当 Part 1.8 执行时输出**；从 Part 1.8 提取，标题用 `## 功能点 N:`）

## 9. 依赖关系
（从 Part 2 提取任务级依赖表）

## 10. 开放问题与需人工确认
（汇总所有步骤的待确认项）
```

> 若某目标端未执行对应 Part（入口索引显示该端分端设计文件本次未生成），则跳过对应清单章节，后续章节编号顺延。

#### 全局一致性校验

- 编号连续性：后端任务编号连续、前端任务按功能点分组
- 各端一致性（若有）：任务清单标题为 `## iOS 任务清单` / `## Android 任务清单` / `## HMOS 任务清单` / `## H5 任务清单`、功能点用 `## 功能点 N:`、与对应分端设计文件（`frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）的功能点一一对应
- 覆盖完整性：01-backend-tasks.md 中的每个工作包在任务清单中有对应任务；入口索引标注「已生成」的每个目标端均有对应任务清单
- 依赖可理解：每个有依赖的任务都显式说明了前置任务；iOS/Android/HMOS/H5 任务对后端接口的依赖已标注
- 格式规范：表格列完整、Markdown 语法正确

#### 开放问题汇总

汇总所有步骤的不确定项，每个问题必须：
- 指明属于后端、前端(PC Web)、iOS、Android、HMOS 还是 H5
- 指明影响到哪些任务或设计文档条目
- 指明需要用户/产品确认的具体问题

#### 待确认项清零检查

扫描终稿全文，搜索残留标记。如有残留，状态必须为 `DONE_WITH_CONCERNS`。

状态报告写入 `{WORKSPACE}/task/02-status-report.md`，不写入终稿。
