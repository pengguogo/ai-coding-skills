# 架构与模块职责

本文件**只讲架构分层与模块组织**，不含代码示例。模式示例见 [design-patterns.md](design-patterns.md)，正反对比见 [examples.md](examples.md)。

## 何时需要复杂架构

| 项目规模 | 推荐 |
|----------|------|
| 单屏 / 简单功能 | MVC 或 ViewController + 自定义 View 即可 |
| 多屏 CRUD | MVVM |
| 多 Tab + 深链 + 复杂导航 | MVVM + Coordinator |
| 大型多模块 | Feature 模块化 + DI 容器 |

**简单优先：** 不从复杂架构起步；task-split.md 未要求时不主动引入新层。

## 推荐目录结构（中大型 App）

```
App/
├── Application/          # 入口、DI 组装
├── Features/             # 按功能垂直切分
│   └── Login/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Core/                 # 横切能力
│   ├── Networking/
│   ├── Storage/
│   └── DesignSystem/
└── Resources/
```

小项目可扁平化，但**职责边界**保持一致。

## 分层职责（唯一关注点）

```
View          → 渲染 UI、转发用户事件；不含网络/持久化/业务判断
ViewModel     → 页面状态与交互逻辑；不持有 UIView/UIViewController
UseCase       → （可选）复杂业务编排；简单任务不需要
Repository    → 数据访问抽象；简单任务可直接用 Service
Service       → 网络、数据库、Keychain 等基础设施
```

**规则：**
- 每一层只依赖下一层的协议，不跨层调用
- View 不 import 网络层
- ViewModel 不 import UIKit（SwiftUI View 除外）

## 模块间通信

| 方式 | 适用 |
|------|------|
| 协议 + 构造函数注入 | 默认首选 |
| Delegate | UI 组件一对一回调 |
| Notification | 跨模块广播（慎用） |

避免 Feature 间直接 import 具体实现类。

## 数据流

- 单向：Action → 状态更新 → UI 渲染
- 同一屏幕状态有单一数据源
- 重复 tap 不重复提交

## 反模式

- Massive View Controller（含网络/DB/布局/导航）
- Singleton 承载可变业务状态
- ViewModel 直接操作 View
- 简单页面强行引入 Coordinator + Repository + UseCase 三层

## 延伸阅读

- 设计模式代码示例：[design-patterns.md](design-patterns.md)
