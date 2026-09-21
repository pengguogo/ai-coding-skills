# 架构与模块职责（HMOS 鸿蒙）

本文件**只讲架构分层与模块组织**，不含代码示例。模式示例见 [design-patterns.md](design-patterns.md)，正反对比见 [examples.md](examples.md)。

## Stage 模型概要

HarmonyOS 应用使用 Stage 模型：
- **UIAbility**：应用入口，管理生命周期
- **Page**：UIAbility 内的页面，承载 UI
- **HAP**：应用入口模块（entry）
- **HAR**：共享库模块（可被多个 HAP 依赖）

## 何时需要复杂架构

| 项目规模 | 推荐 |
|----------|------|
| 单页功能 | Page + @State 即可 |
| 多页 CRUD | MVVM（ViewModel + @ObservedV2） |
| 多模块大型应用 | HAR 分模块 + MVVM + Repository |

**简单优先：** 不从复杂架构起步；task-split.md 未要求时不主动引入新层。

## 推荐目录结构

```
entry/                           # HAP 入口模块
├── src/main/ets/
│   ├── entryability/           # UIAbility 入口
│   ├── pages/                  # 页面（Navigation 容器）
│   └── components/             # 入口模块私有组件
├── src/main/resources/         # 资源文件
└── module.json5                # 模块配置

feature_module/                  # HAR 业务模块
├── src/main/ets/
│   ├── pages/                  # 模块内页面
│   ├── components/             # 模块内组件
│   ├── viewmodel/              # ViewModel
│   ├── model/                  # 数据模型
│   ├── service/                # 网络/存储等服务
│   └── utils/                  # 工具类
└── module.json5

base_module/                     # HAR 基础设施模块
├── src/main/ets/
│   ├── network/                # HTTP 封装
│   ├── storage/                # KV/RDB 封装
│   ├── utils/                  # 通用工具
│   └── crypto/                 # 加解密
└── module.json5
```

## 分层职责（唯一关注点）

```
Page / @Component  → 渲染 UI、转发用户事件；不含网络/持久化/业务判断
ViewModel          → 页面状态与交互逻辑；使用 @ObservedV2/@Trace 驱动 UI
Repository         → 数据访问抽象；合并本地/远程
Service            → 网络、Preferences、RDB、文件等基础设施
```

**规则：**
- 每一层只依赖下一层，不跨层调用
- Page/Component 不 import 网络层
- ViewModel 不直接操作 UI 组件实例

## 模块间通信

| 方式 | 适用 |
|------|------|
| 构造函数/参数传递 | 默认首选 |
| AppStorage / LocalStorage | 跨页面共享简单状态 |
| EventHub（UIAbility 级） | 同 Ability 内跨页面通信 |
| CommonEvent | 跨 Ability / 跨应用广播（慎用） |

避免模块间直接 import 具体实现类；使用接口/抽象。

## 数据流

- 单向：用户操作 → ViewModel 更新状态 → UI 自动响应
- 同一页面状态有单一数据源
- 重复操作不重复提交

## 导航

- Navigation + NavPathStack 管理页面栈
- 路由注册在 `module.json5` 的 `routerMap`
- 跨模块跳转通过路由名而非直接引用 Page 类

## 反模式

- Page 组件内直接发网络请求和做数据解析
- 可变业务状态放全局静态变量
- ViewModel 直接操作 UI 组件实例
- 简单页面强行引入三层抽象
- HAR 模块间循环依赖

## 延伸阅读

- 设计模式代码示例：[design-patterns.md](design-patterns.md)
