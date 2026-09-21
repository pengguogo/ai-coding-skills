# Step 1: 输入收集与范围确认

## 元信息

- execution-mode: inline
- checkpoint-level: L1

## 参数

- input: 用户指定的代码库路径 / 模块名
- output: 扫描范围清单 + 技术栈信息

## 执行指令

### 1. 确认代码库路径

- 若用户已指定路径，直接使用
- 若未指定，列出工作区下所有含 `pom.xml` / `build.gradle` 的目录供用户选择

### 2. 识别入口层

扫描代码库，定位入口层组件（用于后续"未引用"判定）：

| 入口类型 | 识别特征 |
|----------|---------|
| HTTP Controller | `@RestController` / `@Controller` |
| RPC Service | `@DubboService` / `@RpcService` / `@ThriftService` / `implements` RPC接口 |
| MQ Consumer | `@RocketMQMessageListener` / `@KafkaListener` / `@JmsListener` |
| 定时任务 | `@Scheduled` / `@XxlJob` / `@ElasticJob` / `implements Job` |
| 扩展点实现 | `implements ExtensionPoint` / `@Extension` |

产出：入口层清单（类全限定名 + 入口类型 + 调用链起点标注）

### 3. 确认扫描边界

- 排除目录：`/test/`、`/target/`、`/generated/`、`/node_modules/`
- 限定文件类型：`.java`（默认），可扩展 `.xml`（MyBatis Mapper）
- 确认是否包含依赖 jar（默认否）

### 4. 输出

```markdown
## 扫描范围

- 代码库路径：{CODEBASE_ROOT}
- 模块数：{N}
- 入口层清单：
  | 类名 | 入口类型 | 路径 |
  |------|---------|------|
  | XxxController | HTTP | com/xxx/controller/XxxController.java |

## 技术栈

- 框架：{Spring Boot / Dubbo / ...}
- 数据库：{MySQL / PostgreSQL / ...}
- ORM：{MyBatis / MyBatis-Plus / JPA / ...}
```

## 产出

- 扫描范围清单（入口层清单 + 技术栈 + 排除目录）
