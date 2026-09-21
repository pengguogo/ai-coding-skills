# Step 6: 优化方案设计

## 元信息

- execution-mode: inline
- checkpoint-level: L1

## 参数

- input: Step 5 分桶结果中的 high + medium 级别发现
- output: 优化方案 + 单测覆盖方案

## 执行指令

### 1. 仅对 high 和 medium 级别出方案

low 级别仅记录清理建议（一句描述），不展开方案设计。

### 2. 针对每种场景设计标准方案模板

**无效代码 high/medium**：
```markdown
### 问题：{简述}
- 文件：{路径}:{行号}
- 影响：{影响面描述}

#### 方案
- 操作：删除注释代码 / 标注 @Deprecated + 迁移调用方
- 风险：{删除后是否影响编译/运行时}
- 验证：`mvn compile` + 全量单测通过

#### 单测覆盖
- 原调用方的单测是否已覆盖该路径？若否，补充 {N} 个 case
```

**冗余代码 high/medium**：
```markdown
### 问题：{冗余类型} at {路径}:{行号}

#### Before
```java
// 当前代码片段（含行号）
```

#### After（优化方案）
```java
// 优化后代码（含注释说明变更点）
```

#### 单测覆盖
| Case | 输入 | 期望输出 | 说明 |
|------|------|---------|------|
| 批量查询正常 | ids=[1,2,3] | List<Order> size=3 | 替代原逐条查询 |
| 空列表 | ids=[] | List<Order> size=0 | 边界条件 |
| 部分不存在 | ids=[1,999] | List<Order> size=1 | 容错 |
```

**重复代码 high/medium**：
```markdown
### 问题：{重复描述}
- 出现次数：{N}
- 涉及文件：{列表}

#### 抽取方案
- 目标模块：{新建类路径}
- 接口设计：
```java
public class {ClassName} {
    public static {ReturnType} {methodName}({Params}) { ... }
}
```
- 迁移步骤：新建类 → 逐个替换引用文件 → 删除原重复代码

#### 单测覆盖
| Case | 输入 | 期望输出 |
|------|------|---------|
| ... | ... | ... |
```

### 3. 设计完整性检查

- 每个 high 级别项必须有 before/after 代码 + 3 个以上单测 case
- 每个 medium 级别项必须有 before/after 代码 + 1-2 个单测 case
- 涉及 DB 的优化须含 SQL 执行计划对比建议

### 4. 输出

```markdown
# 优化方案设计

## deadcode 方案（{N} 项）

### high（{N} 项）
...

### medium（{N} 项）
...

## redundant 方案（{N} 项）

### high（{N} 项）
...

## duplicate 方案（{N} 项）

### high（{N} 项）
...
```

## 产出

- 优化方案设计文档（`upgrade/{scene}_{date}/_workspace/code-constraint/solution-design.md`）
