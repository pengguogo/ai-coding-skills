# iOS 编码原则
本文档为 `fullstack-code-implementation` 技能在iOS端编码阶段的编码规范参考，实现代码时须遵循本规范。
本文件是**第 2 层参考**：定义编码时必须遵守的核心原则，并索引第 3 层详细规范。

**本文件不包含**具体架构代码、设计模式示例、语言细节——那些内容在各自 reference 中，按需加载。

## 七大原则

### 1. 单一职责（文档分工）

每个 reference 文件只覆盖一个方向，互不重复：

| 文件 | 唯一职责 |
|------|----------|
| `ios-coding-guideline.md`（本文件） | 核心原则 + 索引 |
| `architecture.md` | 架构分层与模块职责（无代码示例） |
| `design-patterns.md` | 设计模式 Swift/ObjC 示例 |
| `swift-objc-style.md` | 语言命名与格式 |
| `security-performance.md` | 安全、性能、内存 |
| `examples.md` | 常见错误快速正反对比 |

### 2. 渐进披露

- 先读 `task-split.md` → 再读本文件 → 最后**仅加载与当前任务相关的 1 个** reference
- 不在一开始加载全部 reference
- 项目既有代码始终优先于本规范

### 3. 先想清楚再动手

动手写代码前，列出 **2–4 个疑问点**向用户澄清（见 SKILL.md Step 3）。

聚焦：技术选型、范围边界、与现有代码的对齐方式、验收标准的具体理解。

### 4. 简单优先

- **用现有模式解决问题**，不为假想的未来需求做抽象
- task-split.md 未要求时不引入 Coordinator、Repository、UseCase 等新层
- 一个 ViewController 能搞定的，不拆成五个类
- 设计模式是工具而非目标；简单任务用 Delegate 即可，不必套 MVVM + Repository + DI

### 5. 手术式修改

修改已有文件时：

- **只改必须改的行**，不顺手重构、不整文件格式化
- **不改**注释风格、引号风格、缩进风格
- **不加**没人要的类型注解、访问修饰符升级
- **不删**与本次任务无关的代码
- 新文件匹配项目已有风格

### 6. 目标驱动

- 每个 TASK 必须有 **可验证的验收标准**（由 `task-split` 技能写入 `task-split.md`）
- 实现前：确认理解每条验收标准
- 实现后：逐条核对，在回复中标注通过 / 未通过
- 验收标准应可观测：「编译通过」「点击按钮弹出 Alert」「单元测试 X 通过」——而非「代码质量良好」

### 7. 类级职责单一

一个类 / struct 应有**单一的变更理由**——如果需要因两个不相关的业务需求而修改同一个类，应考虑拆分。

**判断标准：**
- ViewController 包含网络请求、数据解析、布局、导航等 3 个以上不相关职责 → 按 `architecture.md` 分层指引拆分
- ViewModel 同时管理多个无关业务流程（如登录 + 消息推送） → 拆为独立 ViewModel
- Service 同时处理网络请求和本地缓存逻辑 → 拆为 RemoteDataSource + LocalDataSource

**约束边界：**
- `task-split.md` 未要求拆分时**不主动拆**
- 简单页面（单屏、少量交互）允许 ViewController 直接持有少量逻辑，不强制引入 ViewModel
- 拆分依据是职责数量与变更频率，不是代码行数

### 7. 目标驱动

## 优先级

1. **项目既有约定** — 命名、架构、目录、代码风格
2. **本原则** — 简单优先、手术式修改、目标驱动
3. **第 3 层 reference** — 项目无规定时的行业实践
4. **Apple 平台约束** — HIG、API 规范、App Store 要求

## 第 3 层 Reference 索引

按需加载，每次优先只加载 1 个：

| 何时加载 | 文件 | 内容 |
|----------|------|------|
| 任务涉及模块划分、分层职责 | [architecture.md](architecture.md) | 目录结构、层级职责、何时需要复杂架构 |
| 任务需要选用设计模式 | [design-patterns.md](design-patterns.md) | 15 种模式 Swift/ObjC 示例 |
| 任务涉及 Swift/ObjC 命名与格式 | [swift-objc-style.md](swift-objc-style.md) | 命名、格式、访问控制、互操作 |
| 任务涉及安全、性能、内存 | [security-performance.md](security-performance.md) | 存储、网络、并发、启动优化 |
| 需要快速确认某个写法对不对 | [examples.md](examples.md) | 常见错误 vs 正确写法短对比 |

## 验收自检清单

全部 TASK 完成后对照（结合 task-split.md 逐条验收）：

- [ ] 每个 TASK 的验收标准均已逐条核对
- [ ] 仅修改了 task-split.md 范围内的文件
- [ ] 修改已有文件时未做无关改动（注释/格式/引号/类型注解）
- [ ] 未引入 task-split.md 未要求的架构层或设计模式
- [ ] 疑问点在 Step 3 已澄清或确认无需澄清
- [ ] 代码与项目既有风格一致

## 不应做的事

- 不重复加载已有 reference 的内容到本文件
- 不在本文件写架构代码示例（见 `architecture.md` / `design-patterns.md`）
- 不在本文件写语言细节（见 `swift-objc-style.md`）
- 不跳过疑问澄清直接写代码
- 不为「以后可能需要」做过度设计
