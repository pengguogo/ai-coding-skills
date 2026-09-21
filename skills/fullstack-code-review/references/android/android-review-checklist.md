# Android 代码审查检查项

> 本检查项从 `fullstack-code-implementation/references/Android/android-coding-standard.md` 及其按需加载 reference（official-android-architecture.md、design-patterns-examples.md、official-kotlin-style.md、official-android-java-style.md）提炼。
> 覆盖 Kotlin 与 Java 场景。每个检查项标注严重性、规范来源、判断标准和**适用粒度**。
> blocking / important 级别附带正反示例。规范来源章节号以实际规范为准；若项目约定冲突，以项目约定优先。
>
> **职责边界**：本文件聚焦**编码规范合规**检查。Android 业务实现质量（生命周期/内存/线程/性能/离线）的深度检查由 `android-quality-checklist.md`（AQ-*）统一覆盖。
>
> **适用粒度说明**：
> - **模块级**：在按 Android 任务清单功能点分组的模块审查中执行（Step 3b）。
> - **全局级**：在全局设计合规检查（Step 2）或全局影响分析（Step 5）中执行。

---

## AD-NAME：命名规范

### AD-NAME-01 [I] [P1]：类名使用 PascalCase 且语义明确
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: official-kotlin-style.md / official-android-java-style.md — 命名
- **判断标准**: 类名用大驼峰，Activity/Fragment/ViewModel 等带规范后缀（如 `ClaimDetailActivity`、`ClaimListViewModel`）
- **示例**:
  ```
  ✅ ClaimDetailActivity / ClaimListViewModel / ClaimRepository
  ❌ claimDetail / Claim_VM / Repo
  ```

### AD-NAME-02 [I] [P1]：变量与方法使用 camelCase
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: official-kotlin-style.md — 命名
- **判断标准**: 局部变量、方法名用小驼峰，不使用匈牙利命名或下划线（常量除外）

### AD-NAME-03 [S] [P2]：常量使用 UPPER_SNAKE_CASE
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: official-kotlin-style.md — 命名
- **判断标准**: `const val` / `static final` 常量全大写下划线分隔

### AD-NAME-04 [S] [P2]：资源 ID 命名遵循约定
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — 资源命名
- **判断标准**: layout/drawable/id/string 命名遵循 `类型_模块_用途` 约定，与项目现有资源一致
- **示例**:
  ```
  ✅ activity_claim_detail.xml / btn_submit / tv_claim_no
  ❌ ClaimDetail.xml / button1 / textview
  ```

---

## AD-ARCH：架构与分层

### AD-ARCH-01 [I] [P1]：遵循项目既有架构模式
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: official-android-architecture.md — 架构分层
- **判断标准**: 新增代码遵循项目既有架构（MVVM/MVP/MVI），不混用多种模式
- **示例**:
  ```
  ✅ 项目使用 MVVM：UI → ViewModel → Repository → DataSource
  ❌ 在 MVVM 项目中直接在 Activity 里写网络请求和数据库操作
  ```

### AD-ARCH-02 [B] [P1]：UI 层不直接访问数据源
- **严重性**: blocking
- **适用粒度**: 模块级
- **规范来源**: official-android-architecture.md — 分层职责
- **判断标准**: Activity/Fragment 不直接调用网络/数据库，须经 ViewModel + Repository
- **示例**:
  ```kotlin
  ✅ // Activity 观察 ViewModel 暴露的状态
  viewModel.uiState.observe(this) { render(it) }

  ❌ // Activity 直接调用 Retrofit
  apiService.getClaim(id).enqueue(...)
  ```

### AD-ARCH-03 [I] [P1]：Repository 封装数据来源
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: official-android-architecture.md — 数据层
- **判断标准**: 网络与本地数据的切换、缓存策略封装在 Repository，ViewModel 不感知数据来源细节

### AD-ARCH-04 [I] [P1]：包结构符合项目约定
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — 项目结构
- **判断标准**: 新增文件放在正确的包/模块下（feature 包或分层包），与现有结构一致

