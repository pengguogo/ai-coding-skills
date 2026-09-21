# Step 3: 后端文档扫描与生成（template，固定 4 实例）

## 元信息

- agent: code-scanner
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: doc-type
- instance-mode: fixed
- instance-source: 固定 4 个实例（backend-interface / backend-database / backend-project / backend-external-dependency）
- context-budget: 3000
- complexity-estimate: { backend-interface: 1500, backend-database: 1200, backend-project: 2000, backend-external-dependency: 800, default: 1000 }

## 参数

- input_files: [`{WORKSPACE}/code/01-scan-target.md`, `{WORKSPACE}/code/02-tech-detect.md`, `{CODE_KNOWLEDGE}/scan-plan.md`]
- input_files_subagent: [`{WORKSPACE}/code/summaries/01-scan-target.summary.md`, `{WORKSPACE}/code/summaries/02-tech-detect.summary.md`, `{CODE_KNOWLEDGE}/scan-plan.md`]
- output_file: `{WORKSPACE}/code/03-status-summary.md`
- output_file_per_instance:
  - 实例 1: `{CODE_KNOWLEDGE}/backend-interface/`（§2.0 单文件：`index.md` 全文；§2.3 分册：`index.md` 索引 + `{module}.md` 分册，见 references/backend/project-spec/backend-interface.md §2）
  - 实例 2: `{CODE_KNOWLEDGE}/backend-database/`（§2.0 单文件：`index.md` 全文；§2.3 分册：`index.md` 索引 + `{module}.md` 分册 + `er-diagram.md` / `dict-tables.md`）
  - 实例 3: `{CODE_KNOWLEDGE}/backend-project.md`
  - 实例 4: `{CODE_KNOWLEDGE}/backend-external-dependency.md`
- reference_sections:
  - 实例 1: `references/backend/project-spec/backend-interface.md`
  - 实例 2: `references/backend/project-spec/backend-database.md`
  - 实例 3: `references/backend/project-spec/backend-module.md`
  - 实例 4: `references/backend/project-spec/backend-external-dependency.md`
- script_dir: `script/`
- domain_context: |
    按 scan-plan.md 执行后端代码扫描，每个实例负责一种文档类型的扫描与生成。
    扫描流程严格遵循 unified-scan-task-template.md §2 步骤 D-F。
    实例执行顺序建议：先 interface + database，再 project（project 可引用前两者的扫描结果）。
    若实例并行执行，project 实例须独立完成扫描，在 Step 5 校验与 interface/database 的一致性。

## 全局执行约束（所有实例共享）

### 扫描执行流程（对应 §2 步骤 D）
1. 按 scan-plan.md 从上到下逐项执行
2. 脚本扫描：检测 PowerShell 环境（pwsh --version），支持则执行 .ps1，不支持则转换为 Bash/Python 后执行。脚本失败时排查重试（最多 2 轮），仍失败则切换为 AI 直接扫描，产出标准不变
3. AI 直接扫描：用 grepSearch + readCode 逐文件提取
4. 每完成一项，回写 scan-plan.md 的状态和实际产出数（精确整数）

### 合理性检查（对应 §2 步骤 E，每个扫描项执行完毕后立即检查）

| 检查项 | 判定条件 | 不通过时的动作 |
|--------|---------|--------------|
| 覆盖率 | 产出条目 / 探针命中数 < 0.80 | 逐条归因，修正后重跑 |
| 类型纯度 | 非目标类型占比 > 50% | 修改过滤规则后重跑 |
| 字段完整度 | 非空非占位字段 / 总字段 < 0.30 | 判断是项目特征还是提取 bug |
| 偏差 | 预估目标数 vs 实际产出数偏差 > 20% | 排查原因 |

修复闭环：修复最多 2 轮。2 轮后仍不通过且当前为脚本扫描 → 切换为 AI 直接扫描重做，产出标准不变。禁止以 [需人工确认] 替代未完成的修复。

### 语义补充与写入（对应 §2 步骤 F）
1. 补全空说明、解析常量标记（如 [CONST:xxx]）、继承字段补充、按模块分组
2. 条目 > 100 时按模块分批（每批 30 条目）；条目 > 500 时委托子代理
3. 写入：fsWrite 文件头 → fsAppend 分段（每段 ≤ 300 行）
4. 写入后门禁：文档条目数 vs 中间文件条目数偏差 > 5% → 阻断；空说明 > 0 → 回头补全

