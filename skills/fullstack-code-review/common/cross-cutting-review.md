# 横切关注点审查检查项

> 本检查项适用于所有文件类型（前端、后端、通用配置），覆盖安全、性能、架构、设计合规和 AI 生成代码等横切关注点。
> 与 BE-* / FE-* 检查项互补，不重复。BE-* / FE-* 中标注"由 CC-* 统一覆盖"的检查项以本文件为准。
> 规范来源引用的是 fullstack-code-implementation 下的编码规范；若项目约定与本检查项冲突，以项目约定优先。

---

## CC-SEC：安全审查

### CC-SEC-01：敏感信息不硬编码
- **严重性**: blocking
- **规范来源**: 后端 coding-standard.md §11 + 前端 coding_standard.md §五·错误处理规范
- **判断标准**: 代码中不包含硬编码的密码、密钥、Token、内部 IP 地址等敏感信息；前端代码不包含后端密钥
- **示例**:
  \`\`\`
  ❌ const API_KEY = 'sk-abc123...';
  ❌ spring.datasource.password=root123
  ✅ 通过环境变量或配置中心注入
  \`\`\`

### CC-SEC-02：用户输入校验
- **严重性**: blocking
- **规范来源**: 通用安全规范
- **判断标准**: 所有用户输入（表单、URL 参数、请求体）在使用前须经过校验和清洗，前后端均须校验
- **示例**:
  \`\`\`typescript
  // 前端
  ✅ if (!isValidPhone(phone)) { message.error('手机号格式不正确'); return; }

  // 后端
  ✅ @NotBlank @Pattern(regexp = "^1[3-9]\\\\d{9}$") private String phone;

  ❌ // 前端不校验，完全依赖后端
  ❌ // 后端不校验，完全信任前端
  \`\`\`

### CC-SEC-03：HTTPS 和安全传输
- **严重性**: important
- **规范来源**: 通用安全规范
- **判断标准**: API 调用使用 HTTPS；WebSocket 使用 WSS；不存在 HTTP 明文传输敏感数据

### CC-SEC-04：CORS 配置合理
- **严重性**: important
- **规范来源**: 通用安全规范
- **判断标准**: 后端 CORS 配置不使用 \`*\` 通配符（生产环境）；前端代理配置不暴露内部服务地址
- **示例**:
  \`\`\`java
  ✅ @CrossOrigin(origins = "https://app.example.com")
  ❌ @CrossOrigin(origins = "*")  // 生产环境不应允许所有来源
  \`\`\`

### CC-SEC-05：依赖无已知漏洞
- **严重性**: important
- **规范来源**: 通用安全规范
- **判断标准**: 新引入的第三方依赖无已知高危漏洞（CVE）；版本不过于陈旧

---

## CC-PERF：性能审查

### CC-PERF-01：数据库查询有索引支撑
- **严重性**: important
- **规范来源**: 后端 coding-standard.md §8.8
- **判断标准**: 新增的 SQL 查询条件字段须有对应索引；JOIN 操作的关联字段须有索引
- **示例**:
  \`\`\`sql
  -- 查询: SELECT * FROM claim_order WHERE policy_no = ? AND status = ?
  ✅ CREATE INDEX idx_claim_order_policy_status ON claim_order(policy_no, status);
  ❌ 无对应索引，全表扫描
  \`\`\`

### CC-PERF-02：避免 N+1 查询
- **严重性**: important
- **规范来源**: 后端 coding-standard.md §8.8
- **判断标准**: 列表查询不在循环中逐条查询关联数据，须使用 JOIN 或批量查询
- **示例**:
  \`\`\`java
  ✅ List<ClaimVO> list = claimMapper.selectWithDetails(ids); // 一次查询

  ❌ for (Long id : ids) {
      ClaimDetail detail = detailMapper.selectById(id); // N+1 查询
  }
  \`\`\`

### CC-PERF-03：分页查询
- **严重性**: important
- **规范来源**: 通用性能规范
- **判断标准**: 列表接口须支持分页，不一次性返回全量数据；前端列表须有分页或滚动加载
- **示例**:
  \`\`\`java
  ✅ PageHelper.startPage(pageNum, pageSize);
  ❌ List<ClaimVO> all = claimMapper.selectAll(); // 无分页，数据量大时 OOM 风险
  \`\`\`

### CC-PERF-04：大文件/大数据量处理
- **严重性**: suggestion
- **规范来源**: 通用性能规范
- **判断标准**: 文件导出使用流式写入；大批量数据处理使用分批处理；前端大文件上传使用分片

### CC-PERF-05：缓存使用合理
- **严重性**: suggestion
- **规范来源**: 通用性能规范
- **判断标准**: 高频读取、低频变更的数据考虑缓存；缓存有过期策略和更新机制；不缓存敏感数据

---

## CC-ARCH：架构审查

> 改动影响分析（调用链影响、向后兼容、回滚方案）由 \`impact-analysis-checklist.md\`（IA-*）统一覆盖。本节聚焦架构层面的合规检查。

### CC-ARCH-01：新增文件符合模块边界
- **严重性**: important
- **规范来源**: backend-design.md / frontend-design.md
- **判断标准**: 新增的类/组件放置在正确的模块目录下，不跨模块放置
- **示例**:
  \`\`\`
  ✅ claim-service/src/.../claim/ClaimApprovalService.java  // 在 claim 模块下
  ❌ user-service/src/.../user/ClaimApprovalService.java     // 理赔逻辑不应在用户模块
  \`\`\`

### CC-ARCH-02：模块间依赖方向正确
- **严重性**: blocking
- **规范来源**: backend-design.md / frontend-design.md
- **判断标准**: 依赖方向符合架构设计（上层依赖下层，不反向依赖）；不出现循环依赖
- **示例**:
  \`\`\`
  ✅ Controller → Service → Repository（单向依赖）
  ❌ Service → Controller（反向依赖）
  ❌ ServiceA → ServiceB → ServiceA（循环依赖）
  \`\`\`

### CC-ARCH-03：公共代码提取合理
- **严重性**: suggestion
- **规范来源**: 通用架构规范
- **判断标准**: 重复代码（≥3 处相同逻辑）须提取为公共方法/组件/工具类

### CC-ARCH-04：接口契约前后端一致
- **严重性**: blocking
- **规范来源**: backend-design.md + frontend-design.md
- **判断标准**: 前端调用的 API 路径、请求参数、响应结构须与后端实现完全一致
- **示例**:
  \`\`\`
  // 后端实现
  @PostMapping("/api/v1/claims")
  public Result<ClaimVO> submit(@RequestBody ClaimDTO dto)

  // 前端调用
  ✅ post<Result<ClaimVO>>('/api/v1/claims', claimData)
  ❌ post('/api/claims', claimData)  // 路径不一致，缺少版本号
  \`\`\`

### CC-ARCH-05：错误码前后端统一
- **严重性**: important
- **规范来源**: backend-design.md
- **判断标准**: 后端返回的错误码须在前端有对应的处理逻辑和用户友好提示

---

## CC-DESIGN：设计合规

### CC-DESIGN-01：实现与设计文档一致
- **严重性**: important
- **规范来源**: backend-design.md / frontend-design.md
- **判断标准**: 代码实现的类结构、方法签名、业务流程须与设计文档描述一致；偏差须有合理说明

### CC-DESIGN-02：领域模型字段完整
- **严重性**: important
- **规范来源**: backend-design.md
- **判断标准**: Entity/DTO 的字段须覆盖设计文档中领域模型定义的所有字段，不遗漏、不多余
- **示例**:
  \`\`\`
  // 设计文档定义 ClaimOrder: id, policyNo, claimAmount, status, createTime
  ✅ 实体类包含全部 5 个字段
  ❌ 实体类缺少 createTime 字段
  ❌ 实体类多出未在设计中定义的 remark 字段（须说明原因）
  \`\`\`

### CC-DESIGN-03：异常处理与设计约定一致
- **严重性**: suggestion
- **规范来源**: backend-design.md
- **判断标准**: 错误码定义、异常分类、异常处理策略须与设计文档中的约定一致

### CC-DESIGN-04：时序逻辑与设计吻合
- **严重性**: important
- **规范来源**: backend-design.md
- **判断标准**: 核心业务流程的调用顺序、条件分支须与设计文档中的时序图/流程图一致
- **示例**:
  \`\`\`
  // 设计文档时序: 校验 → 创建订单 → 发送通知 → 返回结果
  ✅ 代码按此顺序执行
  ❌ 代码先创建订单再校验（顺序不一致）
  \`\`\`

### CC-DESIGN-05：数据库表结构与设计一致
- **严重性**: important
- **规范来源**: backend-design.md
- **判断标准**: DDL 脚本中的表名、字段名、字段类型、索引须与设计文档中的数据模型一致

---

## CC-AI：AI 生成代码专项

### CC-AI-01：AI 生成代码标记完整
- **严重性**: blocking
- **规范来源**: 后端 coding-standard.md §6.5 + 前端 coding_standard.md §二·2.3.5
- **判断标准**: 所有 AI 生成的代码须有 \`@AI-Generate\` 标记，标注生成工具名称
- **示例**:
  \`\`\`java
  ✅ /** @AI-Generate Kiro */
  public class ClaimCalculator { }

  ❌ // AI 生成但未标注
  public class ClaimCalculator { }
  \`\`\`

### CC-AI-02：AI 生成代码无安全隐患
- **严重性**: blocking
- **规范来源**: 通用安全规范
- **判断标准**: AI 生成的代码须重点检查：SQL 注入、XSS、硬编码密钥、不安全的反序列化、过于宽泛的权限

### CC-AI-03：AI 生成代码逻辑正确性
- **严重性**: important
- **规范来源**: 通用质量规范
- **判断标准**: AI 生成的代码须验证：边界条件处理、空值检查、异常处理、业务逻辑正确性
- **示例**:
  \`\`\`java
  // AI 生成的计算逻辑须验证
  ✅ public BigDecimal calculate(BigDecimal amount, BigDecimal rate) {
      if (amount == null || rate == null) throw new IllegalArgumentException("参数不能为空");
      return amount.multiply(rate).setScale(2, RoundingMode.HALF_UP);
  }

  ❌ public BigDecimal calculate(BigDecimal amount, BigDecimal rate) {
      return amount.multiply(rate); // 未处理 null，未设置精度
  }
  \`\`\`

### CC-AI-04：AI 生成代码无模板残留
- **严重性**: important
- **规范来源**: 通用质量规范
- **判断标准**: 不包含占位符文本（\`TODO: implement\`、\`your code here\`）、示例数据（\`test@example.com\`）、lorem ipsum 等

### CC-AI-05：AI 生成代码符合项目技术栈
- **严重性**: important
- **规范来源**: 通用架构规范
- **判断标准**: AI 生成的代码须使用项目约定的技术栈和工具库，不引入项目未使用的框架或库
- **示例**:
  \`\`\`
  // 项目使用 MyBatis-Plus
  ✅ claimMapper.selectById(id);
  ❌ entityManager.find(ClaimEntity.class, id); // 引入了项目未使用的 JPA
  \`\`\`