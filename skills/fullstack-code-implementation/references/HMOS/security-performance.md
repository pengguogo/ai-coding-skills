# 安全、性能与内存（HMOS 鸿蒙）

本文件**只讲安全、性能、内存与并发**，不含架构或设计模式内容。

## 安全

### 数据存储

| 数据类型 | 推荐 | 避免 |
|----------|------|------|
| 密码、Token、密钥 | HUKS（密钥管理）/ 加密 Preferences | 普通 Preferences、源码 |
| 用户偏好 | Preferences | — |
| 结构化数据 | RelationalStore (RDB) | Preferences 存大对象 |
| 临时缓存 | 应用沙箱 filesDir | 无过期永久缓存 |

### 网络

- 默认 HTTPS
- Authorization 不写进日志
- API Key 放 `build-profile.json5` 的 `buildOption`，不进版本库

### 隐私

- 敏感权限在 `module.json5` 声明并运行时动态申请
- 日志脱敏：不打印 token、密码、身份信息

## 性能

### 启动

- UIAbility `onCreate` 中不做重活
- 非关键 SDK 延迟到 `onWindowStageCreate` 之后初始化

### 列表

- 使用 `LazyForEach` + `IDataSource` 实现按需加载
- 避免 `ForEach` 渲染全量大列表
- 图片降采样匹配显示尺寸

### 内存

- @Component 持有的订阅/定时器在 `aboutToDisappear` 中释放
- 大数据及时置空

### 组件渲染

- 合理使用 `@Trace` / `@State`，减少不必要的重绘范围
- 避免在 `build()` 中做复杂计算

## 并发

- UI 更新在主线程
- 耗时操作使用 `TaskPool.execute()` 或 `Worker`
- 异步操作使用 `async/await` + `Promise`
- 页面销毁时取消未完成的异步任务

## 日志

- 使用 `hilog` 或项目封装的日志工具
- Release 构建不输出 debug 日志
- 崩溃上报不上传 PII

## 何时加载本文件

task-split.md 涉及以下方向时加载：敏感数据存储、网络请求安全、列表性能、内存管理、并发任务。

简单 UI 任务**不需要**加载本文件。
