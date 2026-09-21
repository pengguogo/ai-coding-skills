# 鸿蒙（HMOS）分端设计标准（frontend-hmos.md）

> 本标准用于 `fullstack-design` 产出鸿蒙分端设计文件 `frontend-hmos.md`。
> 仅当 Phase A 功能点清单中存在 **目标端 = HMOS** 的功能点时加载并执行。
> 鸿蒙设计写入**独立分端设计文件** `design/frontend-hmos.md`，不再作为 `frontend-design.md` 的内嵌章节；`frontend-design.md` 为入口索引文件，通过「HMOS」访问章节指向本文件（与编码侧 `step-00-parse-task-groups.md` 的 `HMOS-{N} → frontend-hmos.md` 约定一致）。
> 涉及后端接口时，须与同需求 `backend-design.md` 一致，禁止臆造冲突接口。

---

## 文件定位

鸿蒙设计写入独立文件 `design/frontend-hmos.md`，文件标题固定为：

```markdown
# [需求名称] — 鸿蒙（HMOS）分端设计（frontend-hmos.md）
```

其下按功能点组织，每个功能点的标题格式须为 `### 功能点 N：{名称}`，以便 `task-split` 与编码侧 `step-00` 正确解析为 `HMOS-{N}` 批次。`frontend-design.md` 入口文件的「HMOS」访问章节须指向本文件。

---

## 一、鸿蒙概述

- **功能概述**：该功能在鸿蒙 App 内实现什么、解决什么问题、在 App 整体中的定位
- **功能定位**：新增页面/功能还是对现有页面的扩展；依赖的现有模块
- **目标端范围**：鸿蒙原生（ArkTS / ArkUI，Stage 模型）；不含跨平台方案
- **最低版本与兼容**：目标 API Version、compatibleSdkVersion；涉及新 API 时标注兼容策略（`canIUse`）

---

## 二、鸿蒙架构说明

> 使用与项目现状一致的架构模式（如 MVVM / MVP）；从 `frontend-project.md` 的鸿蒙项目信息获取，无则扫描仓库归纳。

### 1、模块划分

- **模块名称**：[职责、输入、输出、边界]

### 2、架构层次

- **界面层（UI）**：Page / Component（`@Component`/`@Entry`）的组成与职责
- **状态层（ViewModel/Store）**：状态承载方式（`@State`/`@Prop`/`@Link`/`@Provide`/AppStorage），状态流转
- **数据层（Repository）**：数据来源（网络 / 本地）、缓存与切换策略
- **网络层**：复用现有 `@ohos.net.http` / Axios for HarmonyOS 封装；接口定义风格
- **本地存储层**：Preferences / 关系型数据库（RelationalStore）/ 分布式数据的使用边界

```mermaid
graph TD
    A[Page/@Entry Component] --> B[ViewModel/Store]
    B --> C[Repository]
    C --> D[Remote / @ohos.net.http]
    C --> E[Local / Preferences/RelationalStore]
    B --> F[State/@State]
```

### 3、模块化设计原则

- **单一职责**：每个 ArkTS 文件/组件职责单一
- **UI 与逻辑分离**：业务逻辑下沉到 ViewModel/Store，`@Component` 只负责视图与事件转发
- **数据层分离**：UI 不直接调用网络/数据库，统一经 Repository
- **依赖管理**：与项目一致（模块化/依赖注入约定），不混用

---

## 三、规范文档对齐

### 1、技术标准

- **语言**：ArkTS（TypeScript 超集）；声明式 UI（ArkUI）
- **UI 方式**：ArkUI 声明式语法（`@Component`/`build()`）；与项目一致
- **异步方案**：async/await + Promise / RxJS（与项目一致）
- **网络**：复用现有网络层封装（`@ohos.net.http` 等），列出新增接口
- **应用模型**：Stage 模型（UIAbility / WindowStage）；路由方式（`router` / `Navigation`）

### 2、项目结构

严格遵循 `frontend-project.md` 的鸿蒙目录约定：

- **新增/修改的目录与文件**：`[路径，如 entry/src/main/ets/...]`：[用途]
- **模块结构**：与现有 module（HAP/HAR）与目录命名约定一致

### 3、UI 风格与组件对齐

- **设计体系**：HarmonyOS Design / 项目自定义主题
- **复用组件**：列出本次使用的自定义组件、通用组件、资源（`resources` 下的 color/float/string）
- **参照页面**：选定 2-3 个现有同类型页面作为 UI 与交互基准

---

