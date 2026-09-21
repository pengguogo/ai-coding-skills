# Checkpoint: Step 6 前端分析 + 前端方案设计

> **审查级别**：L1（轻量审查）— 只检查结构和内容维度，接口对齐一致性延迟到 Step 7 的 L2 审查。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。

## 审查时需打开的文件
- 产出文件：`{WORKSPACE}/design/06-frontend-design.md`
- 分析文件：`{WORKSPACE}/design/06-frontend-analysis.md`
- 上游比对：`{DESIGN}/backend-design.md`

## 分析摘要检查（06-frontend-analysis.md）
- [ ] 包含功能点清单（表格形式）
- [ ] 包含前端技术栈与约束
- [ ] 包含接口依赖与对齐表
- [ ] 包含 UI 风格参照基准
- [ ] 接口对齐表中每个接口包含：来源标注、HTTP 方法、URL、入参表、出参表
- [ ] 接口对齐表中的接口数量 = backend-design.md §3.2 中的对外接口数量

## 设计文档结构检查（06-frontend-design.md）
- [ ] 包含"一、概述"
- [ ] 包含"二、架构说明"（模块划分、架构层次、设计原则）
- [ ] 包含"三、规范文档对齐"（技术标准、项目结构、UI 组件）
- [ ] 包含"四、功能逻辑实现"（至少 1 个功能点）

## 功能点完整性检查

> **目标端分流**：先读功能点清单的 `目标端` 列（取值 Web / iOS / Android / HMOS / H5）。`目标端 = Web` 适用下方「Web 前端检查」；`iOS`/`Android` 改用对应端检查；`HMOS` 对照 `design_hmos_standard.md`、`H5` 对照 `design_h5_standard.md`，均不套用 Web 专有维度（TypeScript/组件树/Props）。各端设计写入各自分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`），不写入 `frontend-design.md` 内嵌章节。

### Web 前端检查（目标端 = Web）
- [ ] **每个功能点**都包含：功能概述（§4.0）
- [ ] **每个功能点**都包含：实现方案 — 组件结构（§4.2），不得省略
- [ ] **每个功能点**都包含：实现方案 — 交互流程（§4.3），不得省略
- [ ] **每个功能点**都包含：实现方案 — 状态定义与流转（§4.4），不得省略
- [ ] 涉及接口的功能点包含：数据与接口（§4.1），每个接口有来源标注

### Android 检查（目标端 = Android，对照 design_android_standard.md → frontend-android.md）
- [ ] 写入分端设计文件 `frontend-android.md`，功能点标题为 `### 功能点 N：{名称}`
- [ ] 每个功能点包含：概述（N.1）、数据与接口（N.2）、界面结构（N.4）、状态定义与流转（N.5）、交互流程（N.6）、生命周期与资源管理（N.7）
- [ ] 涉及接口的功能点：数据模型有 Kotlin data class / Java POJO 定义，每个接口有 `来源：backend-design.md §x.x` 标注
- [ ] UiState 结构完整定义；交互流程含 Mermaid 图 + 文字（覆盖 loading/空态/错误态）
- [ ] 涉及运行时权限/敏感数据的功能点包含 N.8 权限与安全

### iOS 检查（目标端 = iOS，对照 design_ios_standard.md → frontend-ios.md）
- [ ] 写入分端设计文件 `frontend-ios.md`，功能点标题为 `### 功能点 N：{名称}`
- [ ] 每个功能点包含：概述（N.1）、数据与接口（N.2）、界面结构（N.4）、状态定义与流转（N.5）、交互流程（N.6）、生命周期与资源管理（N.7）
- [ ] 涉及接口的功能点：数据模型有 Swift struct（Codable）/ ObjC 模型定义，每个接口有 `来源：backend-design.md §x.x` 标注
- [ ] 状态结构完整定义（@Published / 状态枚举）；交互流程含 Mermaid 图 + 文字（覆盖 loading/空态/错误态）
- [ ] 涉及运行时权限/敏感数据的功能点包含 N.8 权限与安全（含 Info.plist 用途描述）

