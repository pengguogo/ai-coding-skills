# 常见正反快速对比（HMOS 鸿蒙）

本文件**只提供短小的 good vs bad 对比**，帮助快速判断某个写法是否合适。

完整设计模式示例见 [design-patterns.md](design-patterns.md)；架构职责见 [architecture.md](architecture.md)。

## 过度设计（避免）

```typescript
// 避免：简单设置页引入五层架构
SettingsPage → SettingsViewModel → SettingsUseCase → SettingsRepository → SettingsService

// 推荐：匹配任务复杂度
SettingsPage + SettingsViewModel（task-split.md 要求时再拆 Repository）
```

## Massive Page（避免）

```typescript
// 避免：Page 内直接发请求、解析、管理状态
@Entry @Component
struct ProfilePage {
  build() {
    // 300 行 UI + 网络 + 数据解析
  }
}

// 推荐：按 architecture.md 分层，task 要求什么拆什么
```

## 手术式修改（推荐 vs 避免）

```typescript
// 任务：给 fetchUser 加 error 处理

// 避免：顺手改整个文件
// - 统一注释风格
// - 给每个变量加显式类型
// - 重排 import 顺序

// 推荐：只改必须改的
async fetchUser(): Promise<void> {
  try {
    this.user = await this.service.fetch()
  } catch (e) {
    this.errorMessage = (e as Error).message  // 仅新增这几行
  }
}
```

## 状态管理（推荐 vs 避免）

```typescript
// 避免：在 build() 中做复杂计算
build() {
  List() {
    ForEach(this.items.filter(i => i.active).sort((a, b) => a.time - b.time), ...)
  }
}

// 推荐：计算提到 ViewModel 的 getter
get displayItems(): Item[] {
  return this.items.filter(i => i.active).sort((a, b) => a.time - b.time)
}
```

## 资源释放（推荐 vs 避免）

```typescript
// 避免：忘记释放定时器
@Component
struct TimerView {
  private timer: number = 0
  aboutToAppear() {
    this.timer = setInterval(() => { /* ... */ }, 1000)
  }
  // 缺少 aboutToDisappear
}

// 推荐：配对释放
aboutToDisappear() {
  clearInterval(this.timer)
}
```

## 主线程阻塞（避免）

```typescript
// 避免：在 UI 线程做耗时操作
onClick() {
  const data = heavyComputation()  // 阻塞主线程
  this.result = data
}

// 推荐：使用 TaskPool
import taskpool from '@ohos.taskpool'

@Concurrent
function heavyComputation(): string { /* ... */ }

onClick() {
  taskpool.execute(heavyComputation).then((result) => {
    this.result = result as string
  })
}
```

## 循环依赖（避免）

```typescript
// 避免：HAR 模块 A import HAR 模块 B，同时 B import A

// 推荐：抽取公共接口到 base 模块，两者都依赖 base
```

## 命名

| 避免 | 推荐 |
|------|------|
| `Mgr`, `Util`（不带功能前缀） | `DRSpeechManager`, `CryptoHelper` |
| `getData()`（有网络副作用） | `fetchData()` |
| `temp`, `data` | `cachedConfig`, `speechSpeedList` |

## 硬编码（避免）

```typescript
// 避免
Text('请输入手机号')
  .fontSize(14)
  .fontColor('#333333')

// 推荐
Text($r('app.string.phone_placeholder'))
  .fontSize($r('app.float.body_font_size'))
  .fontColor($r('app.color.text_primary'))
```
