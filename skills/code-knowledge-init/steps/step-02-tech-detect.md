# Step 2: 识别项目属性 + 技术栈探测 + 注册表探针 + scan-plan 生成

## 元信息

- agent: tech-detector
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1

## Summary 配置

- output: `{WORKSPACE}/code/summaries/02-tech-detect.summary.md`
- must-include:
  - 项目属性判断结果（前端/后端/一体化/移动端/跨端/小程序）
  - 技术栈清单（语言+框架+ORM+构建工具）
  - 项目类型匹配结果（Spring Boot 单体/Spring Cloud 微服务/Dubbo 服务/传统 SSM/SSH/前端项目/Android 客户端/鸿蒙客户端/iOS 客户端/跨端-Flutter/跨端-ReactNative/小程序/混合未知）
  - 注册表子集命中清单（扫描项+命中规则+预估目标数+策略）
  - scan-plan 摘要（扫描项数+总预估目标数+脚本扫描项数+AI扫描项数）
  - 脚本环境检测结果（PowerShell 可用性）
  - DDL 路径发现结果
- must-exclude:
  - 探针执行的详细过程
  - 构建配置文件的原始内容
- max-length: 1000

## 参数

- input_files: [`{WORKSPACE}/code/01-scan-target.md`]
- input_files_subagent: [`{WORKSPACE}/code/summaries/01-scan-target.summary.md`]
- output_file: `{WORKSPACE}/code/02-tech-detect.md`
- reference_sections: [`references/unified-scan-task-template.md`]
- scan_registry: `references/unified-scan-task-template.md#扫描规则注册表`
- domain_context: |
    对选定的扫描目标执行三阶段探测：
    1. 识别项目属性（前端 Web / 后端 / 一体化 / Android·鸿蒙·iOS / 跨端-Flutter·ReactNative / 小程序）
    2. 技术栈探测与注册表探针（按 §1 逐行执行）
    3. 生成 scan-plan.md（同源合并+策略选择）

## 执行指令

### 阶段 A：识别项目属性

按以下**优先级**判定（命中更高优先级后，仍可标注同仓其他工程，但主类型取最高命中）：

1. **Android 客户端**：存在 `AndroidManifest.xml`，且存在 `settings.gradle(.kts)` 或 Android Gradle Plugin（`com.android.application` / `com.android.library`）；源码常见于 `app/src/main/java|kotlin/`、`res/`、`res/navigation/`
2. **鸿蒙客户端**：`build-profile.json5` / `oh-package.json5` / `module.json5` / `entry/src/main/ets/` / `src/main/ets/`
3. **iOS 客户端**：`.xcodeproj` / `.xcworkspace` / `Package.swift` / `Podfile` / `Cartfile` / `Info.plist` / `Assets.xcassets` / `*.swift` / `*.m` / `*.mm`
4. **跨端-Flutter**：`pubspec.yaml` 含 `flutter` 依赖
5. **跨端-ReactNative**：`package.json` 含 `react-native`，或存在 `android/`+`ios/` 且 JS/TS 入口为 RN
6. **小程序**：`project.config.json`（微信）/ 类 `app.json`+pages 结构，或 `package.json` 含 `taro`/`@dcloudio/uni-app` 等
7. **现代前端（Web）**：`package.json` + 前端构建工具（Webpack/Vite/Rollup 等）+ 页面与组件目录 + Vue/React/Angular 等（且非上述跨端/小程序主类型）
8. **传统前端特征（一体化）**：无 `package.json` 的模板引擎（`.jsp/.ftl/.html/.vm` 等）与静态资源目录（`webapp/`、`static/`、`resources/static/`、`resources/templates/` 等）
9. **后端特征**：`pom.xml`、`build.gradle*`、`build.xml`、`src/main/java`、`application*.yml`、后端分层目录等

**后端入口（用于区分 Android Gradle 与后端 Gradle）**：仅当存在以下之一时视为「有后端入口」——`src/main/java|kotlin` 中命中 `@SpringBootApplication` / `@RestController` / `@Controller` / `@DubboService` 等，或明确后端模块（如 `*-web`/`*-service` 含 Spring 依赖）。**仅有** `app/src/main` 的 Android 工程不算后端入口。

**一体化 vs 分离**：同一工程同时承载页面与接口且没有清晰独立的前后端工程边界时为一体化项目；移动端客户端与后端服务同仓但工程边界清晰时按分离项目处理，客户端工程进入前端路径。

