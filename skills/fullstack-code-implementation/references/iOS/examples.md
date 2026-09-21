# 常见正反快速对比

本文件**只提供短小的 good vs bad 对比**，帮助快速判断某个写法是否合适。

完整设计模式示例见 [design-patterns.md](design-patterns.md)；架构职责见 [architecture.md](architecture.md)。

## 过度设计（避免）

```swift
// 避免：简单登录页引入五层架构
LoginView → LoginViewModel → LoginUseCase → LoginRepository → LoginAPIService

// 推荐：匹配任务复杂度
LoginViewController + LoginViewModel + AuthService（task-split.md 要求时再拆 Repository）
```

## Massive ViewController（避免）

```swift
// 避免
class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        URLSession.shared.dataTask(with: url) { ... }.resume()  // 网络
        // + 200 行布局 + 导航 + 解析
    }
}

// 推荐：task-split.md 要求什么拆什么，不多拆
```

## 手术式修改（推荐 vs 避免）

```swift
// 任务：给 fetchUser 加 error 处理

// 避免：顺手改整个文件
// - 改所有注释为 ///
// - 给每个变量加显式类型
// - 单引号改双引号
// - 重排 import 顺序

// 推荐：只改必须改的
func fetchUser() async {
    do {
        user = try await service.fetch()
    } catch {
        errorMessage = error.localizedDescription  // 仅新增这几行
    }
}
```

## Auto Layout（推荐 vs 避免）

```swift
// 推荐
label.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([...])

// 避免
label.frame = CGRect(x: 16, y: 88, width: 300, height: 44)
```

## 闭包循环引用

```swift
// 避免
service.fetch { result in self.updateUI(result) }

// 推荐
service.fetch { [weak self] result in
    guard let self else { return }
    self.updateUI(result)
}
```

## SwiftUI body 过重（避免）

```swift
// 避免
var body: some View {
    List(items.filter { $0.isActive }.sorted { ... }) { ... }
}

// 推荐：提取计算或子视图
var body: some View {
    List(viewModel.displayItems) { ItemRow(item: $0) }
}
```

## 单例滥用（避免）

```swift
// 避免：可变业务状态放单例
UserManager.shared.currentUser = user

// 推荐：构造函数注入
init(authService: AuthServiceProtocol) { ... }
```

## 命名

| 避免 | 推荐 |
|------|------|
| `VC`, `Mgr`, `Util` | `ProfileViewController` |
| `getUser()`（有网络副作用） | `fetchUser()` |
| `data`, `temp` | `userProfile`, `cachedResponse` |

## Objective-C Delegate

```objc
// 推荐
@property (nonatomic, weak, nullable) id<PhotoPickerDelegate> delegate;

// 避免
@property (nonatomic, strong) id<PhotoPickerDelegate> delegate;  // 循环引用
```
