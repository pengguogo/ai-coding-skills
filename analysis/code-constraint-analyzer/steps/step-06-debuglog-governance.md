# Step 6: Debug 日志治理扫描

## 元信息

- execution-mode: subagent
- agent: debuglog-scanner
- checkpoint-level: L1

## 参数

- input: Step 1 的代码库路径 + 入口层清单
- output: Debug 日志发现清单 + 关键节点日志缺失分析

## 目的

扫描 `log.debug(...)` 调用 + 分析关键节点日志缺失情况，双维度产出：

### A. Debug 日志治理（已有维度）

按"是否关键链路 × 量级是否可控"二维矩阵归类，制定移除/升级方案。

```
              高频量级          中频量级          低频量级
关键链路    [移除 → trace]    [改 info]         [改 info]
辅助链路    [移除]            [移除或保留]      [移除]
非关键链路  [移除]            [移除]            [移除]
```

### B. 关键节点日志缺失分析（新增）

分析代码库中以下 4 类关键节点是否缺少必要日志，缺失即产出补充方案：

| 节点类型 | 必打日志 | 级别 | 分析方式 |
|----------|---------|------|---------|
| **入口流量日志** | Controller / RPC / MQ 入参出参、耗时 | INFO | 搜索入口方法，检查是否含 `log.info.*(请求\|入参\|耗时\|result)` |
| **关键 Service 功能日志** | 核心业务动作（下单/支付/审批/对账）的关键步骤 | INFO | 搜索核心 Service 方法，检查是否有业务语义日志 |
| **外部调用日志** | RPC/HTTP/DB 调用的入参、出参、耗时、异常 | INFO/WARN | 搜索 `@DubboReference` / `RestTemplate` / `Feign` / `mapper.` 调用周围是否打日志 |
| **中间件组件日志** | MQ 发送/消费、定时任务执行、缓存命中/未命中 | INFO | 搜索 `@KafkaListener` / `@Scheduled` / `@XxlJob` / `RedisTemplate` 周围 |

## 执行指令

### Part A: Debug 日志扫描

| 搜索项 | 策略 | 风险基线 |
|--------|------|---------|
| 全量 debug | `log\.debug\|logger\.debug\|LOG\.debug` | — |
| 敏感字段 | 内容含 password/token/secret/key/card/idCard/phone | high |
| 大对象 | 内容含 toJSONString / toString / 整个entity | medium |
| 循环内 | debug 在 `for\(` / `while\(` 体内 | high |
| 入口层 | 方法为Controller/RpcService公开方法 | high |

### Part B: 关键节点日志缺失分析

#### B.1 入口流量日志

对 Step 1 入口层清单中的每个入口方法，检查：

1. ✅ **入参日志**：方法开头是否有 `log.info("...请求参数:{}", ...)` 或等价日志
2. ✅ **出参日志**：方法 return 前是否有 `log.info("...返回结果:{}", ...)`
3. ✅ **耗时日志**：是否有 `StopWatch` / `System.currentTimeMillis()` + `log.info("...耗时:{}ms")`
4. ✅ **异常日志**：catch 块中是否记录了完整请求上下文

**缺失判定**：
- 0 项满足 → ❌ 完全缺失（high）
- 1-2 项满足 → ⚠️ 部分缺失（medium）
- 3-4 项满足 → ✅ 基本完善（low/no）

#### B.2 关键 Service 功能日志

识别核心业务节点，检查是否在关键步骤打 INFO：

| 核心动作 | 必打日志点 | 搜索策略 |
|----------|----------|---------|
| 订单状态流转 | 状态变更前后值 + 触发条件 | 搜索 `setStatus\|updateStatus` 前后 |
| 金额计算/分摊 | 计算结果 + 计算公式输入 | 搜索 `calcAmount\|divideAmount\|splitAmount` 周围 |
| 审批/审核 | 审批人+审批结果+审批时间 | 搜索 `approve\|audit\|review` 方法 |
| 对账/清算 | 对账结果+差异明细+处理动作 | 搜索 `reconcile\|settlement\|clear` 方法 |
| 数据订正 | 订正前后值+订正人+订正原因 | 搜索 `correct\|adjust\|fix` 方法 |

**缺失判定**：
- 核心动作完全无日志 → ❌ high
- 有日志但缺少关键字段（如状态变更只打"操作成功"，不打变更前后值） → ⚠️ medium
- 有完整业务语义日志 → ✅ low

#### B.3 外部调用日志

搜索所有外部调用点，检查是否打日志：

