# 改动影响分析检查项

> 本检查项聚焦"改动的影响范围、向后兼容性、回滚方案和可观测性"。
> 适用于所有文件类型（前端、后端、通用配置），与 BQ-*（后端业务质量）、FQ-*（前端业务质量）互补。
> 审查基线来自 \`task/task-split.md\`（任务清单与依赖关系）和设计文档。
> 若项目约定与本检查项冲突，以项目约定优先。

---

## IA-SCOPE：改动范围分析

> 审查基线：\`task/task-split.md\` — 任务清单、依赖关系；设计文档 — 模块设计。

### IA-SCOPE-01：调用链上游影响
- **严重性**: important
- **审查基线**: task/task-split.md — 依赖关系
- **判断标准**: 被修改接口的所有调用方是否已评估影响？参数变更/返回值变更是否向后兼容？
- **示例**:
  \`\`\`
  ✅ 修改 ClaimService.approve() 的返回值时：
     - 已确认 ClaimController 调用处已适配
     - 已确认 UnionAgentService 调用处已适配
     - 已确认前端 claimService.approve() 已适配

  ❌ 修改了 approve() 返回值，但未检查其他调用方是否受影响
  \`\`\`

### IA-SCOPE-02：调用链下游影响
- **严重性**: important
- **审查基线**: task/task-split.md — 依赖关系
- **判断标准**: 修改的逻辑是否影响下游消费方？MQ 消息格式变更是否通知消费方？

### IA-SCOPE-03：共享组件影响
- **严重性**: blocking
- **审查基线**: 设计文档 — 模块设计
- **判断标准**: 修改公共工具类/基类/拦截器/公共组件等共享代码时，是否评估所有使用方的影响？
- **示例**:
  \`\`\`
  ✅ 修改 Result.java 统一响应类时：
     - 已全局搜索所有 Result 引用（Controller/Service/前端解析）
     - 新增字段为可选，不影响现有调用方

  ❌ 修改了 Result 类的字段名，未检查前端解析是否受影响
  \`\`\`

### IA-SCOPE-04：数据库变更影响
- **严重性**: blocking
- **审查基线**: backend-design.md §3.1.2 数据模型
- **判断标准**: DDL 变更（加字段/改类型/加索引）是否评估对现有查询性能和存量数据的影响？
- **示例**:
  \`\`\`sql
  ✅ -- 新增字段允许 NULL，不影响存量数据
  ALTER TABLE claim_order ADD COLUMN approve_remark VARCHAR(500) DEFAULT NULL COMMENT '审批备注';

  ❌ -- 新增 NOT NULL 字段无默认值，存量数据插入失败
  ALTER TABLE claim_order ADD COLUMN approve_remark VARCHAR(500) NOT NULL;
  \`\`\`

---

## IA-COMPAT：向后兼容

> 审查基线：\`backend-design.md\` §3.2 对外接口；\`frontend-design.md\` — 接口对齐表。

### IA-COMPAT-01：接口向后兼容
- **严重性**: blocking
- **审查基线**: backend-design.md §3.2 — 对外接口
- **判断标准**: 已发布接口的变更须向后兼容（新增字段可选、不删除已有字段、不改变字段语义）
- **示例**:
  \`\`\`java
  ✅ // 新增可选字段，不影响旧版调用方
  public class ClaimVO {
      private Long id;
      private String claimNo;
      private String approveRemark; // 新增，旧版调用方忽略即可
  }

  ❌ // 删除已有字段，旧版调用方解析失败
  public class ClaimVO {
      private Long id;
      // private String claimNo; ← 删除了已发布字段
  }
  \`\`\`

### IA-COMPAT-02：数据库向后兼容
- **严重性**: important
- **审查基线**: backend-design.md §3.1.2
- **判断标准**: 新增字段须有默认值或允许 NULL；不直接删除/重命名已有字段；字段类型变更须兼容存量数据

### IA-COMPAT-03：MQ 消息兼容
- **严重性**: important
- **审查基线**: backend-design.md §3.2 — 消息设计
- **判断标准**: 消息体结构变更须向后兼容，消费方能处理新旧两种格式

### IA-COMPAT-04：配置项兼容
- **严重性**: suggestion
- **审查基线**: backend-design.md §1.5 路径约定
- **判断标准**: 新增配置项须有默认值，不因配置缺失导致启动失败

---

## IA-ROLLBACK：回滚与应急

> 审查基线：\`backend-design.md\` §5 风险评估。

### IA-ROLLBACK-01：代码可回滚
- **严重性**: important
- **审查基线**: backend-design.md §5
- **判断标准**: 代码变更支持快速回滚（无不可逆操作），回滚后系统功能正常

### IA-ROLLBACK-02：数据库可回滚
- **严重性**: important
- **审查基线**: backend-design.md §3.1.2
- **判断标准**: DDL/DML 变更有对应的回滚脚本，且经过验证

### IA-ROLLBACK-03：功能开关
- **严重性**: suggestion
- **审查基线**: backend-design.md §4 稳定性评估
- **判断标准**: 高风险功能有开关控制，可在不回滚代码的情况下关闭新功能

### IA-ROLLBACK-04：灰度发布支持
- **严重性**: suggestion
- **审查基线**: backend-design.md §4
- **判断标准**: 变更是否支持灰度发布？是否有按用户/渠道/比例灰度的能力？

---

## IA-OBSERVE：可观测性

> 审查基线：\`backend-design.md\` §4 稳定性评估 — 监控与告警。

### IA-OBSERVE-01：关键路径日志
- **严重性**: important
- **审查基线**: backend-design.md §4 — 日志与监控
- **判断标准**: 核心业务流程的关键节点（入口、出口、分支、异常）有日志，包含 traceId 和业务 ID
- **示例**:
  \`\`\`java
  ✅ log.info("[报案] 开始处理, traceId={}, claimNo={}, channel={}",
      MDC.get("traceId"), claimNo, channel);
  // ... 业务逻辑
  log.info("[报案] 处理完成, traceId={}, claimNo={}, result={}",
      MDC.get("traceId"), claimNo, result);

  ❌ // 核心业务流程无任何日志，出问题无法追溯
  \`\`\`

### IA-OBSERVE-02：监控指标覆盖
- **严重性**: suggestion
- **审查基线**: backend-design.md §4 — 监控指标
- **判断标准**: 新增接口有成功率、耗时、异常率等监控指标；关键业务有业务指标（如报案成功率）

### IA-OBSERVE-03：告警规则配置
- **严重性**: suggestion
- **审查基线**: backend-design.md §4 — 告警规则
- **判断标准**: 新增的监控指标有对应的告警阈值和通知渠道