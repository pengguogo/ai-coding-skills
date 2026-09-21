# Step 5: 异常处理治理扫描

## 元信息

- execution-mode: subagent
- agent: exception-scanner
- checkpoint-level: L1

## 参数

- input: Step 1 的代码库路径 + 入口层清单 + 技术栈信息
- output: 异常处理发现清单

## 目的

扫描外部调用的异常处理，按系统异常（重试可恢复）和业务异常（重试无法恢复）二分分类，发现不合理治理点。

### 异常二分法

| 类型 | 定义 | 典型异常 | 处理策略 |
|------|------|---------|---------|
| 系统异常 | 网络/中间件/基础设施故障，重试可恢复 | TimeoutException, ConnectException, SQLException(死锁), RpcException(超时), CircuitBreakerOpenException | 重试+熔断+兜底 |
| 业务异常 | 业务规则冲突/数据校验失败，重试不可恢复 | 余额不足, 库存不足, 参数校验失败, 重复订单, 状态不合法 | 直接返回错误码, 不重试 |

### 检测维度

1. **异常被吞没** — catch 块为空或仅打日志
2. **异常分类错误** — 系统异常被当作业务异常返回通用错误
3. **重试策略缺失** — RPC/HTTP 调用无 retries 配置
4. **异常包装丢失** — new Exception(msg) 未传 cause
5. **异常粒度过粗** — catch(Exception) 包裹大量业务逻辑

## 执行指令

对每种模式使用对应搜索策略：

| 维度 | 搜索策略 | 风险基线 |
|------|---------|---------|
| 异常被吞没 | `catch\s*\([^)]+\)\s*\{\s*\}` 空catch；`catch.*\{[^}]{0,80}log\.error` 仅日志无重试 | high |
| 异常分类错误 | `catch.*(RpcException\|IOException\|Timeout).*return.*(fail\|"系统)` | high |
| 重试策略缺失 | RPC调用无retries；Feign/RestTemplate无@Retryable | high |
| 包装丢失 | `throw new \w+\([^)]*getMessage\(\)[^)]*\)` | medium |
| 粒度不当 | `catch\s*\(\s*Exception\s` 且方法>50行 | medium |

## 产出

- 异常处理发现清单（`upgrade/{scene}_{date}/_workspace/code-constraint/exception-scan.md`）
