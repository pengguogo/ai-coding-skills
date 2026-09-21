# Google Android 开发者指南 — 常用基础（精要）

> **唯一职责**：developer.android.com 上**日常开发最常查阅**的基础概念与用法（组件、Manifest、资源、权限、构建），不含项目编码执行原则。
> 来源：[Application fundamentals](https://developer.android.com/guide/components/fundamentals) · [App resources](https://developer.android.com/guide/topics/resources) · [Permissions](https://developer.android.com/guide/topics/permissions/overview) · [Gradle 配置](https://developer.android.com/build)
> 架构分层与 UDF 细则见 [official-android-architecture.md](official-android-architecture.md)；本仓库约束见 [android-coding-standard.md](android-coding-standard.md)。

---

## 应用包与发布格式

| 格式 | 后缀 | 用途 |
|------|------|------|
| **APK** | `.apk` | 运行时安装包；含代码、资源 |
| **App Bundle** | `.aab` | **上架 Google Play 用**；按设备生成优化 APK，不能直接装设备 |

- 语言：Kotlin（推荐）、Java、C++（NDK）
- SDK 工具将代码 + 资源编译进 APK/AAB

---

## 安全沙箱（必知）

- 每个应用独立 Linux 用户 ID、独立进程、独立 VM
- 默认**最小权限**：只能访问被授权的数据与组件
- 共享：相同签名 + 相同 `sharedUserId` 可共享 UID（少见）
- 访问相机、位置等须**声明权限**且多数需**用户运行时授权**

**编码含义**：不要把长期状态放在 Activity；不要假设能随意访问其他应用文件。

---

## 四大应用组件

| 组件 | 作用 | 激活方式 | 日常开发 |
|------|------|----------|----------|
| **Activity** | 单屏 UI、用户交互入口 | `Intent` → `startActivity()` | 最常用 |
| **Service** | 后台长任务、无 UI | `startService()` / `bindService()` | 音乐、同步；API 21+ 优先 **WorkManager** / **JobScheduler** |
| **BroadcastReceiver** | 响应系统/应用广播 | `Intent` 广播 | 尽量轻量；重活交给 WorkManager |
| **ContentProvider** | 跨应用结构化数据共享 | `ContentResolver` | 系统联系人等；应用内 DB 通常用 Room 即可 |

- 组件须在 **`AndroidManifest.xml` 声明**（动态注册的 Receiver 除外）
- 应用**没有** `main()` 单一入口；由系统按 Intent 启动对应组件

---

## Intent（组件间通信）

| 类型 | 说明 | 示例 |
|------|------|------|
| **显式** | 指定目标组件类名 | 应用内跳转 Activity |
| **隐式** | 描述 action + data，系统匹配 | 分享、打开链接 |

```java
// 显式 — Java
Intent intent = new Intent(this, DetailActivity.class);
intent.putExtra(DetailActivity.EXTRA_ID, itemId);
startActivity(intent);
```

```kotlin
// 显式 — Kotlin
startActivity(Intent(this, DetailActivity::class.java).apply {
    putExtra(DetailActivity.EXTRA_ID, itemId)
})
```

**安全**：`Service` 仅用**显式** Intent 启动（API 21+ 隐式 `bindService` 会抛异常）。导出组件须谨慎配置 `intent-filter`。

---

## AndroidManifest.xml

**位置**：`app/src/main/AndroidManifest.xml`

| 职责 | 说明 |
|------|------|
| 声明组件 | `<activity>` `<service>` `<receiver>` `<provider>` |
| 权限 | `<uses-permission>` |
| 硬件/功能 | `<uses-feature>`（Play 过滤用） |
| 应用元数据 | `application` 的 `icon`、`label`、`theme` |

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.App">
        <activity
            android:name=".ui.MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

- **`android:exported`**：Android 12+ 有 intent-filter 的组件必须显式声明
- **`minSdk` / `targetSdk`**：在 **`build.gradle`（Module）** 的 `defaultConfig` 配置，**不要**写进 Manifest（会被 Gradle 覆盖）

```groovy
android {
    defaultConfig {
        minSdk 24
        targetSdk 34
    }
}
```

---

## 应用资源（Resources）

- 资源与代码分离：布局、字符串、图片、主题等放在 `res/`
- 编译后生成 **`R`** 类：`R.layout.activity_main`、`R.string.app_name`
- **不要硬编码**用户可见文案与可配置尺寸（与仓库规范一致）

### 常见目录

| 目录 | 内容 |
|------|------|
| `res/layout/` | XML 布局 |
| `res/values/` | 字符串、颜色、尺寸、样式 |
| `res/drawable/` | 矢量/形状 |
| `res/mipmap/` | 启动图标 |

### 限定符（多配置）

目录名带后缀，系统自动选择，例如：

- `values-zh/` 中文
- `layout-land/` 横屏
- `drawable-xxhdpi/` 高密度图

命名与前缀约定见 [reference.md](reference.md)、[android-coding-standard.md](android-coding-standard.md)。

### ViewBinding（Java/XML 栈常用）

```groovy
// build.gradle (Module)
android {
    buildFeatures {
        viewBinding true
    }
}
```

```java
// Activity — Java
binding = ActivityMainBinding.inflate(getLayoutInflater());
setContentView(binding.getRoot());
binding.tvTitle.setText("Hello");
```

```kotlin
// Activity — Kotlin
private lateinit var binding: ActivityMainBinding
binding = ActivityMainBinding.inflate(layoutInflater)
setContentView(binding.root)
binding.tvTitle.text = "Hello"
```

---

## 权限（Permissions）

1. **普通权限**：安装时授予（如 `INTERNET`）— 仅 Manifest 声明
2. **危险权限**：运行时弹窗（位置、相机、存储等）— Manifest + **代码申请**

```java
// 检查 + 申请 — Java（Activity）
if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
        != PackageManager.PERMISSION_GRANTED) {
    ActivityCompat.requestPermissions(this,
            new String[]{Manifest.permission.CAMERA}, REQUEST_CAMERA);
}
```

```kotlin
// Kotlin 可用 Activity Result API
val launcher = registerForActivityResult(
    ActivityResultContracts.RequestPermission()
) { granted -> /* ... */ }
launcher.launch(Manifest.permission.CAMERA)
```

- 在**靠近使用处**申请；申请前在 UI 说明用途（与 [android-coding-standard.md](android-coding-standard.md) 一致）

---

## 常用 Jetpack 库（速查）

| 库 | 用途 |
|----|------|
| **AndroidX AppCompat / Material** | 兼容 UI、主题 |
| **Lifecycle** | `LifecycleOwner`、`viewModelScope` |
| **ViewModel** | 配置变更后保留 UI 状态 |
| **LiveData / Flow** | 可观察数据（Java 栈常用 LiveData） |
| **Room** | SQLite ORM |
| **Navigation** | Fragment/Compose 导航 |
| **Hilt** | 依赖注入（官方推荐） |
| **WorkManager** | deferrable 后台任务 |
| **DataStore** | 替代 SharedPreferences（新代码） |
| **Compose** | 声明式 UI（`tech_stack=kotlin` 时） |

依赖声明优先用 **Version Catalog**（`libs.versions.toml`），Module 内用 `implementation`。

---

## 常用构建命令

| 命令 | 说明 |
|------|------|
| `./gradlew assembleDebug` | 调试 APK |
| `./gradlew installDebug` | 装到已连接设备/模拟器 |
| `./gradlew test` | 单元测试 |
| `./gradlew connectedAndroidTest` | 仪器化测试 |
| `./gradlew lint` | Lint 检查 |

---

## 与现代架构指南的关系

| 主题 | 读本文件 | 读 architecture 精要 |
|------|----------|----------------------|
| Activity/Service 是什么 | ✅ | — |
| Manifest、资源、权限 | ✅ | — |
| 分层、Repository、UDF、ViewModel 推荐 | 仅概览 | ✅ [official-android-architecture.md](official-android-architecture.md) |
| 本仓库怎么写代码 | — | ✅ [android-coding-standard.md](android-coding-standard.md) |

官方「架构强推荐」摘要（避免与 data 层重复展开）：

- UI 与数据层分离；UI 由**数据模型**驱动
- 通过 **Repository** 暴露数据，UI 不直连 DataSource
- 层间通信优先 **协程 + Flow**（Kotlin）；Java 项目可用 LiveData + 回调/Executor
- 大应用可选 **Domain / Use Case**；小任务不必加层

---

## 官方链接

- [应用基础](https://developer.android.com/guide/components/fundamentals)
- [应用资源](https://developer.android.com/guide/topics/resources)
- [权限概览](https://developer.android.com/guide/topics/permissions/overview)
- [构建配置](https://developer.android.com/build)
- [架构建议（完整）](https://developer.android.com/topic/architecture/recommendations)

## 相关文档

- [文档地图](README.md)
- [编码约束核心](android-coding-standard.md)
- [架构精要](official-android-architecture.md)