| 调用类型 | 识别特征 | 必打日志 |
|----------|---------|---------|
| RPC 调用 | `@DubboReference` / `@RpcReference` / `@ThriftService` | 调用前入参 + 调用后出参 + 异常时错误信息 + 耗时 |
| HTTP 调用 | `RestTemplate` / `WebClient` / `Feign` / `HttpClient` | 请求URL+入参+响应码+耗时 |
| DB 慢查询 | `mapper.select*` / `dao.find*` | 无必打日志要求，仅分析是否有慢 SQL 监控（如 MyBatis 拦截器） |
| MQ 发送 | `producer.send` / `kafkaTemplate.send` | 发送 topic+key+消息体摘要+发送结果 |

**缺失判定**：
- RPC/HTTP 调用完全无日志 → ❌ high
- 有日志但缺少耗时/异常信息 → ⚠️ medium
- 无慢 SQL 监控 → ⚠️ medium
- 有完整日志 → ✅ low

#### B.4 中间件组件日志

| 组件 | 必打日志 | 检查方式 |
|------|---------|---------|
| MQ 消费者 | 消费 topic+key+消息体摘要+消费结果+耗时 | 搜索 `@KafkaListener` / `@RocketMQMessageListener` / `@JmsListener` |
| 定时任务 | 任务名+开始时间+处理条数+执行结果+耗时 | 搜索 `@Scheduled` / `@XxlJob` / `@ElasticJob` |
| 缓存命中 | 缓存 key+命中/未命中+缓存操作类型 | 搜索 `redisTemplate` / `RedissonClient` / `@Cacheable` |

**缺失判定**：
- 定时任务完全无日志 → ❌ high
- MQ 消费者无日志或仅打"收到消息" → ⚠️ medium
- 缓存操作无任何日志 → low（非必须，但建议补充监控埋点）

## 产出

### 整体产出结构

```markdown
# Debug 日志治理与关键节点日志分析

## A. Debug 日志扫描结果

### 汇总矩阵
| 链路 \\ 量级 | 高频 | 中频 | 低频 |
|---------------|------|------|------|
| 关键链路      | N    | N    | N    |
| 辅助链路      | N    | N    | N    |
| 非关键链路    | N    | N    | N    |

### 发现明细
| 文件 | 行号 | 内容 | 链路 | 量级 | 敏感 | 建议 | 风险 |
|------|------|------|------|------|------|------|------|

### 建议动作汇总
| 动作 | 数量 |
|------|------|
| 移除 | N |
| 改 info | N |
| 改 trace | N |
| 保留 | N |

## B. 关键节点日志缺失分析

### B.1 入口流量日志
| 入口方法 | 文件:行号 | 入参 | 出参 | 耗时 | 异常 | 缺失等级 | 建议 |
|----------|----------|------|------|------|------|---------|------|
| PayController.pay() | PayController.java:45 | ❌ | ❌ | ❌ | ❌ | high | 补充完整流量日志 |

### B.2 关键 Service 功能日志
| 核心动作 | 方法 | 文件:行号 | 当前日志 | 缺失字段 | 缺失等级 | 建议 |
|----------|------|----------|---------|---------|---------|------|
| 状态流转 | updateStatus() | OrderService.java:78 | log.info("更新成功") | 变更前后值 | medium | 补充 oldStatus/newStatus |

### B.3 外部调用日志
| 调用点 | 文件:行号 | 调用类型 | 入参 | 出参 | 耗时 | 异常 | 缺失等级 | 建议 |
|--------|----------|---------|------|------|------|------|---------|------|
| paymentRpc.pay() | PayService.java:56 | RPC | ❌ | ❌ | ❌ | ✅ | high | 补充调用前后日志 |

### B.4 中间件组件日志
| 组件 | 方法 | 文件:行号 | 当前日志 | 缺失 | 缺失等级 | 建议 |
|------|------|----------|---------|------|---------|------|
| @Scheduled | syncData() | DataJob.java:34 | 无日志 | 任务名+处理条数+耗时 | high | 补充任务执行日志 |

## C. 整体统计
| 类别 | high | medium | low | 合计 |
|------|------|--------|-----|------|
| Debug 日志治理 | N | N | N | N |
| 入口流量日志缺失 | N | N | N | N |
| 关键 Service 日志缺失 | N | N | N | N |
| 外部调用日志缺失 | N | N | N | N |
| 中间件组件日志缺失 | N | N | N | N |
```

## 产出

- Debug 日志发现清单 + 关键节点日志缺失分析（`upgrade/{scene}_{date}/_workspace/code-constraint/debuglog-scan.md`）
