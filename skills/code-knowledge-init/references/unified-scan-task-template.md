# 通用扫描任务模板

> AI 是主导者，脚本是工具。AI 对产出质量负全责，发现问题主动修复脚本并重跑。
> 详细细则见下方[附录](#附录)。

---

## 0.0 全局扫描约束

**全局排除路径**：\`target/、build/、out/、bin/、src/test/、src/it/、**/test/**、**/tests/**、.git/、.svn/、.idea/、.vscode/、.settings/、node_modules/、dist/、bower_components/、generated-sources/、generated-test-sources/、**/META-INF/\`（仅排除非 \`src/main/resources/META-INF\` 的副本）

**扫描范围白名单**：以下为各语言/框架的有效扫描目录，探针和扫描仅在白名单目录内执行：
- Java 后端：\`src/main/java/\`、\`src/main/resources/\`、\`src/main/webapp/\`
- DDL 脚本：\`db/\`、\`sql/\`、\`migration/\`、\`flyway/\`、\`liquibase/\`、\`init_script*/\`（含通配）
- 构建配置：\`pom.xml\`、\`build.gradle\`、\`build.xml\`、\`package.json\`（仅项目根及一级子模块）
- 应用配置：\`application*.yml\`、\`application*.properties\`、\`bootstrap*.yml\`、\`bootstrap*.properties\`
- 前端源码：\`src/\`（含 \`pages/\`、\`views/\`、\`components/\`、\`services/\`、\`store/\`、\`router/\`）
- 不在白名单内的目录一律跳过，不得作为探针或扫描的输入

**探针执行优化**：技术栈探测阶段先执行一次全局文件统计并缓存复用；构建配置探针一次读取 pom.xml/build.gradle 批量匹配；同类文件探针用 \`|\` 合并为一次 grepSearch。详见 [附录 §A2](#a2-构建配置探针扩展)。

**扫描内容精简原则**：
- 只扫描 \`src/main/java\`（或等价主源码目录）和 \`src/main/resources\`，不扫描测试代码
- 接口扫描只关注**对外暴露的入口**（Controller、RPC 服务端、消息消费端），不扫描内部 Service 方法
- 数据模型扫描只关注**持久化实体**（有 ORM 注解或 DDL 定义的表），不扫描纯 DTO/VO/Request/Response
- 外部依赖扫描只关注**运行时外部系统调用**，不扫描开发工具依赖（lombok、mapstruct、junit）

## 1 扫描规则注册表

LLM 探测到技术栈后，按此表确定"扫什么、怎么找、提取什么"。一个项目可能命中多条，须全部执行。语言支持与构建配置探针扩展详见 [附录 §A1-A2](#a1-语言支持说明)。

### 技术栈快速匹配

探针阶段先判断项目类型，再加载对应规则子集，减少逐行遍历：

| 项目类型 | 判断依据 | 加载的注册表子集 |
|---------|---------|----------------|
| Spring Boot 单体 | pom.xml 含 \`spring-boot-starter-web\` 且无 \`spring-cloud-starter-gateway\`/\`dubbo\` | Spring MVC + 数据模型全部 + 外部依赖全部 |
| Spring Cloud 微服务 | pom.xml 含 \`spring-cloud-starter-*\` | Spring MVC + API 网关路由 + Dubbo（若有）+ 数据模型全部 + 外部依赖全部 |
| Dubbo 服务 | pom.xml 含 \`dubbo\` 且无 \`spring-boot-starter-web\` | Dubbo 服务暴露 + Dubbo API 定义 + Dubbo 服务引用 + 数据模型全部 + 外部依赖全部 |
| 传统 SSM/SSH | pom.xml 含 \`spring-webmvc\`（非 Boot）或 build.xml 存在 | Spring MVC + MyBatis XML + 数据模型全部 + 外部依赖全部 |
| 前端项目 | package.json 存在且无 pom.xml/build.gradle | 不走本注册表，由 SKILL.md 前端路径处理 |
| 混合/未知 | 以上均不匹配 | 加载全部注册表，逐行探针 |

匹配到项目类型后，仅对"加载的注册表子集"中的行执行探针。未在子集中的行直接标记 \`SKIPPED(不在技术栈范围)\`。

### 接口扫描

| 技术栈 | 怎么找 | 提取什么 | 参考脚本 | 构建配置探针 |
|--------|--------|---------|---------|------------|
| Spring MVC | \`*.java\` 匹配 \`@RestController\`/\`@Controller\`，排除 \`@ControllerAdvice\`/\`target/\`/\`src/test/\`（同时标注 \`@Controller\` 和 \`@SpringBootApplication\` 的启动类不排除，按 \`backend-interface.md\` §1 Bootstrapper 规则处理） | HTTP 方法、URL（类级+方法级拼接）、说明。\`@RequestMapping\` 无 method 时默认按 GET 计入（详见 \`backend-interface.md\` §1.1） | \`script/controller-scan.ps1\` | pom.xml: \`spring-boot-starter-web\` / \`spring-webmvc\` |
| Spring WebFlux | \`*.java\` 匹配 \`RouterFunction\`/\`@RequestMapping\`（WebFlux 上下文）；\`*.java\`/\`*.kt\` 匹配 \`coRouter\` | HTTP 方法、URL 路径、说明 | 无（需生成） | pom.xml: \`spring-boot-starter-webflux\` / \`spring-webflux\` |
| Dubbo 服务暴露 | XML \`<dubbo:service>\` 或 \`@DubboService\` 注解 | 接口全限定名、版本、分组、方法签名、入参、返回值 | \`script/dubbo-scan.ps1\` | pom.xml: \`dubbo\` ; XML: \`<dubbo:service\` |
| Dubbo 服务引用 | XML \`<dubbo:reference>\` 或 \`@DubboReference\` 注解 | 引用接口名、Bean ID → 归入 backend-external-dependency.md | 无 | XML: \`<dubbo:reference\` |
| Dubbo API 定义 | \`*-api\`/\`*-spi\` 模块中的 \`public interface\` | 接口全限定名、方法签名、入参、返回值（接口数 > 30 时按模块拆分为独立附录文件 \`backend-interface-{module-name}.md\`） | \`script/dubbo-scan.ps1\` | 模块名含 \`-api\`/\`-spi\`/\`-facade\` |
| gRPC | \`*.proto\` 中 \`service\` 定义；\`*.java\` 匹配 \`extends *ImplBase\` 或 \`@GrpcService\` | 服务名、方法签名、请求/响应类型、流式类型 | 无（需生成） | pom.xml: \`grpc-spring-boot-starter\` / \`protobuf-java\` |
| WebSocket | \`*.java\` 匹配 \`@ServerEndpoint\`/\`WebSocketHandler\`/\`@MessageMapping\`；配置类中 \`registerWebSocketHandlers\`/\`registerStompEndpoints\` | 端点路径、消息类型、说明 | 无（需生成） | pom.xml: \`spring-boot-starter-websocket\` / \`javax.websocket-api\` |
| 定时任务 | \`*.java\` 匹配 \`@Scheduled\`/\`@XxlJob\`/\`@ElasticJobConfiguration\`；继承 \`QuartzJobBean\`/\`Job\` 的类 | 任务名/Cron 表达式、执行方法、说明 | 无（需生成） | pom.xml: \`spring-context\` / \`quartz\` / \`xxl-job-core\` / \`elastic-job\` |
| 消息消费入口 | \`*.java\` 匹配 \`@RabbitListener\`/\`@KafkaListener\`/\`@RocketMQMessageListener\`/\`@JmsListener\`/\`@StreamListener\`；编程式消费者：实现 \`MessageListener\`/\`Consumer\` 接口或继承 \`*Consumer\`/\`*Listener\` 基类 | 监听 Topic/Queue、消费组、处理方法、说明 | 无（需生成） | pom.xml: \`spring-kafka\` / \`rocketmq-spring-boot-starter\` / \`spring-boot-starter-amqp\` |
| API 网关路由 | \`application*.yml\`/\`application*.properties\` 中 \`spring.cloud.gateway.routes\` 或 \`zuul.routes\`；\`*.java\` 中 \`RouteLocator\` Bean | 路由 ID、路径谓词、目标 URI、过滤器 | 无（需生成） | pom.xml: \`spring-cloud-starter-gateway\` / \`spring-cloud-starter-netflix-zuul\` |
| GraphQL | \`*.graphqls\`/\`*.graphql\` schema；\`*.java\` 匹配 \`@QueryMapping\`/\`@MutationMapping\`/\`@SubscriptionMapping\`/\`@SchemaMapping\` | Query/Mutation/Subscription 名称、参数类型、返回类型 | 无（需生成） | pom.xml: \`spring-boot-starter-graphql\` / \`graphql-java\` |

### 数据模型扫描

| 技术栈 | 怎么找 | 提取什么 | 参考脚本 | 构建配置探针 |
|--------|--------|---------|---------|------------|
| MyBatis-Plus / JPA | \`*.java\` 匹配 \`@TableName\`/\`@Entity\`/\`@Table\` | 表名、字段、类型、注释、约束 | \`script/entity-scan.ps1\` | pom.xml: \`mybatis-plus\` / \`spring-boot-starter-data-jpa\` / \`dynamic-datasource\` / \`shardingsphere\` |
| Spring Data JDBC | \`*.java\` 匹配 \`@Table\`（\`org.springframework.data.relational\`）+ \`@Id\`（\`org.springframework.data.annotation\`） | 表名、字段、类型 | \`script/entity-scan.ps1\`（需改造） | pom.xml: \`spring-boot-starter-data-jdbc\` / \`spring-data-jdbc\` |
| MyBatis XML | \`*Mapper.xml\` 提取 \`<resultMap>\` | 表名、column、property、jdbcType | \`script/mapper-xml-scan.ps1\` | pom.xml: \`mybatis\` ; 文件: \`*Mapper.xml\` |
| DDL 脚本 | \`*.sql\` 中 \`CREATE TABLE\` | 见 §1.1 | 无（需生成） | 目录: \`db/\`/\`sql/\`/\`migration/\`/\`flyway/\` |
| 自定义表映射注解 | \`*.java\` 匹配含 \`table\`/\`tableName\` 属性的非标准注解 | 表名、字段映射 | 无 | grepSearch: \`@\\w+\\(.*table\\s*=\\s*"\` |
| POJO（降级场景） | model/domain/entity 目录下无 ORM 注解的类 | 类名、字段、类型、注释 | \`script/model-scan.ps1\` | 仅当上述均为 0 时触发 |

### 外部依赖扫描

| 依赖类型 | 怎么找 | 提取什么 | 构建配置探针 |
|---------|--------|---------|------------|
| Dubbo 引用 | XML \`<dubbo:reference>\` / \`@DubboReference\` | 接口名、Bean ID、来源系统 | 同 Dubbo 服务引用 |
| HTTP 客户端 | Feign: \`@FeignClient\` 注解；RestTemplate: \`restTemplate.getForObject\`/\`postForEntity\` 等；WebClient: \`WebClient.create(url)\`/\`.baseUrl(url)\` | 调用 URL、目标系统 | pom.xml: \`spring-web\`/\`openfeign\`/\`httpclient\` |
| 消息队列 | Kafka/RocketMQ/RabbitMQ 配置 | Topic、Group、方向、Broker 地址、集群名 | pom.xml: \`kafka\`/\`rocketmq\`/\`rabbitmq\` |
| 数据库 | JDBC 数据源配置 | 数据库类型、连接信息 | pom.xml: \`ojdbc\`/\`mysql-connector\`/\`postgresql\` |
| 配置中心 | Apollo/Nacos 配置 | app.id、namespace | pom.xml: \`apollo\`/\`nacos-config\` |
| 缓存 | Redis/Ignite/Memcached 配置 | 集群地址、用途 | pom.xml: \`redis\`/\`ignite\`/\`jedis\` |
| 服务注册 | ZooKeeper/Consul/Eureka/Nacos 配置 | 注册中心地址、用途 | pom.xml: \`zookeeper\`/\`consul\`/\`eureka\`/\`nacos-discovery\` |
| 文件存储 | \`*.java\`/\`*.yml\` 匹配 \`OSSClient\`/\`MinioClient\`/\`AmazonS3\`/\`FastDFS\` | 存储类型、Bucket/容器名、用途 | pom.xml: \`aliyun-sdk-oss\` / \`minio\` / \`aws-java-sdk-s3\` / \`fastdfs-client\` |
| 分布式锁 | \`*.java\` 匹配 \`RLock\`/\`RedissonClient\`/\`@DistributedLock\` | 锁 Key 模式、超时配置、使用场景 | pom.xml: \`redisson\` / \`redisson-spring-boot-starter\` |
| 分布式事务 | \`*.java\` 匹配 \`@GlobalTransactional\`/\`@TwoPhaseBusinessAction\` | 事务组、模式（AT/TCC/SAGA）、涉及服务 | pom.xml: \`seata-spring-boot-starter\` / \`seata-all\` |
| 链路追踪 | 配置中 \`spring.zipkin\`/\`spring.sleuth\`/\`skywalking.agent\` | 采集端点、采样率 | pom.xml: \`spring-cloud-starter-zipkin\` / \`spring-cloud-sleuth\` / \`skywalking\` |
| 日志收集 | \`logback*.xml\`/\`log4j2*.xml\` 中远程 appender | 日志目标地址、格式 | pom.xml: \`logstash-logback-encoder\` / \`log4j2-elasticsearch\` |
| 安全框架 | \`*.java\` 匹配 \`WebSecurityConfigurerAdapter\`/\`SecurityFilterChain\`/\`@EnableWebSecurity\`；Shiro 的 \`ShiroFilterFactoryBean\` | 认证方式、权限模型、安全过滤器链 | pom.xml: \`spring-boot-starter-security\` / \`spring-security-oauth2\` / \`shiro\` |

多环境配置处理详见 [附录 §A3](#a3-多环境配置处理规则)。

### 1.1 DDL 扫描策略

**DDL 路径自动发现**：探针阶段须执行 \`grepSearch\` 匹配 \`CREATE TABLE\` 关键字，从命中文件的路径中提取所有包含 \`.sql\` 文件的目录，与标准路径（\`db/\`、\`sql/\`、\`migration/\`、\`flyway/\`、\`liquibase/\`）取并集作为 DDL 扫描范围。非标准路径（如 \`init_script_tpb/\`）只要包含 \`CREATE TABLE\` 语句即纳入扫描，不得因路径不在预设列表中而跳过。

| 组织方式 | 扫描策略 |
|---------|---------|
| Flyway SQL | 按 \`V{version}__\` 前缀排序，回放 \`CREATE TABLE\` + \`ALTER TABLE\`，还原最终态 |
| Liquibase XML/YAML | 解析 \`<changeSet>\` 中的 \`<createTable>\`/\`<addColumn>\`/\`<dropColumn>\`/\`<modifyColumn>\`，按 \`id\` 排序回放 |
| Liquibase SQL | 同 Flyway SQL 策略 |
| 单文件全量 | 只扫 \`CREATE TABLE\` |
| 先 DROP 再 CREATE | 取最后一个 \`CREATE TABLE\` |

**白名单**：\`CREATE TABLE\`、\`ALTER TABLE ADD/MODIFY/DROP COLUMN\`、\`CREATE INDEX\`、\`ALTER TABLE ADD CONSTRAINT\`。其余排除。可选扫描项详见 [附录 §A4](#a4-ddl-可选扫描项)。

### 1.2 backend-database.md 产出决策树

\`\`\`
有 ORM 实体 + 有自定义注解 → ORM 为主，自定义注解补充（合并去重）
有 ORM 实体 → 标准产出（有 DDL 时交叉验证字段完整性）
无 ORM + 有 DDL → DDL 产出
无 ORM + 无 DDL + 有 Mapper XML → Mapper 推断产出
无 ORM + 无 DDL + 无 Mapper + 有 POJO → 降级产出（"数据对象清单"）
以上均无 → 跳过
\`\`\`

---

## 2 扫描执行流程

AI 探测完技术栈后，按以下 6 步顺序执行。每步只做一件事。

### 步骤 A：确定注册表子集

按 §1 技术栈快速匹配表判断项目类型，加载对应的注册表子集。未在子集中的行直接标记 \`SKIPPED(不在技术栈范围)\`。

### 步骤 B：逐行执行探针

对子集中的每一行，执行两类探针：
1. **构建配置探针**：在 pom.xml/build.gradle/build.xml 中搜索该行的"构建配置探针"列关键词。
2. **文件探针**：用 grepSearch 按该行的"怎么找"列识别标记，统计命中文件数。

探针结果处理：
- 构建配置命中 + 文件命中 > 0 → 列入 scan-plan
- 构建配置命中 + 文件命中 = 0 → 标记 \`SKIPPED(依赖存在但未使用)\`
- 构建配置未命中 → 标记 \`SKIPPED(不在技术栈范围)\`
- **网关例外**：构建配置命中 \`spring-cloud-starter-gateway\` 或 \`zuul\` 时，"API 网关路由"必须列入 scan-plan，即使同时有 Controller 接口

### 步骤 C：合并同源项并生成 scan-plan.md

1. **同源合并**：
   - Controller + HTTP 接口 → 合并为"HTTP 接口扫描"
   - ORM 实体 + POJO + Mapper XML → 合并为"数据模型扫描"（按 §1.2 决策树顺序）
   - 消息队列 + 缓存 + HTTP 客户端等 → 合并为"外部依赖扫描"
2. **选择策略**：每个 scan-plan 行项独立选择——有参考脚本且文件数 > 30 时用脚本扫描，其余用 AI 直接扫描（文件数 > 30 时每批 15 个文件）。
3. **生成 scan-plan.md**：在产出目录写入，表头为 \`| 序号 | 扫描项 | 命中规则 | 扫描范围 | 预估目标数 | 策略 | 状态 | 实际产出数 |\`。YAML front matter 见 [附录 §A5](#a5-scan-planmd-yaml-front-matter-模板)。"扫描范围"填 grepSearch 实际命中路径，不预设固定路径名。

### 步骤 D：逐项执行扫描

按 scan-plan.md 从上到下逐项执行：
1. 脚本扫描：检测 PowerShell 环境（\`pwsh --version\`），支持则执行 \`.ps1\`，不支持则转换为 Bash/Python 后执行。脚本失败时排查重试（最多 2 轮），仍失败则切换为 AI 直接扫描，产出标准不变。
2. AI 直接扫描：用 grepSearch + readCode 逐文件提取。
3. 每完成一项，回写 scan-plan.md 的状态和实际产出数（精确整数）。

**大型项目**（文件总数 > 200 或模块数 > 20）：scan-plan 按模块分组执行；\`backend-interface.md\` 按模块拆分为独立文件；\`backend-database.md\` ER 图按业务域拆分（每域 ≤ 30 表）；语义补充委托子代理，每个子代理处理一个模块。

### 步骤 E：合理性检查

每个扫描项执行完毕后，立即检查以下 4 项（不通过则修正后重检）：

| 检查项 | 判定条件 | 不通过时的动作 |
|--------|---------|--------------|
| 覆盖率 | 产出条目 / 探针命中数 < 0.80 | 逐条归因，修正后重跑 |
| 类型纯度 | 非目标类型占比 > 50% | 修改过滤规则后重跑 |
| 字段完整度 | 非空非占位字段 / 总字段 < 0.30 | 判断是项目特征还是提取 bug |
| 偏差 | 预估目标数 vs 实际产出数偏差 > 20% | 排查原因 |

修复最多 2 轮。2 轮后仍不通过且当前为脚本扫描 → 切换为 AI 直接扫描重做，产出标准不变。禁止以 \`[需人工确认]\` 替代未完成的修复。

### 步骤 F：语义补充与写入

1. 补全空说明、解析常量标记（如 \`[CONST:xxx]\`）、继承字段补充、按模块分组。
2. 条目 > 100 时按模块分批（每批 30 条目）；条目 > 500 时委托子代理。
3. 写入：\`fsWrite\` 文件头 → \`fsAppend\` 分段（每段 ≤ 300 行）。
4. 写入后门禁：文档条目数 vs 中间文件条目数偏差 > 5% → 阻断；空说明 > 0 → 回头补全。

---

## 2.5 扫描结果合理性检查

合理性检查已内置于步骤 E。详细异常模式和修复闭环规则见步骤 E 及 [附录 §A7](#a7-修复闭环详细说明)。

---

## 3 LLM 语义补充 + 写入

语义补充与写入流程已内置于 §2 步骤 F。

---

## 4 \`[需人工确认]\` 约束

- 禁止批量标注，必须逐条附原因；单份文档占比不超 20%
- 能力范围内（grepSearch 可匹配）的禁止标注

---

## 5 执行红线

1. 全量列出，不得省略。
2. 单次写入不超 300 行。
3. Review 后删除所有 \`*-scan-result.md\` 中间文件。scan-plan.md 保留。
4. 中间文件到最终文档由 LLM 逐段处理，不得用脚本批量转换。
5. 写入前后必须输出门禁校验行。
6. 生成/改造脚本时参考 \`script/\` 下现有脚本的输出格式，不得自创格式。
7. 不得跳过 §2 扫描执行流程（步骤 A-D）和 §2 步骤 E 合理性检查。
8. 脚本执行前须验证运行环境兼容性，不兼容时须转换为等价脚本。

脚本规范详见 [附录 §A9](#a9-脚本规范详细说明)。


---

## 附录

---

## A1 语言支持说明

本注册表中的 \`*.java\` 匹配规则同样适用于 \`*.kt\`（Kotlin）和 \`*.groovy\`（Groovy）文件。Kotlin 文件中的注解可能使用 \`@field:\` 或 \`@get:\` 前缀（如 \`@field:Column(name = "xxx")\`），扫描时须兼容处理。

---

## A2 构建配置探针扩展

- Maven: pom.xml 中的 \`<dependency>\` 匹配
- Gradle: build.gradle/build.gradle.kts 中的 implementation/compile 匹配
- Ant: build.xml 中的 \`<classpath>\`/\`<fileset>\` 引用的 jar 文件名匹配，或 lib/ 目录下的 jar 文件名匹配

---

## A3 多环境配置处理规则

- 优先读取 application.yml（基础配置）和 application-dev.yml（开发环境）
- 外部依赖的地址信息以 application.yml 为准，若使用占位符（如 \`\${DB_HOST}\`）则标注"环境变量注入"
- 不同环境的差异配置不逐一列出，仅在备注中说明"该配置因环境而异"

---

## A4 DDL 可选扫描项

探针命中时纳入：
- \`CREATE VIEW\`：记录视图名、基表、用途。在 ER 图中以虚线框表示
- \`CREATE PROCEDURE\`/\`CREATE FUNCTION\`：记录名称、参数、用途。归入 backend-project.md 的业务规则章节

---

## A5 scan-plan.md YAML front matter 模板

\`\`\`yaml
---
project: {项目名}
scan_date: {扫描日期时间}
git_commit: {当前 HEAD commit hash，若可获取}
scan_type: full | incremental
previous_scan: {上次 scan-plan.md 路径，增量时必填}
---
\`\`\`

---

## A6 适用度判断细则

参考脚本适用度三级判断：
- **直接用**：参考脚本的识别标记、输出格式、排除规则与目标项目完全匹配
- **改造（≤3 处）**：仅需修改 ≤3 处（如正则模式、排除路径、输出字段），核心逻辑不变
- **新生成（>3 处）**：需修改 >3 处，或核心提取逻辑需重写。新生成时须参考现有脚本的输出格式

---

## A7 修复闭环详细说明

§2 步骤 E 合理性检查的修复闭环规则：
- 脚本扫描：最多 2 轮修复脚本。2 轮后仍未通过 → 切换为 AI 直接扫描（grepSearch + readCode 逐文件提取），不视为降级
- AI 直接扫描：产出须通过步骤 E 全部合理性检查，不通过则继续修正产出直到通过
- 不得以 \`[需人工确认]\` 替代未完成的修复
- 不得用 \`[需人工确认]\` 规避可修复异常
- 不得添加任何"降级说明"或"需人工确认完整性"标注

---

## A8 占位字段定义

以下值视为占位字段，不计入有效信息：
- \`[需人工确认]\`、\`[待补充]\`
- \`TODO\`、\`TBD\`
- \`N/A\`、\`-\`

信息荒漠判定中"非空非占位字段"即排除以上值后的字段。

---

## A9 脚本规范详细说明

- 所有脚本须输出统一的中间格式（Markdown 表格），表头由注册表"提取什么"列定义
- 新增脚本须在 script/ 目录下同时提供 .ps1 和 .sh 版本（或由 AI 在执行时按需转换）
- 脚本须支持 \`--dry-run\` 参数，仅输出将要扫描的文件列表而不执行提取
- 脚本须支持 \`--output\` 参数指定输出文件路径