### HMOS 检查（目标端 = HMOS，对照 design_hmos_standard.md → frontend-hmos.md）
- [ ] 写入分端设计文件 `frontend-hmos.md`，功能点标题为 `### 功能点 N：{名称}`
- [ ] 每个功能点包含：概述（N.1）、数据与接口（N.2）、界面结构（N.4）、状态定义与流转（N.5）、交互流程（N.6）、生命周期与资源管理（N.7）
- [ ] 涉及接口的功能点：数据模型有 ArkTS interface/class 定义，每个接口有 `来源：backend-design.md §x.x` 标注
- [ ] 状态结构完整定义（`@State`/`@Observed` 等）；交互流程含 Mermaid 图 + 文字（覆盖 loading/空态/错误态）
- [ ] 涉及权限/敏感数据的功能点包含 N.8 权限与安全（含 module.json5 声明）

### H5 检查（目标端 = H5，对照 design_h5_standard.md → frontend-h5.md）
- [ ] 写入分端设计文件 `frontend-h5.md`，功能点标题为 `### 功能点 N：{名称}`
- [ ] 每个功能点包含：概述（N.1）、数据与接口（N.2）、组件结构（N.4）、状态定义与流转（N.5）、交互流程（N.6）、移动端适配与生命周期（N.7）
- [ ] 涉及接口的功能点：数据类型有 TypeScript interface 定义，每个接口有 `来源：backend-design.md §x.x` 标注；涉及 JSBridge 的标注原生方法与降级
- [ ] 交互流程含 Mermaid 图 + 文字（覆盖 loading/空态/错误态）；覆盖移动端适配（视口/安全区）
- [ ] 涉及性能/弱网的功能点包含 N.8 性能与边界

## 字段粒度检查
- [ ] 每个数据类型有完整的 TypeScript interface 定义（逐字段列出，含类型和注释）
- [ ] 每个接口的入参有字段表（字段名、类型、必填、说明、备注）
- [ ] 每个接口的出参有字段表，展开到叶子字段

## 组件粒度检查
- [ ] 每个功能点列出完整的组件树（主组件 + 所有子组件，含文件路径和职责）
- [ ] 每个子组件有 Props 定义表和 Events 定义表
- [ ] UI 组件选型明确标注了使用的 UI 库组件和参照页面

## 交互粒度检查
- [ ] 每个功能点的交互流程包含 Mermaid 图表 + 文字步骤说明
- [ ] 图表包含异常路径（错误态、空态、超时等）
- [ ] 有页面初始化流程描述和用户操作清单
- [ ] 表单功能点有字段校验规则表（如适用）
- [ ] 列表功能点有表格列定义表（如适用）

## 改动标注检查（L1，跑存在性 + 反极端，按 change-annotation-standard）
- [ ] §4.3 交互流程图中本期新增/改造的交互有标注（时序图用 `rect` 着色 / 流程图用 `:::chg-*` 着色 / 或文字前缀）；复用不标
- [ ] §4.4 状态流转图中改动的状态/转换有 `[新增]/[改造]` 文字前缀（如涉及 stateDiagram）
- [ ] 出参字段表「标记」列使用 `[新增]/[改造]/—`（不残留 `[变更]`）
- [ ] 整体全改走图下声明块（图内零标签 + 有声明块 → 合格，不算 0% 漏标）；逐元素全标 → 提示精简（`DONE_WITH_CONCERNS`，非 FAIL）；既无标签又无声明块 → 真漏标 FAIL

## 待确认项提取
- 产出正文中所有 `[需与产品确认]`、`[需后端设计补充]` 标记
- 接口对齐表信息不完整导致基于推断设计的功能点
- 状态报告中的 concerns / items-skipped