读取 XML 格式构建配置文件时，须先过滤注释再解析。

### 阶段 B：技术栈快速匹配（对应 unified-scan-task-template.md §1 技术栈快速匹配表）

按以下表判断项目类型，加载对应注册表子集：

| 项目类型 | 判断依据 | 加载的注册表子集 |
|---------|---------|----------------|
| Spring Boot 单体 | pom.xml 含 spring-boot-starter-web 且无 spring-cloud-starter-gateway/dubbo | Spring MVC + 数据模型全部 + 外部依赖全部 |
| Spring Cloud 微服务 | pom.xml 含 spring-cloud-starter-* | Spring MVC + API 网关路由 + Dubbo（若有）+ 数据模型全部 + 外部依赖全部 |
| Dubbo 服务 | pom.xml 含 dubbo 且无 spring-boot-starter-web | Dubbo 服务暴露 + Dubbo API 定义 + Dubbo 服务引用 + 数据模型全部 + 外部依赖全部 |
| 传统 SSM/SSH | pom.xml 含 spring-webmvc（非 Boot）或 build.xml 存在 | Spring MVC + MyBatis XML + 数据模型全部 + 外部依赖全部 |
| 前端项目 | package.json 存在且无 pom.xml/build.gradle | 不走本注册表，由 SKILL.md 前端路径处理 |
| Android 客户端 | `settings.gradle(.kts)` / Android Gradle Plugin / `AndroidManifest.xml` / `app/src/main/` 命中，且无后端入口 | 不走本注册表，由 SKILL.md 前端路径处理 |
| 鸿蒙客户端 | `build-profile.json5` / `oh-package.json5` / `module.json5` / `entry/src/main/ets/` 命中，且无后端入口 | 不走本注册表，由 SKILL.md 前端路径处理 |
| iOS 客户端 | `.xcodeproj` / `.xcworkspace` / `Package.swift` / `Podfile` / `Info.plist` 命中，且无后端入口 | 不走本注册表，由 SKILL.md 前端路径处理 |
| 跨端-Flutter | `pubspec.yaml` 含 `flutter` | 不走本注册表，由 SKILL.md 前端路径处理 |
| 跨端-ReactNative | `package.json` 含 `react-native`，或 RN 工程结构（JS/TS 入口 + `android/`/`ios/`） | 不走本注册表，由 SKILL.md 前端路径处理 |
| 小程序 | `project.config.json` / `app.json`+pages，或 `package.json` 含 `taro`/`@dcloudio/uni-app` 等 | 不走本注册表，由 SKILL.md 前端路径处理 |
| 混合/未知 | 以上均不匹配 | 加载全部注册表，逐行探针 |

匹配到项目类型后，仅对"加载的注册表子集"中的行执行探针。未在子集中的行直接标记 SKIPPED(不在技术栈范围)。

### 阶段 C：逐行执行探针（对应 unified-scan-task-template.md §2 步骤 A-B）

**全局扫描约束**（必须在探针执行前应用）：
- 全局排除路径：target/、build/、out/、bin/、src/test/、src/it/、**/test/**、**/tests/**、.git/、.svn/、.idea/、.vscode/、.settings/、node_modules/、dist/、bower_components/、generated-sources/、generated-test-sources/、**/META-INF/（仅排除非 src/main/resources/META-INF 的副本）
- 扫描范围白名单：Java 后端 src/main/java/ + src/main/resources/ + src/main/webapp/；DDL 脚本 db/ + sql/ + migration/ + flyway/ + liquibase/ + init_script*/；构建配置仅项目根及一级子模块；应用配置 application*.yml/properties + bootstrap*.yml/properties；Web 前端源码 src/（含 pages/views/components/services/store/router）；移动端源码 Android `src/main/java/`、`src/main/kotlin/`、`src/main/cpp/`、`src/main/jni/`、`res/`、`assets/`、`AndroidManifest.xml`；鸿蒙 `src/main/ets/`、`src/main/cpp/`、`resources/`、`module.json5`；iOS 工程源码目录与 .xcodeproj/.xcworkspace/Package.swift/Podfile/Info.plist/Assets.xcassets/Storyboard/XIB；Flutter `lib/`；小程序 `pages/`/`components/` 与对应配置
- 不在白名单内的目录一律跳过

