# AOSP Android Java 代码风格（精要）

> **唯一职责**：Java 格式、异常、import、字段命名、日志等**风格细节**。执行原则见 [android-coding-standard.md](android-coding-standard.md)。
> 来源：[AOSP Java code style](https://source.android.com/docs/setup/contribute/code-style)

## 最高原则：保持一致（BE CONSISTENT）

- 修改文件时先看周围代码风格并匹配
- 全局规则提供词汇表；**局部一致性**同样重要
- 新代码应合规；旧代码可不 retrofix，但新增须遵循

## Java 语言规则

### 1. 不要忽略异常（Don't ignore exceptions）

```java
// 禁止：空 catch
try {
    serverPort = Integer.parseInt(value);
} catch (NumberFormatException e) { }
```

**推荐处理方式（按优先级）：**

1. 向上抛出：`throws NumberFormatException`
2. 包装为领域异常：`throws ConfigurationException`
3. catch 中优雅降级并赋默认值（需 Javadoc 说明）
4. 确属不可恢复时 `throw new RuntimeException(..., e)`
5. 最后手段：忽略但必须注释**为何**安全

### 2. 不要捕获泛型异常（Don't catch generic Exception）

```java
// 禁止
try {
    io();
    parse();
} catch (Exception e) { handleError(); }
```

- 几乎不应 catch `Exception` 或 `Throwable`（含 `Error`）
- 会掩盖 `ClassCastException` 等未预期问题
- **例外**：测试代码、顶层批处理需兜住所有错误时——须注释说明

**替代：** 多 catch、拆分 try、向上抛、细粒度 catch

### 3. 不要使用 finalizer（Don't use finalizers）

- Android 不用 finalizer；优先 try-finally / `close()`
- 若必须 finalizer：提供 `close()` 并文档化调用时机；finalizer 中可打短日志

### 4. 完全限定导入（Fully qualify imports）

- Android 代码：**`import foo.Bar;`**，不用 `import foo.*;`
- **例外**：JDK 标准库（`java.util.*`）、JUnit（`junit.framework.*`）

## Java 风格规则

### 文件结构

```
版权头
package
import（块之间空行：android → 第三方 → java/javax）
类 Javadoc（至少一句，第三人称动词开头）
class
```

### Javadoc

- 每个非平凡 public 类/方法至少一句描述
-  trivial getter/setter 可省略（如仅 "sets Foo"）
- public 方法都建议写 Javadoc

### 方法与字段

| 规则 | 说明 |
|------|------|
| 短方法 | 无硬上限；超过约 40 行考虑拆分 |
| 字段位置 | 文件顶部或紧挨使用它的方法前 |
| 变量作用域 | 最小化；首次使用处声明并尽量初始化 |
| for 循环变量 | 写在 `for` 内，除非有充分理由 |

### import 顺序

1. `android.*`
2. 第三方：`com`、`junit`、`net`、`org`
3. `java.*`、`javax.*`

- 组内字母序（大写先于小写）
- 组间空行
- **static import** 放在最前，同样分组排序

### 缩进与换行

| 项 | 规则 |
|----|------|
| 块缩进 | **4 空格**，不用 Tab |
| 换行续行 | **8 空格**（调用、赋值换行） |
| 行宽 | **最多 100 字符**（注释中的命令/URL、import 可例外） |

```java
// 推荐换行缩进
Instrument i =
        someLongExpression(that, wouldNotFit, on, one, line);
```

### 字段命名（AOSP 惯例）

| 类型 | 前缀/风格 |
|------|-----------|
| static final 常量 | `ALL_CAPS_WITH_UNDERSCORES` |
| static 字段 | `s` 前缀，如 `sSingleton` |
| 非 public 非 static | `m` 前缀，如 `mPrivate` |
| 其他实例字段 | 小写开头 |
| public 字段 | 小写开头，如 `publicField` |

```java
public static final int SOME_CONSTANT = 42;
private static MyClass sSingleton;
private int mPrivate;
public int publicField;
```

> **App 项目**：若模块未使用 `m`/`s` 前缀，与 [android-coding-standard.md](android-coding-standard.md) 一致——保持模块内统一即可。

### 大括号风格

- 开括号与前面代码**同一行**（K&R / Android 风格）
- **必须**为条件语句加括号

```java
// 可接受
if (condition) body();

// 禁止
if (condition)
    body();
```

### 注解

- 注解在其它修饰符之前
- 简单标记（`@Override`）可与元素同行
- 多个/带参注解：每行一个，字母序

| 注解 | 用法 |
|------|------|
| `@Override` | 覆盖超类/接口方法时必须 |
| `@Deprecated` | 配合 `@deprecated` Javadoc 与替代方案 |
| `@SuppressWarnings` | 仅当无法消除警告；须 `TODO` 说明原因；范围尽量小 |

### 缩写词当作普通单词

| 好 | 差 |
|----|-----|
| `XmlHttpRequest` | `XMLHTTPRequest` |
| `getCustomerId` | `getCustomerID` |
| `Html` | `HTML` |

### TODO 注释

```java
// TODO: Remove this code after the UrlTable2 has been checked in.
```

- 全大写 `TODO:` + 说明；若有期限写具体日期或事件

## 日志（Log sparingly）

| 级别 | 用途 |
|------|------|
| VERBOSE | 其余细节；仅 debug；`if (LOCAL_LOGV)` 包裹 |
| DEBUG | 调试信息；release 也可能存在；`if (LOCAL_LOG)` |
| INFORMATIVE | 有影响但不一定是错误；模块内权威来源才打 |
| WARNING | 用户可见但可能可恢复 |
| ERROR | 致命、难恢复 |

**要点：**

- 字符串拼接放在 `if (LOCAL_LOG)` 内，避免 release 成本
- 不用 `System.out.println()`（重定向到 `/dev/null` 仍会构建字符串）
- 不记 PII/敏感内容；单条日志宜 80–100 字符，尽量单行
- 网络断开等常见情况勿滥打 WARNING+
- 成功路径勿用高于 VERBOSE 的级别

## Javatests 命名

```
testMethod_specificCase1
testMethod_specificCase2

void testIsDistinguishable_protanopia() { ... }
```

- 下划线分隔：被测方法 + 具体场景

## 相关文档

- [编码约束核心](android-coding-standard.md)
- [文档地图](README.md)
