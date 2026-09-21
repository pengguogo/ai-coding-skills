# Swift 与 Objective-C 风格

本文件**只讲语言命名、格式与互操作**，不含架构或设计模式内容。

## 手术式修改（修改已有文件时）

- 沿用该文件已有的缩进、引号、括号换行风格
- 不整文件替换引号（单/双引号）
- 不给已有代码「补」类型注解或访问修饰符
- 不统一注释风格（`//` vs `///` vs `#pragma mark`）
- 新增代码匹配周围 10 行的风格

## Swift 命名

| 场景 | 规则 | 示例 |
|------|------|------|
| 类型 / 协议 | UpperCamelCase | `ProfileViewController` |
| 变量 / 函数 | lowerCamelCase | `fetchUser()` |
| 布尔 | is/has/should 前缀 | `isEnabled` |
| 工厂 | make 前缀 | `makeViewController()` |
| 副作用方法 | 动词 | `loadData()` |
| 无副作用查询 | 名词 / 形容词 | `itemCount` |

## Swift 格式

- 4 空格缩进；类型推断够用时不写冗余类型
- 多行集合用尾随逗号
- `guard` 提前返回，减少嵌套
- 非子类化类标记 `final`

## Swift 访问控制

默认最严：`private` > `fileprivate` > `internal`。仅在有需要时放宽。

## Objective-C 风格

### 文件组织

```
MyView.h  — 公开 API
MyView.m  — 类扩展 → 生命周期 → 公开方法 → 私有方法 → Delegate
```

### 属性修饰符

| 用途 | 修饰符 |
|------|--------|
| 对象 | `nonatomic, strong` |
| Delegate | `nonatomic, weak` |
| 标量 | `nonatomic, assign` |

### Import 顺序

1. 对应 `.h`（`.m` 中）→ 2. 同模块 → 3. 系统框架 → 4. 第三方

### Nullability

公开头文件 `NS_ASSUME_NONNULL_BEGIN/END`；可空显式 `nullable`。

## Swift ↔ Objective-C 互操作

- Swift → ObjC：`@objc` / `@objcMembers`
- ObjC → Swift：`NS_SWIFT_NAME`
- 桥接头最小化

## 注释

- 公开 API 在不直观处写 `///`；解释 *why* 而非 *what*
- `#pragma mark -`（ObjC）/ `// MARK: -`（Swift）分组

## 语言层反模式

- 魔法字符串路由 / Notification 名
- Domain 层 import UIKit
- 无 guard 就 force-unwrap（`!`）
- 修改已有文件时统一「个人偏好」风格
