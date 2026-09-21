# iOS 代码审查检查项

> 本检查项从 `fullstack-code-implementation/references/iOS/ios-coding-guideline.md` 及其按需加载 reference（architecture.md、design-patterns.md、swift-objc-style.md、security-performance.md）提炼。
> 覆盖 Swift 与 Objective-C 场景。每个检查项标注严重性、规范来源、判断标准和**适用粒度**。
> blocking / important 级别附带正反示例。规范来源章节号以实际规范为准；若项目约定冲突，以项目约定优先。
>
> **职责边界**：本文件聚焦**编码规范合规**检查。iOS 业务实现质量（生命周期/内存/线程/性能/离线）的深度检查由 `ios-quality-checklist.md`（IQ-*）统一覆盖。
>
> **适用粒度说明**：
> - **模块级**：在按 iOS 任务清单功能点分组的模块审查中执行（Step 3c）。
> - **全局级**：在全局设计合规检查（Step 2）或全局影响分析（Step 5）中执行。

---

## IO-NAME：命名规范

### IO-NAME-01 [I] [P1]：类型名使用 PascalCase 且语义明确
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: swift-objc-style.md — 命名
- **判断标准**: 类型（class/struct/enum/protocol）用大驼峰，ViewController 等带规范后缀（如 `ClaimDetailViewController`、`ClaimListViewModel`）
- **示例**:
  ```
  ✅ ClaimDetailViewController / ClaimListViewModel / ClaimService
  ❌ claimDetailVC / Claim_VM / svc
  ```

### IO-NAME-02 [I] [P1]：变量与方法使用 camelCase
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: swift-objc-style.md — 命名
- **判断标准**: 变量、方法名用小驼峰；ObjC 方法遵循既有前缀约定，不使用下划线命名

### IO-NAME-03 [S] [P2]：常量与枚举 case 命名规范
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: swift-objc-style.md — 命名
- **判断标准**: Swift 常量/枚举 case 用小驼峰；全局常量按项目约定（如 `k` 前缀或命名空间）

### IO-NAME-04 [S] [P2]：资源与 Storyboard ID 命名遵循约定
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: ios-coding-guideline.md — 资源命名
- **判断标准**: Assets、Storyboard/XIB、reuseIdentifier 命名遵循项目约定，与现有资源一致

---

## IO-ARCH：架构与分层

### IO-ARCH-01 [I] [P1]：遵循项目既有架构模式
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: architecture.md — 架构分层
- **判断标准**: 新增代码遵循项目既有架构（MVC/MVVM/VIPER/TCA），不混用多种模式

### IO-ARCH-02 [B] [P1]：避免 Massive View Controller
- **严重性**: blocking
- **适用粒度**: 模块级
- **规范来源**: architecture.md — 分层职责
- **判断标准**: 业务逻辑、网络请求、数据处理下沉到 ViewModel/Presenter/Service，ViewController 只负责视图与事件转发
- **示例**:
  ```
  ✅ VC 观察 ViewModel 状态，业务逻辑在 ViewModel
  ❌ VC 里直接写网络请求 + 数据解析 + 业务规则
  ```

### IO-ARCH-03 [I] [P1]：数据层封装
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: architecture.md — 数据层
- **判断标准**: 网络与本地数据切换、缓存策略封装在 Repository/Service，View 层不感知数据来源细节

### IO-ARCH-04 [I] [P1]：文件分组符合项目约定
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: ios-coding-guideline.md — 项目结构
- **判断标准**: 新增文件放在正确的 group/目录（feature 分组或分层分组），与现有结构一致

---

## IO-MEM：内存管理

### IO-MEM-01 [B] [P0]：避免强引用循环
- **严重性**: blocking
- **适用粒度**: 模块级
- **规范来源**: security-performance.md — 内存管理
- **判断标准**: delegate 属性用 `weak`；闭包捕获 self 用 `[weak self]`/`[unowned self]`；父子对象无双向 strong 持有
- **示例**:
  ```swift
  ✅ weak var delegate: ClaimDelegate?
  ✅ service.fetch { [weak self] in self?.render($0) }
  ❌ var delegate: ClaimDelegate?  // strong，循环引用
  ❌ service.fetch { self.render($0) }  // 闭包强持有 self
  ```

### IO-MEM-02 [I] [P1]：ObjC 属性内存语义正确
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: swift-objc-style.md — 属性
- **判断标准**: ObjC 中 delegate/block 用 weak/copy，NSString/NSArray 等用 copy，符合既有语义约定

---

## IO-LANG：语言与可选值

### IO-LANG-01 [B] [P1]：避免强制解包滥用
- **严重性**: blocking
- **适用粒度**: 模块级
- **规范来源**: swift-objc-style.md — 可选值
- **判断标准**: 不滥用 `!` 强制解包；用 if let / guard let / `??` 安全处理可选值
- **示例**:
  ```swift
  ✅ guard let claim = claim else { return }
  ❌ let no = claim!.claimNo  // claim 为 nil 时崩溃
  ```

### IO-LANG-02 [I] [P1]：优先值类型与不可变
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: swift-objc-style.md — 类型选择
- **判断标准**: 模型优先用 struct；优先 `let` 而非 `var`；集合暴露只读

### IO-LANG-03 [S] [P2]：guard 提前返回
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: swift-objc-style.md — 控制流
- **判断标准**: 用 guard 做前置校验与提前返回，避免深层嵌套 if

---

## IO-DOC：注释规范

### IO-DOC-01 [I] [P1]：公共类型/方法须有说明注释
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: ios-coding-guideline.md — 注释
- **判断标准**: 公共类型、对外方法须有文档注释说明职责、参数与返回值

### IO-DOC-02 [N] [P2]：TODO/FIXME 关联任务编号
- **严重性**: nit
- **适用粒度**: 模块级
- **规范来源**: ios-coding-guideline.md — 注释
- **判断标准**: `TODO`/`FIXME` 关联任务编号或计划处理说明

---

## IO-AI：AI-Generate 标记

> 完整标记检查由 `cross-cutting-review.md` CC-AI-* 统一覆盖；此处为 iOS 特有补充。

### IO-AI-01 [I] [P1]：AI 代码标记位置
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: ios-coding-guideline.md — AI 标记
- **判断标准**: Swift/ObjC 文件用 `// AI-Generate`，位置符合规范

---

## IO-DEP：依赖与配置

### IO-DEP-01 [I] [P1]：依赖版本明确
- **严重性**: important
- **适用粒度**: 模块级
- **规范来源**: ios-coding-guideline.md — 依赖管理
- **判断标准**: CocoaPods/SPM 新增依赖使用明确版本；不引入与现有库冲突的版本

### IO-DEP-02 [S] [P2]：Deployment Target 与项目一致
- **严重性**: suggestion
- **适用粒度**: 模块级
- **规范来源**: ios-coding-guideline.md — 构建配置
- **判断标准**: 不擅自变更最低 iOS 版本；使用高版本 API 时用 `@available` / `if #available` 判断