**探针执行优化**：
- 先执行一次全局文件统计并缓存复用
- 构建配置探针一次读取 pom.xml/build.gradle 批量匹配
- 同类文件探针用 `|` 合并为一次 grepSearch

**扫描内容精简原则**：
- 只扫描 src/main/java（或等价主源码目录）和 src/main/resources，不扫描测试代码
- 接口扫描只关注对外暴露的入口（Controller、RPC 服务端、消息消费端），不扫描内部 Service 方法
- 数据模型扫描只关注持久化实体（有 ORM 注解或 DDL 定义的表），不扫描纯 DTO/VO/Request/Response
- 外部依赖扫描只关注运行时外部系统调用，不扫描开发工具依赖（lombok、mapstruct、junit）

对注册表子集中的每一行，执行两类探针：

**接口扫描探针（12 行）**：

| 技术栈 | 构建配置探针关键词 | 文件探针 grepSearch 模式 |
|--------|------------------|------------------------|
| Spring MVC | pom.xml: spring-boot-starter-web / spring-webmvc | *.java 匹配 @RestController/@Controller，排除 @ControllerAdvice/target//src/test/ |
| Spring WebFlux | pom.xml: spring-boot-starter-webflux / spring-webflux | *.java 匹配 RouterFunction/@RequestMapping（WebFlux 上下文）；*.java/*.kt 匹配 coRouter |
| Dubbo 服务暴露 | pom.xml: dubbo ; XML: <dubbo:service | XML <dubbo:service> 或 @DubboService 注解 |
| Dubbo 服务引用 | XML: <dubbo:reference | XML <dubbo:reference> 或 @DubboReference 注解 |
| Dubbo API 定义 | 模块名含 -api/-spi/-facade | *-api/*-spi 模块中的 public interface |
| gRPC | pom.xml: grpc-spring-boot-starter / protobuf-java | *.proto 中 service 定义；*.java 匹配 extends *ImplBase 或 @GrpcService |
| WebSocket | pom.xml: spring-boot-starter-websocket / javax.websocket-api | *.java 匹配 @ServerEndpoint/WebSocketHandler/@MessageMapping |
| 定时任务 | pom.xml: spring-context / quartz / xxl-job-core / elastic-job | *.java 匹配 @Scheduled/@XxlJob/@ElasticJobConfiguration；继承 QuartzJobBean/Job |
| 消息消费入口 | pom.xml: spring-kafka / rocketmq-spring-boot-starter / spring-boot-starter-amqp | *.java 匹配 @RabbitListener/@KafkaListener/@RocketMQMessageListener/@JmsListener/@StreamListener；编程式消费者 |
| API 网关路由 | pom.xml: spring-cloud-starter-gateway / spring-cloud-starter-netflix-zuul | application*.yml 中 spring.cloud.gateway.routes 或 zuul.routes；*.java 中 RouteLocator Bean |
| GraphQL | pom.xml: spring-boot-starter-graphql / graphql-java | *.graphqls/*.graphql schema；*.java 匹配 @QueryMapping/@MutationMapping/@SubscriptionMapping/@SchemaMapping |

**数据模型扫描探针（6 行）**：

| 技术栈 | 构建配置探针关键词 | 文件探针 grepSearch 模式 |
|--------|------------------|------------------------|
| MyBatis-Plus / JPA | pom.xml: mybatis-plus / spring-boot-starter-data-jpa / dynamic-datasource / shardingsphere | *.java 匹配 @TableName/@Entity/@Table |
| Spring Data JDBC | pom.xml: spring-boot-starter-data-jdbc / spring-data-jdbc | *.java 匹配 @Table(org.springframework.data.relational) + @Id(org.springframework.data.annotation) |
| MyBatis XML | pom.xml: mybatis ; 文件: *Mapper.xml | *Mapper.xml 提取 <resultMap> |
| DDL 脚本 | 目录: db//sql//migration//flyway/ | *.sql 中 CREATE TABLE |
| 自定义表映射注解 | grepSearch: @\w+\(.*table\s*=\s*" | *.java 匹配含 table/tableName 属性的非标准注解 |
| POJO（降级场景） | 仅当上述均为 0 时触发 | model/domain/entity 目录下无 ORM 注解的类 |

**外部依赖扫描探针（14 行）**：

| 依赖类型 | 构建配置探针关键词 | 文件探针 grepSearch 模式 |
|---------|------------------|------------------------|
| Dubbo 引用 | 同 Dubbo 服务引用 | XML <dubbo:reference> / @DubboReference |
| HTTP 客户端 | pom.xml: spring-web/openfeign/httpclient | @FeignClient；restTemplate.getForObject/postForEntity；WebClient.create(url)/.baseUrl(url) |
| 消息队列 | pom.xml: kafka/rocketmq/rabbitmq | Kafka/RocketMQ/RabbitMQ 配置 |
| 数据库 | pom.xml: ojdbc/mysql-connector/postgresql | JDBC 数据源配置 |
| 配置中心 | pom.xml: apollo/nacos-config | Apollo/Nacos 配置 |
| 缓存 | pom.xml: redis/ignite/jedis | Redis/Ignite/Memcached 配置 |
| 服务注册 | pom.xml: zookeeper/consul/eureka/nacos-discovery | ZooKeeper/Consul/Eureka/Nacos 配置 |
| 文件存储 | pom.xml: aliyun-sdk-oss / minio / aws-java-sdk-s3 / fastdfs-client | *.java/*.yml 匹配 OSSClient/MinioClient/AmazonS3/FastDFS |
| 分布式锁 | pom.xml: redisson / redisson-spring-boot-starter | *.java 匹配 RLock/RedissonClient/@DistributedLock |
| 分布式事务 | pom.xml: seata-spring-boot-starter / seata-all | *.java 匹配 @GlobalTransactional/@TwoPhaseBusinessAction |
| 链路追踪 | pom.xml: spring-cloud-starter-zipkin / spring-cloud-sleuth / skywalking | 配置中 spring.zipkin/spring.sleuth/skywalking.agent |
| 日志收集 | pom.xml: logstash-logback-encoder / log4j2-elasticsearch | logback*.xml/log4j2*.xml 中远程 appender |
| 安全框架 | pom.xml: spring-boot-starter-security / spring-security-oauth2 / shiro | *.java 匹配 WebSecurityConfigurerAdapter/SecurityFilterChain/@EnableWebSecurity；Shiro 的 ShiroFilterFactoryBean |

**DDL 路径自动发现**（对应 §1.1）：
- 探针阶段须执行 grepSearch 匹配 CREATE TABLE 关键字
- 从命中文件的路径中提取所有包含 .sql 文件的目录
- 与标准路径（db/、sql/、migration/、flyway/、liquibase/）取并集作为 DDL 扫描范围
- 非标准路径（如 init_script_tpb/）只要包含 CREATE TABLE 语句即纳入扫描，不得因路径不在预设列表中而跳过

**探针结果处理**：
- 构建配置命中 + 文件命中 > 0 → 列入 scan-plan
- 构建配置命中 + 文件命中 = 0 → 标记 SKIPPED(依赖存在但未使用)
- 构建配置未命中 → 标记 SKIPPED(不在技术栈范围)
- 网关例外：构建配置命中 spring-cloud-starter-gateway 或 zuul 时，"API 网关路由"必须列入 scan-plan，即使同时有 Controller 接口

**语言支持扩展**（附录 §A1）：
- *.java 匹配规则同样适用于 *.kt（Kotlin）和 *.groovy（Groovy）文件
- Kotlin 文件中的注解可能使用 @field: 或 @get: 前缀，扫描时须兼容处理

**构建配置探针扩展**（附录 §A2）：
- Maven: pom.xml 中的 <dependency> 匹配
- Gradle: build.gradle/build.gradle.kts 中的 implementation/compile 匹配
- Ant: build.xml 中的 <classpath>/<fileset> 引用的 jar 文件名匹配，或 lib/ 目录下的 jar 文件名匹配

### 阶段 D：同源合并与 scan-plan 生成（对应 §2 步骤 C）

1. **同源合并**：
   - Controller + HTTP 接口 → 合并为"HTTP 接口扫描"
   - ORM 实体 + POJO + Mapper XML → 合并为"数据模型扫描"（按 §1.2 决策树顺序）
   - 消息队列 + 缓存 + HTTP 客户端等 → 合并为"外部依赖扫描"
2. **策略选择**：每个 scan-plan 行项独立选择——有参考脚本且文件数 > 30 时用脚本扫描，其余用 AI 直接扫描（文件数 > 30 时每批 15 个文件）
3. **脚本环境检测**：执行 pwsh --version 检测 PowerShell 可用性；若 shell 工具不可用，所有脚本扫描项标记为 AI 直接扫描
4. **生成 scan-plan.md**：在产出目录写入，表头为 `| 序号 | 扫描项 | 命中规则 | 扫描范围 | 预估目标数 | 策略 | 状态 | 实际产出数 |`。"扫描范围"填 grepSearch 实际命中路径，不预设固定路径名
5. **YAML front matter**：
   ```yaml
   ---
   project: {项目名}
   scan_date: {扫描日期时间}
   git_commit: {当前 HEAD commit hash，若可获取}
   scan_type: full | incremental
   previous_scan: {上次 scan-plan.md 路径，增量时必填}
   ---
   ```
6. **大型项目策略**（文件总数 > 200 或模块数 > 20）：scan-plan 按模块分组执行；backend-interface 须按 references/backend/project-spec/backend-interface.md §2.3 分册模式产出；backend-database 须按 references/backend/project-spec/backend-database.md §2.3 分册模式产出；ER 图按业务域拆分（每域 ≤ 30 表）

### 产出格式

```markdown
# 项目识别与扫描计划

## 1. 项目属性
- 项目类型：[前端/后端/一体化/移动端/跨端/小程序]
- 判断依据：[...]

## 2. 技术栈
| 维度 | 值 |
|------|---|
| 语言 | [Java/Kotlin/...] |
| 框架 | [Spring Boot/...] |
| ORM | [MyBatis-Plus/JPA/...]（前端项目填「不适用」） |
| 构建工具 | [Maven/Gradle/Ant/Vite/Hvigor/Xcode/SPM/CocoaPods/Flutter] |
| 项目类型匹配 | [Spring Boot 单体/.../前端项目/Android 客户端/鸿蒙客户端/iOS 客户端/跨端-Flutter/跨端-ReactNative/小程序/...] |

## 3. 注册表探针结果
| 注册表行 | 构建配置探针 | 文件探针 | 命中文件数 | 状态 |
|---------|------------|---------|-----------|------|

## 4. DDL 路径发现
| 路径 | 来源 | CREATE TABLE 数 |
|------|------|----------------|

## 5. scan-plan 摘要
- 扫描项数：[N]
- 总预估目标数：[N]
- 脚本扫描项数：[N]
- AI 扫描项数：[N]
- 脚本环境：[PowerShell 可用/不可用，需转换为 Bash]

## 6. 待确认清单
| 序号 | 问题 | 影响范围 |
|------|------|---------|
```

### 增量扫描判断（在阶段 A 之前执行）

若产出目录中已存在 scan-plan.md：
1. 读取已有 scan-plan.md 的 YAML front matter（git_commit、scan_date）
2. 判断增量条件：
   - 构建配置变更 → 全量重新执行（scan_type: full）。按类型检查：后端 pom.xml/build.gradle*；Web/跨端-RN package.json 及锁文件；Android build.gradle(.kts)/libs.versions.toml；鸿蒙 oh-package.json5/build-profile.json5；iOS Podfile.lock/Package.resolved；Flutter pubspec.yaml/pubspec.lock；小程序 project.config.json / app.json / 对应 package.json
   - 文件数量变更（探针命中文件数与 scan-plan.md 记录偏差 > 20%）→ 重新执行该扫描项
   - 文件内容变更（若可获取 `git diff --name-only {last_scan_commit}`）→ 仅重新扫描变更文件所属的扫描项
   - 无法判断时 → 全量重新执行
3. 增量模式下 scan-plan.md 的 YAML front matter 中 scan_type 设为 incremental，previous_scan 填上次路径
4. 未变化的扫描项保留历史状态和实际产出数，不重新执行

### 关键约束
- 技术栈信息必须来自实际构建配置文件，不得凭印象判断
- 策略选择必须基于实际文件统计
- 前端项目只进入前端路径；Android、鸿蒙、iOS 客户端、跨端-Flutter / 跨端-ReactNative、小程序均视为前端特征并进入前端路径；后端项目只进入后端路径；一体化项目同时进入前后端路径
- scan-plan.md 同时写入 `{CODE_KNOWLEDGE}/scan-plan.md`（Init 解析路径，禁止新建 ocspec-*）
- 注册表子集中的每一行都必须有明确的探针结果（命中/SKIPPED），不得遗漏
