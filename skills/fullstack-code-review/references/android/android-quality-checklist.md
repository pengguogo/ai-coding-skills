# Android 业务实现质量检查项

> 本检查项聚焦"Android 运行时健壮性与业务实现正确性"，与 `android-review-checklist.md`（编码规范合规）互补。
> 审查基线来自上游设计文档（Android 分端设计文件 `frontend-android.md`（经入口 `frontend-design.md` 定位）、`backend-design.md`）和 Android 任务清单。
> 每个检查项标注严重性、审查基线来源、判断标准和**适用粒度**。blocking / important 级别附带正反示例。
> 覆盖 Kotlin 与 Java 场景。若项目约定与本检查项冲突，以项目约定优先。
>
> **适用粒度说明**：
> - **模块级**：在按 Android 任务清单功能点分组的模块审查中执行（Step 3b）。
> - **全局级**：在全局影响分析（Step 5）中执行。

---

## AQ-LIFE：生命周期与资源管理

> 审查基线：`frontend-android.md` — 生命周期与资源管理章节。

### AQ-LIFE-01 [B] [P0]：协程/订阅绑定生命周期
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 生命周期
- **判断标准**: 协程使用 viewModelScope/lifecycleScope；RxJava 订阅在 onDestroy 解除；无脱离生命周期的长任务
- **示例**:
  ```kotlin
  ✅ viewModelScope.launch { repository.loadClaim(id) }
  ❌ GlobalScope.launch { repository.loadClaim(id) } // 脱离生命周期，泄漏风险
  ```

### AQ-LIFE-02 [B] [P0]：Fragment 置空 ViewBinding
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 资源释放
- **判断标准**: Fragment 在 onDestroyView 将 binding 置 null，避免 View 泄漏
- **示例**:
  ```kotlin
  ✅ override fun onDestroyView() { super.onDestroyView(); _binding = null }
  ❌ // 持有 binding 不释放，Fragment 复用时 View 泄漏
  ```

### AQ-LIFE-03 [I] [P1]：监听器/广播/观察者注销
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 资源释放
- **判断标准**: 注册的 BroadcastReceiver、Listener、ContentObserver 在对应生命周期注销

### AQ-LIFE-04 [I] [P1]：配置变更与进程重建
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 生命周期
- **判断标准**: 屏幕旋转/配置变更后数据不丢失（状态在 ViewModel 或 SavedStateHandle）；进程被杀重建后关键状态可恢复

---

## AQ-LEAK：内存与泄漏

> 审查基线：通用 Android 最佳实践。

### AQ-LEAK-01 [B] [P0]：无 Context/View 长引用
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: ViewModel、单例、静态字段、长生命周期对象不持有 Activity/Fragment/View 引用；需要 Context 时用 ApplicationContext
- **示例**:
  ```kotlin
  ✅ class ClaimViewModel(app: Application) : AndroidViewModel(app)
  ❌ class ClaimViewModel(val activity: Activity) // 持有 Activity，泄漏
  ```

### AQ-LEAK-02 [I] [P1]：Handler/匿名内部类泄漏防护
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: Handler 使用静态内部类 + WeakReference 或绑定生命周期；延时消息在销毁时 removeCallbacks

### AQ-LEAK-03 [I] [P1]：Bitmap/Cursor/Stream 及时回收
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: Cursor、InputStream、Bitmap 等资源用完即关闭/回收（use 块或 finally）

---

## AQ-THREAD：线程与 ANR

> 审查基线：通用 Android 最佳实践。

### AQ-THREAD-01 [B] [P0]：主线程无耗时操作
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 主线程不执行网络请求、数据库读写、文件 IO、大量计算（避免 ANR）
- **示例**:
  ```kotlin
  ✅ withContext(Dispatchers.IO) { dao.queryAll() }
  ❌ val list = dao.queryAll() // 在主线程直接查询数据库
  ```

### AQ-THREAD-02 [I] [P1]：UI 更新在主线程
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 后台线程结果回到主线程更新 UI（withContext(Main)/postValue/runOnUiThread）

### AQ-THREAD-03 [I] [P1]：状态用线程安全方式更新
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 状态定义
- **判断标准**: LiveData 后台线程用 postValue；StateFlow/共享状态更新无竞态

---

## AQ-STATE：状态与数据一致性

> 审查基线：`frontend-android.md` — 状态定义与流转。