### [需人工确认] 约束（对应 §4）
- 禁止批量标注，必须逐条附原因
- 单份文档占比不超 20%
- 能力范围内（grepSearch 可匹配）的禁止标注

### 执行红线（对应 §5）
1. 全量列出，不得省略
2. 单次写入不超 300 行
3. Review 后删除所有 *-scan-result.md 中间文件。scan-plan.md 保留
4. 中间文件到最终文档由 LLM 逐段处理，不得用脚本批量转换
5. 写入前后必须输出门禁校验行
6. 生成/改造脚本时参考 script/ 下现有脚本的输出格式，不得自创格式
7. 不得跳过扫描执行流程和合理性检查
8. 脚本执行前须验证运行环境兼容性，不兼容时须转换为等价脚本

### 占位字段定义（附录 §A8）
以下值视为占位字段，不计入有效信息：[需人工确认]、[待补充]、TODO、TBD、N/A、-

### 多环境配置处理（附录 §A3）
- 优先读取 application.yml（基础配置）和 application-dev.yml（开发环境）
- 外部依赖的地址信息以 application.yml 为准，若使用占位符（如 ${DB_HOST}）则标注"环境变量注入"
- 不同环境的差异配置不逐一列出，仅在备注中说明"该配置因环境而异"

## 实例 1 执行指令：生成 backend-interface/

按 scan-plan.md 中接口相关扫描项执行。完整扫描规则如下：

### 接口扫描规则（12 种技术栈）