## 四、功能逻辑实现（逐功能点）

> 每个功能点必须包含以下全部子章节。

### 功能点 N：{名称}

#### N.1 功能概述

- **功能描述**（用户视角）
- **实现位置**：Page / `@Component` 路径、ViewModel/Store 路径
- **关联需求**：REQ 编号

#### N.2 数据与接口

> 凡后端 HTTP/API，须标注 `来源：backend-design.md §x.x 接口N`，禁止臆造；后端未覆盖标注 `[需后端设计补充]`。

- **数据模型**：给出 ArkTS interface / class 定义，逐字段标注来源
  ```typescript
  interface ClaimItem {
    id: number;        // 来源：backend-design.md §3.2 出参字段 id
    claimNo: string;   // 来源：backend-design.md §3.2 出参字段 claimNo
  }
  ```
- **接口依赖**（逐接口展开入参/出参字段表）：
  - `[网络方法/API]`（`[Service 文件路径]`）— **来源：backend-design.md §x.x 接口N**
    - 方法 / 路径 / 调用时机
    - 入参字段表、出参字段表（与 Web 前端标准同格式）
- **字段映射**：客户端字段名/类型与后端不一致时逐字段说明
- **本地存储**（如涉及）：Preferences 键 / RelationalStore 表定义、与后端模型的映射、迁移策略

#### N.3 代码复用分析

- **可复用组件**：[路径、用途]
- **可复用数据/类型**：[路径、用途]
- **可复用服务/工具**：网络封装、工具类、公共 Component [路径、用途]

#### N.4 实现方案 — 界面结构

- **界面载体**：Page / `@Entry` Component — 职责
- **布局**：`build()` 结构、关键 ArkUI 组件（List/Grid/Column/Row 等）
- **条件显隐**：列出需按状态/权限显隐的 UI 区域及条件（`if/else`、`Visibility`）
- **导航**：进入/退出本界面的导航关系（`router.pushUrl` / `Navigation` 路由栈）

#### N.5 实现方案 — 状态定义与流转

- **状态结构**：给出完整定义（`@State`/`@Prop`/`@Link` 或 ViewModel 可观察属性）
  ```typescript
  @Observed
  class ClaimListState {
    loading: boolean = false;
    items: ClaimItem[] = [];
    error: string | null = null;
  }
  ```
- **状态承载**：`@State`/`@Prop`/`@Link`/`@Provide`+`@Consume` / AppStorage（与项目一致）
- **流转**：复杂流转用 mermaid stateDiagram 表达（含 loading / 空态 / 错误态）

#### N.6 实现方案 — 交互流程

必须包含 Mermaid 图 + 文字说明，覆盖：

- **页面初始化流程**（sequenceDiagram：用户 → Page/Component → ViewModel → Repository → 网络/本地），含 loading / 空态 / 错误态切换
- **用户操作清单**（逐一列出可交互元素：触发动作、处理流程、用户反馈）

  | 交互元素 | 触发动作 | 处理流程 | 用户反馈 |
  |----------|----------|----------|----------|
  | [按钮/输入/列表项] | [点击/输入/下拉刷新/加载更多] | [校验 → ViewModel → Repository → 状态更新] | [Loading/Toast/弹窗/页面跳转] |

- **列表交互**（如有 List/Grid）：LazyForEach + IDataSource、下拉刷新、分页加载、空态
- **表单交互**（如有）：逐字段校验规则表、校验时机、联动
- **弹窗交互**（如有 CustomDialog/promptAction）：弹出条件、关闭方式、回调

#### N.7 生命周期与资源管理

- **生命周期处理**：数据加载时机（`aboutToAppear`）、页面显隐（`onPageShow`/`onPageHide`）、UIAbility 生命周期（`onForeground`/`onBackground`）
- **资源释放**：`aboutToDisappear` 中取消订阅/定时器、注销监听、释放大对象
- **后台与前台**：是否需要在后台停止刷新/定位/轮询

#### N.8 权限与安全

- **权限申请**（如涉及）：申请的权限（`ohos.permission.*`）、申请时机、拒绝后的降级处理
- **数据安全**：敏感数据存储方式（加密 Preferences / 通用密钥库）、传输加密、日志脱敏
- **module.json5 声明**：新增的 `requestPermissions`、abilities、skills 等

#### N.9 边界与错误处理

- 空数据 / 网络异常 / 超时 / 接口错误码的处理与用户反馈
- 弱网与无网处理、重试与降级
- 错误恢复机制（重试入口、缓存兜底）
