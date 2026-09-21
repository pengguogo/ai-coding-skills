# Android P0 检查项精简集

> 共 14 项（通用 5 + Android 专项 9）。小节评审和终审均使用此集合作为 P0 级检查基线。
> 严重性：B = blocking（阻断），I = important（重要）。
> 适用范围：Android 原生（Kotlin / Java）。设计基线为 `frontend-android.md`（经入口 `frontend-design.md` 定位）。
> 本文件不含示例代码，仅保留一句话判断标准。

---

## 通用必检（5 项）

> **去重规则**：通用必检 5 项与 `p0-backend-checklist.md` / `p0-frontend-checklist.md` 共享。若同一文件已在其他端审查中通过通用必检，本端审查跳过该文件的通用必检项，仅执行 Android 专项。

| # | 编号 | 严重性 | 一句话判断标准 |
|---|------|--------|--------------|
| 1 | CC-DESIGN-01 | I | 接口路径、参数、返回值、类结构与设计文档一致 |
| 2 | CC-DESIGN-02 | I | data class / Entity 字段覆盖设计文档领域模型所有字段 |
| 3 | CC-DESIGN-04 | I | 调用顺序、条件分支与设计文档时序图一致 |
| 4 | CC-SEC-01 | B | 无硬编码密码/密钥/Token/内部 IP（应使用 BuildConfig 或安全存储） |
| 5 | CC-AI-01 | I | AI 生成代码有 `// AI-Generate`（Kotlin/Java）或 `<!-- AI-Generate -->`（XML）标记 |

## Android 专项（9 项）

| # | 编号 | 严重性 | 一句话判断标准 |
|---|------|--------|--------------|
| 6 | AD-ANR-01 | B | 主线程无网络请求/数据库/文件等耗时阻塞操作（避免 ANR） |
| 7 | AD-LEAK-01 | B | ViewModel/静态字段/单例不持有 Activity/Fragment/View/Context 引用（避免内存泄漏） |
| 8 | AD-LIFE-01 | B | Fragment 在 onDestroyView 置空 ViewBinding；协程用 viewModelScope/lifecycleScope，无泄漏 |
| 9 | AD-LIFE-02 | B | 注册的监听器/广播/观察者在对应生命周期注销 |
| 10 | AD-NPE-01 | B | 可空类型经判空处理，无未保护的 `!!` 强解包导致崩溃风险 |
| 11 | AD-PERM-01 | B | 危险权限运行时申请，且对用户拒绝有降级处理 |
| 12 | AD-DATA-01 | B | 本地存储（SharedPreferences/Room/文件）不含明文敏感信息 |
| 13 | AD-NET-01 | I | 网络请求有超时与异常处理，弱网/无网有用户反馈 |
| 14 | AD-API-01 | B | Retrofit 接口路径、方法、入参/出参与 backend-design.md 一致 |

---

## 使用说明

- **小节评审（L1.5）**：全部 14 项均执行，发现问题按白名单规则判定是否可自动修复。
- **终审（Step 3b）**：对已通过小节评审的功能点跳过 P0 级，仅补充 P1 级检查；对未经小节评审的功能点执行全部 14 项。
- **确信度要求**：每个发现必须标注确信度（高/中/低），低确信度标注 `[需人工确认]`。
