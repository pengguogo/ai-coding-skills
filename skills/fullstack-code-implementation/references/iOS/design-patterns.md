# iOS 常用设计模式实践

本文件**只提供设计模式的 Swift / Objective-C 对照示例**，不含架构分层原则（见 [architecture.md](architecture.md)）或语言风格（见 [swift-objc-style.md](swift-objc-style.md)）。

编码时优先匹配项目已有模式；task-split.md 未要求时不主动引入新模式。

## 模式速查

| 模式 | 典型场景 | Apple 框架中的体现 |
|------|----------|-------------------|
| Delegate | 一对一回调、组件事件 | `UITableViewDelegate` |
| Target-Action | 控件事件绑定 | `UIButton` + `#selector` |
| Notification | 一对多广播 | `NotificationCenter` |
| Singleton | 全局唯一资源（慎用） | `URLSession.shared` |
| Factory | 屏蔽创建细节 | `UIStoryboard` 实例化 |
| Builder | 分步构建复杂对象 | `UIButton.Configuration` |
| Strategy | 可替换算法 | 排序、格式化、支付渠道 |
| Adapter | 接口转换 | `UITableViewDataSource` |
| Facade | 简化子系统调用 | 统一网络层封装 |
| Repository | 数据访问抽象 | 本地 + 远程数据源 |
| MVVM | 视图与逻辑分离 | ViewModel + 数据绑定 |
| Coordinator | 导航解耦 | 多页面流程编排 |
| Dependency Injection | 依赖可替换 | 构造函数注入协议 |
| Command | 封装操作、支持撤销 | `NSUndoManager` |
| Composite | 树形结构统一操作 | `UIView` 层级 |

---

## Delegate（委托）

**场景：** 组件将决策/事件回调给外部；一对一通信。

### Swift

```swift
protocol ImageLoaderDelegate: AnyObject {
    func imageLoader(_ loader: ImageLoader, didFinishWith image: UIImage)
    func imageLoader(_ loader: ImageLoader, didFailWith error: Error)
}

final class ImageLoader {
    weak var delegate: ImageLoaderDelegate?

    func load(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            if let error {
                self.delegate?.imageLoader(self, didFailWith: error)
                return
            }
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.delegate?.imageLoader(self, didFinishWith: image)
            }
        }.resume()
    }
}

// 使用方
extension ProfileViewController: ImageLoaderDelegate {
    func imageLoader(_ loader: ImageLoader, didFinishWith image: UIImage) {
        avatarView.image = image
    }

    func imageLoader(_ loader: ImageLoader, didFailWith error: Error) {
        showError(error)
    }
}
```

### Objective-C

```objc
// ImageLoader.h
@protocol ImageLoaderDelegate <NSObject>
@optional
- (void)imageLoader:(ImageLoader *)loader didFinishWithImage:(UIImage *)image;
- (void)imageLoader:(ImageLoader *)loader didFailWithError:(NSError *)error;
@end

@interface ImageLoader : NSObject
@property (nonatomic, weak, nullable) id<ImageLoaderDelegate> delegate;
- (void)loadFromURL:(NSURL *)url;
@end

// ImageLoader.m
- (void)loadFromURL:(NSURL *)url {
    __weak typeof(self) weakSelf = self;
    [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        if (error) {
            [self.delegate imageLoader:self didFailWithError:error];
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageLoader:self didFinishWithImage:image];
        });
    }].resume;
}
```

---

## Target-Action（目标-动作）

**场景：** UIKit 控件事件绑定。

### Swift

```swift
final class LoginViewController: UIViewController {
    private let loginButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    @objc private func loginTapped() {
        viewModel.submit()
    }
}
```

### Objective-C

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.loginButton addTarget:self
                         action:@selector(loginTapped)
               forControlEvents:UIControlEventTouchUpInside];
}

- (void)loginTapped {
    [self.viewModel submit];
}
```

---

## Notification / Observer（通知观察者）

**场景：** 一对多广播；模块间松耦合。优先 Delegate 或 Combine，Notification 适合跨模块全局事件。

### Swift

```swift
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
}

// 发送
NotificationCenter.default.post(name: .userDidLogin, object: nil, userInfo: ["userID": id])

// 观察（记得 removeObserver 或用 token）
var token: NSObjectProtocol?
token = NotificationCenter.default.addObserver(
    forName: .userDidLogin,
    object: nil,
    queue: .main
) { notification in
    let userID = notification.userInfo?["userID"] as? String
    // 更新 UI
}
```

### Objective-C

```objc
// 定义
NSNotificationName const UserDidLoginNotification = @"UserDidLoginNotification";