| 技术栈 | 怎么找 | 提取什么 | 参考脚本 |
|--------|--------|---------|---------|
| Spring MVC | *.java 匹配 @RestController/@Controller，排除 @ControllerAdvice/target//src/test/（同时标注 @Controller 和 @SpringBootApplication 的启动类不排除，按 backend-interface.md §1 Bootstrapper 规则处理） | HTTP 方法、URL（类级+方法级拼接）、说明。@RequestMapping 无 method 时默认按 GET 计入 | script/controller-scan.ps1 |
| Spring WebFlux | *.java 匹配 RouterFunction/@RequestMapping（WebFlux 上下文）；*.java/*.kt 匹配 coRouter | HTTP 方法、URL 路径、说明 | 无（需生成） |
| Dubbo 服务暴露 | XML <dubbo:service> 或 @DubboService 注解 | 接口全限定名、版本、分组、方法签名、入参、返回值 | script/dubbo-scan.ps1 |
| Dubbo 服务引用 | XML <dubbo:reference> 或 @DubboReference 注解 | 引用接口名、Bean ID → 归入 backend-external-dependency.md | 无 |
| Dubbo API 定义 | *-api/*-spi 模块中的 public interface | 接口全限定名、方法签名、入参、返回值（方法数 > 30 且 §2.3 分册时归入 `dubbo-api.md`） | script/dubbo-scan.ps1 |
| gRPC | *.proto 中 service 定义；*.java 匹配 extends *ImplBase 或 @GrpcService | 服务名、方法签名、请求/响应类型、流式类型 | 无（需生成） |
| WebSocket | *.java 匹配 @ServerEndpoint/WebSocketHandler/@MessageMapping；配置类中 registerWebSocketHandlers/registerStompEndpoints | 端点路径、消息类型、说明 | 无（需生成） |
| 定时任务 | *.java 匹配 @Scheduled/@XxlJob/@ElasticJobConfiguration；继承 QuartzJobBean/Job 的类 | 任务名/Cron 表达式、执行方法、说明 | 无（需生成） |
| 消息消费入口 | *.java 匹配 @RabbitListener/@KafkaListener/@RocketMQMessageListener/@JmsListener/@StreamListener；编程式消费者：实现 MessageListener/Consumer 接口或继承 *Consumer/*Listener 基类 | 监听 Topic/Queue、消费组、处理方法、说明 | 无（需生成） |
| API 网关路由 | application*.yml/application*.properties 中 spring.cloud.gateway.routes 或 zuul.routes；*.java 中 RouteLocator Bean | 路由 ID、路径谓词、目标 URI、过滤器 | 无（需生成） |
| GraphQL | *.graphqls/*.graphql schema；*.java 匹配 @QueryMapping/@MutationMapping/@SubscriptionMapping/@SchemaMapping | Query/Mutation/Subscription 名称、参数类型、返回类型 | 无（需生成） |

### 执行步骤
1. 读取 scan-plan.md 中接口相关扫描项
2. 按 scan-plan 策略执行扫描（脚本或 AI 直接扫描）
3. 注意：Dubbo 服务引用（`<dubbo:reference>` / `@DubboReference`）的探针结果虽在接口扫描注册表中，但其产出归入实例 4（backend-external-dependency.md）。本实例只记录探针命中数，不提取 Dubbo 引用的详细内容
4. 每完成一项回写 scan-plan.md 状态和实际产出数
4. 执行合理性检查（覆盖率/类型纯度/字段完整度/偏差）
5. 执行语义补充（补全空说明、解析常量标记、继承字段补充、按模块分组）
6. **判定输出模式**（§2.3）：统计入口条目总数与功能模块数，满足拆分条件则启用分册模式
7. 按 backend-interface.md 规范生成文档并写入 `backend-interface/` 目录：
   - **单文件模式**：全文写入 `backend-interface/index.md`，分段（每段 ≤ 300 行）
   - **分册模式**：`index.md` 仅含统计概要 + 模块索引表；各模块写入 `backend-interface/{module}.md`；全局入口写入 `scheduled.md` / `messaging.md` / `dubbo-api.md`（见 §2.3）
   - **禁止**在父目录生成 `backend-interface.md` 或 `backend-interface-*.md`
8. 写入后门禁校验（含分册模式专项校验，见 checkpoints/step-03-checkpoint.md）

## 实例 2 执行指令：生成 backend-database/

按 scan-plan.md 中数据模型相关扫描项执行。完整扫描规则如下：

### 提取分层原则（强制）

数据模型采用**"确定性提取（脚本） + AI 语义补全（子代理）"两层职责分离**：

| 层 | 由谁做 | 负责什么 | 特点 |
|----|--------|---------|------|
| 确定性提取层 | 脚本（entity-scan / ddl-scan / mapper-xml-scan） | 哪些是表、表名、字段名、类型、文件:行号、来源 | 可复现、可审计，出错易定位 |
| 语义补全层 | 子代理（读实体源码 + Mapper XML + DDL COMMENT + 字段名语义） | 仅补全 `[需人工确认]` 的字段/表说明 | 结合上下文，禁止改动字段名/类型/结构 |

**先脚本、后子代理**：脚本产出后先跑 DDL 合并（COMMENT 会消化一批占位），再对残留 `[需人工确认]` 派子代理，工作量最小、质量最高。

### 数据模型扫描规则（技术栈 + 脚本）

| 技术栈/来源 | 怎么找 | 提取什么 | 参考脚本 |
|--------|--------|---------|---------|
| MyBatis-Plus / JPA 实体 | *.java 匹配 @TableName/@Entity/@Table（**须真注解**；字段注释含 Javadoc、独立行 `//`、**行尾 `//`**） | 表名、字段、Java 类型、注释、来源行号 | script/entity-scan.ps1（增强版，支持 `-ProvenanceJson`/`-ModuleName`） |
| Spring Data JDBC | *.java 匹配 @Table(org.springframework.data.relational) + @Id(org.springframework.data.annotation) | 表名、字段、类型 | script/entity-scan.ps1 |
| MyBatis XML | *Mapper.xml 提取 <resultMap> | 表名、column、property、jdbcType | script/mapper-xml-scan.ps1 |
| DDL 脚本 | *.sql 中 CREATE TABLE / ALTER TABLE / COMMENT | 表名、精确列类型、约束、COMMENT 说明、版本、来源行号 | script/ddl-scan.ps1（版本回放 + COMMENT 提取 + 溯源） |
| 三源合并 | 实体 ∪ DDL（∪ Mapper XML） | 按归一化表名并集去重 + 对账报告 | script/db-merge.ps1 |
| 自定义表映射注解 | *.java 匹配含 table/tableName 属性的非标准注解 | 表名、字段映射 | 无 |
| POJO（降级场景） | model/domain/entity 目录下无 ORM 注解的类 | 类名、字段、类型、注释 | script/model-scan.ps1 |

**脚本参数约定**：
- `entity-scan.ps1 -SourceRoot <模块根> -OutputDir <输出> [-ProvenanceJson <溯源json> -ModuleName <模块名>]`
- `ddl-scan.ps1 -SourceRoot <仓库根> -OutputDir <输出> [-ProvenanceJson <溯源json>]`
- `db-merge.ps1 -EntityProvDir <各模块实体溯源目录> -DdlProvJson <ddl溯源json> -OutputDir <输出>`
- 溯源/中间产物均写入 `{WORKSPACE}/code/` 下（临时审计产物，交付后随 workspace 清理）

### DDL 扫描策略（对应 §1.1）

| 组织方式 | 扫描策略 |
|---------|---------|
| Flyway SQL | 按 V{version}__ 前缀排序，回放 CREATE TABLE + ALTER TABLE，还原最终态 |
| Liquibase XML/YAML | 解析 <changeSet> 中的 <createTable>/<addColumn>/<dropColumn>/<modifyColumn>，按 id 排序回放 |
| Liquibase SQL | 同 Flyway SQL 策略 |
| 单文件全量 | 只扫 CREATE TABLE |
| 先 DROP 再 CREATE | 取最后一个 CREATE TABLE |
| 版本目录（任意前缀） | 按目录中的版本号排序回放；**不写死项目专有前缀** |

**版本识别（通用，`ddl-scan.ps1` 自动适配）**：版本回放的排序 key 由多策略自动识别，**不得写死某项目专有的版本目录名**（如 `AIAS-CCPS<x.y.z>` 只是某项目形式）：
1. `-VersionRegex`（可选参数，捕获组1为版本串）显式指定，优先级最高——项目版本目录形式特殊时用它适配；
2. Flyway 文件名 `V<版本>__desc.sql`；
3. 通用路径多段数字（`<任意前缀><x.y[.z...]>`，如 `release-3.4.0`、`v2.1`、`PROJ-1.2.3`）；
4. 均未命中 → 版本 key 归零，退化为"路径 + 文件名字典序"回放（单文件全量/无版本组织同样可用）。
`.` 与 `_` 分隔等价，版本段数不固定（短段补 0 比较）。若项目版本形式脚本无法自动识别，Scheduler/执行者应传 `-VersionRegex` 而非改脚本硬编码。

DDL 白名单：CREATE TABLE、ALTER TABLE ADD/MODIFY/DROP COLUMN、CREATE INDEX、ALTER TABLE ADD CONSTRAINT。其余排除。

DDL 可选扫描项（附录 §A4，探针命中时纳入）：
- CREATE VIEW：记录视图名、基表、用途。在 ER 图中以虚线框表示
- CREATE PROCEDURE/CREATE FUNCTION：记录名称、参数、用途。归入 backend-project.md 的业务规则章节

### backend-database/ 产出决策树（对应 §1.2 数据源 + §2 输出模式）

**并集优先（强制，避免遗漏）**：只要同时存在实体与 DDL，须取**并集**而非取其一——单靠实体会漏掉"只有 DDL/Mapper 无 ORM 实体"的表，单靠 DDL 会漏掉"只有实体无建表脚本"的表。

```
有 ORM 实体 + 有 DDL → 实体 ∪ DDL 并集（both 表字段类型以【实体】为准；说明按 backend-database.md §0.2.1 取 DDL COMMENT 与实体注释中首个非空者；仅实体/仅 DDL 的表全部保留并标注来源）
有 ORM 实体 + 无 DDL → 实体产出（类型标 (推断)）
无 ORM + 有 DDL → DDL 产出
无 ORM + 无 DDL + 有 Mapper XML → Mapper 推断产出
无 ORM + 无 DDL + 无 Mapper + 有 POJO → 降级产出（"数据对象清单"）
以上均无 → 跳过
```

**表名归一化去重**：合并时统一小写、去 schema 前缀（`a.b`→`b`）、去引号/反引号，作为去重 key，避免同一物理表因大小写/前缀不同被算成多表。备份/临时表（`_bk`/`_bak`/`_tmp`/`_temp`/`_backup`）单列"疑似备份表"，不计入业务表并集。

### 执行步骤
1. 按产出决策树确定数据源；**存在 DDL 时一律走并集**
2. **确定性提取（脚本）**：
   - 逐模块执行 `entity-scan.ps1`（传 `-ProvenanceJson`/`-ModuleName`），得到实体表 + 字段 + 行号溯源
   - 执行 `ddl-scan.ps1`（传 `-ProvenanceJson`），按 DDL 扫描策略回放版本、提取 COMMENT + 行号溯源
   - 大型项目文件数 > 30 优先脚本；脚本失败排查重试（≤2 轮）仍失败则切 AI 直接扫描，产出标准不变
3. **三源合并 + 对账（脚本）**：执行 `db-merge.ps1`，生成 `merged-tables.json`（每表来源 entity/ddl/both + 溯源）与 `reconcile-report.md`（仅实体/仅DDL/双有/疑似备份 四清单）
4. **对账门禁**：核对 `登记表数` 与 `真注解实体类数`、DDL `CREATE TABLE` 数的差异；差异清单须逐项归因（新表/废弃表/命名不一致），不得无解释吞掉
5. 每完成一项回写 scan-plan.md 状态和实际产出数（精确整数）
6. 执行合理性检查（覆盖率/类型纯度/字段完整度/偏差）
7. **判定输出模式**（§2.3）：统计并集表总数与模块数，满足拆分条件则启用分册模式
8. 按 backend-database.md 规范生成文档并写入 `backend-database/` 目录：
   - 每张表标题下须写 `> 来源类型: entity/ddl/both` 与 `> 溯源: 文件:行号`（来自脚本溯源）
   - **字段类型优先级（强制，见 backend-database.md §0.2）**：来源含实体（both / 仅实体）→ 字段类型以**实体类型**为准；仅 DDL → 以 **DDL 类型**为准。both 表中实体未声明、仅 DDL 有的列，保留 DDL 类型。说明合并见 **§0.2.1**（两侧取有注释者，不得因一侧为空丢弃另一侧）。
   - **单文件模式**：全文写入 `backend-database/index.md`（含表结构与 ER 图），分段（每段 ≤ 300 行）
   - **分册模式**：`index.md` 仅含统计概要 + 模块索引表 + ER 摘要；各模块表结构写入 `backend-database/{module}.md`；字典表写入 `dict-tables.md`、ER 图写入 `er-diagram.md`（见 §2.3）
   - **禁止**在父目录生成 `backend-database.md` 或 `backend-database-*.md`
9. **语义补全（子代理，仅补占位）**：对文档中残留的 `[需人工确认]` 字段/表说明，派子代理读实体源码 + Mapper XML + DDL COMMENT + 字段名语义补全；**只改说明列，不动字段名/类型/结构/来源/溯源**。无法推断的保留 `[需人工确认]`。
10. **伪字段清理**：删除脚本可能残留的解析伪行（如 Java `if(...)`、`CREATE TABLE IF NOT EXISTS` 被误切为字段）；增强版 entity-scan 已在源头过滤 Java 关键字/非标识符，如仍有残留须在文档中删除该行。
11. 机读溯源 json（entity-provenance / ddl-provenance / merged-tables）留在 `{WORKSPACE}/code/` 作临时审计
12. 写入后门禁校验（含分册模式专项校验，见 checkpoints/step-03-checkpoint.md）

## 实例 3 执行指令：生成 backend-project.md

### 执行步骤
1. 读取 scan-plan.md 确认接口扫描和数据模型扫描的状态
2. 若 interface/database 实例已完成（scan-plan.md 状态为 DONE）：引用其扫描结果
3. 若 interface/database 实例未完成：独立执行必要的扫描（入口层扫描、模块结构分析），并在产出中标注 [待与 interface/database 交叉验证]
4. 按 backend-module.md 规范生成文档：
   - §2 项目目录结构（含 §2.1 分层归类）
   - §3.1 核心业务流程（代码级调用链，每条附 Mermaid 时序图或流程图）
   - §3.2 业务模块

### 入口层完整性自检（关键步骤）

> 并行模式说明：本实例独立执行入口类识别（grepSearch @RestController/@Controller/@DubboService 等），不依赖实例 1（interface）的产出。若实例 1 已完成，可交叉验证入口类清单的一致性；若未完成，以本实例独立扫描结果为准，Step 5 做最终一致性校验。

1. **根包扫描**：扫描 src/main/java 下的根包，识别所有顶层 package
2. **启动类追踪**：找到 @SpringBootApplication 标注的启动类，确认 ComponentScan 范围
3. **配置文件追踪**：读取 application*.yml 中的路由、端口、上下文路径等配置
4. **入口类识别**：汇总所有 @RestController/@Controller/@DubboService/@GrpcService/@ServerEndpoint 等入口类
5. **覆盖检查**：核心业务流程必须覆盖入口层中的所有入口类；未覆盖的入口须补充流程或标注为"非业务入口"并说明理由

### 核心业务流程覆盖要求
- 每条核心业务流程必须是代码级调用链：入口层 → 编排层 → 领域层 → 数据层
- 每条流程附带 Mermaid 时序图或流程图
- 流程必须覆盖入口层中的所有入口类（不是举例，是全量覆盖）
- Maven/Gradle 多模块项目须包含模块依赖图（Mermaid graph TB）

### 关键约束
- 分段写入（每段 ≤300 行）
- 不臆造不存在的模块或调用关系

## 实例 4 执行指令：生成 backend-external-dependency.md

按 scan-plan.md 中外部依赖相关扫描项执行。完整扫描规则如下：

### 外部依赖扫描规则（14 种依赖类型）

| 依赖类型 | 怎么找 | 提取什么 |
|---------|--------|---------|
| Dubbo 引用 | XML <dubbo:reference> / @DubboReference | 接口名、Bean ID、来源系统 |
| HTTP 客户端 | Feign: @FeignClient 注解；RestTemplate: restTemplate.getForObject/postForEntity 等；WebClient: WebClient.create(url)/.baseUrl(url) | 调用 URL、目标系统 |
| 消息队列 | Kafka/RocketMQ/RabbitMQ 配置 | Topic、Group、方向、Broker 地址、集群名 |
| 数据库 | JDBC 数据源配置 | 数据库类型、连接信息 |
| 配置中心 | Apollo/Nacos 配置 | app.id、namespace |
| 缓存 | Redis/Ignite/Memcached 配置 | 集群地址、用途 |
| 服务注册 | ZooKeeper/Consul/Eureka/Nacos 配置 | 注册中心地址、用途 |
| 文件存储 | *.java/*.yml 匹配 OSSClient/MinioClient/AmazonS3/FastDFS | 存储类型、Bucket/容器名、用途 |
| 分布式锁 | *.java 匹配 RLock/RedissonClient/@DistributedLock | 锁 Key 模式、超时配置、使用场景 |
| 分布式事务 | *.java 匹配 @GlobalTransactional/@TwoPhaseBusinessAction | 事务组、模式（AT/TCC/SAGA）、涉及服务 |
| 链路追踪 | 配置中 spring.zipkin/spring.sleuth/skywalking.agent | 采集端点、采样率 |
| 日志收集 | logback*.xml/log4j2*.xml 中远程 appender | 日志目标地址、格式 |
| 安全框架 | *.java 匹配 WebSecurityConfigurerAdapter/SecurityFilterChain/@EnableWebSecurity；Shiro 的 ShiroFilterFactoryBean | 认证方式、权限模型、安全过滤器链 |

### 多环境配置处理
- 优先读取 application.yml（基础配置）和 application-dev.yml（开发环境）
- 外部依赖的地址信息以 application.yml 为准，若使用占位符（如 ${DB_HOST}）则标注"环境变量注入"
- 不同环境的差异配置不逐一列出，仅在备注中说明"该配置因环境而异"

### 执行步骤
1. 按 scan-plan 策略执行扫描（AI 直接扫描为主）
2. 每完成一项回写 scan-plan.md 状态和实际产出数
3. 执行合理性检查
4. 按 backend-external-dependency.md 规范生成文档
5. 分段写入

## 全局关键约束
- 所有扫描项须执行合理性检查（4 项检查 + 修复闭环）
- 修复最多 2 轮，2 轮后仍不通过且为脚本扫描 → 切换为 AI 直接扫描
- 禁止以 [需人工确认] 替代未完成的修复
- 不得在文档末尾添加任何降级说明
- 删除所有 *-scan-result.md 中间文件（scan-plan.md 保留）
- 每个实例直接写入最终交付路径
- 大型项目（文件总数 > 200 或模块数 > 20）：scan-plan 按模块分组执行；**backend-interface 须按 §2.3 分册模式产出**（入口条目 > 300 或模块数 > 20 时强制拆分）；**backend-database 须按 §2.3 分册模式产出**（表总数 > 50 或模块数 > 20 时强制拆分）；ER 图按业务域拆分（每域 ≤ 30 表）；语义补充委托子代理，每个子代理处理一个模块
