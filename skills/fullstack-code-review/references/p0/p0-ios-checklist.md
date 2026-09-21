# iOS P0 检查项精简集

> 共 14 项（通用 5 + iOS 专项 9）。小节评审和终审均使用此集合作为 P0 级检查基线。
> 严重性：B = blocking（阻断），I = important（重要）。
> 适用范围：iOS 原生（Swift / Objective-C）。设计基线为 `frontend-ios.md`（经入口 `frontend-design.md` 定位）。
> 本文件不含示例代码，仅保留一句话判断标准。

---

## 通用必检（5 项）

> **去重规则**：通用必检 5 项与 `p0-backend-checklist.md` / `p0-frontend-checklist.md` / `p0-android-checklist.md` 共享。若同一文件已在其他端审查中通过通用必检，本端审查跳过该文件的通用必检项，仅执行 iOS 专项。

| # | 编号 | 严重性 | 一句话判断标准 |
|---|------|--------|--------------|
| 1 | CC-DESIGN-01 | I | 接口路径、参数、返回值、类结构与设计文档一致 |
| 2 | CC-DESIGN-02 | I | struct/model 字段覆盖设计文档领域模型所有字段 |
| 3 | CC-DESIGN-04 | I | 调用顺序、条件分支与设计文档时序图一致 |
| 4 | CC-SEC-01 | B | 无硬编码密码/密钥/Token/内部 IP（应使用配置或 Keychain） |
| 5 | CC-AI-01 | I | AI 生成代码有 `// AI-Generate` 标记（Swift/ObjC） |

## iOS 专项（9 项）

| # | 编号 | 严重性 | 一句话判断标准 |
|---|------|--------|--------------|
| 6 | IO-MEM-01 | B | 无强引用循环：delegate 用 weak，闭包捕获 self 用 `[weak self]`/`[unowned self]` |
| 7 | IQ-THREAD-01 | B | 主线程无网络/数据库/大量计算等耗时阻塞操作 |
| 8 | IQ-THREAD-02 | B | UI 更新在主线程执行（DispatchQueue.main） |
| 9 | IO-LIFE-01 | I | 通知/KVO 观察者、Timer、Combine cancellables 在生命周期结束时释放 |
| 10 | IO-NPE-01 | B | 可选值经安全解包（if let/guard let/??），无未保护的强制解包 `!` 崩溃风险 |
| 11 | IQ-PERM-01 | B | 隐私权限运行时申请，Info.plist 有用途描述，拒绝后有降级处理 |
| 12 | IQ-DATA-01 | B | 敏感数据存 Keychain，不明文存 UserDefaults/plist/文件 |
| 13 | IQ-NET-01 | I | 网络请求有超时与异常处理，弱网/无网有用户反馈 |
| 14 | IQ-API-01 | B | 网络接口路径、方法、入参/出参与 backend-design.md 一致 |

---

## 使用说明

- **小节评审（L1.5）**：全部 14 项均执行，发现问题按白名单规则判定是否可自动修复。
- **终审（Step 3c）**：对已通过小节评审的功能点跳过 P0 级，仅补充 P1 级检查；对未经小节评审的功能点执行全部 14 项。
- **确信度要求**：每个发现必须标注确信度（高/中/低），低确信度标注 `[需人工确认]`。
