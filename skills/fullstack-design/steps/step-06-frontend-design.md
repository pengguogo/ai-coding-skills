# Step 6: 前端分析 + 前端方案设计（template，按功能分批）

## 元信息

- agent: function-designer
- checkpoint: checkpoints/step-06-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: feature
- instance-source: `{WORKSPACE}/design/06-frontend-analysis.md#功能点清单`
- context-budget: 3000
- complexity-estimate: { simple: 400, medium: 1000, complex: 2500, default: 800 }
- grouping-strategy: |
    先按 `目标端`（Web / iOS / Android / HMOS / H5）分组，不同目标端不混入同一实例（因每个目标端写入各自独立的分端设计文件）；
    组内再按复杂度聚合：simple 功能尽量聚合到同一实例（一个实例可容纳 5~7 个 simple 功能）；
    medium 功能 2~3 个一组；complex 功能独占一个实例。
    只有 1 组时不实例化，作为普通 static 步骤执行。
    每个实例须在产出中标注其 `目标端`，供组装步骤路由到对应分端设计文件（Web→frontend-web.md，iOS→frontend-ios.md，Android→frontend-android.md，HMOS→frontend-hmos.md，H5→frontend-h5.md）。

## 参数

- input_files: [`{REQ}/requirement.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/architecture-design.md`, `{CODE_KNOWLEDGE}/frontend-project.md`, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- output_file: `{WORKSPACE}/design/06-frontend-design.md`
- output_file_per_instance: `{WORKSPACE}/design/06-frontend-design-${instance-id}.md`
- analysis_output_file: `{WORKSPACE}/design/06-frontend-analysis.md`
- reference_sections:
    - `references/design_frontend_standard.md`（PC Web 分端标准，产出 frontend-web.md；仅当存在目标端 = Web 的功能点时加载）
    - `references/design_ios_standard.md`（产出 frontend-ios.md；仅当存在目标端 = iOS 的功能点时按需加载）
    - `references/design_android_standard.md`（产出 frontend-android.md；仅当存在目标端 = Android 的功能点时按需加载）
    - `references/design_hmos_standard.md`（产出 frontend-hmos.md；仅当存在目标端 = HMOS 的功能点时按需加载）
    - `references/design_h5_standard.md`（产出 frontend-h5.md；仅当存在目标端 = H5 的功能点时按需加载）
    - `references/change-annotation-standard.md`
- domain_context: 先完成前端需求分析，再以需求驱动的功能点为单位设计前端方案（含 PC Web、iOS 原生、Android 原生、鸿蒙 HMOS、H5 五类目标端），各目标端设计写入各自独立的分端设计文件

## 执行指令

本步骤分 2 个 Phase 执行。Phase A 产出分析摘要，Phase B 基于分析结果做 template 分批设计。

### Phase A：前端需求与上下文分析（写入 analysis_output_file）

**核心原则：以需求文档为驱动，不以后端接口列表为驱动。**

#### A1. 需求驱动的功能点提取（核心）

从 {REQ}/requirement.md 中提取前端视角的完整功能范围：
- **对照架构文档确认应用边界**：先读 architecture-design.md（应用清单/改造矩阵），确认本次前端涉及的应用及其承载的功能点，避免跨应用边界识别错位
- **页面清单**：识别所有需要新建或修改的页面（页面名称、路由路径、所属模块、页面类型、访问权限）
- **用户交互流程**：页面间跳转关系（含条件跳转）、每个页面内的核心操作、操作的前置条件和后置效果
- **业务规则（前端侧）**：表单校验规则、权限控制规则（按钮显隐、字段可编辑性）、状态驱动的 UI 变化
- **纯前端功能**（不涉及后端接口的部分也必须识别）：前端路由与导航、本地状态管理、前端计算与格式化、前端缓存策略

对功能点清单中的每个功能点，标注复杂度（simple/medium/complex）和依赖关系。

**目标端识别（强制）**：对每个功能点标注 `目标端`，取值 `Web` / `iOS` / `Android` / `HMOS` / `H5`。

按以下优先级**依序**判定：

**① 优先读取上游需求声明（权威来源）**

检查 `{REQ}/requirement.md` 中该需求项/功能点的 `§3.1.1 平台适用与差异`：
- 若存在 `Applicable_Platforms` 且为非空合法集合 → **直接采用**，不再推断。
- 同时提取 `Shared_REQ_Trace`，记入功能点清单表格的对应列，供后续设计和 task-split 追踪。
- 同时提取 `Common_Acceptance_Criteria` 和 `Platform_Difference`，作为各端设计的共同约束和差异基线。
- 若 `Web_H5_Merge = 是`：Web 功能点同时覆盖 H5 场景（移动浏览器、WebView 内嵌页面），不拆出独立 H5 功能点，`frontend-web.md` 中增加移动端/H5 适配章节，不生成 `frontend-h5.md`。

**② 上游声明为"待确认"时，结合工程证据补充**

若 `Applicable_Platforms` 为"待确认"：
- 检查同项目目录下的多端工程迹象（如同时存在 iOS、Android、鸿蒙、H5 工程目录）。
- 推断成功 → 使用推断结果，并在功能点备注中标注"依据工程目录推断，需求侧待确认"。
- 推断失败（无明确工程迹象）→ 默认 `Web`，并在「待确认项」记录原因和影响。

**③ 上游无平台信息时（旧格式需求文档 / 需求未写 §3.1.1），使用旧推断逻辑兼容**

当需求文档中不存在 `§3.1.1` 或 `§2.4 平台信息总览` 时，按兼容模式执行：
- 从需求正文推断交互载体（管理后台/PC Web → `Web`；iOS 原生 → `iOS`；Android 原生 → `Android`；鸿蒙原生 → `HMOS`；移动浏览器/WebView H5 → `H5`）。
- 判定时可结合同项目目录下的多端工程迹象。
- 仍无法确定时默认 `Web` 并记录待确认。

**④ 冲突处理（强制）**

若上游 `§3.1.1` 声明的平台与工程目录证据**矛盾**（例如：需求声明 [iOS, HMOS]，但工程目录额外有 Android 工程）：
- **保留上游需求声明作为本次设计基线**（不静默扩展或覆盖）。
- 在「待确认项」中记录冲突：列出需求声明值、工程证据、受影响功能点。
- 标注 `[PLATFORM-CONFLICT: 需求声明与工程证据不一致，需人工确认]`。
- 不阻塞已声明平台的设计执行；仅冲突平台暂不纳入本次设计。

**⑤ 人工确认机制**

当发生以下情况时，Phase A **暂停**并向用户展示确认选项：
- a) 上游声明与工程证据冲突（④ 中识别到冲突）
- b) 上游声明为"待确认"且工程推断不确定
- c) 需求同时涉及 Web 和 H5 但未声明 `Web_H5_Merge`

