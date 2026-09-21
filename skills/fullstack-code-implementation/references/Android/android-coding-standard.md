# Android 编码规范（核心约束）

> **本文件是唯一权威的编码约束入口**。工作流见 [SKILL.md](../SKILL.md)；文档分层见 [README.md](README.md)。

平台常用基础（组件、Manifest、资源、权限、构建）见 [official-android-developer-guide-basics.md](official-android-developer-guide-basics.md)。`tech_stack` 默认 **`java`**（详见下文）。

---

## 编码执行原则（必读）

以下原则优先于具体技巧；与 `task-split.md` 冲突时以 **task-split.md** 为准。

### 1. 单文件单一职责（reference 目录）

每个 reference 文件只解决一个方向，互不重复维护同一条规则。按需打开，见 [README.md](README.md)。

### 2. 渐进式披露

先读本文件 + `task-split.md`；仅当任务需要时再打开 `reference.md`、`design-patterns-examples.md` 或某一 `official-*.md`。

### 3. 先想清楚再写代码

动手实现前必须完成：

1. 阅读 `task-split.md` 中**当前任务**的描述、影响文件、验收标准
2. 若存在模糊点，向用户列出 **2～4 个具体疑问**（范围、行为、边界、与现有代码关系），**待澄清后再写**
3. 用一句话写出**本任务完成定义**（可对照验收标准逐条勾选）

**无 `task-split.md` 时**：先确认范围与验收方式，同样先澄清再写。

### 4. 简单优先

- 只实现当前任务所需的最小方案
- 不引入「以后可能用到」的抽象、额外模块、通用框架
- Use Case / 额外接口层：**仅当** task 要求或已有模块已采用时再沿用
- 能用一个类解决的不拆三个

### 5. 手术式修改

- **只改完成任务所必需的行**；不顺手重构无关文件
- 不统一修改：注释风格、无关类型注解、引号风格、import 顺序、整文件格式化
- 新代码与**相邻现有代码**风格一致即可
- 禁止「顺便」删除未使用代码、重命名无关符号（除非 task 明确要求）

### 6. 目标驱动、可验证完成

- 每个任务必须以 `task-split.md` 中的**验收标准**为完成依据
- 验收标准须可验证（可运行、可点击路径、可断言、可编译）
- 完成后在回复或 `task-split.md` 中说明：如何验证、已勾选哪几条
- 未写验收标准的任务：**先补 task-split.md**，不默认「看起来做完」

---

## 动手前：澄清疑问（模板）

存在任一项不明时，先输出疑问再编码：

```markdown
## 待澄清（实现 T00x 前）
1. …
2. …
（共 2～4 条，具体、可回答）
```

常见澄清方向：UI 行为边界、错误处理、是否复用某现有类、是否包含测试、与后端/权限的约定。

---

## 技术栈入参（tech_stack）

| 入参值 | 技术栈 | 新功能默认 |
|--------|--------|------------|
| **`java`（默认）** | Java + XML + ViewBinding | Activity/Fragment + XML |
| `kotlin` | Kotlin + Jetpack Compose | Kotlin + Compose |

**优先级**：用户明文 > `task-split.md` 元数据 > 入参 > 模块既有栈 > `java`。

语言细则：**不重复于此**——Java 见 [official-android-java-style.md](official-android-java-style.md)；Kotlin 见 [official-kotlin-style.md](official-kotlin-style.md)。

---

## 快速检查清单（提交前）

按 `tech_stack` 勾选适用项：

- [ ] 仅修改 task 要求范围内的文件（手术式）
- [ ] 验收标准逐条可验证且已满足
- [ ] 命名符合 [reference.md](reference.md) 命名表
- [ ] UI 无业务逻辑；状态单向流动
- [ ] 文案/颜色/尺寸在资源文件
- [ ] 生命周期与线程使用正确（主线程不阻塞）
- [ ] 非平凡逻辑有测试（仅当 task 要求或项目惯例）

---

## 语言与栈选择

| 场景 | `java`（默认） | `kotlin` |
|------|----------------|----------|
| 新功能 | Java + XML + ViewBinding | Kotlin + Compose |
| 既有模块 | 与模块一致 | 与模块一致 |
| 禁止 | 无计划混入 Compose | 无计划硬改 XML 屏 |

---

## 架构（原则级）

```
UI → ViewModel → Repository → 数据源
```

- Use Case 层：**可选**，task 或项目已有再使用
- 分层与 UDF/SSOT 细节：[official-android-architecture.md](official-android-architecture.md)
- MVVM/Repository 示例代码：[design-patterns-examples.md](design-patterns-examples.md)（**仅**需要示例时打开）

| 层次 | 职责 |
|------|------|
| UI | 渲染状态、转发事件 |
| ViewModel | 持有 UI 状态；`java`→LiveData/Flow；`kotlin`→StateFlow |
| Repository | 单一数据源；合并本地/远程 |

---

## UI 约束

### XML（`tech_stack=java`）

- ViewBinding；`ConstraintLayout`；ID：`btn_`/`tv_`/`rv_` 等前缀
- Fragment：`viewLifecycleOwner`；`onDestroyView` 清空 binding

### Compose（`tech_stack=kotlin`）

- 无状态 Composable；状态在 ViewModel
- 公共组件命名/API：[official-compose-api-guidelines.md](official-compose-api-guidelines.md)（**仅**写 Composable 时打开）

---

## 资源与 Manifest

布局 `activity_`/`fragment_`/`item_`；字符串 `feature_context_action`；文案进 `strings.xml`。

---

## 数据层（原则）

- DTO 在 `data.remote`；映射在 Repository（示例见 design-patterns **Mapper**）
- Room：显式迁移；禁止擅自 `fallbackToDestructiveMigration()`
- 网络：401 一处处理；不向 UI 抛裸异常

---

## Gradle / 测试 / 安全

- `implementation` 优先；Release 开 R8
- 测试工具按栈选；**仅 task 要求时新增测试**
- 无密钥入仓；不 log PII

---

## Code Review 分级

- **Critical**：崩溃、泄漏、主线程阻塞、安全
- **Suggestion**：可读性、性能
- **Nice to have**：非 task 范围的重构（默认不做）

---

## 按需阅读（勿通读）

| 需要 | 打开 |
|------|------|
| 组件/Manifest/资源/权限/Gradle | [official-android-developer-guide-basics.md](official-android-developer-guide-basics.md) |
| 新类命名/包路径 | [reference.md](reference.md) |
| 模式示例 | [design-patterns-examples.md](design-patterns-examples.md) |
| Java 格式争议 | [official-android-java-style.md](official-android-java-style.md) |
| Kotlin 格式争议 | [official-kotlin-style.md](official-kotlin-style.md) |
| 架构分层争议 | [official-android-architecture.md](official-android-architecture.md) |
| Compose API 争议 | [official-compose-api-guidelines.md](official-compose-api-guidelines.md) |

完整地图：[README.md](README.md)