// 发送
[[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification
                                                    object:nil
                                                  userInfo:@{@"userID": userID}];

// 观察
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(userDidLogin:)
                                             name:UserDidLoginNotification
                                           object:nil];

- (void)userDidLogin:(NSNotification *)note {
    NSString *userID = note.userInfo[@"userID"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
```

---

## Singleton（单例）

**场景：** 进程内唯一实例（网络配置、主题管理）。**避免**用单例承载可变业务状态。

### Swift

```swift
final class AppConfiguration {
    static let shared = AppConfiguration()
    private init() {}

    private(set) var apiBaseURL: URL = URL(string: "https://api.example.com")!
}
```

### Objective-C

```objc
@interface AppConfiguration : NSObject
+ (instancetype)shared;
@end

@implementation AppConfiguration

+ (instancetype)shared {
    static AppConfiguration *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppConfiguration alloc] init];
    });
    return instance;
}

@end
```

---

## Factory（工厂）

**场景：** 封装对象创建，调用方不依赖具体类。

### Swift

```swift
enum ViewControllerFactory {
    static func makeProfile(userID: String) -> UIViewController {
        let vm = ProfileViewModel(userID: userID, repository: ProfileRepository())
        return ProfileViewController(viewModel: vm)
    }

    static func makeSettings() -> UIViewController {
        SettingsViewController()
    }
}
```

### Objective-C

```objc
@interface ViewControllerFactory : NSObject
+ (UIViewController *)profileViewControllerWithUserID:(NSString *)userID;
+ (UIViewController *)settingsViewController;
@end

@implementation ViewControllerFactory

+ (UIViewController *)profileViewControllerWithUserID:(NSString *)userID {
    ProfileViewModel *vm = [[ProfileViewModel alloc] initWithUserID:userID];
    return [[ProfileViewController alloc] initWithViewModel:vm];
}

+ (UIViewController *)settingsViewController {
    return [[SettingsViewController alloc] init];
}

@end
```

---

## Builder（建造者）

**场景：** 分步构建复杂对象；参数多、可选配置多。

### Swift

```swift
struct AlertBuilder {
    private var title = ""
    private var message = ""
    private var actions: [UIAlertAction] = []

    func title(_ value: String) -> Self {
        var copy = self
        copy.title = value
        return copy
    }

    func message(_ value: String) -> Self {
        var copy = self
        copy.message = value
        return copy
    }

    func addAction(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) -> Self {
        var copy = self
        copy.actions.append(UIAlertAction(title: title, style: style) { _ in handler?() })
        return copy
    }

    func build() -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        return alert
    }
}

// 使用
let alert = AlertBuilder()
    .title("提示")
    .message("确定删除？")
    .addAction(title: "取消", style: .cancel)
    .addAction(title: "删除", style: .destructive) { deleteItem() }
    .build()
```

### Objective-C

```objc
@interface AlertBuilder : NSObject
- (AlertBuilder *)title:(NSString *)title;
- (AlertBuilder *)message:(NSString *)message;
- (AlertBuilder *)addActionWithTitle:(NSString *)title
                               style:(UIAlertActionStyle)style
                             handler:(void (^)(void))handler;
- (UIAlertController *)build;
@end

@implementation AlertBuilder {
    NSString *_title;
    NSString *_message;
    NSMutableArray<UIAlertAction *> *_actions;
}

- (instancetype)init {
    self = [super init];
    _actions = [NSMutableArray array];
    return self;
}

- (AlertBuilder *)title:(NSString *)title {
    _title = title;
    return self;
}

- (AlertBuilder *)message:(NSString *)message {
    _message = message;
    return self;
}

- (AlertBuilder *)addActionWithTitle:(NSString *)title
                               style:(UIAlertActionStyle)style
                             handler:(void (^)(void))handler {
    [_actions addObject:[UIAlertAction actionWithTitle:title style:style handler:^(__unused UIAlertAction *action) {
        if (handler) handler();
    }]];
    return self;
}

- (UIAlertController *)build {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_title
                                                                   message:_message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in _actions) {
        [alert addAction:action];
    }
    return alert;
}

@end
```

---

## Strategy（策略）

**场景：** 运行时切换算法或行为。

### Swift

```swift
protocol SortStrategy {
    func sort(_ items: [Product]) -> [Product]
}