**确认选项**（固定四选一）：
1. **按需求声明** — 严格使用 §3.1.1 的 Applicable_Platforms
2. **扩展采纳** — 在需求声明基础上补充工程证据发现的额外平台
3. **自选平台** — 从 Web/iOS/Android/HMOS/H5 中手动指定任意非空子集
4. **自行推导** — AI 综合分析需求正文、工程目录和项目上下文后展示推断结果和依据，用户二次确认

**确认结果记录**：用户选择写入功能点表格的 `目标端来源` 列。

**无冲突无歧义时不暂停**：上游有明确声明且与工程一致 → 直接采用；旧格式需求 + 推断唯一确定 → 直接使用。

**⑥ 多端拆分规则不变**

若同一业务功能同时存在多端（不论来源是需求声明还是推断），拆为多个功能点分别标注目标端。每个目标端的功能点将写入各自独立的分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）。

产出功能点清单表格：

| 序号 | 名称 | 所属页面 | 类型 | 目标端 | 目标端来源 | Shared_REQ_Trace | 是否涉及接口 | 复杂度 | 依赖 | 核心交互描述 |
|------|------|---------|------|--------|-----------|-----------------|--------|------|------|------------|

#### A2. 前端项目上下文（若存在 frontend-project.md）

从 frontend-project.md 中提取：技术栈、目录结构约定、接口调用规范、UI 风格与组件参考。若不存在，标注 `[前端项目上下文缺失，按新项目模式处理]`。

