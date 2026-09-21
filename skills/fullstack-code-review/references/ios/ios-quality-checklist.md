# iOS 业务实现质量检查项

> 本检查项聚焦"iOS 运行时健壮性与业务实现正确性"，与 `ios-review-checklist.md`（编码规范合规）互补。
> 审查基线来自上游设计文档（iOS 分端设计文件 `frontend-ios.md`（经入口 `frontend-design.md` 定位）、`backend-design.md`）和 iOS 任务清单。
> 每个检查项标注严重性、审查基线来源、判断标准和**适用粒度**。blocking / important 级别附带正反示例。
> 覆盖 Swift 与 Objective-C 场景。若项目约定与本检查项冲突，以项目约定优先。
>
> **适用粒度说明**：
> - **模块级**：在按 iOS 任务清单功能点分组的模块审查中执行（Step 3c）。
> - **全局级**：在全局影响分析（Step 5）中执行。

---

## IQ-LIFE：生命周期与资源管理

> 审查基线：`frontend-ios.md` — 生命周期与资源管理章节。

### IQ-LIFE-01 [B] [P0]：观察者/定时器/订阅释放
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 资源释放
- **判断标准**: NotificationCenter/KVO 观察者、Timer、Combine cancellables 在 deinit 或对应生命周期释放
- **示例**:
  ```swift
  ✅ deinit { NotificationCenter.default.removeObserver(self) }
  ❌ 注册观察者后从不移除，导致野指针/泄漏
  ```

### IQ-LIFE-02 [I] [P1]：数据加载时机合理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 生命周期
- **判断标准**: 数据加载放在合适生命周期（viewDidLoad/viewWillAppear），避免重复请求；页面消失时停止无用刷新

### IQ-LIFE-03 [I] [P1]：状态恢复与内存警告
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 生命周期
- **判断标准**: 涉及大内存资源的页面处理 didReceiveMemoryWarning；必要时支持状态恢复

---

## IQ-MEM：内存与泄漏

> 审查基线：通用 iOS 最佳实践。

### IQ-MEM-01 [B] [P0]：无闭包/delegate 强引用循环
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 异步闭包捕获 self 用 `[weak self]`；delegate 用 weak；避免 VC 被闭包长期持有无法释放
- **示例**:
  ```swift
  ✅ api.load { [weak self] result in self?.update(result) }
  ❌ api.load { result in self.update(result) }  // 强持有，VC 无法释放
  ```

### IQ-MEM-02 [I] [P1]：大资源及时释放
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 图片/视频/文件句柄等大资源用完释放；列表图片按需加载不全量驻留内存

---

## IQ-THREAD：线程与卡顿

> 审查基线：通用 iOS 最佳实践。

### IQ-THREAD-01 [B] [P0]：主线程无耗时操作
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 主线程不执行网络请求、数据库读写、文件 IO、大量计算，避免卡顿/watchdog 杀进程
- **示例**:
  ```swift
  ✅ DispatchQueue.global().async { let d = heavyWork(); DispatchQueue.main.async { render(d) } }
  ❌ let d = heavyWork()  // 主线程同步大计算
  ```

### IQ-THREAD-02 [B] [P0]：UI 更新在主线程
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 网络/后台回调更新 UI 前切回主线程（DispatchQueue.main.async / @MainActor）

### IQ-THREAD-03 [I] [P1]：共享状态线程安全
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 状态定义
- **判断标准**: 多线程访问的共享状态有同步保护（串行队列/锁/actor），无数据竞争

---

## IQ-STATE：状态与数据一致性

> 审查基线：`frontend-ios.md` — 状态定义与流转。

### IQ-STATE-01 [I] [P1]：状态覆盖四态
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 状态定义
- **判断标准**: 数据加载覆盖 loading/success/error/empty 四态，UI 按状态正确切换

### IQ-STATE-02 [I] [P1]：操作后数据刷新
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 交互流程
- **判断标准**: 增删改成功后，列表/详情数据同步刷新，用户看到最新数据

