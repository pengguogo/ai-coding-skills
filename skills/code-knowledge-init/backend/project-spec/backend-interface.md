# 接口信息

本文档是项目规格中**对外接口清单**的产出规范。每条接口仅需 **HTTP 方法**、**URL**、**接口说明** 三项，**不包含**入参、出参、错误码等扩展说明。

---

## 1 说明

本规范适用于存量项目基于代码扫描产出对外接口清单，应覆盖 **Controller**（\`@RestController\` / \`@Controller\`）等 HTTP 入口；若项目使用 Spring WebFlux 函数式路由（\`RouterFunction\`），须从路由定义中提取 HTTP 方法与路径，按同样表格格式输出。若项目另有 RPC、消息消费等对外契约，可按同样「方法 + 路径/标识 + 说明」原则在对应 specs 中增列表格列或单独小节说明。

**消息消费入口**：消息消费入口（\`@KafkaListener\`、\`@RabbitListener\`、\`@RocketMQMessageListener\` 等）作为业务入口，须在 \`backend-interface.md\` 中以独立小节列出，表格列为：监听标识 | Topic/Queue | 说明。

**定时任务入口**：定时任务入口（\`@Scheduled\`、\`@XxlJob\`、Quartz 等）作为业务入口，须在 \`backend-interface.md\` 中以独立小节列出，表格列为：任务标识 | Cron 表达式/触发方式 | 说明。

**Dubbo API 定义接口例外**：\`*-api\`/\`*-spi\` 模块中的 \`public interface\`（Dubbo API 定义接口）须展开方法签名表格（| 方法签名 | 入参 | 返回值 | 说明 |），不受 §4 禁止入参出参的约束。接口数 > 30 时按模块拆分为独立附录文件，命名规范：\`backend-interface-{module-name}.md\`，放在同一产出目录。

- **忽略无 Controller 注解的类**：仅统计类上标注了 \`@RestController\` 或 \`@Controller\` 的 **HTTP 入口实现类**。未标注上述注解的类型（例如仅存在于 \`*-api\` 模块中的 \`*Rest\` 接口定义本身、普通接口、抽象类等）**不得**单独作为一行接口或单独一份 specs 产出；映射信息若只出现在接口上，须在 **带 Controller 注解的实现类** 分册中解析并列出（见 1.1「边界情况处理 - 接口继承」）。
- **Bootstrapper 双重角色处理**：同时标注 \`@Controller\`（或 \`@RestController\`）和 \`@SpringBootApplication\` 的启动类，若包含 \`@RequestMapping\` 方法，纳入接口清单但标注"启动类入口，非业务 API"。
- **基础设施端点排除**：以下端点不得列入业务接口清单，须在文档末尾以独立小节"非业务入口"汇总说明：
  - 健康检查：\`/health\`、\`/actuator/**\`、\`/ready\`、\`/liveness\`
  - 监控指标：\`/metrics\`、\`/prometheus\`
  - API 文档：\`/swagger-ui/**\`、\`/v3/api-docs/**\`、\`/v2/api-docs\`、\`/swagger-resources/**\`
  - 框架错误页：\`/error\`
  - Dubbo 框架服务：\`DubboHealthService\`、\`MetadataService\`
  - Spring Boot Admin：\`/instances\`、\`/applications\`
  若 Controller 中同时包含业务接口和基础设施端点，业务接口正常列入清单，基础设施端点移至"非业务入口"小节。
- **扫描依据**：以实际代码中带 \`@RestController\` / \`@Controller\` 的 **实现类** 为锚点，结合映射注解、路径拼接规则与 \`context-path\`；**不得**仅以 Swagger/OpenAPI 注解替代代码结论作为唯一依据（可与代码交叉核对）。
- **表格字段**：每条接口在表格中对应一行，列为 **方法** | **URL** | **接口说明**。URL 须为完整可识别的路径（含类级与方法级路径、路径变量写法等，与运行时一致或等价）。
- **组织维度**：**单文件输出**——所有接口信息汇总至一份 \`backend-interface.md\` 文件中。文件内部按 **功能模块 (Module)** 划分二级标题，按 **Controller 类** 划分三级标题进行组织。不得将多个 Controller 的接口表格混杂在一起。
- **完整性**：同一 Controller 下对外暴露的每个 HTTP 接口均须在对应表格中占一行，**不得**合并多行、**不得**遗漏或写「其余略」。
- **生成方式**：接口文档需**一次性全量生成**。禁止分批增补（例如先生成部分接口后再补录），也禁止用「需人工确认」「待确认」等占位动作跳过关键接口；若信息无法从代码扫描得到，应视为输出不合格并在同轮产出中补齐。
- **强制执行扫描任务模板**：生成 \`backend-interface.md\` 时，**必须**按 [unified-scan-task-template.md](../../unified-scan-task-template.md) 任务模板执行分步扫描流程（脚本提取 + LLM 分批补充）。**不得**由 LLM 自行判断是否需要走该流程，**不得**跳过脚本扫描步骤直接生成接口清单。无论项目规模大小，一律走全流程。

### 1.1 扫描实现要点（经验约束）

以下为接口清单代码扫描落地时必须遵守的实现约束，用于避免出现“统计为 0”或“每个 Controller 多 1 条接口”等系统性错误。

- **类级映射与方法级映射严格区分**：
  - **类级**：仅允许从 \`class\` 关键字之前的注解区域识别（通常为 \`@RequestMapping(...)\`）。不得把类级映射当成接口行写入表格。
  - **方法级**：仅统计 \`class\` 关键字之后出现的映射注解（\`@GetMapping/@PostMapping/@PutMapping/@DeleteMapping/@PatchMapping/@RequestMapping\`），一条映射对应表格一行。
- **避免“重复拼接路径”**：
  - URL 由 \`context-path\` + 类级 path + 方法级 path 拼接。\`context-path\` 优先从 \`application*.yml\` 的 \`server.servlet.context-path\`（Spring MVC）或 \`spring.webflux.base-path\`（WebFlux）中读取；若未配置则为空。
  - 若方法级 path **已经包含** 类级 path（例如方法级写了完整路径或存在重复片段），拼接时应做去重，避免生成形如 \`/v1/.../v1/...\` 的 URL。
- **支持无参映射注解**：
  - 例如 \`@GetMapping\`、\`@PostMapping\` 等无参数写法仍视为接口（路径为空时仅拼接类级 path）。
- **\`@RequestMapping\` 的 method 推断**：
  - 若 \`method = RequestMethod.*\` 未显式声明，按以下优先级推断：
    1. 方法参数中有 \`@RequestBody\` → **POST**
    2. 方法名以 \`delete\`/\`remove\` 开头 → **DELETE**
    3. 方法名以 \`update\`/\`modify\`/\`edit\` 开头 → **PUT**
    4. 方法名以 \`patch\` 开头 → **PATCH**
    5. 以上均不满足 → **GET**
  - 禁止输出 "ALL"，必须推断为具体的 HTTP 方法。

**边界情况处理**：
- 接口继承：若 Controller 实现了接口且 \`@RequestMapping\` 在接口上，须从接口继承映射信息，URL 以实现类为锚点输出
- 多路径映射：\`@GetMapping({"/list", "/all"})\` 须拆为两行，每个路径独立一行
- \`path\` 与 \`value\` 等价：\`@RequestMapping(path="/x")\` 与 \`@RequestMapping(value="/x")\` 等价处理
- \`consumes\`/\`produces\`：不作为必填项，但若项目大量使用可在表格中增加"Content-Type"列
- **接口说明来源**：
  - 优先取方法附近的 \`@ApiOperation("...")\`。
  - 若不存在识别到可用的 \`@ApiOperation\`，则基于方法名进行中文翻译生成接口说明（不使用“接口”等占位符；若翻译仍无法得到可读文本，则回退到方法名本身）。

---

## 2 文档结构与组织

接口信息**必须合并为单一文件**，统一输出在项目规格目录下，文件名为 **\`backend-interface.md\`**。整个文档需按照以下结构进行组织：

1. **接口统计概要（可选）**：位于文档开头，可包含应用名、\`context-path\`、接口总数等。
2. **按功能模块分组（二级标题）**：使用 \`## {功能模块名}\`。
3. **按 Controller 分组（三级标题）**：使用 \`### {Controller类名}\`。

### 2.1 功能模块 \`{module}\`（二级标题）

- **含义**：将**同一功能模块**下的多个 Controller 归入同一个二级标题下。
- **命名来源（存量项目扫描）**：优先取 Controller **全限定包名**中，紧接在业务约定的 \`controller\` 包段之后的**下一级包名**作为模块名。  
  - 示例：包 \`com.example.app.controller.budget.BiBudgetController\` → 模块目录 \`budget\`。  
  - 若类直接位于 \`...controller\` 下无子包（无「下一级包名」），模块名取 **\`root\`**（或项目内统一约定为 \`default\`，全仓须一致）。

### 2.2 Controller 类（三级标题）

- 在对应的功能模块二级标题下，为每个 Controller 类创建一个三级标题 \`### {Controller类名}\`。
- 在三级标题下方，使用 Markdown 表格列出该 Controller 下的所有接口。

### 2.3 大型项目拆分

当接口总数 > 300 时，须按功能模块拆分为独立文件：
- 主文件 \`backend-interface.md\`：仅包含接口统计概要和模块索引表（模块名 | 接口数 | 文件链接）
- 分册文件 \`backend-interface-{module}.md\`：每个模块的完整接口清单

---

## 3 接口文档内容示例

文档结构与表格示例：

\`\`\`markdown
# 接口信息

> 接口来源：基于 Controller 代码扫描产出
> 应用 Context Path: /api

## user-auth

### UserAuthController

> 可选：Controller 职责一行说明。

| 方法 | URL | 接口说明 |
|------|-----|----------|
| POST | /api/v1/auth/login | 用户登录 |
| POST | /api/v1/auth/logout | 用户登出 |

## order

### OrderController

| 方法 | URL | 接口说明 |
|------|-----|----------|
| POST | /api/v1/orders | 创建订单 |
| GET  | /api/v1/orders/{id} | 按 ID 查询 |
\`\`\`

- **方法**：HTTP 动词（GET、POST、PUT、DELETE、PATCH 等）。
- **URL**：完整路径（含全局前缀、版本段等）；路径变量用 \`{id}\` 等形式与代码一致。
- **接口说明**：一句话描述业务含义或用途，避免空泛表述。

若同一 Controller 内存在多个 \`@RequestMapping\` 前缀，仍保持**一张表内一行一接口**，**不得**将其他 Controller 的接口混入该表格。

---

## 4 禁止表述

- **不得**在本规范约定的接口清单中要求或展开 **入参、出参、错误码**（若项目另有 API 详细设计文档，不在本文件规范范围内）。
- **不得**用「详见 Swagger」「以 DTO 为准」等替代 **URL 与接口说明** 的明确写出。
- **不得**将多个不同 Controller 的接口表格混为一谈，必须按 Controller 分小节和表格列出。
- **不得**在表格中合并多行 URL 或「一条说明对应多个接口」。

---