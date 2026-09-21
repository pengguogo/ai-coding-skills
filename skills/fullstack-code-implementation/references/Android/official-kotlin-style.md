# Kotlin 官方编码规范（精要）

> **唯一职责**：Kotlin 格式、命名、惯用法**风格细节**。执行原则见 [android-coding-standard.md](android-coding-standard.md)。
> 来源：[Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)

## IDE 配置

- **Settings → Editor → Code Style → Kotlin → Set from… → Kotlin style guide**
- 开启 **Incorrect formatting** 等检查，提交前自动格式化

## 源码组织

| 规则 | 说明 |
|------|------|
| 目录结构 | 纯 Kotlin 项目按包结构组织，省略公共根包路径 |
| 文件名 | 单类型文件 = 类型名.kt；多声明文件用 UpperCamelCase 描述性名称 |
| 避免 Util | 文件名应描述文件内容，不用无意义 `Util` |
| 多平台 | 平台专属顶层声明加后缀：`Platform.jvm.kt`、`Platform.android.kt` |
| 单文件多声明 | 语义相关可放同一文件，但单文件不宜超过数百行 |
| 扩展函数 | 与类强相关放同类文件；仅特定客户端用则放客户端旁 |

### 类内成员顺序

1. 属性与 init 块
2. 次构造函数
3. 方法
4. companion object

- 不按字母/可见性排序；相关逻辑放在一起
- 嵌套类靠近使用处；对外暴露的嵌套类放 companion 之后
- 重载方法必须相邻

## 命名（最常用）

| 类别 | 规则 | 示例 |
|------|------|------|
| 包名 | 全小写，不用下划线 | `org.example.project` |
| 类/对象 | UpperCamelCase | `DeclarationProcessor` |
| 函数/属性/局部变量 | lowerCamelCase | `processDeclarations()` |
| 常量 | SCREAMING_SNAKE_CASE | `const val MAX_COUNT = 8` |
| 工厂函数 | 可与返回类型同名 | `fun Foo(): Foo` |
| 测试方法 | 反引号或下划线 | `` `ensure everything works` `` |
| backing 属性 | 私有加 `_` 前缀 | `_elementList` / `elementList` |
| 缩写词 | 两字母全大写；更长仅首字母大写 | `IOStream`、`XmlFormatter` |

**命名语义**：类名用名词；方法名用动词；`sort`（原地）vs `sorted`（返回新集合）；避免 `Manager`、`Wrapper` 等空洞词。

## 格式（高频）

- **缩进**：4 空格，不用 Tab
- **大括号**：开括号在行尾，闭括号单独一行对齐
- **行宽**：建议 100 字符
- **二元运算符**两侧加空格；一元不加
- `if`/`when`/`for`/`while` 与 `(` 之间加空格
- 调用/声明的 `(` 前不加空格
- 类型参数 `<>`、`::` 两侧不加空格
- 避免水平对齐（改名不应影响格式）

### 修饰符顺序

```
public/protected/private/internal → expect/actual → final/open/abstract/sealed/const →
external → override → lateinit → tailrec → vararg → suspend → inner →
enum/annotation/fun → companion → inline/value → infix → operator → data
```

注解写在修饰符**之前**。非库代码省略冗余 `public`。

### 函数与属性

- 参数过长：换行，参数缩进 4 空格，`)` 单独一行
- 单表达式函数优先 `fun foo() = 1`
- 多行 `if`/`when` 条件：条件续行缩进 4 空格，`)` 与 `{` 同行
- 链式调用：`.` / `?.` 换行并缩进
- Lambda：花括号、箭头两侧加空格；单 lambda 尽量尾随 lambda 语法

### 尾随逗号（推荐）

声明处鼓励尾随逗号，便于 diff 与增删元素；调用处自行决定。

## 文档注释

- 长注释：`/**` 单独一行，每行以 `*` 开头
- 参数/返回值尽量写在正文，少用 `@param`/`@return`（除非需长说明）

## 避免冗余

- 返回 `Unit` 时省略返回类型
- 省略分号
- 简单变量插值不用 `{}`：`"$name"`；复杂用 `"${x.size}"`

## 语言惯用法（Android 高频）

| 主题 | 推荐 |
|------|------|
| 不可变 | 优先 `val`；对外 `List`/`Set`/`Map`，不用 `Mutable*` |
| 集合创建 | `listOf()` 而非 `arrayListOf()`（若不需可变） |
| 默认参数 | 优先默认参数，少写重载 |
| Lambda | 短且非嵌套用 `it`；嵌套 lambda 显式参数名 |
| 命名参数 | 多个同类型或 Boolean 参数时用命名参数 |
| 条件表达式 | 优先 `if`/`when` 表达式而非多 `return` |
| 二元条件 | 用 `if`，不用 `when` |
| 三元以上 | 用 `when` |
| 可空 Boolean | `if (value == true)` / `if (value == false)` |
| 循环 | 优先高阶函数；`forEach` 可空 receiver 或长链除外 |
| 开区间 | `0..<n` 优于 `0..n-1` |

## 与 Android 项目的关系

- Android Studio 对 Kotlin 与上述规范一致
- Compose 常量命名见 [official-compose-api-guidelines.md](official-compose-api-guidelines.md)（按需）
