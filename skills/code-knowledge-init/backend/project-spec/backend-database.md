# 数据模型

本文档是项目初始化标准中涉及的数据模型设计相关内容。

**强制执行扫描任务模板**：生成 \`backend-database.md\` 时，**必须**按 [unified-scan-task-template.md](../../unified-scan-task-template.md) 任务模板中的数据模型扫描注册表执行扫描流程。**不得**跳过扫描步骤直接生成数据模型文档。

---

## 1 数据模型设计

数据模型设计涵盖表结构设计、表关系（ER 图）等，与领域模型对应，支撑持久化与查询。

### 1.1 表结构设计

列出各业务模块涉及的数据表，说明表名、说明、主要字段及约束。

**全量表展示（必须遵循）**：
- 表结构章节须**全量展示**所有识别到的表，不得只列出部分表或示例表。
- 识别范围：所有带 \`@TableName\`（MyBatis-Plus）或 \`@Table\` / \`@Entity\`（JPA/Hibernate）的实体类对应的表，或 DDL 中出现的表（以项目实际扫描为准），**全部**纳入文档并逐表输出字段表。
- 文档末尾说明中须注明“扫描到表约 N 张（全量展示）”。

**多数据源处理**：
- 若项目使用 \`dynamic-datasource\`（\`@DS\` 注解）或手动配置多 DataSource，须在表结构中标注数据源归属（如"数据源: master"/"数据源: slave"）
- 若项目使用 ShardingSphere 分表，仅记录逻辑表名（如 \`t_order\`），在备注中说明分表规则（如"按 user_id 取模分 16 表"）
- ER 图中跨数据源的表关系须用虚线标注"跨库关联"

**无集中式 DDL 时的补充数据来源**（集中式 DDL 指项目根目录或专用目录（如 \`db/\`、\`sql/\`、\`migration/\`、\`flyway/\`、\`liquibase/\`）下统一存放的建表脚本。散落在各模块 \`resources/\` 下的 SQL 文件也视为集中式 DDL，只要其路径可通过 grepSearch 统一匹配）：
- 若仓库中**未发现集中式建表脚本目录**（如 \`db/migration\`、\`sql/ddl\`、\`**/*.sql\` 等，以项目实际路径为准），则须从以下来源**补充表与 ER 信息**，仍保证全量表展示与表关系说明：
  - **实体别名包（MyBatis/MyBatis-Plus）**：从 MyBatis/MyBatis-Plus 配置中读取 \`typeAliasesPackage\`（如 \`ocss.cms.service.entity\`），扫描该包下所有实体类；通过 \`@TableName\`、\`@TableId\`、\`@TableField\` 及字段类型推断表名与列信息，用于表结构及字段表。
  - **JPA 实体扫描**：扫描带 \`@Entity\` 或 \`@Table\` 注解的实体类（可从 \`@EntityScan\` 配置的包路径或 \`persistence.xml\` 中确定扫描范围，若无显式配置则扫描主包及子包下所有 \`@Entity\` 类）；通过 \`@Table(name=...)\` 推断表名（无 \`@Table\` 时按类名转下划线推断），\`@Id\` / \`@EmbeddedId\` 推断主键，\`@Column(name=...)\` 推断列名，\`@JoinColumn\` / \`@ManyToOne\` / \`@OneToMany\` 等推断表间关系，用于表结构、字段表及 ER 图。
  - **Mapper XML**：扫描项目中实际配置的 mapper 路径，从 **SQL 片段**（\`<select>\`/\`<insert>\`/\`<update>\`/\`<delete>\` 中的表名与列）、**ResultMap**（\`<resultMap>\` 的 \`type\` 与列映射）、以及**条件拼接**（\`<if>\`/\`<where>\` 中出现的列名）中提取表名与列名，用于补全表列表、字段列表；并根据 SQL 中的多表关联（JOIN、子查询引用）推断表间关系，用于 ER 图与表关系说明。
- 合并策略：以实体 + DDL（若存在）为主表与字段来源；Mapper XML（MyBatis 项目）或 JPA 关系注解（JPA 项目）用于补全 DDL 中未出现的表/列，以及补充 ER 关系；同一表多来源时以 DDL 为准，无 DDL 时以实体 + Mapper/JPA 注解推断结果为准，并在说明中注明“部分表/关系由实体与 Mapper XML / JPA 注解推断”。

**回填与判定规则（必须遵循）**：
- **字段映射**：实体字段与数据库列名按以下优先级映射：
  - MyBatis-Plus：\`@TableId(value=...)\` / \`@TableField(value=...)\` > 驼峰转下划线（如 \`dateCreated -> date_created\`）。
  - JPA：\`@Column(name=...)\` > \`@JoinColumn(name=...)\` > 驼峰转下划线。
- **忽略字段**：\`@TableField(exist = false)\`（MyBatis-Plus）或 \`@Transient\`（JPA）标注的字段不进入表结构文档。
- **必填判定**：仅当 DDL 中显式声明 \`NOT NULL\` 时标记为 \`是\`；无 DDL 时可回退到 JPA \`@Column(nullable = false)\` 标记为 \`是\`；均未显式声明时一律标记为 \`否\`。
- **默认值判定**：优先取 DDL 中 \`DEFAULT\` 值；无 \`DEFAULT\` 时标记为 \`[无默认值]\`。
- **说明判定**：字段说明优先使用 \`COMMENT ON COLUMN\`；无列注释时回退到实体字段注释/Javadoc。若字段注释/Javadoc 仅为字段名本身、英文标识符、驼峰/下划线命名，或不能形成自然中文说明，则不得直接原样输出。此时"说明"必须基于字段名语义拆分并翻译为中文业务说明（如 \`createTime -> 创建时间\`、\`userName -> 用户名称\`、\`isDeleted -> 是否删除\`、\`remark -> 备注\`、\`application_id -> 应用ID\`、\`created_by -> 由创建\`）；仅当结合上下文仍无法判断语义时，"说明"统一输出 \`[需人工确认]\`，不得输出英文、拼音、下划线的"说明"，严禁省略"说明"。
- **表说明判定**：优先使用 \`COMMENT ON TABLE\`；无表注释时回退为“由实体 xxx 映射”。
- **索引判定**：从 DDL 的 \`PRIMARY KEY\`、\`UNIQUE\`、\`CREATE INDEX\`、\`ALTER TABLE ... ADD CONSTRAINT\` 中提取并汇总；无 DDL 时可回退到 JPA \`@Table(indexes = {...})\` 及 \`@Table(uniqueConstraints = {...})\` 中声明的索引与唯一约束。无 DDL 项目，索引信息在文档头部统一说明"本项目无 DDL，索引信息无法推断"，各表不再逐一标注 \`[需人工确认] 无 DDL 可推断索引\`。
- **值规范化**：默认值与说明中的换行、连续空白需折叠为单空格，避免 Markdown 表格错列。

**继承关系处理**：
- \`@MappedSuperclass\` / MyBatis-Plus 基类：须递归扫描父类字段，合并到子类对应的表结构中。在备注中标注"继承自 {基类名}"
- \`@Inheritance(SINGLE_TABLE)\`：一个表对应多个实体类时，合并所有子类字段到同一表，在备注中说明"单表继承，鉴别列: {discriminator_column}"
- \`@Inheritance(JOINED)\`：每个子类对应独立表，在 ER 图中用继承关系线连接
- \`@Inheritance(TABLE_PER_CLASS)\`：每个具体类对应独立表，父类字段在每个子表中重复出现

**软删除标识**：
- \`@TableLogic\`（MyBatis-Plus）或 \`@Where\`/\`@SQLDelete\`（Hibernate）标注的字段，在字段说明中追加"（软删除标记）"
- 在表级备注中标注"本表使用软删除，删除字段: {field_name}"

**MyBatis-Plus 特殊注解处理**：
- \`@TableField(fill = FieldFill.INSERT/INSERT_UPDATE)\`：在字段说明中追加"（自动填充）"
- \`@Version\`：在字段说明中追加"（乐观锁）"
- \`@TableLogic\`：在字段说明中追加"（软删除标记）"
- \`@EnumValue\`：字段类型标注为枚举对应的 DB 类型，说明中注明枚举类名
- \`@TableField(typeHandler = JacksonTypeHandler.class)\` 等：字段类型标注为 \`json\`/\`text\`，说明中注明"JSON 存储"

**Java → DB 类型推断（无 DDL 时使用）**：

| Java 类型 | 默认 DB 类型 | 说明 |
|-----------|-------------|------|
| Long/long | bigint | - |
| Integer/int | int | - |
| String | varchar(255) | 有 \`@Column(length=N)\` 时用 varchar(N) |
| BigDecimal | decimal(19,2) | 有 \`@Column(precision=P, scale=S)\` 时用 decimal(P,S) |
| Boolean/boolean | tinyint(1) | - |
| Date/LocalDate | date | - |
| LocalDateTime/Timestamp | datetime | - |
| byte[] | blob | - |
| Enum | varchar(32) | 有 \`@Enumerated(EnumType.ORDINAL)\` 时用 int |

注：推断类型须在字段表"类型"列后标注 \`(推断)\` 以区分 DDL 定义的精确类型。

**枚举表/字典表标注**：
- 符合以下特征的表标注为"字典表"：表名含 \`dict\`/\`enum\`/\`config\`/\`code\`/\`type\`，或字段数 ≤ 5 且含 \`code\`+\`name\`/\`value\` 组合
- 字典表在 ER 图中以灰色背景或虚线框区分，避免关系线过密
- 字典表可集中在一个独立小节"字典表清单"中列出，不与业务表混排

**输出格式**：
\`\`\`markdown
#### 表1: [表名]（如：t_user）
- **说明**: [表业务说明]
- **字段**:
  | 字段名 | 类型 | 必填 | 默认值 | 说明 |
  |--------|------|------|--------|------|
  | id | bigint | 是 | - | 主键 |
  | xxx | varchar(64) | 是 | - | 说明 |
  | created_at | datetime | 是 | CURRENT_TIMESTAMP | 创建时间 |
  | updated_at | datetime | 是 | CURRENT_TIMESTAMP ON UPDATE | 更新时间 |
- **索引**: 主键 id；唯一索引/普通索引（如有）
- **备注**: [其他约束或说明]

#### 表2: [表名]
- **说明**: [表业务说明]
- **字段**: [同上表格形式]
\`\`\`

### 1.2 分组索引与按模块分段的全量清单（仅无集中式 DDL 场景，必须遵循）

仅在仓库**未发现集中式 DDL**（如 \`db/migration\`、\`sql/ddl\`）且需要以实体/Mapper 扫描结果产出全量表清单时，若表数量较多且实体按模块分目录存放，须在「全量表清单」前增加**分组索引**，并在文档后半段增加**按模块分段的全量清单**，便于按业务域查阅。

**分组索引（按实体模块）**：
- 模块按实体文件路径 \`src/main/java/.../entity/<module>/...\` 中的 \`<module>\` 统计；实体直接放在 \`entity\` 目录下无子目录时，归为模块 \`root\`。
- 在「全量表统计」后输出**分组索引表**：列为「模块」「表数量」，按表数量降序排列。
- 表中**模块名须为可点击锚点**：使用 \`[\`模块名\`](#模块名)\` 形式，其中锚点 ID 使用小写（如 \`#contractmanage\`、\`#newec\`），与下文「按模块分段的全量清单」中各模块标题的锚点一致。
- 在分组索引表前增加说明：点击模块名可跳转到下方「按模块分段的全量清单」对应段落。

**按模块分段的全量清单**：
- 在「全量表清单（按表名排序）」表格之后、表关系（ER 图）章节之前，增加**按模块分段的全量清单**大节。
- 每个模块对应一个小节：标题使用 \`##### 模块名 {#模块名}\`，其中 \`{#模块名}\` 的 ID 与分组索引中的链接一致（小写）；若渲染器不支持 \`{...#}\` 语法，则依赖标题自动生成的 ID（多数为标题文本小写）。
- 每个模块小节下为该模块的**全量**表清单表格，列与全量表一致：**表名 | 实体类 | 实体文件**，内容与「全量表清单」中该模块的表完全一致，仅按模块拆段展示。
- 模块顺序与分组索引表顺序一致（建议按表数量降序），便于与索引一一对应。

**输出格式示例**：
\`\`\`markdown
#### 分组索引（按实体模块）
| 模块 | 表数量 |
|---|---:|
| [\`contractmanage\`](#contractmanage) | 94 |
| [\`printing\`](#printing) | 22 |
...

#### 全量表清单（按表名排序）
| 表名 | 实体类 | 实体文件 |
...

#### 按模块分段的全量清单
##### contractmanage {#contractmanage}
| 表名 | 实体类 | 实体文件 |
...
##### printing {#printing}
...
\`\`\`

### 2.2 表关系（ER 图）

描述表与表之间的关联关系（一对一、一对多、多对多等），并使用 Mermaid ER 图展示。

**关系说明**：
- 明确外键字段及引用表
- 说明关联类型（如：用户 1-N 订单、订单 N-1 用户）
- 如有中间表，需在 ER 图中体现
- 如 DDL 未显式定义外键（无 \`FOREIGN KEY\` / \`REFERENCES\`），应在文档中明确标注“未解析到外键约束，可能由应用层维护关系”，不得臆造物理外键。

**Mermaid ER 图关系方向语法对照**：
- 多对一：子表 \`}o--||\` 主表（如 \`position }o--|| account\`，表示 position 多对一 account）
- 一对多：主表 \`||--o{\` 子表（如 \`account ||--o{ position\`，表示 account 一对多 position）

**JPA 关系注解 → ER 关系映射**：

| JPA 注解 | ER 关系 | Mermaid 语法 |
|---------|---------|-------------|
| \`@ManyToOne\` | 多对一 | \`子表 }o--\\|\\| 主表\` |
| \`@OneToMany\` | 一对多 | \`主表 \\|\\|--o{ 子表\` |
| \`@OneToOne\` | 一对一 | \`表A \\|\\|--\\|\\| 表B\` |
| \`@ManyToMany\` + \`@JoinTable\` | 多对多（含中间表） | \`表A }o--o{ 表B\`，中间表单独列出 |
- 注意：关系方向须与文字描述一致，避免图形与说明矛盾。

**输出格式**：
\`\`\`markdown
#### 表关系说明
- **[表A]** 与 **[表B]**：{关系类型}（如：一对多，表A 主键对应 表B 外键 xxx）
- **[表B]** 与 **[表C]**：{关系类型}
\`\`\`

#### Mermaid ER 图示例

\`\`\`mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : "order_item"

    USER {
        bigint id PK
        varchar username
        varchar email
        datetime created_at
        datetime updated_at
    }

    ORDER {
        bigint id PK
        bigint user_id FK
        varchar order_no
        decimal total_amount
        varchar status
        datetime created_at
        datetime updated_at
    }

    ORDER_ITEM {
        bigint id PK
        bigint order_id FK
        bigint product_id FK
        int quantity
        decimal price
        datetime created_at
    }

    PRODUCT {
        bigint id PK
        varchar name
        varchar sku
        decimal price
        datetime created_at
        datetime updated_at
    }
\`\`\`

**图例说明**：
- \`||--o{\`：一对多（一方可选）
- \`||--|{\`：一对多（一方必选）
- \`PK\`：主键，\`FK\`：外键
- 根据实际表名、字段名替换上述示例中的实体与属性