#### A2.1 自定义知识补充（若 CUSTOM_KNOWLEDGE_STATUS=present）

先读 `{CUSTOM_KNOWLEDGE}/README.md`（若存在），再按需读取相关 `.md` 文件，提取 UI 规范、对接约束等补充信息；若 `absent` 则跳过，不 Halt。

#### A3. UI 风格与组件一致性分析

优先从 frontend-project.md 的「UI 风格与组件参考」章节获取。若无，则扫描现有项目识别 UI 组件库和同类型页面。确定本次设计的 UI 参照基准（选定 2-3 个现有页面）。若无设计稿且无法推断，标注 `[需提供设计稿或 UI 参照]`。

#### A4. 接口依赖梳理（按需查阅后端设计）

逐个功能点判断是否涉及后端数据交互：
- 涉及接口调用的功能点：查阅 backend-design.md §3.2，提取对应接口的完整字段级信息，构建接口对齐记录
- 不涉及接口的功能点：标注"无接口依赖"
- 后端接口修改影响前端的：识别新增/变更字段对前端渲染逻辑的影响

接口信息必须从 backend-design.md 提取，不得臆造。后端未覆盖的接口标注 `[需后端设计补充]`。


#### Phase A 产出格式（写入 analysis_output_file）

```
# 前端分析摘要

## 1. 页面清单与用户交互流程
## 2. 功能点清单（表格）
## 3. 前端业务规则
## 4. 前端技术栈与约束
## 5. UI 风格参照基准
## 6. 接口依赖与对齐表
## 7. 后端变更影响梳理
## 8. 平台识别来源与冲突记录
## 9. 待确认项
```

**Phase A 完成后，Scheduler 基于功能点清单执行 template 分批逻辑，进入 Phase B。**

---

### Phase B：前端方案设计（template 分批执行）

**目标端分流（强制）**：每个功能点按 Phase A 标注的 `目标端` 选择设计标准与产出的**分端设计文件**。各目标端设计写入各自独立的分端设计文件，**不再**写入 `frontend-design.md` 的内嵌章节（`frontend-design.md` 由 Step 6 生成为入口索引文件）：

| 目标端 | 设计标准 | 分端设计文件 | 功能点标题 | 解析批次 |
|--------|----------|-------------|-----------|----------|
| `Web` | `design_frontend_standard.md`（本步骤 §1~§4） | `frontend-web.md` | `### 功能点 N：{名称}` | `FE-{N}` |
| `iOS` | `design_ios_standard.md`（章节结构一～四） | `frontend-ios.md` | `### 功能点 N：{名称}` | `iOS-{N}` |
| `Android` | `design_android_standard.md`（章节结构一～四） | `frontend-android.md` | `### 功能点 N：{名称}` | `Android-{N}` |
| `HMOS` | `design_hmos_standard.md`（章节结构一～四） | `frontend-hmos.md` | `### 功能点 N：{名称}` | `HMOS-{N}` |
| `H5` | `design_h5_standard.md`（章节结构一～四） | `frontend-h5.md` | `### 功能点 N：{名称}` | `H5-{N}` |

> 同一实例内不混合不同目标端；Scheduler 分批时按目标端聚合，每个实例只服务单一目标端并在产出中标注其 `目标端`，供 Step 6 路由到对应分端设计文件。以下 §1~§4 为 Web 前端（`frontend-web.md`）设计要求；iOS / Android / HMOS / H5 功能点改用对应端的设计标准章节，写入对应分端设计文件。

**以需求驱动的功能点为单位**，设计前端架构、组件、状态管理和交互方案。每个功能点的设计从用户交互出发，涉及接口调用时才引用接口对齐表。

#### 1. 撰写"一、概述"
- 功能概述、功能定位、架构定位

#### 2. 撰写"二、架构说明"
- 模块划分与职责边界、模块依赖（可用 Mermaid）
- 架构层次（UI/状态/服务/类型）
- 目录结构（对齐 frontend-project.md 或框架约定）

#### 3. 撰写"三、规范文档对齐"
- 技术标准（从 Phase A 分析获取）
- 项目结构（新增/修改的目录和文件）
- **UI 组件与风格对齐**：基于 Phase A 确定的 UI 参照基准，为每个功能点选定使用的 UI 库组件；必须包含本次使用的 UI 组件清单表格和布局与交互模式参照