### AQ-STATE-01 [I] [P1]：UiState 覆盖四态
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 状态定义
- **判断标准**: 数据加载覆盖 loading/success/error/empty 四态，UI 按状态正确切换

### AQ-STATE-02 [I] [P1]：操作后数据刷新
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 交互流程
- **判断标准**: 增删改成功后，列表/详情数据同步刷新，用户看到最新数据

### AQ-STATE-03 [I] [P1]：列表防重渲染与状态保持
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 列表交互
- **判断标准**: 列表局部更新用 DiffUtil；分页加载时滚动位置不丢失

---

## AQ-NET：网络与接口健壮性

> 审查基线：`frontend-android.md` — 数据与接口；`backend-design.md`。

### AQ-NET-01 [B] [P0]：接口数据防御性处理
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 数据与接口
- **判断标准**: 后端返回 null/字段缺失/空列表时不崩溃；有默认值兜底与空安全处理
- **示例**:
  ```kotlin
  ✅ val items = response.data?.list.orEmpty()
  ❌ val items = response.data!!.list // data 为 null 时崩溃
  ```

### AQ-NET-02 [I] [P1]：超时与异常处理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 异常处理
- **判断标准**: 网络请求设置超时；异常（IOException/HttpException）被捕获并转为用户可感知反馈

### AQ-NET-03 [I] [P1]：弱网与无网处理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 异常处理
- **判断标准**: 无网络时有明确提示与重试入口；弱网下有 loading 与超时反馈，不无限转圈

### AQ-NET-04 [B] [P0]：接口路径与后端一致
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: backend-design.md §3.2 对外接口
- **判断标准**: Retrofit Service 的路径、方法、入参/出参与 backend-design.md 一致

---

## AQ-UX：交互与操作防护

> 审查基线：`frontend-android.md` — 交互流程。

### AQ-UX-01 [B] [P0]：防重复提交
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 交互流程
- **判断标准**: 提交按钮点击后禁用或加 loading 锁，连续点击只触发一次请求
- **示例**:
  ```kotlin
  ✅ btn.isEnabled = false; try { submit() } finally { btn.isEnabled = true }
  ❌ btn.setOnClickListener { submit() } // 无防抖，快速双击重复提交
  ```

### AQ-UX-02 [B] [P0]：危险操作二次确认
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 交互流程
- **判断标准**: 删除/不可逆操作有确认对话框，文案明确告知后果

### AQ-UX-03 [I] [P1]：操作反馈即时性
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 交互流程
- **判断标准**: 每个用户操作有即时反馈（Loading/Toast/Snackbar/状态变化），不存在"点了没反应"

---

## AQ-PERM：权限与安全

> 审查基线：`frontend-android.md` — 权限与安全章节。

### AQ-PERM-01 [B] [P0]：运行时权限申请与降级
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 权限
- **判断标准**: 危险权限运行时申请；用户拒绝有降级处理，不直接崩溃或功能卡死
- **示例**:
  ```kotlin
  ✅ 拒绝相机权限后提示"无法拍照"并提供跳设置入口
  ❌ 未申请直接 camera.open()，权限缺失时 SecurityException 崩溃
  ```

### AQ-PERM-02 [B] [P0]：本地敏感数据不明文
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 数据安全
- **判断标准**: SharedPreferences/Room/文件不明文存储密码、token 外的敏感信息（身份证、银行卡）；必要时加密（EncryptedSharedPreferences/Keystore）

### AQ-PERM-03 [I] [P1]：日志脱敏
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用安全规范
- **判断标准**: Logcat 不输出敏感信息；Release 包移除调试日志

### AQ-PERM-04 [I] [P1]：导出组件安全
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用安全规范
- **判断标准**: AndroidManifest 中 exported 组件有必要的权限保护；非必要不导出

---

## AQ-PERF：性能与体验

> 审查基线：`frontend-android.md` — 性能。

### AQ-PERF-01 [I] [P1]：图片加载优化
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 图片使用 Glide/Coil 等库加载并设置合适尺寸/缓存；列表图片不加载原图导致 OOM

### AQ-PERF-02 [S] [P2]：列表加载性能
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 列表交互
- **判断标准**: 长列表分页加载；item 布局轻量；避免 onBindViewHolder 中做耗时操作

### AQ-PERF-03 [S] [P2]：离线与缓存策略
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: frontend-android.md — 数据层
- **判断标准**: 涉及离线场景时有本地缓存兜底；缓存有失效与刷新策略
