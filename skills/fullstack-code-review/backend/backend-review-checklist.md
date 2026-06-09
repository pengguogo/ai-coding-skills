# 后端代码审查检查项

> 本检查项从 fullstack-code-implementation 的后端编码规范（coding-standard.md）全部 13 章提炼。
> 每个检查项标注严重性、规范来源和判断标准。blocking / important 级别检查项附带正反示例。
> 规范来源中的章节号以 coding-standard.md 实际章节为准；若项目约定与本检查项冲突，以项目约定优先。
> AI-Generate 标记和安全合规的详细检查由 \`cross-cutting-review.md\`（CC-AI-*、CC-SEC-*）统一覆盖，本文件仅保留后端特有的检查项。
>
> **职责边界**：本文件聚焦**编码规范合规**检查。业务实现质量（幂等/事务/一致性/并发/重试/状态机/异常处理深度）的深度检查由 \`business-quality-checklist.md\`（BQ-*）统一覆盖。改动影响分析由 \`impact-analysis-checklist.md\`（IA-*）统一覆盖。

---

## BE-ENCODE：字符编码（§1）

### BE-ENCODE-01：源文件编码为 UTF-8
- **严重性**: blocking
- **规范来源**: coding-standard.md §1.1
- **判断标准**: 所有 \`.java\`、\`.xml\`、\`.yml\`、\`.properties\` 文件必须使用 UTF-8 编码，不得出现 BOM 头
- **示例**:
  \`\`\`
  ✅ 文件编码为 UTF-8 without BOM
  ❌ 文件编码为 GBK 或 UTF-8 with BOM
  \`\`\`

### BE-ENCODE-02：配置文件声明编码
- **严重性**: important
- **规范来源**: coding-standard.md §1.2
- **判断标准**: XML 文件头部包含 \`<?xml version="1.0" encoding="UTF-8"?>\`；properties 文件中中文使用 Unicode 转义或确认 Spring Boot 已配置 UTF-8 读取
- **示例**:
  \`\`\`xml
  ✅ <?xml version="1.0" encoding="UTF-8"?>
  ❌ <?xml version="1.0"?>  <!-- 缺少编码声明 -->
  \`\`\`

---

## BE-NAME：命名规范（§2）

### BE-NAME-01：类名使用 UpperCamelCase
- **严重性**: important
- **规范来源**: coding-standard.md §2.1
- **判断标准**: 所有类名首字母大写，多单词使用大驼峰，不含下划线
- **示例**:
  \`\`\`java
  ✅ public class ClaimApprovalService { }
  ❌ public class claimApprovalService { }
  ❌ public class Claim_Approval_Service { }
  \`\`\`

### BE-NAME-02：方法名使用 lowerCamelCase
- **严重性**: important
- **规范来源**: coding-standard.md §2.2
- **判断标准**: 方法名首字母小写，多单词使用小驼峰
- **示例**:
  \`\`\`java
  ✅ public void submitClaim() { }
  ❌ public void SubmitClaim() { }
  ❌ public void submit_claim() { }
  \`\`\`

### BE-NAME-03：常量名使用 UPPER_SNAKE_CASE
- **严重性**: important
- **规范来源**: coding-standard.md §2.3
- **判断标准**: \`static final\` 常量全大写，单词间用下划线分隔
- **示例**:
  \`\`\`java
  ✅ public static final String CLAIM_STATUS_APPROVED = "APPROVED";
  ❌ public static final String claimStatusApproved = "APPROVED";
  \`\`\`

### BE-NAME-04：包名全小写，层级清晰
- **严重性**: suggestion
- **规范来源**: coding-standard.md §2.4
- **判断标准**: 包名全小写，不含大写字母或下划线，层级反映模块结构

### BE-NAME-05：布尔变量/方法命名语义明确
- **严重性**: suggestion
- **规范来源**: coding-standard.md §2.5
- **判断标准**: 布尔类型使用 \`is\`/\`has\`/\`can\`/\`should\` 前缀，避免否定命名（如 \`isNotValid\`）

### BE-NAME-06：领域术语与设计文档一致
- **严重性**: important
- **规范来源**: coding-standard.md §2.6
- **判断标准**: 类名、字段名中的业务术语须与 \`backend-design.md\` 中领域模型定义一致
- **示例**:
  \`\`\`java
  // 设计文档定义领域对象为 ClaimOrder
  ✅ public class ClaimOrder { }
  ❌ public class ClaimInfo { }  // 与设计文档术语不一致
  \`\`\`

---

## BE-ARCH：架构与分层（§3）

### BE-ARCH-01：严格遵循分层架构
- **严重性**: blocking
- **规范来源**: coding-standard.md §3.1
- **判断标准**: Controller 不直接调用 Mapper/DAO；Service 不直接操作 HttpServletRequest/Response；各层职责不越界
- **示例**:
  \`\`\`java
  // ✅ Controller → Service → Mapper
  @RestController
  public class ClaimController {
      @Autowired private ClaimService claimService;
      @PostMapping("/claims")
      public Result submit(@RequestBody ClaimDTO dto) {
          return claimService.submit(dto);
      }
  }

  // ❌ Controller 直接调用 Mapper
  @RestController
  public class ClaimController {
      @Autowired private ClaimMapper claimMapper;
      @PostMapping("/claims")
      public Result submit(@RequestBody ClaimDTO dto) {
          claimMapper.insert(dto); // 越层调用
      }
  }
  \`\`\`

### BE-ARCH-02：DTO/VO/Entity 职责分离
- **严重性**: important
- **规范来源**: coding-standard.md §3.2
- **判断标准**: 不将数据库 Entity 直接暴露给前端；Controller 层使用 DTO/VO，Service 层内部可使用 Entity
- **示例**:
  \`\`\`java
  ✅ public Result getClaimDetail(Long id) {
      ClaimEntity entity = claimMapper.selectById(id);
      return Result.ok(ClaimVO.from(entity)); // 转换为 VO
  }
  ❌ public Result getClaimDetail(Long id) {
      return Result.ok(claimMapper.selectById(id)); // 直接返回 Entity
  }
  \`\`\`

### BE-ARCH-03：禁止循环依赖
- **严重性**: blocking
- **规范来源**: coding-standard.md §3.3
- **判断标准**: Service 之间不存在 A→B→A 的循环注入；如需交互，通过事件或中间层解耦

### BE-ARCH-04：模块间通过接口交互
- **严重性**: suggestion
- **规范来源**: coding-standard.md §3.4
- **判断标准**: 跨模块调用通过接口而非直接依赖实现类

---

## BE-PATH：路径一致性（§3.3）

### BE-PATH-01：API 路径与设计文档一致
- **严重性**: blocking
- **规范来源**: coding-standard.md §3.3 + backend-design.md
- **判断标准**: \`@RequestMapping\` 路径须与 \`backend-design.md\` 中接口定义完全一致
- **示例**:
  \`\`\`java
  // 设计文档: POST /api/v1/claims/{id}/approve
  ✅ @PostMapping("/api/v1/claims/{id}/approve")
  ❌ @PostMapping("/api/v1/claims/approve/{id}")  // 路径结构不一致
  \`\`\`

### BE-PATH-02：RESTful 路径命名规范
- **严重性**: suggestion
- **规范来源**: coding-standard.md §3.3
- **判断标准**: 路径使用小写字母和连字符，名词复数形式，避免动词（除特殊操作外）

---

## BE-CONST：常量与配置（§4）

### BE-CONST-01：禁止魔法值
- **严重性**: important
- **规范来源**: coding-standard.md §4.1
- **判断标准**: 代码中不出现未经定义的字面量（字符串、数字），须提取为常量或枚举
- **示例**:
  \`\`\`java
  ✅ if (claim.getStatus().equals(ClaimStatus.APPROVED)) { }
  ❌ if (claim.getStatus().equals("1")) { }  // 魔法值
  \`\`\`

### BE-CONST-02：配置项外部化
- **严重性**: important
- **规范来源**: coding-standard.md §4.2
- **判断标准**: 环境相关配置（URL、端口、密钥等）不硬编码在 Java 代码中，须通过 \`@Value\` 或配置中心注入
- **示例**:
  \`\`\`java
  ✅ @Value("\${claim.service.timeout}") private int timeout;
  ❌ private int timeout = 30000; // 硬编码超时时间
  \`\`\`

### BE-CONST-03：枚举优先于常量类
- **严重性**: suggestion
- **规范来源**: coding-standard.md §4.3
- **判断标准**: 有限状态集合优先使用枚举类型，而非字符串/整数常量

---

## BE-STYLE：代码风格（§5）

### BE-STYLE-01：单方法不超过 80 行
- **严重性**: important
- **规范来源**: coding-standard.md §5.1
- **判断标准**: 单个方法体（不含注释和空行）不超过 80 行，超过须拆分
- **示例**:
  \`\`\`java
  // ✅ 职责单一的短方法
  public ClaimVO submit(ClaimDTO dto) {
      validate(dto);
      ClaimEntity entity = convert(dto);
      claimMapper.insert(entity);
      return ClaimVO.from(entity);
  }
  \`\`\`

### BE-STYLE-02：单类不超过 500 行
- **严重性**: suggestion
- **规范来源**: coding-standard.md §5.2
- **判断标准**: 单个 Java 文件不超过 500 行（含注释），超过考虑拆分职责

### BE-STYLE-03：方法参数不超过 5 个
- **严重性**: suggestion
- **规范来源**: coding-standard.md §5.3
- **判断标准**: 方法参数超过 5 个时，应封装为参数对象

### BE-STYLE-04：大括号使用 K&R 风格
- **严重性**: nit
- **规范来源**: coding-standard.md §5.4
- **判断标准**: 左大括号不换行，右大括号独占一行

### BE-STYLE-05：import 不使用通配符
- **严重性**: nit
- **规范来源**: coding-standard.md §5.5
- **判断标准**: 不使用 \`import java.util.*\`，须明确导入具体类

---

## BE-DOC：注释与文档（§6）

### BE-DOC-01：公共类和方法必须有 Javadoc
- **严重性**: important
- **规范来源**: coding-standard.md §6.1
- **判断标准**: 所有 \`public\` 类和方法须有 Javadoc 注释，包含功能描述、参数说明、返回值说明
- **示例**:
  \`\`\`java
  ✅
  /**
   * 提交理赔申请
   * @param dto 理赔申请数据
   * @return 提交结果
   */
  public Result submitClaim(ClaimDTO dto) { }

  ❌
  public Result submitClaim(ClaimDTO dto) { } // 缺少 Javadoc
  \`\`\`

### BE-DOC-02：注释与代码同步更新
- **严重性**: suggestion
- **规范来源**: coding-standard.md §6.2
- **判断标准**: 修改代码逻辑后，相关注释须同步更新，不得出现注释与代码矛盾

### BE-DOC-03：禁止无意义注释
- **严重性**: nit
- **规范来源**: coding-standard.md §6.3
- **判断标准**: 不出现 \`// 获取用户\` 这类重复代码语义的注释

### BE-DOC-04：复杂业务逻辑须有说明注释
- **严重性**: suggestion
- **规范来源**: coding-standard.md §6.4
- **判断标准**: 包含复杂条件判断、算法或业务规则的代码段须有解释性注释

---

## BE-AI：AI-Generate 标记（§6.5）

> AI-Generate 标记的完整检查由 \`cross-cutting-review.md\` CC-AI-* 统一覆盖（含前后端）。
> 后端特有补充：AI 生成的 MyBatis XML、SQL 脚本等非 Java 文件也须标注。

### BE-AI-01：非 Java 文件的 AI 标记
- **严重性**: important
- **规范来源**: coding-standard.md §6.5
- **判断标准**: AI 生成的 MyBatis XML 使用 \`<!-- AI-Generate -->\`，SQL 脚本使用 \`-- AI-Generate\`，properties 使用 \`# AI-Generate\`

---

## BE-MVC：Spring MVC（§7）

### BE-MVC-01：Controller 方法使用明确的 HTTP 方法注解
- **严重性**: important
- **规范来源**: coding-standard.md §7.1
- **判断标准**: 使用 \`@GetMapping\`/\`@PostMapping\`/\`@PutMapping\`/\`@DeleteMapping\` 而非通用 \`@RequestMapping\`
- **示例**:
  \`\`\`java
  ✅ @PostMapping("/claims")
  ❌ @RequestMapping(value = "/claims", method = RequestMethod.POST)
  \`\`\`

### BE-MVC-02：统一响应封装
- **严重性**: important
- **规范来源**: coding-standard.md §7.2
- **判断标准**: Controller 方法返回统一的 \`Result<T>\` 或项目约定的响应包装类，不直接返回裸对象
- **示例**:
  \`\`\`java
  ✅ public Result<ClaimVO> getDetail(@PathVariable Long id) { }
  ❌ public ClaimVO getDetail(@PathVariable Long id) { }
  \`\`\`

### BE-MVC-03：参数校验使用 @Valid/@Validated
- **严重性**: suggestion
- **规范来源**: coding-standard.md §7.3
- **判断标准**: 请求体参数使用 \`@Valid\` 或 \`@Validated\` 触发校验，DTO 字段使用 JSR-303 注解

### BE-MVC-04：Controller 不包含业务逻辑
- **严重性**: important
- **规范来源**: coding-standard.md §7.4
- **判断标准**: Controller 方法仅做参数接收、调用 Service、返回结果，不包含 if-else 业务判断
- **示例**:
  \`\`\`java
  ✅ @PostMapping("/claims")
  public Result submit(@Valid @RequestBody ClaimDTO dto) {
      return Result.ok(claimService.submit(dto));
  }

  ❌ @PostMapping("/claims")
  public Result submit(@RequestBody ClaimDTO dto) {
      if (dto.getAmount() > 10000) {  // 业务逻辑不应在 Controller
          // ...复杂处理
      }
  }
  \`\`\`

---

## BE-DESIGN：设计原则（§8）

### BE-DESIGN-01：异常使用自定义业务异常类
- **严重性**: important
- **规范来源**: coding-standard.md §8.1
- **判断标准**: 业务异常使用项目定义的 \`BusinessException\` 或类似自定义异常，不直接抛出 \`RuntimeException\`
- **示例**:
  \`\`\`java
  ✅ throw new BusinessException(ErrorCode.CLAIM_NOT_FOUND, "理赔单不存在");
  ❌ throw new RuntimeException("理赔单不存在");
  \`\`\`

### BE-DESIGN-02：全局异常处理器存在且覆盖完整
- **严重性**: important
- **规范来源**: coding-standard.md §8.2
- **判断标准**: 项目须有 \`@ControllerAdvice\` 全局异常处理器，覆盖业务异常、参数校验异常、系统异常

### BE-DESIGN-03：日志规范使用
- **严重性**: important
- **规范来源**: coding-standard.md §8.3
- **判断标准**: 使用 SLF4J 日志门面；异常日志使用 \`log.error(msg, e)\` 保留堆栈；不使用 \`System.out.println\`
- **示例**:
  \`\`\`java
  ✅ log.error("理赔提交失败, claimId={}", claimId, e);
  ❌ System.out.println("理赔提交失败");
  ❌ log.error("理赔提交失败" + e.getMessage()); // 丢失堆栈
  \`\`\`

### BE-DESIGN-04：逻辑删除而非物理删除
- **严重性**: suggestion
- **规范来源**: coding-standard.md §8.4
- **判断标准**: 业务数据使用逻辑删除（\`is_deleted\` 字段），不直接执行 \`DELETE\` SQL

### BE-DESIGN-05：数据库脚本规范
- **严重性**: important
- **规范来源**: coding-standard.md §8.5
- **判断标准**: DDL/DML 脚本须有注释说明、回滚方案；字段须有 \`COMMENT\`；索引命名规范（\`idx_表名_字段名\`）
- **示例**:
  \`\`\`sql
  ✅ ALTER TABLE claim_order ADD COLUMN approve_time DATETIME COMMENT '审批时间';
  ❌ ALTER TABLE claim_order ADD COLUMN approve_time DATETIME; -- 缺少字段注释
  \`\`\`

### BE-DESIGN-06：事务边界合理
- **严重性**: important
- **规范来源**: coding-standard.md §8.6
- **判断标准**: \`@Transactional\` 注解在 Service 层使用，不在 Controller 层；事务范围不过大（不包含远程调用）。**深度检查见 BQ-TX-*（business-quality-checklist.md）**
- **示例**:
  \`\`\`java
  ✅ @Service
  public class ClaimService {
      @Transactional(rollbackFor = Exception.class)
      public void approve(Long id) { }
  }

  ❌ @RestController
  public class ClaimController {
      @Transactional  // 事务不应在 Controller 层
      @PostMapping("/approve")
      public Result approve(Long id) { }
  }
  \`\`\`

---

## BE-CFG：配置规范（§9）

### BE-CFG-01：多环境配置分离
- **严重性**: important
- **规范来源**: coding-standard.md §9.1
- **判断标准**: 使用 \`application-{profile}.yml\` 分离 dev/test/prod 配置，不在主配置中硬编码环境特定值
- **示例**:
  \`\`\`
  ✅ application.yml + application-dev.yml + application-prod.yml
  ❌ 所有配置写在 application.yml 中，通过注释切换
  \`\`\`

### BE-CFG-02：敏感信息不入库
- **严重性**: blocking
- **规范来源**: coding-standard.md §9.2
- **判断标准**: 数据库密码、API 密钥、Token 等敏感信息不出现在代码仓库中，须通过环境变量或配置中心注入

### BE-CFG-03：配置项有注释说明
- **严重性**: nit
- **规范来源**: coding-standard.md §9.3
- **判断标准**: yml/properties 中自定义配置项须有注释说明用途

---

## BE-TEST：测试规范（§10）

### BE-TEST-01：核心业务逻辑有单元测试
- **严重性**: important
- **规范来源**: coding-standard.md §10.1
- **判断标准**: Service 层核心方法须有对应的单元测试，覆盖正常流程和主要异常分支

### BE-TEST-02：测试方法命名清晰
- **严重性**: suggestion
- **规范来源**: coding-standard.md §10.2
- **判断标准**: 测试方法名体现测试意图，推荐 \`should_预期行为_when_条件\` 格式

### BE-TEST-03：测试数据独立
- **严重性**: suggestion
- **规范来源**: coding-standard.md §10.3
- **判断标准**: 测试用例不依赖外部环境或其他测试的执行顺序，数据自包含

---

## BE-SEC：安全合规（§11）

> 通用安全检查（硬编码密钥、用户输入校验、HTTPS 等）由 \`cross-cutting-review.md\` CC-SEC-* 统一覆盖。
> 本节仅保留后端特有的安全检查项。

### BE-SEC-01：SQL 注入防护
- **严重性**: blocking
- **规范来源**: coding-standard.md §11
- **判断标准**: MyBatis 中使用 \`#{}\` 参数绑定，禁止使用 \`\${}\` 拼接用户输入
- **示例**:
  \`\`\`xml
  ✅ <select id="findByName">
      SELECT * FROM claim WHERE name = #{name}
  </select>

  ❌ <select id="findByName">
      SELECT * FROM claim WHERE name = '\${name}'  <!-- SQL 注入风险 -->
  </select>
  \`\`\`

### BE-SEC-02：XSS 防护
- **严重性**: blocking
- **规范来源**: coding-standard.md §11.2
- **判断标准**: 用户输入在输出到页面前须经过转义处理；富文本内容须经过白名单过滤

### BE-SEC-03：接口鉴权
- **严重性**: blocking
- **规范来源**: coding-standard.md §11.3
- **判断标准**: 非公开接口须有权限校验（\`@PreAuthorize\`、拦截器或网关鉴权），不存在未授权可访问的敏感接口

### BE-SEC-04：敏感数据脱敏
- **严重性**: important
- **规范来源**: coding-standard.md §11.4
- **判断标准**: 日志和接口响应中的手机号、身份证号、银行卡号等须脱敏处理
- **示例**:
  \`\`\`java
  ✅ log.info("用户手机号: {}", DesensitizeUtil.mobile(phone)); // 138****5678
  ❌ log.info("用户手机号: {}", phone); // 13812345678 明文输出
  \`\`\`

### BE-SEC-05：文件上传校验
- **严重性**: important
- **规范来源**: coding-standard.md §11.5
- **判断标准**: 文件上传须校验文件类型、大小限制，存储路径不可由用户控制