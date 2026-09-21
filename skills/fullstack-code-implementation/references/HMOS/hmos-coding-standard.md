# 鸿蒙 HMOS 编码规范（核心约束）

> **本文件是唯一权威的编码约束入口**。工作流见 [SKILL.md](../../SKILL.md)；文档分层见 [README.md](README.md)。

---

## 编码执行原则（必读）

以下原则优先于具体技巧；与 `task-split.md` 冲突时以 **task-split.md** 为准。

### 1. 单文件单一职责（reference 目录）

每个 reference 文件只解决一个方向，互不重复维护同一条规则。按需打开，见 [README.md](README.md)。

### 2. 渐进式披露

先读本文件 + `task-split.md`；仅当任务需要时再打开 `architecture.md`、`reference.md`、`design-patterns.md` 或 `security-performance.md`。

### 3. 先想清楚再写代码

动手实现前必须完成：

1. 阅读 `task-split.md` 中**当前任务**的描述、影响文件、验收标准
2. 若存在模糊点，向用户列出 **2～4 个具体疑问**（范围、行为、边界、与现有代码关系），**待澄清后再写**
3. 用一句话写出**本任务完成定义**（可对照验收标准逐条勾选）

**无 `task-split.md` 时**：先确认范围与验收方式，同样先澄清再写。

### 4. 简单优先

- 只实现当前任务所需的最小方案
- 不引入「以后可能用到」的抽象、额外模块、通用框架
- 能用一个 Page 或 @Component 解决的不拆多层
- task-split.md 未要求时不主动引入新层

### 5. 手术式修改

- **只改完成任务所必需的行**；不顺手重构无关文件
- 不统一修改：注释风格、无关类型注解、import 顺序、整文件格式化
- 新代码与**相邻现有代码**风格一致即可
- 禁止「顺便」删除未使用代码、重命名无关符号（除非 task 明确要求）

### 6. 目标驱动、可验证完成

- 每个任务必须以 `task-split.md` 中的**验收标准**为完成依据
- 验收标准须可验证（可运行、可点击路径、可断言、可编译）
- 完成后在回复或 `task-split.md` 中说明：如何验证、已勾选哪几条
- 未写验收标准的任务：**先补 task-split.md**，不默认「看起来做完」

### 7. 类级职责单一

一个类 / struct 应有**单一的变更理由**。

**判断标准：**
- Page 组件包含网络请求、数据解析、布局、导航等 3 个以上不相关职责 → 按 `architecture.md` 分层指引拆分
- ViewModel 同时管理多个无关业务流程 → 拆为独立 ViewModel
- Service 同时处理网络请求和本地缓存逻辑 → 拆为 RemoteDataSource + LocalDataSource

**约束边界：**
- `task-split.md` 未要求拆分时**不主动拆**
- 简单页面允许 Page 直接持有少量逻辑，不强制引入 ViewModel
- 拆分依据是职责数量与变更频率，不是代码行数

---

## 动手前：澄清疑问（模板）

存在任一项不明时，先输出疑问再编码：

```markdown
## 待澄清（实现 T00x 前）
1. …
2. …
（共 2～4 条，具体、可回答）
```

常见澄清方向：UI 行为边界、错误处理、是否复用某现有组件、是否包含测试、与后端/权限的约定。

---

## 快速检查清单（提交前）

- [ ] 仅修改 task 要求范围内的文件（手术式）
- [ ] 验收标准逐条可验证且已满足
- [ ] 命名符合 [reference.md](reference.md) 命名表
- [ ] UI 无业务逻辑；状态管理使用 @State/@Observed 等响应式机制
- [ ] 文案/颜色/尺寸在资源文件（`resources/`）
- [ ] 生命周期与线程使用正确（主线程不阻塞）
- [ ] 非平凡逻辑有测试（仅当 task 要求或项目惯例）
- [ ] 新增代码有 `// AI-Generate` 标记

---

## 架构（原则级）

```
Page/Component → ViewModel → Repository → 数据源
```

- 分层与模块详情：[architecture.md](architecture.md)（**仅**需要时打开）
- 模式示例代码：[design-patterns.md](design-patterns.md)（**仅**需要时打开）

| 层次 | 职责 |
|------|------|
| Page / @Component | 渲染 UI、转发用户事件 |
| ViewModel | 持有页面状态；使用 @ObservedV2/@Trace 驱动 UI 更新 |
| Repository | 单一数据源；合并本地/远程 |
| Service | 网络、Preferences/RDB、文件等基础设施 |

---

## UI 约束

- 声明式 ArkUI：@Component + build() 方法定义 UI
- 无状态组件优先；状态在 ViewModel 或 @State 管理
- 列表使用 LazyForEach + IDataSource 实现高性能渲染
- 文案进 `resources/base/element/string.json`
- 颜色进 `resources/base/element/color.json`
- 尺寸进 `resources/base/element/float.json`

---

## 数据层（原则）

- DTO 在 data/remote；映射在 Repository
- Preferences：轻量 KV 存储（用户偏好、配置缓存）
- RelationalStore/RDB：结构化数据存储（显式迁移）
- 网络：统一 HTTP 封装；401 一处处理；不向 UI 抛裸异常

---

## 安全 / 性能 / 并发

详见 [security-performance.md](security-performance.md)（仅涉及时加载）。

核心要点：
- 敏感数据用安全存储（Keystore/加密 Preferences），不用普通 Preferences
- 无密钥入仓；不 log PII
- UI 更新在主线程；耗时操作使用 TaskPool/Worker
- 组件消失时取消异步任务/定时器（`aboutToDisappear`）

---

## Code Review 分级

- **Critical**：崩溃、泄漏、主线程阻塞、安全
- **Suggestion**：可读性、性能
- **Nice to have**：非 task 范围的重构（默认不做）

---

## 优先级

1. **项目既有约定** — 命名、架构、目录、代码风格
2. **本原则** — 简单优先、手术式修改、目标驱动
3. **第 3 层 reference** — 项目无规定时的行业实践
4. **HarmonyOS 平台约束** — API 规范、上架要求

---

## 按需阅读（勿通读）

| 需要 | 打开 |
|------|------|
| 模块划分/分层职责 | [architecture.md](architecture.md) |
| 新类命名/目录路径 | [reference.md](reference.md) |
| 模式示例 | [design-patterns.md](design-patterns.md) |
| 安全/性能/并发 | [security-performance.md](security-performance.md) |
| 正反快速对比 | [examples.md](examples.md) |

完整地图：[README.md](README.md)

---

## 不应做的事

- 不重复加载已有 reference 的内容到本文件
- 不在本文件写架构代码示例（见 `architecture.md` / `design-patterns.md`）
- 不跳过疑问澄清直接写代码
- 不为「以后可能需要」做过度设计
