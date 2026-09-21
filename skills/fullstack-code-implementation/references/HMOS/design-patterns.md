# 鸿蒙 HMOS 常用设计模式实践

本文件**只提供设计模式的 ArkTS 对照示例**，不含架构分层原则（见 [architecture.md](architecture.md)）。

编码时优先匹配项目已有模式；task-split.md 未要求时不主动引入新模式。

## 模式速查

| 模式 | 典型场景 |
|------|----------|
| MVVM | 视图与逻辑分离（@ObservedV2 + @Trace） |
| Repository | 统一数据访问（本地 + 远程） |
| Observer/EventHub | 跨页面事件通信 |
| Singleton | 全局唯一资源（Manager 类） |
| Factory | 屏蔽创建细节（播放器工厂等） |
| Strategy | 可替换算法（排序、TTS 引擎切换） |
| Builder | 分步构建复杂配置 |
| Dependency Injection | 依赖可替换 |

---

## MVVM

```typescript
// ViewModel
@ObservedV2
export class LoginViewModel {
  @Trace phone: string = ''
  @Trace code: string = ''
  @Trace isLoading: boolean = false
  @Trace errorMessage: string = ''

  get canSubmit(): boolean {
    return this.phone.length > 0 && this.code.length === 6
  }

  async login(): Promise<void> {
    this.isLoading = true
    this.errorMessage = ''
    try {
      await AuthService.login(this.phone, this.code)
    } catch (e) {
      this.errorMessage = (e as Error).message
    }
    this.isLoading = false
  }
}

// Page
@Entry
@Component
struct LoginPage {
  private vm: LoginViewModel = new LoginViewModel()

  build() {
    Column() {
      TextInput({ placeholder: '手机号' })
        .onChange((value: string) => { this.vm.phone = value })
      TextInput({ placeholder: '验证码' })
        .onChange((value: string) => { this.vm.code = value })
      Button('登录')
        .enabled(this.vm.canSubmit && !this.vm.isLoading)
        .onClick(() => { this.vm.login() })
    }
  }
}
```

---

## Repository

```typescript
export class UserRepository {
  private remote: RemoteUserService
  private local: LocalUserStorage

  constructor(remote: RemoteUserService, local: LocalUserStorage) {
    this.remote = remote
    this.local = local
  }

  async getUser(id: string): Promise<UserModel> {
    const cached = await this.local.getUser(id)
    if (cached) return cached
    const user = await this.remote.fetchUser(id)
    await this.local.saveUser(user)
    return user
  }
}
```

---

## Observer / EventHub

```typescript
// 发送事件（同 UIAbility 内）
const context = getContext(this) as common.UIAbilityContext
context.eventHub.emit('userDidLogin', { userId: '123' })

// 监听事件
context.eventHub.on('userDidLogin', (data: Record<string, string>) => {
  // 更新状态
})

// 页面销毁时移除监听
aboutToDisappear() {
  context.eventHub.off('userDidLogin')
}
```

---

## Singleton（Manager）

```typescript
export class AppConfig {
  private static instance: AppConfig | null = null

  private constructor() {}

  static getInstance(): AppConfig {
    if (!AppConfig.instance) {
      AppConfig.instance = new AppConfig()
    }
    return AppConfig.instance
  }

  baseUrl: string = 'https://api.example.com'
}
```

---

## Factory

```typescript
interface Player {
  play(data: ArrayBuffer): void
  setSpeed(rate: number): void
  stop(): void
}

class AudioRenderPlayer implements Player { /* ... */ }
class RTCAudioPlayer implements Player { /* ... */ }
class SystemPlayer implements Player { /* ... */ }

export class PlayerFactory {
  static create(type: 'render' | 'rtc' | 'system'): Player {
    switch (type) {
      case 'render': return new AudioRenderPlayer()
      case 'rtc': return new RTCAudioPlayer()
      case 'system': return new SystemPlayer()
    }
  }
}
```

---

## Strategy

```typescript
interface SortStrategy<T> {
  sort(items: T[]): T[]
}

class PriceAscending implements SortStrategy<Product> {
  sort(items: Product[]): Product[] {
    return items.sort((a, b) => a.price - b.price)
  }
}

class SalesDescending implements SortStrategy<Product> {
  sort(items: Product[]): Product[] {
    return items.sort((a, b) => b.sales - a.sales)
  }
}
```

---

## 模式选用建议

| 需求 | 推荐模式 |
|------|----------|
| 视图与逻辑分离 | MVVM（@ObservedV2 + @Trace） |
| 统一本地/远程数据 | Repository |
| 跨页面通信 | EventHub / CommonEvent |
| 全局唯一资源 | Singleton (Manager) |
| 屏蔽创建细节 | Factory |
| 可切换算法 | Strategy |
| 复杂配置分步构建 | Builder |
| 可测试依赖 | Dependency Injection |

**避免过度设计：** 简单页面不必强行引入多层架构；优先匹配项目已有复杂度。