struct PriceAscendingStrategy: SortStrategy {
    func sort(_ items: [Product]) -> [Product] {
        items.sorted { $0.price < $1.price }
    }
}

struct SalesDescendingStrategy: SortStrategy {
    func sort(_ items: [Product]) -> [Product] {
        items.sorted { $0.sales > $1.sales }
    }
}

final class ProductListViewModel {
    private var strategy: SortStrategy

    init(strategy: SortStrategy) {
        self.strategy = strategy
    }

    func updateStrategy(_ strategy: SortStrategy) {
        self.strategy = strategy
    }

    func sortedProducts(_ products: [Product]) -> [Product] {
        strategy.sort(products)
    }
}
```

### Objective-C

```objc
@protocol ProductSortStrategy <NSObject>
- (NSArray<Product *> *)sortProducts:(NSArray<Product *> *)products;
@end

@interface PriceAscendingStrategy : NSObject <ProductSortStrategy>
@end

@implementation PriceAscendingStrategy
- (NSArray<Product *> *)sortProducts:(NSArray<Product *> *)products {
    return [products sortedArrayUsingComparator:^NSComparisonResult(Product *a, Product *b) {
        return [@(a.price) compare:@(b.price)];
    }];
}
@end

@interface ProductListViewModel : NSObject
@property (nonatomic, strong) id<ProductSortStrategy> sortStrategy;
- (NSArray<Product *> *)sortedProducts:(NSArray<Product *> *)products;
@end
```

---

## Adapter（适配器）

**场景：** 将现有接口转换为目标接口；常见于 DataSource。

### Swift

```swift
struct RemoteUser: Decodable {
    let user_name: String
    let avatar_url: String
}

struct UserCellModel {
    let displayName: String
    let avatarURL: URL
}

struct UserAdapter {
    static func adapt(_ remote: RemoteUser) -> UserCellModel? {
        guard let url = URL(string: remote.avatar_url) else { return nil }
        return UserCellModel(displayName: remote.user_name, avatarURL: url)
    }
}

// UITableViewDataSource 适配
final class UserListDataSource: NSObject, UITableViewDataSource {
    private var items: [UserCellModel] = []

    func update(with remoteUsers: [RemoteUser]) {
        items = remoteUsers.compactMap(UserAdapter.adapt)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 绑定 items[indexPath.row]
        UITableViewCell()
    }
}
```

### Objective-C

```objc
@interface UserAdapter : NSObject
+ (nullable UserCellModel *)adaptRemoteUser:(RemoteUser *)remote;
@end

@implementation UserAdapter

+ (UserCellModel *)adaptRemoteUser:(RemoteUser *)remote {
    NSURL *url = [NSURL URLWithString:remote.avatarURL];
    if (!url) return nil;
    UserCellModel *model = [[UserCellModel alloc] init];
    model.displayName = remote.userName;
    model.avatarURL = url;
    return model;
}

@end
```

---

## Facade（外观）

**场景：** 为复杂子系统提供统一简洁入口。

### Swift

```swift
protocol HTTPClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class APIFacade {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func fetchUserProfile(id: String) async throws -> User {
        try await client.request(.userProfile(id: id))
    }

    func updateAvatar(id: String, imageData: Data) async throws {
        try await client.request(.uploadAvatar(userID: id, data: imageData))
    }
}
```

### Objective-C

```objc
@interface APIFacade : NSObject
- (instancetype)initWithClient:(id<HTTPClientProtocol>)client;
- (void)fetchUserProfileWithID:(NSString *)userID
                    completion:(void (^)(User * _Nullable, NSError * _Nullable))completion;
@end

@implementation APIFacade

- (instancetype)initWithClient:(id<HTTPClientProtocol>)client {
    self = [super init];
    _client = client;
    return self;
}

- (void)fetchUserProfileWithID:(NSString *)userID
                    completion:(void (^)(User *, NSError *))completion {
    [self.client requestWithEndpoint:[Endpoint userProfileWithID:userID]
                          completion:completion];
}

@end
```

---

## Repository（仓储）

**场景：** 统一数据访问，屏蔽网络/本地细节。

### Swift

```swift
protocol UserRepositoryProtocol {
    func fetchUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
}

final class UserRepository: UserRepositoryProtocol {
    private let remote: RemoteUserDataSource
    private let local: LocalUserDataSource

    init(remote: RemoteUserDataSource, local: LocalUserDataSource) {
        self.remote = remote
        self.local = local
    }

