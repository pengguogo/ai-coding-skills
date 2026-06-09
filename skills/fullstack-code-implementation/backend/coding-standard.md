# 编码标准

本文档定义了代码编写的标准规范，适用于所有新项目的代码编写。

## 1 编码规范

### 1.1 字符编码规范

#### 1.1.1 编码原则

- **新项目**：统一使用 UTF-8 编码格式
- **存量项目**：根据扫描的存量代码编码格式进行指定，保持与现有代码一致
- 【强制】所有源代码文件、配置文件、资源文件均应明确指定编码格式

#### 1.1.2 文件类型编码要求

| 文件类型 | 编码格式 | 说明 |
|---------|---------|------|
| Java 源文件 | UTF-8 | \`.java\` 文件 |
| 配置文件 | UTF-8 | YAML、Properties、XML 等 |
| 资源文件 | UTF-8 | SQL、JSON、文本文件等 |
| 构建工具配置 | UTF-8 | Maven/Gradle 配置文件 |

#### 1.1.3 构建工具配置

- 【强制】在 Maven/Gradle 配置中明确指定编码格式
- Maven 示例：在 \`pom.xml\` 中配置 \`<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>\`
- Gradle 示例：在 \`build.gradle\` 中配置 \`tasks.withType(JavaCompile) { options.encoding = 'UTF-8' }\`

## 2 命名规范

### 2.1 基本约定

- 【强制】代码中的命名均不能以下划线或美元符号开始或结束。
- 【强制】禁止使用拼音与英文混合，禁止使用中文命名（国际团队或特殊约定除外）。
- 【强制】类名使用 **UpperCamelCase**（大驼峰）；方法名、参数名、成员变量、局部变量使用 **lowerCamelCase**（小驼峰）。
- 【强制】常量命名**全大写**，单词间用下划线分隔，如 \`MAX_COUNT\`、\`DEFAULT_TIMEOUT_MS\`。
- 【强制】抽象类以 **Abstract** 或 **Base** 开头；异常类以 **Exception** 结尾；测试类以 **Test** 结尾。
- 【推荐】包名全小写，单词连续；多个单词连写，不按下划线分隔。

### 2.2 Java 命名规范

#### 2.2.1 类名
- 使用大驼峰（UpperCamelCase）
- 类名应该是名词或名词短语
- 示例：\`UserService\`、\`BillingController\`、\`OrderRepository\`

**类名类型约定**：

| 类型 | 约定 | 示例 |
|------|------|------|
| 普通类 / 接口 | 大驼峰，名词或名词短语 | \`UserService\`、\`OrderController\` |
| 接口实现类 | Impl 结尾 | \`UserServiceImpl\` |
| 抽象类 | Abstract / Base 开头 | \`AbstractBaseService\`、\`BaseController\` |
| 异常类 | Exception 结尾 | \`BusinessException\` |
| 测试类 | Test 结尾 | \`UserServiceTest\` |
| DTO / VO / BO / DO / PO | 后缀明确 | \`UserDTO\`、\`OrderVO\`、\`QueryBO\` |
| 枚举类 | Enum 结尾（可选） | \`OrderStatusEnum\` |
| 工具类 | Util / Utils / Helper 结尾 | \`DateUtils\`、\`JsonHelper\` |
| 常量类 | 全大写下划线常量 | \`CacheKeys\`、\`ErrorCodes\` |

- 【强制】POJO 类中布尔类型变量不要加 **is** 前缀，避免部分框架序列化时把 \`isXxx\` 解析成 \`xxx\` 导致错误。

**正确示例**：
\`\`\`java
public class User {
    private Boolean active;  // ✅ 正确
    private Boolean deleted; // ✅ 正确
}
\`\`\`

**错误示例**：
\`\`\`java
public class User {
    private Boolean isActive;  // ❌ 错误：避免 is 前缀
    private Boolean isDeleted; // ❌ 错误：避免 is 前缀
}
\`\`\`

#### 2.2.2 方法名和变量名
- 使用小驼峰（lowerCamelCase）
- 方法名：动词或动词短语，见名知意。如 \`getUserById\`、\`saveOrder\`、\`listByStatus\`。
- 成员变量、局部变量、参数：小驼峰；不与关键字、保留字冲突。
- 示例：
  - 方法：\`calculateFee()\`、\`getUserById()\`、\`createOrder()\`
  - 变量：\`userName\`、\`orderAmount\`、\`active\`

#### 2.2.3 常量
- 【强制】常量使用全大写下划线；**禁止魔法值**，必须用有意义的常量或枚举替代。
- 常量命名要能表达含义与单位（如 \`TIMEOUT_MS\`、\`MAX_RETRY_COUNT\`）。
- 示例：\`MAX_RETRY_COUNT\`、\`DEFAULT_TIMEOUT_MS\`、\`API_BASE_URL\`

#### 2.2.4 包名
- 全小写；多单词连写。推荐与模块/层级对应，如：
  - \`com.<公司/组织>.<产品>.<模块>.controller\`
  - \`com.<公司/组织>.<产品>.<模块>.service\`
  - \`com.<公司/组织>.<产品>.<模块>.dal\` / \`mapper\` / \`repository\`
  - \`com.<公司/组织>.<产品>.<模块>.domain\` / \`entity\` / \`dto\` / \`vo\`
- 示例：\`com.company.project.module.submodule\`

### 2.3 数据库命名规范

#### 2.3.1 表名
- 使用下划线命名（snake_case）
- 表名应该是名词或名词短语
- 表必须有 **COMMENT** 中文注释，且注释规范合理。
- 示例：\`user_info\`、\`order_detail\`、\`billing_record\`

#### 2.3.2 字段名
- 使用下划线命名（snake_case）
- 字段名应该是名词或名词短语
- 字段必须有 **COMMENT** 中文注释，且注释规范合理。
- 示例：\`user_name\`、\`order_amount\`、\`created_time\`

#### 2.3.3 索引名
- 使用**大写前缀** + **小写下划线**（snake_case）命名。
- 索引中字段数建议**不超过 3 个**。
- 索引名格式：\`IDX_表名_字段名\`。
- 唯一索引名格式：\`UK_表名_字段名\`。
- 示例：\`IDX_user_info_user_name\`、\`UK_user_info_email\`、\`IDX_order_detail_created_time\`

#### 2.3.4 约束名
- 除**单列主键**与**非空约束**外，所有约束（唯一、外键、检查约束）必须有明确的约束名。
- 【推荐】单列主键（如 \`id\`）可直接使用 \`PRIMARY KEY\` 关键字定义，由数据库自动命名；复合主键或有特殊需求时，建议按规范命名。
- 约束命名规范如下（大写前缀 + 小写表名/字段名）：
  - **主键约束**：\`PK_表名\`（可选）
  - **外键约束**：\`FK_子表名_子表字段名\`
  - **唯一约束**：\`UK_表名_字段名\`
  - **检查约束**：\`CK_表名_字段名\`
- 示例：\`PK_user_info\`、\`FK_order_detail_user_id\`、\`UK_user_info_email\`、\`CK_user_info_age\`

## 3 代码结构与分层

### 3.1 分层建议

- **Controller / API 层**：接收请求、参数校验、调用 Service、封装统一返回；不写业务逻辑、不直接访问持久层。
- **Service 层**：业务编排、事务边界、调用持久层与外部服务；保持单一职责，避免超大类。
- **持久层**：仅负责数据访问（CRUD、查询）；SQL 或 ORM 与业务解耦，不在持久层写业务判断。
- **领域 / 模型层**：实体、DTO、VO、枚举等；与框架、协议解耦，便于复用与测试。

### 3.2 依赖方向

- 依赖指向稳定方向：Controller → Service → 持久层；避免反向依赖与循环依赖。
- 跨模块调用通过接口；实现可替换（便于测试与扩展）。

### 3.3 包路径与资源路径约定（新项目与存量）

#### 3.3.1 总则

- **存量项目**：新增或变更的 Java 类、资源文件路径**不得机械套用**下文新项目模板。须以仓库内**现有**同类代码所在包、资源目录为基准，新类与**同模块、同分层语义**的已有文件并列。禁止单独引入与存量根包、分层命名或模块边界冲突的新路径。
- **新项目**：可采用 **§3.3.2** 四层架构推荐包后缀与 **§3.3.3** 中 Mapper XML 等资源路径；\`{模块名}\` 与业务模块一致。若与**设计文档**约定冲突，以设计文档为准。
- 文档、示例中的 \`package\` 仅作新项目说明；**存量**须使用仓库内**实际**包名。

#### 3.3.2 新项目推荐 Java 包分层（接在根包之后）

| 类型 | 包路径后缀 |
|------|------------|
| Entity | \`infrastructure.dal.entity.{模块名}\` |
| Mapper 接口 | \`infrastructure.dal.mapper.{模块名}\` |
| Domain Service | \`domainService.{模块名}\` |
| Service | \`businessLogic.service.{模块名}\` |
| Controller | \`trafficEntry.controller.{模块名}\` |
| RPC | \`trafficEntry.rpc.{模块名}\` |
| Consumer（消息） | \`trafficEntry.consumer.{模块名}\` |
| Schedule（定时任务） | \`trafficEntry.schedule.{模块名}\` |
| Facade | \`trafficEntry.facade.{类型}\` |

#### 3.3.3 MyBatis Mapper XML 等资源路径

- **新项目**：\`src/main/resources/mapper/{模块名}/\`（或团队在资源根下统一约定的等价子目录）。
- **存量项目**：与现有 Mapper XML **相同的资源根目录与子目录**（如 \`mapper/\`、\`mybatis/\` 等以仓库为准），与同类文件并列，勿新增与存量不一致的层级。

#### 3.3.4 单元测试源码路径

- 测试类放在 \`src/test/java\`，包路径与 \`src/main/java\` 中被测类**镜像**；命名与结构另见本文 **§10.3**。

#### 3.3.5 设计与日志文档约定

- 设计文档与实现阶段执行日志的**文件名与目录**可按项目实际情况灵活组织，不要求固定路径或固定文件名。
- 若涉及状态维护或执行记录，确保同一需求周期内引用一致、可追溯即可。

## 4 常量与配置

### 4.1 常量

- 【强制】禁止魔法值直接出现在代码中；使用常量或枚举。
- 常量类或枚举集中管理；按业务域或模块划分，避免单文件过大。
- 常量命名要能表达含义与单位（如 \`TIMEOUT_MS\`、\`MAX_RETRY_COUNT\`）。

**示例**：
\`\`\`java
// ❌ 错误：魔法值
if (timeout > 5000) {
    // ...
}

// ✅ 正确：使用常量
public class TimeoutConstants {
    public static final int DEFAULT_TIMEOUT_MS = 5000;
    public static final int MAX_TIMEOUT_MS = 30000;
}

if (timeout > TimeoutConstants.DEFAULT_TIMEOUT_MS) {
    // ...
}
\`\`\`

### 4.2 配置项

- 环境相关、可调参数放入配置文件或配置中心，不写死在代码中。
- 【强制】密钥、密码、Token 等敏感信息不得硬编码；使用配置中心、环境变量或密钥管理服务。
- 配置项命名建议：小写 + 点号分层，如 \`app.redis.timeout-ms\`、\`app.feign.connect-timeout\`。

## 5 代码风格规范

### 5.1 代码格式化
- 遵循 Java 官方代码风格指南和阿里巴巴 Java 开发手册
- 使用统一的代码格式化工具：Google Java Format 或 IDEA 内置格式化
- 在 IDE 中配置自动格式化，保存时自动格式化代码
- 【推荐】缩进统一 4 空格；不使用 Tab 与空格混用。
- 【推荐】单行字符数不超过 120；超长时换行并对齐。
- 【强制】左大括号不换行；右大括号换行；if / for / while 等即使单行也建议加大括号。

**示例**：
\`\`\`java
// ✅ 正确：左大括号不换行
if (condition) {
    doSomething();
}

// ❌ 错误：左大括号换行
if (condition)
{
    doSomething();
}

// ✅ 正确：单行也加大括号
if (condition) {
    doSomething();
}

// ❌ 错误：单行省略大括号（不推荐）
if (condition) doSomething();
\`\`\`

### 5.2 代码质量检查
- 使用 Checkstyle 或 SpotBugs 进行代码质量检查
- 在构建流程中集成代码质量检查
- 修复所有代码质量问题后再提交代码

### 5.3 集合与判空

- 使用 \`isEmpty()\`、\`CollectionUtils.isEmpty()\` 等判空；避免 \`list == null || list.size() == 0\` 分散书写。
- 初始化集合时建议指定初始容量，减少扩容：如 \`new ArrayList<>(size)\`。
- 【强制】在使用并发集合时，注意其线程安全语义；简单场景优先使用无锁或局部变量。

**示例**：
\`\`\`java
// ❌ 错误：分散的判空
if (list == null || list.size() == 0) {
    // ...
}

// ✅ 正确：使用工具方法
if (CollectionUtils.isEmpty(list)) {
    // ...
}

// ✅ 正确：指定初始容量
List<String> list = new ArrayList<>(expectedSize);
Map<String, Object> map = new HashMap<>(expectedSize);
\`\`\`

### 5.4 并发与事务

- 多线程场景明确共享变量的线程安全策略（锁、线程安全类、不可变对象等）。
- 事务边界放在 Service 层；只读操作可加只读事务；避免大事务与长锁。

### 5.5 代码组织
- **包结构**：按照功能模块组织包结构
- **类职责**：每个类应该有单一职责
- **方法长度**：方法长度不应超过 50 行（特殊情况可适当放宽）
- **类长度**：类长度不应超过 500 行（特殊情况可适当放宽）

## 6 注释与文档

### 6.1 类与接口

- 类、接口上建议写简要说明：职责、使用场景、注意事项。
- 公共 API、对外接口类必须写清楚用途、入参、返回值、异常或错误码。

**示例**：
\`\`\`java
/**
 * 用户服务类
 * 
 * <p>提供用户相关的业务操作，包括用户创建、查询、更新等功能。
 * 
 * <p>注意事项：
 * <ul>
 *   <li>所有操作都会记录操作日志</li>
 *   <li>删除操作为逻辑删除，不会物理删除数据</li>
 * </ul>
 * 
 * @author xxx
 * @since 1.0.0
 */
@Service
public class UserService {
    // ...
}
\`\`\`

### 6.2 方法

- 公共方法建议 JavaDoc：功能、参数、返回值、异常、示例（若复杂）。
- 复杂业务逻辑、算法、分支条件建议加注释说明意图；命名已清晰可省略。

**示例**：
\`\`\`java
/**
 * 根据用户ID获取用户信息
 * 
 * @param userId 用户ID，不能为null
 * @return 用户信息，如果用户不存在返回null
 * @throws BusinessException 当userId无效时抛出
 */
public UserVO getUserById(Long userId) {
    // ...
}
\`\`\`

### 6.3 常量与配置

- 常量、配置项须说明含义、单位、取值范围或示例；避免"魔数"仅靠名字猜。

**示例**：
\`\`\`java
/**
 * 默认超时时间（毫秒）
 * 取值范围：1000-60000
 */
public static final int DEFAULT_TIMEOUT_MS = 5000;

/**
 * 最大重试次数
 * 取值范围：1-10
 */
public static final int MAX_RETRY_COUNT = 3;
\`\`\`

### 6.4 TODO 注释

- 使用 \`// TODO: 说明\` 标记待完成的工作
- 复杂逻辑注释：对于复杂的业务逻辑，应该添加注释说明

### 6.5 AI 生成代码注释标记（AI-Generate）

- 【强制】凡由 **AI 辅助生成**或**主要由 AI 产出**的代码（含类、方法、代码块、SQL/XML 等资源），须在相应位置增加可检索的注释标记 **\`AI-Generate\`**，便于评审、审计与后续人工维护时区分人机贡献。
- **标记文本**：固定使用英文 **\`AI-Generate\`**（大小写一致），可与其他说明文字同处一行，但标记本身须完整出现，勿改写为「AI生成」「auto」等变体。
- **放置位置（按粒度选用，至少满足其一）**：
  - **新建类 / 接口**：在类/接口的 JavaDoc 首行或 \`@apiNote\` 中写明 \`AI-Generate\`；若无 JavaDoc，则在 \`class\`/\`interface\` 关键字上一行使用块注释 \`/** AI-Generate */\` 或 \`// AI-Generate\`。
  - **新增或整段替换的方法**：在方法 JavaDoc 首行或方法体第一行使用 \`// AI-Generate\`；若仅方法内局部为多行 AI 生成，可在该逻辑块**上方**单独一行注释 \`// AI-Generate\`。
  - **非 Java 文件**（如 MyBatis XML、SQL、Properties、前端脚本等）：在生成片段**上方**使用该行语法允许的注释形式写入 \`AI-Generate\`（如 XML 使用 \`<!-- AI-Generate -->\`）。
- **人工修改后**：若已对 AI 生成部分做实质性重写或审核确认，可保留 \`AI-Generate\` 并追加说明（例如 \`// AI-Generate, reviewed by xxx @ 2026-03-23\`），或删除标记（团队约定以「可追溯」为准时建议保留追加说明而非静默删除）。

**Java 示例（类）**：
\`\`\`java
/**
 * AI-Generate
 * <p>订单查询服务实现。
 */
@Service
public class OrderQueryServiceImpl implements OrderQueryService {
\`\`\`

**Java 示例（方法）**：
\`\`\`java
// AI-Generate
public BigDecimal calculateDiscount(Order order) {
    // ...
}
\`\`\`

**Java 示例（局部块）**：
\`\`\`java
public void process() {
    // AI-Generate: 以下为对账规则拼装逻辑
    String rule = buildRule();
    // ...
}
\`\`\`

## 7 Spring MVC 注解规范

### 7.1 URL 路径规范
- **必须显式指定 URL 路径**：所有 \`@GetMapping\`、\`@PostMapping\`、\`@PutMapping\`、\`@DeleteMapping\`、\`@PatchMapping\` 等注解必须显式指定 \`value\` 或 \`path\` 参数，不可省略

**正确示例**：
\`\`\`java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @PostMapping("/create")
    public Result<UserVO> createUser(@RequestBody UserCreateDTO dto) {
        // ...
    }
    
    @GetMapping("/{id}")
    public Result<UserVO> getUserById(@PathVariable Long id) {
        // ...
    }
    
    @PutMapping("/update")
    public Result<Void> updateUser(@RequestBody UserUpdateDTO dto) {
        // ...
    }
}
\`\`\`

**错误示例**：
\`\`\`java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @PostMapping  // ❌ 错误：不可省略 URL
    public Result<UserVO> createUser(@RequestBody UserCreateDTO dto) {
        // ...
    }
    
    @GetMapping  // ❌ 错误：不可省略 URL
    public Result<UserVO> getUserById(@PathVariable Long id) {
        // ...
    }
}
\`\`\`

### 7.2 RESTful API 设计
- **GET**：查询资源
- **POST**：创建资源
- **PUT**：更新资源（全量）
- **PATCH**：更新资源（部分）
- **DELETE**：删除资源

## 8 设计原则

### 8.1 依赖注入
- 使用 Spring 依赖注入（DI）管理组件依赖
- 优先使用构造函数注入
- 避免使用字段注入（Field Injection）

**示例**：
\`\`\`java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    
    // 构造函数注入
    public UserService(UserRepository userRepository, RoleRepository roleRepository) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
    }
}
\`\`\`

### 8.2 API 设计
- 遵循 RESTful 规范
- 使用统一的响应格式封装 API 响应
- 使用统一的异常处理机制

### 8.3 统一响应格式

- 对外 API 建议统一返回结构：如 \`{ code, message, data }\`；便于前端与网关统一处理。
- 成功/失败通过 code 或 status 区分；业务错误与系统错误建议分开错误码段。
- 使用统一的 Result/Response 封装 API 响应
- 响应格式应包含：状态码、消息、数据

**示例**：
\`\`\`java
public class Result<T> {
    private Integer code;
    private String message;
    private T data;
    
    public static <T> Result<T> success(T data) {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage("success");
        result.setData(data);
        return result;
    }
    
    public static <T> Result<T> error(Integer code, String message) {
        Result<T> result = new Result<>();
        result.setCode(code);
        result.setMessage(message);
        return result;
    }
}

// 错误码建议分段：
// 200: 成功
// 400-499: 客户端错误（参数错误、业务异常等）
// 500-599: 服务器错误（系统异常等）
\`\`\`

### 8.4 异常处理

#### 8.4.1 异常使用原则

- 【强制】不要捕获 Java 标准库中未定义的 RuntimeException，如 \`NullPointerException\`、\`IndexOutOfBoundsException\`；应通过预检查规避，或让调用方处理。
- 【强制】异常不要用来做流程控制；业务分支用条件判断。
- 【推荐】方法返回值可以为 null 时，必须显式注释；调用方做 null 判断。
- 业务异常使用自定义异常类（如 \`BusinessException\`），并统一错误码与消息格式，便于前端与监控处理。

**示例**：
\`\`\`java
// ❌ 错误：捕获 NPE
try {
    String name = user.getName();
} catch (NullPointerException e) {
    // ...
}

// ✅ 正确：预检查
if (user != null) {
    String name = user.getName();
}

// ❌ 错误：用异常做流程控制
try {
    return findUser(id);
} catch (NotFoundException e) {
    return createDefaultUser();
}

// ✅ 正确：用条件判断
User user = findUser(id);
if (user == null) {
    return createDefaultUser();
}
return user;
\`\`\`

#### 8.4.2 异常处理规范

- 捕获异常后需处理（日志、转换、重抛）；禁止空 catch。
- 在事务或资源操作中注意：异常抛出时事务回滚、资源释放（try-with-resources、finally）。
- 对外部调用（RPC、HTTP、MQ）做超时与异常处理；避免未捕获异常导致主流程中断，必要时降级或返回默认值。

**示例**：
\`\`\`java
// ❌ 错误：空 catch
try {
    doSomething();
} catch (Exception e) {
    // 禁止空 catch
}

// ✅ 正确：处理异常
try {
    doSomething();
} catch (Exception e) {
    log.error("操作失败", e);
    throw new BusinessException("操作失败", e);
}

// ✅ 正确：资源释放
try (Connection conn = getConnection()) {
    // 使用连接
} // 自动关闭连接

// ✅ 正确：外部调用异常处理
try {
    return externalService.call();
} catch (Exception e) {
    log.warn("外部调用失败，使用默认值", e);
    return getDefaultValue(); // 降级处理
}
\`\`\`

#### 8.4.3 统一异常处理

- 使用全局异常处理器统一处理异常
- 定义业务异常类，区分不同类型的异常
- 异常信息应该清晰、准确

**示例**：
\`\`\`java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusinessException(BusinessException e) {
        return Result.error(e.getCode(), e.getMessage());
    }
    
    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.error(500, "系统异常，请稍后重试");
    }
}
\`\`\`

### 8.5 日志打印规范

#### 8.5.1 基本要求

- 【强制】应用中不可直接使用日志系统（Log4j、Logback）中的 API，应依赖使用 SLF4J 或项目统一的日志门面。
- 【强制】日志文件推荐按日期、按大小滚动；禁止直接写 stdout 作为生产落盘方式（除容器标准输出采集外）。
- 【强制】异常信息须包含案发现场信息（如入参、关键 ID）；异常堆栈要打全，便于排查。

**示例**：
\`\`\`java
// ❌ 错误：直接使用 Log4j
import org.apache.log4j.Logger;
Logger logger = Logger.getLogger(UserService.class);

// ✅ 正确：使用 SLF4J
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
private static final Logger log = LoggerFactory.getLogger(UserService.class);

// 或使用 Lombok
@Slf4j
public class UserService {
    // ...
}
\`\`\`

#### 8.5.2 日志级别

- **error**：系统错误、需人工介入；须带上下文与堆栈。
- **warn**：可恢复异常、降级、外部调用失败但不影响主流程。
- **info**：关键业务流程节点；避免在循环或高频路径打 info。
- **debug**：排查用；生产默认关闭。

**示例**：
\`\`\`java
// ERROR：系统错误
log.error("用户创建失败: userId={}, error={}", userId, e.getMessage(), e);

// WARN：可恢复异常
log.warn("外部服务调用失败，使用缓存数据: service={}, error={}", serviceName, e.getMessage());

// INFO：关键业务流程
log.info("用户创建成功: userId={}, username={}", userId, username);

// DEBUG：排查用
log.debug("查询参数: userId={}, status={}", userId, status);
\`\`\`

#### 8.5.3 日志格式与性能

- 使用占位符，避免字符串拼接：\`log.info("userId={}, orderId={}", userId, orderId);\`。
- 避免在循环中打大量日志；集合过大时只打印 size 或摘要。

**示例**：
\`\`\`java
// ❌ 错误：字符串拼接
log.info("userId=" + userId + ", orderId=" + orderId);

// ✅ 正确：使用占位符
log.info("userId={}, orderId={}", userId, orderId);

// ❌ 错误：循环中打大量日志
for (User user : users) {
    log.info("用户: {}", user); // 如果 users 很大，会产生大量日志
}

// ✅ 正确：只打印摘要
log.info("处理用户数量: {}", users.size());
if (log.isDebugEnabled()) {
    for (User user : users) {
        log.debug("用户: {}", user);
    }
}
\`\`\`

#### 8.5.4 接口日志
所有接口（Controller、RPC、Consumer）的入参和出参必须打印日志。

**入参日志**：
- 记录请求参数、请求头信息（如需要）、请求路径、请求方法等
- 使用 \`INFO\` 级别
- 敏感信息必须脱敏处理

**出参日志**：
- 记录响应结果、响应时间、响应状态码等
- 使用 \`INFO\` 级别
- 异常使用 \`ERROR\` 级别

**示例**：
\`\`\`java
@RestController
@RequestMapping("/api/users")
@Slf4j
public class UserController {
    
    @PostMapping("/create")
    public Result<UserVO> createUser(@RequestBody UserCreateDTO dto) {
        long startTime = System.currentTimeMillis();
        log.info("创建用户接口入参: userId={}, username={}, email={}", 
            dto.getUserId(), dto.getUsername(), maskEmail(dto.getEmail()));
        
        try {
            UserVO result = userService.createUser(dto);
            long costTime = System.currentTimeMillis() - startTime;
            log.info("创建用户接口出参: userId={}, username={}, 耗时={}ms", 
                result.getUserId(), result.getUsername(), costTime);
            return Result.success(result);
        } catch (Exception e) {
            long costTime = System.currentTimeMillis() - startTime;
            log.error("创建用户接口异常: userId={}, 耗时={}ms, error={}", 
                dto.getUserId(), costTime, e.getMessage(), e);
            throw e;
        }
    }
}
\`\`\`

#### 8.5.5 外部系统调用日志
所有外部系统调用（HTTP、RPC、消息队列等）的请求和响应必须打印日志。

**请求日志**：
- 记录请求URL、请求方法、请求参数、请求头等
- 使用 \`INFO\` 级别

**响应日志**：
- 记录响应状态码、响应内容、响应时间等
- 使用 \`INFO\` 级别

**异常日志**：
- 记录调用失败时的异常信息、重试次数等
- 使用 \`ERROR\` 级别

**示例**：
\`\`\`java
@Component
@Slf4j
public class ExternalSystemClient {
    
    public ExternalResult callExternalAPI(ExternalRequest request) {
        String url = externalSystemConfig.getUrl() + "/api/endpoint";
        log.info("调用外部系统请求: url={}, param1={}, param2={}", 
            url, request.getParam1(), request.getParam2());
        
        long startTime = System.currentTimeMillis();
        try {
            ExternalResult result = httpClient.post(url, request);
            long costTime = System.currentTimeMillis() - startTime;
            log.info("调用外部系统响应: success={}, costTime={}ms", 
                result.isSuccess(), costTime);
            return result;
        } catch (Exception e) {
            long costTime = System.currentTimeMillis() - startTime;
            log.error("调用外部系统异常: url={}, costTime={}ms, error={}", 
                url, costTime, e.getMessage(), e);
            throw e;
        }
    }
}
\`\`\`

#### 8.5.6 敏感信息脱敏

- 【强制】敏感信息（证件号、手机号、账号、密钥等）必须脱敏，禁止明文输出。
密码、身份证号、银行卡号等敏感信息必须脱敏处理后再打印日志。

**示例**：
\`\`\`java
// 敏感信息脱敏工具方法
private String maskEmail(String email) {
    if (StringUtils.isBlank(email)) {
        return email;
    }
    int atIndex = email.indexOf("@");
    if (atIndex > 0) {
        return email.substring(0, Math.min(2, atIndex)) + "***" + email.substring(atIndex);
    }
    return "***";
}

private String maskPhone(String phone) {
    if (StringUtils.isBlank(phone) || phone.length() < 7) {
        return "***";
    }
    return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
}

private String maskIdCard(String idCard) {
    if (StringUtils.isBlank(idCard) || idCard.length() < 8) {
        return "***";
    }
    return idCard.substring(0, 4) + "********" + idCard.substring(idCard.length() - 4);
}
\`\`\`

#### 8.5.7 日志格式
- 使用统一的日志格式，包含时间戳、线程名、日志级别、类名、方法名等信息
- 使用结构化日志格式（如 JSON 格式）便于日志分析

### 8.6 Facade 模式
- 通过 Facade 层统一对外服务接口定义，隔离内部实现
- Facade 层定义统一的请求参数、响应格式和消息体格式

### 8.7 数据删除规范

#### 8.7.1 逻辑删除
- **所有数据删除操作必须使用逻辑删除，不得使用物理删除**
- 删除标记字段：数据库表中必须包含删除标记字段（如 \`deleted\`、\`is_deleted\`），类型为 \`boolean\` 或 \`tinyint\`，默认值为 \`false\` 或 \`0\`
- 查询过滤：所有查询操作必须自动过滤已逻辑删除的数据（可使用 MyBatis-Plus 的逻辑删除插件）
- 删除操作：执行删除操作时，更新删除标记字段为 \`true\` 或 \`1\`，并记录删除时间（\`deleted_time\`）和删除人（\`deleted_by\`）
- 恢复功能：支持逻辑删除的数据恢复功能（可选，根据业务需求）

**表结构示例**：
\`\`\`sql
CREATE TABLE user_info (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL COMMENT '用户名',
    email VARCHAR(200) NOT NULL COMMENT '邮箱',
    -- 其他字段...
    deleted BOOLEAN DEFAULT FALSE COMMENT '逻辑删除标记',
    deleted_time TIMESTAMP COMMENT '删除时间',
    deleted_by VARCHAR(100) COMMENT '删除人',
    created_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT '用户信息表';
\`\`\`

**Java 代码示例**：
\`\`\`java
// 使用 MyBatis-Plus 逻辑删除
@TableLogic
private Boolean deleted;

// 删除操作
userMapper.deleteById(userId); // 自动执行逻辑删除

// 或手动更新
UPDATE user_info 
SET deleted = TRUE, deleted_time = NOW(), deleted_by = 'admin' 
WHERE id = ?;
\`\`\`

### 8.8 数据库脚本规范

#### 8.8.1 脚本目录与文件命名
- **新项目**：数据库脚本统一放在 \`src/main/resources/db/init/\` 目录中。
- **存量项目**：以仓库内**当前已使用的脚本目录**为准，新增或变更脚本须与既有存放路径、分文件方式保持一致，勿在无关目录另起一套。
- 按表名隔离：每个表的建表语句建议单独放在一个 SQL 文件中（团队另有统一迁移工具约定时从其约定）。
- DML 脚本（数据初始化/更新）：支持批量处理，可按业务主题或日期组织。
- **文件名**：**新项目**建议 \`V{版本号}__create_{表名}.sql\`；**存量项目**遵循仓库内现有 SQL 的版本号/命名约定（如 Flyway、Liquibase 或与存量文件风格一致）。

#### 8.8.2 SQL 编写规范
- **Schema 显式指定**：所有 SQL 语句中的表名建议带上 Schema 前缀（如 \`public.table_name\`）。
- **注释要求**：SQL 文件头部及关键 DML 操作前应有业务用途说明。
- **字段对齐**：INSERT 语句建议显式列出所有目标字段，避免依赖默认顺序。
- **DML 格式**：批量 INSERT 建议采用多行对齐格式，便于人工审计与维护。

#### 8.8.3 授权语句
- 每个建表语句后必须包含授权语句
- 格式：\`GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE {表名} TO {角色名};\`
- 授权角色可根据实际环境修改

**示例**：
\`\`\`sql
-- 预置供应商信息
-- 杭州惠涵汽车配件有限公司
INSERT INTO public.pts_party
(id, party_code, party_name, party_type, is_receiving, is_supplier, status, created_by, created_at, updated_by, updated_at)
VALUES (1991422941495710011, 'YC2601000003', '杭州惠涵汽车配件有限公司', 1, true, true, 1, 'SYSTEM', now(), 'SYSTEM', now());

-- 用户表
CREATE TABLE IF NOT EXISTS public.user_info (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL CONSTRAINT UK_user_info_username UNIQUE COMMENT '用户名',
    email VARCHAR(200) NOT NULL COMMENT '邮箱',
    created_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT '用户信息表';

-- 索引
CREATE INDEX IDX_user_info_username ON public.user_info(username);
CREATE INDEX IDX_user_info_email ON public.user_info(email);

-- 授权语句（可根据实际环境修改角色名）
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_info TO app_role;
\`\`\`

## 9 配置文件规范

### 9.1 环境隔离
- 数据库、Redis 等**环境相关**的底层依赖配置必须按环境隔离，不得全部写在**默认无条件区分环境**的主配置里（与具体文件名、后缀无关）。
- **新项目（Spring Boot，YAML 约定）**：主文件 \`application.yml\` 仅包含应用名称、激活的 Profile、配置中心入口等通用项；环境差异放在 \`application-{env}.yml\`。**不得**把数据源、Redis 等直连信息堆在默认主配置中。
- **存量项目**：配置文件格式与拆分以仓库**现状**为准，常见为 **\`.properties\`**（如 \`application.properties\`、\`application-dev.properties\`）、**\`bootstrap.yml\` / \`bootstrap.properties\`**，或结合 Nacos/Apollo 等以外部配置为主；新增或修改项须落在与存量**相同类型、相同环境维度**的文件中，**勿**为统一规范而强行整体迁到 YAML 导致与既有加载顺序、团队习惯或运维脚本不一致。

### 9.2 配置文件结构

以下 **YAML 示例**面向**新项目**的典型 Spring Boot 布局；**存量项目**若使用 Properties/XML/外部配置，在同等语义下满足 §9.1 的隔离原则即可，无需改为 YAML。

#### 9.2.1 主配置文件（新项目示例：\`application.yml\`）
\`\`\`yaml
spring:
  application:
    name: {project-name}
  profiles:
    active: dev

# 其他通用配置
\`\`\`

#### 9.2.2 开发环境配置（新项目示例：\`application-dev.yml\`）
\`\`\`yaml
spring:
  datasource:
    driver-class-name: org.postgresql.Driver
    url: jdbc:postgresql://localhost:5432/{db_name}_dev
    username: postgres
    password: postgres
  redis:
    host: localhost
    port: 6379
    database: 0
    timeout: 3000ms

logging:
  level:
    root: INFO
    com.company.project: DEBUG
\`\`\`

#### 9.2.3 生产环境配置（新项目示例：\`application-prod.yml\`）
\`\`\`yaml
spring:
  datasource:
    driver-class-name: org.postgresql.Driver
    url: jdbc:postgresql://prod-db:5432/{db_name}
    username: \${DB_USERNAME}
    password: \${DB_PASSWORD}
  redis:
    host: \${REDIS_HOST}
    port: \${REDIS_PORT}
    database: 0
    timeout: 3000ms

logging:
  level:
    root: INFO
    com.company.project: INFO
\`\`\`

### 9.3 敏感信息处理
- 生产环境配置中的敏感信息（密码、密钥等）必须使用环境变量
- 不要在配置文件中硬编码敏感信息
- 使用 \`\${ENV_VAR}\` 格式引用环境变量

## 10 测试规范

### 10.1 单元测试框架
- 使用 JUnit 作为单元测试框架
- 使用 Mockito 进行 Mock 对象创建
- 使用 AssertJ 或 Hamcrest 进行断言

### 10.2 测试覆盖率要求
- 核心业务逻辑 ≥ 80%
- 关键业务逻辑必须有完整的测试用例
- 使用 JaCoCo 等工具检查测试覆盖率

### 10.3 测试编写规范

- 【推荐】核心业务、公共组件必须有单测；单测保持独立、可重复运行，不依赖外部环境与顺序。
- 【强制】必须为新增或修改的代码编写对应的单元测试
- 新增 Controller 方法时，必须编写对应的 Controller 测试
- 新增 Service 方法时，必须编写对应的 Service 测试
- 新增 Domain Service 方法时，必须编写对应的 Domain Service 测试
- 测试类命名：\`{被测试类名}Test\`，如 \`UserControllerTest\`、\`UserServiceTest\`；与主代码同包或镜像包（如 \`src/test/java\` 镜像 \`src/main/java\`）。
- 测试方法命名：能表达场景，如 \`testXxxWhenYyy\`、\`shouldReturnZzzWhenCondition\`。
- 测试文件位置：与源代码目录结构保持一致，放在 \`src/test/java\` 对应包路径下
- 测试数据避免魔法值；不使用真实敏感数据；可集中用 Builder 或常量构造。

### 10.4 测试方法
- 使用测试驱动开发（TDD）或行为驱动开发（BDD）
- 编写测试用例时，覆盖正常流程、异常流程和边界条件

### 10.5 集成测试
- 覆盖主要业务流程
- 使用 \`@SpringBootTest\` 进行集成测试
- 使用 TestContainers 进行数据库集成测试（如需要）

### 10.6 性能测试
- 定期进行性能测试和压力测试
- 使用 JMeter 或 Gatling 进行性能测试
- 记录性能测试结果，分析性能瓶颈

**示例**：
\`\`\`java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void testCreateUser() throws Exception {
        // Given
        UserCreateDTO dto = new UserCreateDTO();
        dto.setUsername("testuser");
        dto.setEmail("test@example.com");
        
        UserVO userVO = new UserVO();
        userVO.setUserId(1L);
        userVO.setUsername("testuser");
        
        when(userService.createUser(any(UserCreateDTO.class))).thenReturn(userVO);
        
        // When & Then
        mockMvc.perform(post("/api/users/create")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.username").value("testuser"));
    }
}
\`\`\`

## 11 安全与合规

- 【强制】用户输入必须做校验与过滤（长度、类型、范围、白名单）；防止注入与非法参数。
- 【强制】用户敏感数据展示与日志必须脱敏。
- 【强制】禁止将密钥、密码、Token 等写死在代码或配置文件中提交到仓库；使用配置中心或密钥管理。
- SQL 使用参数化或 ORM，禁止拼接用户输入形成 SQL。

**示例**：
\`\`\`java
// ❌ 错误：SQL 拼接
String sql = "SELECT * FROM user WHERE name = '" + userName + "'";

// ✅ 正确：参数化查询
String sql = "SELECT * FROM user WHERE name = ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, userName);

// ✅ 正确：使用 ORM
User user = userRepository.findByName(userName);
\`\`\`

## 12 代码审查规范

### 12.1 代码审查检查清单

- [ ] 命名符合规范（类、方法、变量、常量、包）；无拼音、无 is 前缀布尔字段。
- [ ] 包路径、Mapper XML 等资源路径、数据库脚本目录与命名符合 §3.3、§8.8（存量与仓库现状一致）。
- [ ] 无魔法值；常量、配置项有含义说明。
- [ ] 异常处理完整；无空 catch；业务异常统一封装。
- [ ] 日志级别与内容合适；敏感信息已脱敏。
- [ ] 注释与 JavaDoc 对公共接口、复杂逻辑、常量有说明。
- [ ] AI 生成代码已按 §6.5 标注 **AI-Generate**（类/方法/块/资源文件注释可追溯）。
- [ ] 大括号与缩进统一；集合判空与初始化合理。
- [ ] 无硬编码密钥、密码等敏感信息。
- [ ] 新增/修改点有对应单测或已在测试计划内。
- [ ] 代码是否符合代码风格规范
- [ ] 是否遵循了设计原则
- [ ] 是否有性能问题
- [ ] 是否有安全问题

### 12.2 代码审查流程
1. 提交代码前进行自检
2. 创建 Pull Request
3. 至少一名其他开发者进行代码审查
4. 根据审查意见修改代码
5. 审查通过后合并代码

## 13 使用说明

### 13.1 初始化新项目
1. 配置项目编码为 UTF-8
2. 配置代码格式化工具
3. 配置代码质量检查工具
4. 配置测试框架和覆盖率工具
5. 创建统一的响应格式和异常处理类

### 13.2 日常开发
1. 编写代码前，先了解相关规范
2. 编写代码时，遵循命名规范和代码风格规范
3. 编写代码后，运行代码质量检查工具
4. 提交代码前，运行单元测试
5. 提交代码时，添加清晰的提交信息

### 13.3 代码审查
1. 使用代码审查检查清单进行审查
2. 重点关注代码质量、安全性和性能
3. 提供建设性的审查意见
4. 及时响应审查意见并修改代码