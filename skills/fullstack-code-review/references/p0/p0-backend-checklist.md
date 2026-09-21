# 后端 P0 检查项精简集

> 共 18 项（通用 5 + 后端专项 13）。小节评审和终审均使用此集合作为 P0 级检查基线。
> 严重性：B = blocking（阻断），I = important（重要）。
> 本文件不含示例代码，仅保留一句话判断标准。

---

## 通用必检（5 项）

> **去重规则**：通用必检 5 项与 `p0-frontend-checklist.md` 共享。若同一文件同时被后端审查和前端审查覆盖（如 BFF 层），通用必检项仅在首次审查时执行，后续审查跳过已覆盖的通用项。

| # | 编号 | 严重性 | 一句话判断标准 |
|---|------|--------|--------------|
| 1 | CC-DESIGN-01 | I | 接口路径、参数、返回值、类结构与设计文档一致 |
| 2 | CC-DESIGN-02 | I | Entity/DTO 字段覆盖设计文档领域模型所有字段 |
| 3 | CC-DESIGN-04 | I | 调用顺序、条件分支与设计文档时序图一致 |
| 4 | CC-SEC-01 | B | 无硬编码密码/密钥/Token/内部 IP |
| 5 | CC-SEC-02 | B | 用户输入使用前经过校验和清洗 |

## 后端专项（13 项）

| # | 编号 | 严重性 | 一句话判断标准 |
|---|------|--------|--------------|
| 6 | BE-SEC-01 | B | MyBatis 用 `#{}` 不用 `${}`；动态排序/表名白名单校验 |
| 7 | BE-SEC-03 | B | 非公开接口有权限校验 |
| 8 | BE-SEC-06 | B | Fastjson 禁 autoType，Jackson 禁 defaultTyping |
| 9 | BE-ARCH-01 | B | Controller→Service→Mapper 不越层 |
| 10 | BE-PATH-01 | B | API 路径与 backend-design.md 接口定义一致 |
| 11 | BE-CFG-02 | B | 敏感信息不在代码仓库中 |
| 12 | BQ-TX-01 | B | 事务不包含远程调用/MQ 发送/文件 IO |
| 13 | BQ-TX-03 | B | @Transactional 声明 rollbackFor=Exception.class |
| 14 | BQ-SPRING-01 | B | 同类内调用不绕过代理（self-invocation 导致 @Transactional 失效） |
| 15 | BQ-IDEM-01 | B | POST/PUT 写接口有幂等策略 |
| 16 | BQ-CONCUR-01 | B | 并发修改同一资源有锁机制 |
| 17 | BQ-RETRY-01 | B | 外部调用有超时设置 |
| 18 | BQ-CONSIST-05 | B | 金额用 BigDecimal/long，不用 float/double |

---

## 使用说明

- **小节评审（L1.5）**：全部 18 项均执行，发现问题按白名单规则判定是否可自动修复。
- **终审（Step 3）**：对已通过小节评审的模块跳过 P0 级，仅补充 P1 级检查；对未经小节评审的模块执行全部 18 项。
- **确信度要求**：每个发现必须标注确信度（高/中/低），低确信度标注 `[需人工确认]`。