    func fetchUser(id: String) async throws -> User {
        if let cached = try await local.user(id: id) {
            return cached
        }
        let user = try await remote.fetchUser(id: id)
        try await local.save(user)
        return user
    }

    func saveUser(_ user: User) async throws {
        try await local.save(user)
        try await remote.sync(user)
    }
}
```

### Objective-C

```objc
@protocol UserRepositoryProtocol <NSObject>
- (void)fetchUserWithID:(NSString *)userID
             completion:(void (^)(User * _Nullable, NSError * _Nullable))completion;
@end

@interface UserRepository : NSObject <UserRepositoryProtocol>
- (instancetype)initWithRemote:(RemoteUserDataSource *)remote
                           local:(LocalUserDataSource *)local;
@end

@implementation UserRepository

- (void)fetchUserWithID:(NSString *)userID
             completion:(void (^)(User *, NSError *))completion {
    [self.local userWithID:userID completion:^(User *cached, NSError *error) {
        if (cached) {
            completion(cached, nil);
            return;
        }
        [self.remote fetchUserWithID:userID completion:^(User *user, NSError *remoteError) {
            if (user) {
                [self.local saveUser:user completion:nil];
            }
            completion(user, remoteError);
        }];
    }];
}

@end
```

---

## MVVM（模型-视图-视图模型）

**场景：** 视图与业务逻辑分离；SwiftUI / UIKit 均适用。

### Swift

```swift
@MainActor
@Observable
final class LoginViewModel {
    var phone = ""
    var code = ""
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var canSubmit: Bool {
        !phone.isEmpty && code.count == 6
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.login(phone: phone, code: code)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct LoginView: View {
    @State private var viewModel: LoginViewModel

    var body: some View {
        Form {
            TextField("手机号", text: $viewModel.phone)
            TextField("验证码", text: $viewModel.code)
            Button("登录") {
                Task { await viewModel.login() }
            }
            .disabled(!viewModel.canSubmit || viewModel.isLoading)
        }
    }
}
```

### Objective-C

```objc
// LoginViewModel.h
@interface LoginViewModel : NSObject
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly, copy, nullable) NSString *errorMessage;
@property (nonatomic, readonly) BOOL canSubmit;
- (instancetype)initWithAuthService:(id<AuthServiceProtocol>)authService;
- (void)loginWithCompletion:(void (^)(BOOL success))completion;
@end

// LoginViewController.m — VC 只绑定 ViewModel，不直接发网络请求
- (void)loginTapped {
    self.loginButton.enabled = NO;
    [self.viewModel loginWithCompletion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginButton.enabled = YES;
            if (success) {
                [self.coordinator showHome];
            } else {
                self.errorLabel.text = self.viewModel.errorMessage;
            }
        });
    }];
}
```

---

## Coordinator（协调器）

**场景：** 导航逻辑从 ViewController 中剥离。

### Swift

```swift
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