---

## AD-COMP：组件与控件

### AD-COMP-01 [I] [P1]：ViewBinding/Compose 使用方式与项目一致
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — UI 实现
- **判断标准**: XML 项目用 ViewBinding（不用 findViewById/kotlin-synthetics）；Compose 项目遵循既有 Composable 组织方式
- **示例**:
  ```kotlin
  ✅ binding.tvClaimNo.text = claim.claimNo
  ❌ findViewById<TextView>(R.id.tv_claim_no).text = claim.claimNo
  ```

### AD-COMP-02 [I] [P1]：RecyclerView 使用 DiffUtil/ListAdapter
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: design-patterns-examples.md — 列表
- **判断标准**: 列表更新使用 ListAdapter + DiffUtil 或 notifyItemXxx，不滥用 notifyDataSetChanged
- **示例**:
  ```kotlin
  ✅ class ClaimAdapter : ListAdapter<Claim, VH>(ClaimDiff())
  ❌ adapter.items = newList; adapter.notifyDataSetChanged() // 每次全量刷新
  ```

### AD-COMP-03 [S] [P2]：布局层级扁平化
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — 布局优化
- **判断标准**: 优先 ConstraintLayout 减少嵌套；避免无意义的嵌套 LinearLayout（嵌套不超过 4 层）

---

## AD-LANG：语言与空安全

### AD-LANG-01 [B] [P1]：避免非空断言滥用
- **严重性**: blocking
- **适用粒度**: 模块级
- **规范来源**: official-kotlin-style.md — 空安全
- **判断标准**: Kotlin 不滥用 `!!`；可空类型经判空或安全调用处理
- **示例**:
  ```kotlin
  ✅ val no = claim?.claimNo ?: "—"
  ❌ val no = claim!!.claimNo  // claim 为 null 时崩溃
  ```

### AD-LANG-02 [I] [P1]：使用不可变优先
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: official-kotlin-style.md — 变量声明
- **判断标准**: 优先 `val` 而非 `var`；集合优先使用只读类型暴露

### AD-LANG-03 [S] [P2]：作用域函数使用恰当
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: official-kotlin-style.md — 惯用法
- **判断标准**: let/run/apply/also/with 使用语义恰当，不嵌套过深影响可读性

---

## AD-DOC：注释规范

### AD-DOC-01 [I] [P1]：公共类/方法须有说明注释
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — 注释
- **判断标准**: 公共类、对外方法须有 KDoc/Javadoc 说明职责、参数与返回值

### AD-DOC-02 [N] [P2]：TODO/FIXME 关联任务编号
- **严重性**: nit
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — 注释
- **判断标准**: `TODO`/`FIXME` 关联任务编号或计划处理说明

---

## AD-AI：AI-Generate 标记

> 完整标记检查由 `cross-cutting-review.md` CC-AI-* 统一覆盖；此处为 Android 特有补充。

### AD-AI-01 [I] [P1]：AI 代码标记位置
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — AI 标记
- **判断标准**: Kotlin/Java 文件用 `// AI-Generate`，XML 用 `<!-- AI-Generate -->`，位置符合规范

---

## AD-GRADLE：构建配置

### AD-GRADLE-01 [I] [P1]：依赖版本明确且无冲突
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — 依赖管理
- **判断标准**: 新增依赖使用明确版本号（或 version catalog），不引入与现有库冲突的版本
- **示例**:
  ```
  ✅ implementation("com.squareup.retrofit2:retrofit:2.9.0")
  ❌ implementation("com.squareup.retrofit2:retrofit:+")  // 动态版本
  ```

### AD-GRADLE-02 [S] [P2]：minSdk/targetSdk 与项目一致
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: android-coding-standard.md — 构建配置
- **判断标准**: 不擅自变更 minSdk/targetSdk；使用高版本 API 时有版本判断或 AndroidX 兼容封装
