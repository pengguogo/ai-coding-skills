# 后端业务实现质量检查项

> 本检查项聚焦"业务实现正确性与健壮性"，与 \`backend-review-checklist.md\`（编码规范合规）互补。
> 审查基线来自上游设计文档（\`backend-design.md\`）和任务拆分（\`task/task-split.md\`）。
> 每个检查项标注严重性、审查基线来源和判断标准。blocking / important 级别附带正反示例。
> 若项目约定与本检查项冲突，以项目约定优先。

---

## BQ-IDEM：幂等性

> 审查基线：\`backend-design.md\` §3.2 各功能的"幂等"小节（系统侧/业务侧）。

### BQ-IDEM-01：写接口幂等策略
- **严重性**: blocking
- **审查基线**: backend-design.md §3.2 — 幂等
- **判断标准**: 所有 POST/PUT 写接口须有幂等策略（唯一键约束 / 幂等 Token / 状态机前置校验）；设计文档中标注的幂等要求须有对应实现
- **示例**:
  \`\`\`java
  // 设计文档要求：报案接口幂等，基于 报案号+操作类型 去重
  ✅ @Transactional
  public Result submitClaim(ClaimDTO dto) {
      // 幂等校验：基于业务键去重
      if (claimMapper.existsByClaimNoAndAction(dto.getClaimNo(), dto.getAction())) {
          return Result.ok(claimMapper.selectByClaimNo(dto.getClaimNo()));
      }
      // 正常业务逻辑...
  }

  ❌ public Result submitClaim(ClaimDTO dto) {
      claimMapper.insert(convert(dto)); // 无幂等校验，重复提交产生重复数据
      return Result.ok();
  }
  \`\`\`

### BQ-IDEM-02：幂等键选择合理
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 幂等
- **判断标准**: 幂等键须基于业务语义（如订单号+操作类型），不依赖请求时间戳或随机数
- **示例**:
  \`\`\`java
  ✅ // 幂等键 = 报案号 + 操作类型（业务语义）
  String idempotentKey = claimNo + ":" + actionType;

  ❌ // 幂等键 = 时间戳（不稳定，毫秒级并发会冲突）
  String idempotentKey = String.valueOf(System.currentTimeMillis());
  \`\`\`

### BQ-IDEM-03：重复调用安全
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 幂等
- **判断标准**: 同一请求重复提交不产生重复数据、不重复扣款、不重复发送通知

### BQ-IDEM-04：幂等窗口合理
- **严重性**: suggestion
- **审查基线**: backend-design.md §3.2 — 幂等
- **判断标准**: 幂等 Token 或去重窗口时长与业务场景匹配（如支付类 ≥24h，普通操作 ≥5min）

### BQ-IDEM-05：查询接口天然幂等
- **严重性**: nit
- **审查基线**: 通用
- **判断标准**: GET 查询接口无副作用，多次调用结果一致

---

## BQ-TX：事务完整性

> 审查基线：\`backend-design.md\` §3.2 各功能的时序图（调用链顺序）和 §2.2 技术选型。

### BQ-TX-01：事务边界合理
- **严重性**: blocking
- **审查基线**: backend-design.md §3.2 — 时序图
- **判断标准**: 事务范围覆盖所有需要原子性的操作，不过大（不包含远程调用/MQ 发送/文件 IO）
- **示例**:
  \`\`\`java
  ✅ @Transactional(rollbackFor = Exception.class)
  public void approveClaim(Long id) {
      claimMapper.updateStatus(id, APPROVED);
      approvalMapper.insert(buildApproval(id));
      // 事务内只有 DB 操作
  }
  // 事务外发送通知
  public void approveAndNotify(Long id) {
      approveClaim(id);
      notificationService.sendAsync(id); // MQ 发送在事务外
  }

  ❌ @Transactional
  public void approveClaim(Long id) {
      claimMapper.updateStatus(id, APPROVED);
      httpClient.post(externalUrl, data); // 事务内包含远程调用 → 长事务风险
      mqProducer.send(topic, message);    // 事务内包含 MQ 发送 → 数据不一致风险
  }
  \`\`\`

### BQ-TX-02：事务内无远程调用
- **严重性**: blocking
- **审查基线**: backend-design.md §3.2 — 时序图
- **判断标准**: @Transactional 方法内不包含 HTTP/RPC/MQ 发送等远程调用，避免长事务和数据不一致
- **示例**:
  \`\`\`java
  ✅ // 先完成本地事务，再异步通知
  @Transactional(rollbackFor = Exception.class)
  public void createOrder(OrderDTO dto) {
      orderMapper.insert(convert(dto));
      // 将消息写入本地消息表（同事务）
      localMessageMapper.insert(buildMessage(dto));
  }
  // 定时任务扫描本地消息表发送 MQ

  ❌ @Transactional
  public void createOrder(OrderDTO dto) {
      orderMapper.insert(convert(dto));
      mqProducer.send("ORDER_CREATED", dto); // 事务未提交就发 MQ
  }
  \`\`\`

### BQ-TX-03：rollbackFor 显式声明
- **严重性**: important
- **审查基线**: 通用
- **判断标准**: @Transactional 须显式声明 rollbackFor = Exception.class，不依赖默认行为（默认只回滚 RuntimeException）
- **示例**:
  \`\`\`java
  ✅ @Transactional(rollbackFor = Exception.class)
  ❌ @Transactional  // 默认只回滚 RuntimeException，checked exception 不回滚
  \`\`\`

### BQ-TX-04：事务传播行为正确
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 时序图
- **判断标准**: 嵌套事务的传播行为（REQUIRED/REQUIRES_NEW/NESTED）与业务语义匹配
- **示例**:
  \`\`\`java
  // 审批操作须独立事务，不受外层事务回滚影响
  ✅ @Transactional(propagation = Propagation.REQUIRES_NEW)
  public void recordAuditLog(Long id, String action) { }

  // 日志记录不应影响主业务
  ❌ @Transactional  // 默认 REQUIRED，外层回滚会连带日志也回滚
  public void recordAuditLog(Long id, String action) { }
  \`\`\`

### BQ-TX-05：分布式事务方案
- **严重性**: important
- **审查基线**: backend-design.md §2.2 技术选型 + §3.2 功能设计
- **判断标准**: 跨服务数据变更须有分布式事务方案（TCC/Saga/本地消息表/最终一致性），设计文档中标注的方案须有对应实现

### BQ-TX-06：事务失败补偿
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 异常处理
- **判断标准**: 事务回滚后的补偿逻辑完整（如已发送的通知需撤回、已扣减的库存需回补）

---

## BQ-CONSIST：数据一致性

> 审查基线：\`backend-design.md\` §2.2 技术选型（缓存/MQ）和 §3.2 功能设计。

### BQ-CONSIST-01：缓存与 DB 一致性
- **严重性**: important
- **审查基线**: backend-design.md §2.2 + §3.2
- **判断标准**: 数据变更时缓存更新/失效策略明确（先更新 DB 再删缓存 / 延迟双删 / 订阅 binlog）
- **示例**:
  \`\`\`java
  ✅ public void updateClaim(ClaimDTO dto) {
      claimMapper.updateById(convert(dto));
      redisTemplate.delete("claim:" + dto.getId()); // 先更新 DB，再删缓存
  }

  ❌ public void updateClaim(ClaimDTO dto) {
      redisTemplate.opsForValue().set("claim:" + dto.getId(), dto); // 先更新缓存
      claimMapper.updateById(convert(dto)); // 后更新 DB → DB 失败时缓存脏数据
  }
  \`\`\`

### BQ-CONSIST-02：主从延迟处理
- **严重性**: suggestion
- **审查基线**: backend-design.md §2.2
- **判断标准**: 写后立即读的场景是否走主库？关键业务是否有强制主库读的机制？

### BQ-CONSIST-03：跨服务数据一致
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 依赖接口
- **判断标准**: 跨服务数据变更有最终一致性保障（MQ + 重试 + 对账），不依赖同步调用的"假一致"

### BQ-CONSIST-04：数据校验完整
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 对外接口
- **判断标准**: 关键业务数据入库前有完整性校验（非空、范围、格式、业务规则），不仅依赖前端校验

### BQ-CONSIST-05：金额计算精度
- **严重性**: blocking
- **审查基线**: 通用
- **判断标准**: 金额使用 BigDecimal 或 long（分），不使用 float/double；除法须指定精度和舍入模式
- **示例**:
  \`\`\`java
  ✅ BigDecimal total = amount.multiply(rate).setScale(2, RoundingMode.HALF_UP);
  ❌ double total = amount * rate; // 浮点精度丢失
  \`\`\`

---

## BQ-CONCUR：并发安全

> 审查基线：\`backend-design.md\` §2.2 技术选型（分布式锁）和 §3.2 功能设计。

### BQ-CONCUR-01：竞态条件防护
- **严重性**: blocking
- **审查基线**: backend-design.md §3.2
- **判断标准**: 并发修改同一资源时有锁机制（乐观锁 version / 悲观锁 SELECT FOR UPDATE / 分布式锁）
- **示例**:
  \`\`\`java
  ✅ // 乐观锁：基于 version 字段
  int rows = claimMapper.updateStatusWithVersion(id, newStatus, currentVersion);
  if (rows == 0) {
      throw new BusinessException("数据已被他人修改，请刷新后重试");
  }

  ❌ // 无并发控制：先查后改
  Claim claim = claimMapper.selectById(id);
  claim.setStatus(newStatus);
  claimMapper.updateById(claim); // 并发时可能覆盖他人修改
  \`\`\`

### BQ-CONCUR-02：锁粒度合理
- **严重性**: important
- **审查基线**: backend-design.md §3.2
- **判断标准**: 锁的粒度与业务匹配（行级锁优于表级锁），锁持有时间尽量短

### BQ-CONCUR-03：分布式锁使用正确
- **严重性**: important
- **审查基线**: backend-design.md §2.2
- **判断标准**: 分布式锁有超时释放、续期机制、异常释放保障，不出现死锁
- **示例**:
  \`\`\`java
  ✅ RLock lock = redisson.getLock("claim:approve:" + claimId);
  try {
      if (lock.tryLock(5, 30, TimeUnit.SECONDS)) { // 等待 5s，持有 30s
          // 业务逻辑
      } else {
          throw new BusinessException("操作正在处理中，请稍后重试");
      }
  } finally {
      if (lock.isHeldByCurrentThread()) {
          lock.unlock();
      }
  }

  ❌ RLock lock = redisson.getLock("claim:approve:" + claimId);
  lock.lock(); // 无超时，可能死锁
  // 业务逻辑
  lock.unlock(); // 异常时不释放
  \`\`\`

### BQ-CONCUR-04：线程安全
- **严重性**: important
- **审查基线**: 通用
- **判断标准**: 共享变量（静态变量、Spring 单例 Bean 的成员变量）线程安全，不使用非线程安全的集合
- **示例**:
  \`\`\`java
  ✅ private final ConcurrentHashMap<String, Object> cache = new ConcurrentHashMap<>();
  ❌ private final HashMap<String, Object> cache = new HashMap<>(); // 非线程安全
  ❌ private int counter = 0; // Spring 单例 Bean 的成员变量，多线程不安全
  \`\`\`

---

## BQ-RETRY：重试与超时

> 审查基线：\`backend-design.md\` §3.2 各功能的"依赖接口"和"异常处理"小节，§4 稳定性评估。

### BQ-RETRY-01：外部调用有超时
- **严重性**: blocking
- **审查基线**: backend-design.md §3.2 — 依赖接口
- **判断标准**: 所有 HTTP/RPC/DB 外部调用须设置超时时间，不使用无限等待
- **示例**:
  \`\`\`java
  ✅ RestTemplate restTemplate = new RestTemplateBuilder()
      .setConnectTimeout(Duration.ofSeconds(3))
      .setReadTimeout(Duration.ofSeconds(10))
      .build();

  ❌ new RestTemplate().getForObject(url, String.class); // 无超时，可能永久阻塞
  \`\`\`

### BQ-RETRY-02：重试策略合理
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 异常处理
- **判断标准**: 重试有最大次数限制（通常 ≤3）、退避策略（指数退避优于固定间隔）、可重试异常白名单
- **示例**:
  \`\`\`java
  ✅ @Retryable(
      value = {TimeoutException.class, ConnectException.class}, // 仅网络异常重试
      maxAttempts = 3,
      backoff = @Backoff(delay = 1000, multiplier = 2) // 指数退避
  )

  ❌ @Retryable(maxAttempts = 10) // 重试次数过多，无异常白名单
  \`\`\`

### BQ-RETRY-03：重试幂等安全
- **严重性**: blocking
- **审查基线**: backend-design.md §3.2 — 幂等 + 异常处理
- **判断标准**: 被重试的操作必须是幂等的，非幂等操作不可重试

### BQ-RETRY-04：降级方案
- **严重性**: important
- **审查基线**: backend-design.md §4 稳定性评估
- **判断标准**: 外部依赖不可用时有降级方案（返回缓存数据/默认值/友好提示），不直接抛异常给用户
- **示例**:
  \`\`\`java
  ✅ public PolicyInfo queryPolicy(String policyNo) {
      try {
          return policyClient.query(policyNo);
      } catch (Exception e) {
          log.warn("保单查询降级, policyNo={}", policyNo, e);
          return PolicyInfo.defaultValue(); // 降级返回默认值
      }
  }

  ❌ public PolicyInfo queryPolicy(String policyNo) {
      return policyClient.query(policyNo); // 外部服务挂了直接抛异常给用户
  }
  \`\`\`

---

## BQ-STATE：状态机完整性

> 审查基线：\`backend-design.md\` §3.1.3 状态机定义。

### BQ-STATE-01：状态流转与设计一致
- **严重性**: blocking
- **审查基线**: backend-design.md §3.1.3 状态机
- **判断标准**: 业务状态流转须与设计文档中的状态机定义完全一致；代码中的状态枚举值、转换路径须可追溯到设计

### BQ-STATE-02：非法状态转换防护
- **严重性**: important
- **审查基线**: backend-design.md §3.1.3 状态机
- **判断标准**: 代码中有状态前置校验，拒绝非法状态转换
- **示例**:
  \`\`\`java
  ✅ public void approveClaim(Long id) {
      Claim claim = claimMapper.selectById(id);
      if (!ClaimStatus.PENDING_APPROVAL.equals(claim.getStatus())) {
          throw new BusinessException("当前状态不允许审批操作");
      }
      // 执行审批...
  }

  ❌ public void approveClaim(Long id) {
      claimMapper.updateStatus(id, ClaimStatus.APPROVED); // 无状态前置校验
  }
  \`\`\`

### BQ-STATE-03：状态变更有审计
- **严重性**: suggestion
- **审查基线**: backend-design.md §3.1.3
- **判断标准**: 关键业务状态变更须记录操作人、操作时间、变更前后状态，便于追溯

---

## BQ-EXCEPT：异常处理深度

> 审查基线：\`backend-design.md\` §3.2 各功能的"异常处理"小节。

### BQ-EXCEPT-01：异常分类处理
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 异常处理
- **判断标准**: 区分可恢复异常（重试）和不可恢复异常（告警+人工介入），不一刀切 catch Exception
- **示例**:
  \`\`\`java
  ✅ try {
      externalService.call(data);
  } catch (TimeoutException e) {
      // 可恢复：重试
      retryService.scheduleRetry(data);
  } catch (BusinessRejectException e) {
      // 不可恢复：记录并告警
      log.error("业务拒绝, data={}", data, e);
      alertService.send("业务拒绝告警", e.getMessage());
  }

  ❌ try {
      externalService.call(data);
  } catch (Exception e) {
      log.error("调用失败", e); // 一刀切，不区分异常类型
  }
  \`\`\`

### BQ-EXCEPT-02：部分失败处理
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 异常处理
- **判断标准**: 批量操作中部分失败时的处理策略明确（全部回滚 / 跳过失败项继续 / 记录失败项后续补偿）

### BQ-EXCEPT-03：异常信息完整
- **严重性**: important
- **审查基线**: 通用
- **判断标准**: 异常日志包含完整上下文（业务 ID、操作类型、输入参数摘要），便于定位问题
- **示例**:
  \`\`\`java
  ✅ log.error("理赔审批失败, claimId={}, operator={}, action={}", claimId, operator, action, e);
  ❌ log.error("操作失败", e); // 缺少业务上下文，无法定位问题
  \`\`\`