#### 4. 撰写"四、功能逻辑实现"

对分配的每个功能点，**从用户交互视角出发**设计，必须包含以下全部子章节：

##### 4.0 功能概述
- 功能描述（用户视角）、实现位置（页面路径、组件路径）、关联需求项（REQ 编号）、是否涉及后端接口

##### 4.1 数据与接口（仅涉及接口调用的功能点）
- **TS interface 定义**：每个数据类型必须给出完整的 TypeScript interface，逐字段列出字段名、类型、注释、来源标注
- **接口入参/出参字段表**：从 Phase A 的接口对齐表获取，必须以表格形式逐字段展开
- **字段映射说明**：若前端字段名或类型与后端不一致，须逐字段注明映射规则与原因
- **后端变更影响**：若后端修改了现有接口，须说明新增/变更字段对本功能点渲染逻辑的具体影响

##### 4.2 实现方案 — 组件结构
- **组件树**：列出主组件和所有子组件，每个组件标注文件路径和职责
- **组件接口定义**：每个子组件必须列出完整的 Props 和 Events 定义（字段名、类型、是否必填、默认值、说明）
- **UI 组件选型**：列出本功能点使用的所有 UI 库组件，标注参照页面
- **条件渲染逻辑**：列出所有需要条件显隐的 UI 区域，说明显隐条件

##### 4.3 实现方案 — 交互流程
每个功能点必须包含 Mermaid 图表（sequenceDiagram 或 flowchart）+ 图表下方的关键步骤文字说明。禁止只有图没有文字，也禁止只有文字没有图。

图表要求：
- 页面初始化流程用 sequenceDiagram（用户 → 组件 → Store → API → 后端）
- 用户操作流程用 flowchart（含分支：校验通过/失败、接口成功/失败）
- 图表必须包含异常路径（错误态、空态、超时等）
- **改动标注**：本期新增/改造的交互（页面/操作/分支）须标注，复用既有交互不标——**按图类型分别落地**：`sequenceDiagram`（页面初始化流程）用 `rect`（新增绿/改造黄）+ Note（§4.1）；`flowchart`（用户操作流程）用 `classDef`+`:::chg-new`/`:::chg-mod`（§4.3）；两类图均可叠加 `[新增]/[改造]` 文字前缀作为统一底线（按 change-annotation-standard.md §4.1/§4.3）
- **异常态完整性（强制）**：功能点设计须覆盖需求中该交互的全部异常态（错误态/空态/超时/无权限），与正常态一并设计，不得只画主流程

图表下方必须补充的文字说明：
- **页面初始化流程**：组件挂载后的完整数据加载链路（含 loading 态、空态、错误态的切换）
- **用户操作清单**：逐一列出页面上所有可交互元素，每个元素说明触发动作、完整处理流程、用户反馈
- **表单交互**：逐功能点判定是否涉及表单——涉及须逐字段列出校验规则表格（字段名、校验类型、规则、错误提示文案）、校验触发时机、表单联动逻辑；不涉及须说明理由
- **列表/表格交互**：逐功能点判定是否涉及列表——涉及须给出表格列定义表格（列名、字段映射、宽度、是否可排序、格式化方式）、操作列按钮及其点击流程、筛选/搜索的触发方式和防抖策略、分页交互；不涉及须说明理由
- **弹窗/抽屉交互**：逐功能点判定是否涉及弹窗——涉及须说明打开条件和触发方式、关闭方式、关闭后的回调；不涉及须说明理由

##### 4.4 实现方案 — 状态定义与流转
- 必须给出完整的状态结构定义（TypeScript 类型）
- 复杂流转须用 mermaid stateDiagram 或 flowchart 表达；本期新增/改造的状态/转换加 `[新增]/[改造]` 文字前缀（按 change-annotation-standard.md §4.2）

### 关键约束

- 每个功能点必须完整包含 §4.0~§4.4，禁止因功能点多而省略任何子章节
- 接口定义必须从 Phase A 的对齐表获取，不得臆造
- 新增/改造字段必须以 `[新增]` / `[改造]` 标记
- 不处理未分配给本实例的功能点
