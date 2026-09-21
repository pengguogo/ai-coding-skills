# Jetpack Compose API 指南（精要）

> **唯一职责**：Composable 命名、Modifier、State 等 **Compose API 规则**。`tech_stack=kotlin` 且写 UI 组件时按需打开。
> 来源：[Compose API Guidelines](https://android.googlesource.com/platform/frameworks/support/+/androidx-main/compose/docs/compose-api-guidelines.md)

## 适用范围

| 受众 | 严格程度 |
|------|----------|
| `androidx.compose` 框架 | 必须严格遵守 |
| 基于 Compose 的库 | 应尽量遵守 |
| 应用开发 | 结构/风格可因既有架构适度调整 |

Kotlin 格式争议见 [official-kotlin-style.md](official-kotlin-style.md)；下文仅 Compose 特有规则。

## Kotlin 风格补充

### 常量、枚举、密封类

- 深度不可变常量：可用 **`PascalCase`**（如 `DefaultKeyName`），替代 `SCREAMING_SNAKE_CASE`
- `enum` 值：`Idle`、`Busy`，不用 `IDLE`、`BUSY`
- 与「稳定、可组合」心智模型一致

```kotlin
// 推荐
enum class Status { Idle, Busy }
const val DefaultKeyName = "__defaultKey"

// 避免（Compose 库/新代码）
enum class Status { IDLE, BUSY }
const val DEFAULT_KEY_NAME = "__defaultKey"
```

## @Composable 命名

### 返回 Unit 的 Composable（声明式实体）

- **必须** `PascalCase`
- **必须** 名词（可加形容词），**不能** 动词/动宾短语
- 适用于 UI 与非 UI 的 composition 实体

```kotlin
// 推荐
@Composable fun FancyButton(...) { }
@Composable fun BackButtonHandler(...) { }

// 避免
@Composable fun fancyButton(...) { }      // 未 PascalCase
@Composable fun RenderFancyButton(...) { } // 动词
@Composable fun drawProfileImage(...) { }  // 动词
```

### 返回非 Unit 的 Composable

- 遵循普通 Kotlin **camelCase** 函数名
- **禁止** 工厂函数豁免（不能用 `Style()` 伪装构造函数）

```kotlin
// 推荐
@Composable fun defaultStyle(): Style

// 避免
@Composable fun Style(): Style  // 像无上下文构造
```

### 内部 `remember {}` 并返回可变对象

- **必须** 以 `remember` 为前缀
- 例：`rememberCoroutineScope()`，不用 `createCoroutineScope()`

## CompositionLocal 命名

- **禁止** 以 `CompositionLocal` / `Local` 作名词后缀
- 可用 `Local` 作形容词前缀：`LocalTheme`
- 避免：`ThemeLocal`

## 稳定类型（@Stable / @Immutable）

| 注解 | 含义 |
|------|------|
| `@Immutable` | 构造后属性永不改；方法引用透明 |
| `@Stable` | 可变，但变更会通知 Compose；属性仅依赖 Stable/Immutable 类型 |

- 自定义 `@Stable` 的 `equals`：对任意 `a`、`b`，`a.equals(b)` 结果必须始终一致
- 公开 API 应正确标注；**不得** 在稳定发布后随意增删 `@Stable`/`@Immutable`（二进制兼容）

## 发射 vs 返回值（Emit XOR return）

- **禁止** 同一 `@Composable` 既发射 UI 又返回值
- 控制面通过**参数**传入（含 hoisted state），不通过返回值

```kotlin
// 推荐：状态由调用方持有
val inputState = remember { InputState() }
InputField(inputState)

// 避免
val inputState = InputField()  // 从 Composable 返回值获取状态
```

## Compose UI 元素（Element）

- 只发射**一个** UI 节点；**必须**返回 `Unit`
- **必须**接受 `modifier: Modifier = Modifier`
  - 参数名固定 `modifier`
  - 第一个**可选**参数
  - 传给子节点/根节点
  - 额外 Modifier 接在传入 modifier **末尾**，不要插在开头

```kotlin
@Composable
fun FancyButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) { ... }
```

## Compose UI 布局（Layout）

- 接受 `@Composable` 子内容的函数
- 单个 lambda 参数名：**`content`**
- 主 `content` 放**最后**，便于尾随 lambda

```kotlin
@Composable
fun SimpleRow(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) { ... }
```

## Modifier 工厂

- 不暴露 `Modifier.Element` 实现类型
- 扩展函数形式：`fun Modifier.myModifier(...): Modifier = then(...)`
- 父数据 Modifier（如 `weight`）定义在 **Layout Scope** 内，非顶层函数

## API 设计模式（应用最常违反）

### 1. 无状态、受控 Composable

```kotlin
// 推荐：状态在调用方
Checkbox(isChecked = checked, onToggle = { ... })

// 避免：Composable 内部 remember 初始值当真相源
Checkbox(initialValue = false, onChecked = { ... })
```

### 2. 区分 State 与 Event

| 类型 | 特点 |
|------|------|
| **State** | 可合并；观察者应对同一值幂等；Compose 以 state 为输入 |
| **Event** | 时点性；不可丢；如点击流 |

- Composable 是 **state 观察者**（参数 + 读取的 `mutableStateOf`）

### 3. Hoisted State 类型

- 参数过多时：抽 `XxxState` 接口，`@Stable`
- 命名：`{ComposableName}State`（如 `VerticalScrollerState`）
- 优先 **interface** + 默认 `remember { XxxState() }` 工厂
- **禁止** 用 `null` 表示「内部 remember」——易与合法 null 混淆

```kotlin
@Stable
interface VerticalScrollerState {
    var scrollPosition: Int
    var scrollRange: Int
}

@Composable
fun VerticalScroller(
    state: VerticalScrollerState = remember { VerticalScrollerState() },
) { ... }
```

### 4. 可扩展性

- 库/API：hoisted state 用 **interface**，便于 App 单一数据源适配多模块
- App：简单场景可用具体类，需要时再抽 interface + 工厂（源兼容）

## 快速对照表

| 场景 | 规则 |
|------|------|
| 屏幕/卡片 Composable | PascalCase 名词 |
| 返回 State/Style | camelCase，非 PascalCase 工厂名 |
| 缓存 CoroutineScope | `rememberXxx()` 前缀 |
| 自定义 Button/Text | 必有 `modifier`，默认 `Modifier` |
| Row/Column 子内容 | 尾随 `content` lambda |
| 表单控件状态 | 调用方持有，Composable 受控 |
| 滚动/列表状态 | `XxxState` + 默认 remember 实现 |

## 相关文档

- [Android 编码规范](android-coding-standard.md)
- [Kotlin 编码规范精要](official-kotlin-style.md)
- [Android 架构精要](official-android-architecture.md)