final class LoginCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let authService: AuthServiceProtocol

    init(navigationController: UINavigationController, authService: AuthServiceProtocol) {
        self.navigationController = navigationController
        self.authService = authService
    }

    func start() {
        let vm = LoginViewModel(authService: authService)
        let vc = LoginViewController(viewModel: vm, coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showHome() {
        let coordinator = HomeCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}

protocol LoginCoordinating: AnyObject {
    func showHome()
}
```

### Objective-C

```objc
@protocol LoginCoordinating <NSObject>
- (void)showHome;
@end

@interface LoginCoordinator : NSObject <LoginCoordinating>
- (instancetype)initWithNavigationController:(UINavigationController *)nav
                                 authService:(id<AuthServiceProtocol>)authService;
- (void)start;
@end

@implementation LoginCoordinator

- (void)start {
    LoginViewModel *vm = [[LoginViewModel alloc] initWithAuthService:self.authService];
    LoginViewController *vc = [[LoginViewController alloc] initWithViewModel:vm coordinator:self];
    [self.navigationController setViewControllers:@[vc] animated:NO];
}

- (void)showHome {
    HomeCoordinator *coordinator = [[HomeCoordinator alloc] initWithNavigationController:self.navigationController];
    [coordinator start];
}

@end
```

---

## Dependency Injection（依赖注入）

**场景：** 依赖面向协议，便于测试与替换。

### Swift

```swift
protocol AuthServiceProtocol {
    func login(phone: String, code: String) async throws
}

final class AuthService: AuthServiceProtocol {
    private let client: HTTPClientProtocol
    init(client: HTTPClientProtocol) { self.client = client }

    func login(phone: String, code: String) async throws {
        try await client.request(.login(phone: phone, code: code))
    }
}

// 组装根（App 入口）
enum AppContainer {
    static func makeLoginModule() -> LoginViewController {
        let client = URLSessionHTTPClient()
        let authService = AuthService(client: client)
        let viewModel = LoginViewModel(authService: authService)
        return LoginViewController(viewModel: viewModel)
    }
}

// 测试注入 Mock
final class MockAuthService: AuthServiceProtocol {
    var shouldFail = false
    func login(phone: String, code: String) async throws {
        if shouldFail { throw AuthError.invalidCode }
    }
}
```

### Objective-C

```objc
@interface LoginViewModel : NSObject
- (instancetype)initWithAuthService:(id<AuthServiceProtocol>)authService;
@end

// AppDelegate / SceneDelegate 组装
LoginViewModel *vm = [[LoginViewModel alloc] initWithAuthService:[[AuthService alloc] initWithClient:client]];
LoginViewController *vc = [[LoginViewController alloc] initWithViewModel:vm];
```

---

## Command（命令）

**场景：** 封装操作为对象，支持队列、撤销。

### Swift

```swift
protocol Command {
    func execute()
    func undo()
}

final class DeleteItemCommand: Command {
    private weak var store: ItemStore?
    private let item: Item
    private var index: Int?

    init(store: ItemStore, item: Item) {
        self.store = store
        self.item = item
    }

    func execute() {
        index = store?.remove(item)
    }

    func undo() {
        guard let store, let index else { return }
        store.insert(item, at: index)
    }
}

final class CommandInvoker {
    private var history: [Command] = []

    func run(_ command: Command) {
        command.execute()
        history.append(command)
    }

    func undoLast() {
        history.popLast()?.undo()
    }
}
```

### Objective-C

```objc
@protocol Command <NSObject>
- (void)execute;
- (void)undo;
@end

@interface DeleteItemCommand : NSObject <Command>
- (instancetype)initWithStore:(ItemStore *)store item:(Item *)item;
@end

@interface CommandInvoker : NSObject
- (void)runCommand:(id<Command>)command;
- (void)undoLast;
@end
```

---

## Composite（组合）

**场景：** 树形结构统一操作；UIView 层级是典型 Composite。

### Swift

```swift
protocol ViewComponent {
    var view: UIView { get }
    func layout(in container: UIView)
}

struct HeaderComponent: ViewComponent {
    let view = UILabel()

    func layout(in container: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }
}

struct FormComposite: ViewComponent {
    let view = UIStackView()
    private let children: [ViewComponent]

    init(children: [ViewComponent]) {
        self.children = children
        view.axis = .vertical
        view.spacing = 12
        children.forEach { view.addArrangedSubview($0.view) }
    }

    func layout(in container: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 16),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
    }
}
```

### Objective-C

```objc
@protocol ViewComponent <NSObject>
@property (nonatomic, readonly) UIView *view;
- (void)layoutInContainer:(UIView *)container;
@end

@interface FormComposite : UIView <ViewComponent>
- (instancetype)initWithComponents:(NSArray<id<ViewComponent>> *)components;
@end

@implementation FormComposite {
    UIStackView *_stackView;
}

- (instancetype)initWithComponents:(NSArray<id<ViewComponent>> *)components {
    self = [super initWithFrame:CGRectZero];
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 12;
    for (id<ViewComponent> component in components) {
        [_stackView addArrangedSubview:component.view];
    }
    [self addSubview:_stackView];
    return self;
}

- (UIView *)view { return self; }

@end
```

---

## 模式选用建议

| 需求 | 推荐模式 |
|------|----------|
| 组件回调给持有者 | Delegate |
| 按钮/手势事件 | Target-Action |
| 跨模块广播 | Notification / Combine |
| 屏蔽创建细节 | Factory |
| 复杂对象分步配置 | Builder |
| 可切换算法 | Strategy |
| 接口不一致需转换 | Adapter |
| 简化多层 API 调用 | Facade |
| 统一本地/远程数据 | Repository |
| 视图与逻辑分离 | MVVM |
| 导航流程复杂 | Coordinator |
| 可测试、可替换依赖 | Dependency Injection |
| 操作可撤销 | Command |
| UI 树形组合 | Composite |

**避免过度设计：** 简单页面不必强行引入 Coordinator + Repository + UseCase；优先匹配项目已有复杂度。