### IQ-STATE-03 [I] [P1]：列表刷新与状态保持
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 列表交互
- **判断标准**: 列表局部更新优先（reloadRows/Diffable DataSource）；分页加载时滚动位置不丢失

---

## IQ-NET：网络与接口健壮性

> 审查基线：`frontend-ios.md` — 数据与接口；`backend-design.md`。

### IQ-NET-01 [B] [P0]：接口数据防御性处理
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 数据与接口
- **判断标准**: 后端返回 null/字段缺失/空数组时不崩溃；Codable 解码失败有兜底，可选值安全处理
- **示例**:
  ```swift
  ✅ let items = response.data?.list ?? []
  ❌ let items = response.data!.list  // data 为 nil 时崩溃
  ```

### IQ-NET-02 [I] [P1]：超时与异常处理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 异常处理
- **判断标准**: 网络请求设置超时；错误（网络错误/解码错误/业务错误码）被捕获并转为用户可感知反馈

### IQ-NET-03 [I] [P1]：弱网与无网处理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 异常处理
- **判断标准**: 无网络时有明确提示与重试入口；弱网有 loading 与超时反馈，不无限转圈

### IQ-NET-04 [B] [P0]：接口路径与后端一致
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: backend-design.md §3.2 对外接口
- **判断标准**: 网络请求的路径、方法、入参/出参与 backend-design.md 一致

---

## IQ-UX：交互与操作防护

> 审查基线：`frontend-ios.md` — 交互流程。

### IQ-UX-01 [B] [P0]：防重复提交
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 交互流程
- **判断标准**: 提交按钮点击后禁用或加 loading，连续点击只触发一次请求
- **示例**:
  ```swift
  ✅ button.isEnabled = false; defer { button.isEnabled = true }
  ❌ 无防抖，快速双击重复提交
  ```

### IQ-UX-02 [B] [P0]：危险操作二次确认
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 交互流程
- **判断标准**: 删除/不可逆操作有 UIAlertController 确认，文案明确告知后果

### IQ-UX-03 [I] [P1]：操作反馈即时性
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 交互流程
- **判断标准**: 每个用户操作有即时反馈（Loading/HUD/Toast/状态变化），不存在"点了没反应"

---

## IQ-PERM：权限与安全

> 审查基线：`frontend-ios.md` — 权限与安全章节。

### IQ-PERM-01 [B] [P0]：运行时权限申请与降级
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 权限
- **判断标准**: 隐私权限（相机/定位/通知/相册等）运行时申请，Info.plist 有用途描述（Usage Description），拒绝后有降级处理不崩溃
- **示例**:
  ```
  ✅ 拒绝定位后提示"无法获取位置"并提供跳设置入口
  ❌ 未配 Info.plist 用途描述直接访问 → 崩溃；或未处理拒绝分支
  ```

### IQ-PERM-02 [B] [P0]：敏感数据存 Keychain
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 数据安全
- **判断标准**: token、密码等敏感数据存 Keychain，不明文存 UserDefaults/plist/文件

### IQ-PERM-03 [I] [P1]：日志脱敏
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用安全规范
- **判断标准**: 不 print/NSLog 输出敏感信息；Release 配置移除调试日志

---

## IQ-PERF：性能与体验

> 审查基线：`frontend-ios.md` — 性能。

### IQ-PERF-01 [I] [P1]：Cell 复用与图片加载
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: TableView/CollectionView 正确复用 Cell；图片异步加载并缓存，不在主线程解码大图

### IQ-PERF-02 [S] [P2]：列表加载性能
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 列表交互
- **判断标准**: 长列表分页加载；cellForRow 中不做耗时操作；高度计算缓存

### IQ-PERF-03 [S] [P2]：离线与缓存策略
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: frontend-ios.md — 数据层
- **判断标准**: 涉及离线场景时有本地缓存兜底；缓存有失效与刷新策略
