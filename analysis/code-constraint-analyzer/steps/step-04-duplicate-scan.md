# Step 4: 重复代码扫描

## 元信息

- execution-mode: subagent
- agent: duplication-scanner
- checkpoint-level: L1

## 参数

- input: Step 1 的代码库路径
- output: 重复代码发现清单（按风险初分级）

## 目的

扫描可抽取共用模块的重复代码，包括但不限于：

1. **相同代码块**：同一代码库中相同/高度相似的代码块（≥8 行）出现 2 次以上
2. **重复工具方法**：不同类中存在相同签名的私有/静态工具方法（如 `formatDate`、`maskPhone`）
3. **重复校验逻辑**：多处出现相同的参数校验代码（`if (x == null) throw...` / `Assert.notNull` 序列）
4. **重复异常处理**：多处出现相同的 try-catch-log 模式
5. **重复转换逻辑**：DTO → VO / Entity → BO 的字段拷贝模式重复出现
6. **分散的 AOP 切点**：多处重复的 `@Transactional`、操作日志记录逻辑可统一为切面
7. **魔法值/硬编码**：同一常量在多处硬编码（如 `"SUCCESS"`、`"0"`、过期时间值）

## 执行指令

### Part 1: 代码块相似度检测

1. 在 `*.java` 文件中提取方法体（排除 getter/setter/空方法）
2. 对方法体做标准化（去除注释、统一变量名为占位符）
3. 使用滑动窗口（窗口大小 8 行）检测相似块
4. 相似度 ≥ 80% 且跨文件/跨模块的标记为重复

### Part 2: 模式识别

对特定模式做精确匹配：

| 模式 | 搜索策略 | 风险 |
|------|---------|------|
| 重复校验逻辑 | `if.*==.*null.*throw\|Assert.notNull` 在 3+ 文件中出现 | medium |
| 重复异常处理 | `catch.*\{[\s\S]{0,50}log\.error` 模式在 3+ 文件中出现 | medium |
| 重复 DTO 转换 | `new.*DTO\|BeanUtils.copyProperties\|builder\(\)\.build\(\)` 模式群 | low |
| 分散切点 | `@Transactional` + 相同注解组合在不同方法上重复 | medium |
| 魔法值 | 搜索字符串/数字字面量在 5+ 不相关文件中相同值 | low |

## 产出

```markdown
# 重复代码扫描结果

## 重复代码块

| ID | 文件1:行号 | 文件2:行号 | 相似度 | 描述 | 建议抽取 | 风险 |
|----|-----------|-----------|--------|------|---------|------|
| D01 | A.java:34-48 | B.java:56-70 | 92% | 订单金额计算逻辑 | OrderAmountCalculator | high |

## 重复模式

| 模式 | 出现次数 | 涉及文件 | 建议 | 风险 |
|------|---------|---------|------|------|
| 参数校验序列 | 8 | A,B,C,... | 统一 AOP @Valid + 全局异常处理 | medium |
```

## 产出

- 重复代码发现清单（`upgrade/{scene}_{date}/_workspace/code-constraint/duplicate-scan.md`）
