# Step 2: 代码链路追踪

## 元信息

- execution-mode: subagent
- agent: context-gatherer

## 参数

- input: Step 1 产出的表名和字段列表
- output: 代码引用清单（按触发条件 / 数据读取分类）

## 执行指令

使用 `invokeSubAgent`（name: `context-gatherer`）执行代码扫描。

### Subagent Prompt 模板

```
针对以下表和字段，搜索工作区代码库中的所有引用：

目标表：{表名列表}
目标字段：{字段列表}

搜索内容：
1. Entity/Model 定义（Java 实体类中对应字段的属性定义）
2. Mapper XML 中的 SQL 引用（SELECT/UPDATE/INSERT 中使用目标字段的语句，重点关注 WHERE/ON 条件）
3. Service 层业务逻辑（读取或写入目标字段的 Java 代码）
4. EOD/Batch Job（日终批量作业中依赖目标字段作为触发条件或计算输入的逻辑）
5. 上下游联动（字段值变化后会触发哪些关联表更新）

搜索范围：工作区内所有 Java/XML 目录，多仓库全覆盖。

优先搜索的 Mapper XML 文件模式：
- *ClEodData*.xml
- *MbInvoice*.xml
- *MbAcctSchedule*.xml
- *MbAcctIntDetail*.xml

搜索策略：
- 表名：精确匹配（如 mb_acct_schedule）+ 驼峰匹配（如 MbAcctSchedule/mbAcctSchedule）
- 字段名：下划线匹配（如 next_deal_date）+ 驼峰匹配（如 nextDealDate）
- 重点关注 WHERE/ON 条件中使用这些字段的查询

输出要求：
- 列出每个找到的引用：文件路径、行号、引用上下文（包含该行及上下各 2 行）
- 按「触发条件引用（WHERE/ON 中出现）」和「数据读取/写入引用（SELECT/SET 中出现）」分类
```

### 补充搜索（inline）

如果 subagent 返回结果不足，使用 `grepSearch` 工具补充搜索：
- 按表名搜索所有 XML 文件
- 按字段驼峰名搜索所有 Java 文件
- 关注包含 `Eod`、`Batch`、`Job`、`Schedule` 关键词的类文件

## 产出

代码引用清单，按以下维度分类：
- **触发条件引用**：字段出现在 WHERE/ON/JOIN 条件中（值变化会改变功能行为）
- **数据读取引用**：字段出现在 SELECT/SET/计算表达式中（值变化会影响展示或计算结果）

每条引用记录：
- 文件路径（含仓库前缀）
- 行号
- 引用类型（触发/读取）
- 上下文代码片段
