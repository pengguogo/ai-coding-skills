# Android 官方应用架构（精要）

> **唯一职责**：官方分层、SSOT、UDF、最佳实践**架构条文**。模式示例见 [design-patterns-examples.md](design-patterns-examples.md)。
> 组件/Manifest/资源等基础见 [official-android-developer-guide-basics.md](official-android-developer-guide-basics.md)。
> 来源：[Guide to app architecture](https://developer.android.com/topic/architecture)

## 为什么需要架构

- 应用需在手机、平板、折叠屏、ChromeOS、车载、XR 等多形态运行
- 系统可能随时回收进程；组件生命周期短且可独立启动
- **不要把应用数据或状态存在 Activity/Service 等组件里**——组件应自包含、彼此独立

## 核心原则

### 1. 关注点分离（Separation of concerns）

- 不要把所有代码写在 `Activity` 里
- `Activity` 主要职责是承载 UI；因旋转、低内存等会被频繁销毁重建
- 状态与数据应放在 ViewModel、Repository 等更持久的层

### 2. 用数据模型驱动 UI（Drive UI from data models）

- UI 由**数据模型**驱动，模型最好可持久化
- 模型与 UI 元素、组件生命周期解耦
- 好处：进程被杀不丢数据；弱网/离线仍可用；易测试

### 3. 单一数据源（Single Source of Truth, SSOT）

- 每种数据类型指定**唯一**可修改来源
- 对外暴露**不可变**类型；修改通过 SSOT 暴露的函数或事件
- 离线优先场景：SSOT 通常是数据库；有时也可以是 ViewModel

### 4. 单向数据流（Unidirectional Data Flow, UDF）

- **状态**自上而下（高层 → 低层，如数据源 → UI）
- **事件**自下而上（UI → SSOT 修改数据）
- 与 SSOT 配合：一致性更好、易调试、少 bug

```
用户点击 → UI 发出事件 → ViewModel/Repository 更新 SSOT → 新状态流向 UI
```

## 推荐分层（至少两层）

```
┌─────────────────────────────────────┐
│  UI 层：展示数据、响应用户            │
├─────────────────────────────────────┤
│  Data 层：业务逻辑、暴露应用数据       │
├─────────────────────────────────────┤
│  Domain 层（可选）：复杂/复用业务逻辑   │
└─────────────────────────────────────┘
```

箭头表示**依赖方向**（上层依赖下层类）。

### UI 层

| 组成 | 职责 |
|------|------|
| UI 元素 | Compose 函数 / View，渲染数据 |
| State holder | 如 `ViewModel`，持有并暴露 UI 状态、处理逻辑 |

- State holder 生命周期应 ≥ 其服务的 UI（如屏幕在 back stack 期间保留 ViewModel）
- 自适应 UI：`ViewModel` 暴露适配窗口大小的状态；`NavigationSuiteScaffold` 等按空间切换导航形态

### Data 层

| 组成 | 职责 |
|------|------|
| Repository | 对一种数据类型的 SSOT；暴露数据、集中变更、解决多源冲突、抽象数据源、承载业务规则 |
| Data source | 单一来源：文件、网络、本地 DB |

- 每种数据一个 Repository（如 `MoviesRepository`、`PaymentsRepository`）

### Domain 层（可选）

- 封装复杂或被多个 ViewModel 复用的业务逻辑
- 类常称 **Use Case** / **Interactor**，一个类一个功能
- 例：`GetTimeZoneUseCase`
- 不需要时不要加这一层

## 依赖管理

| 方式 | 说明 |
|------|------|
| **依赖注入（DI）** | 推荐；类声明依赖，运行时由容器提供 |
| 服务定位器 | 从注册表取依赖；可测试性较差 |

> **Android 推荐**：DI 模式 + **Hilt**（编译期校验、自动构建依赖树、Android 类容器）

## 通用最佳实践（Checklist）

| 做法 | 说明 |
|------|------|
| 不在组件里存数据 | Activity/Service/BroadcastReceiver 只协调，不当数据源 |
| 减少对 Android 类的依赖 | 仅组件层依赖 `Context` 等；其余抽象便于测试 |
| 模块职责清晰 | 网络加载、缓存、绑定不要散落成一团 |
| 少暴露模块内部 | 不要为省事暴露实现细节 |
| 专注应用核心价值 | 重复样板交给 Jetpack |
| 使用规范布局 | Compose 规范布局 + 设计模式库 |
| 配置变更保留 UI 状态 | 旋转、折叠、窗口大小变化时状态不丢 |
| UI 组件可复用、可组合 | 便于多尺寸重组，少重构 |
| 可隔离测试 | 网络层与 DB 层 API 清晰，便于单测 |
| 类型负责并发策略 | 长阻塞由类型移到正确线程；类型应 **main-safe** |
| 尽量持久化新鲜数据 | 离线可用；勿假设用户始终在线 |

## 现代 Android 架构技术栈

- 自适应、分层架构
- 各层 UDF
- UI 层用 state holder 管理复杂度
- Coroutines + Flow
- DI 最佳实践（Hilt）

## 架构收益

- 可维护性、质量、稳定性提升
- 易扩展（多人协作、少冲突）
- 新人上手快
- 易测试、易按流程排查 bug
- 用户侧：更稳定、功能迭代更快

## 相关文档

- [编码约束核心](android-coding-standard.md)
- [模式示例](design-patterns-examples.md)
- [文档地图](README.md)
