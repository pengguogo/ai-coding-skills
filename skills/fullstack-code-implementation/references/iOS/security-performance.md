# 安全、性能与内存

本文件**只讲安全、性能、内存与并发**，不含架构或设计模式内容。

## 安全

### 数据存储

| 数据类型 | 推荐 | 避免 |
|----------|------|------|
| 密码、Token | Keychain | UserDefaults、源码 |
| 用户偏好 | UserDefaults | — |
| 大量数据 | Core Data / SQLite | UserDefaults |
| 临时缓存 | URLCache / 磁盘目录 | 无过期永久缓存 |

### 网络

- 默认 HTTPS（ATS 开启）
- Authorization 不写进日志
- API Key 放 Build Configuration，不进版本库

### 隐私

- 敏感权限前请求授权（Info.plist 用途字符串）
- 日志脱敏：不打印 token、密码

## 性能

### 启动

- 减少 `didFinishLaunching` 同步重活
- 非关键 SDK 延迟初始化

### 列表

- Cell 复用；`prepareForReuse` 取消异步任务
- 图片降采样匹配显示尺寸

### 内存

- 闭包 / Delegate 避免循环引用
- 大图及时释放

### SwiftUI

- 稳定 `ForEach` 的 `id`
- 大列表用 `LazyVStack` / `List`

## 并发

- UI 更新在 Main Actor / 主线程
- 新代码优先 `async/await`
- View 消失时 `Task.cancel()`

## 日志

- Release 用 `os.Logger`，不用 `print`
- 崩溃上报不上传 PII

## 何时加载本文件

task-split.md 涉及以下方向时加载：敏感数据存储、网络请求、列表性能、内存泄漏风险、并发。

简单 UI 任务**不需要**加载本文件。
