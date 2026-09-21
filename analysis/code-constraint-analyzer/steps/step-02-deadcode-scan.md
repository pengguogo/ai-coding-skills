# Step 2: 无效代码扫描

## 元信息

- execution-mode: subagent
- agent: deadcode-scanner
- checkpoint-level: L1

## 参数

- input: Step 1 的入口层清单 + 代码库路径
- output: 无效代码发现清单（按风险初分级）

## 目的

扫描两类无效代码：
1. **注释代码**（Comment-out Code）：被 `//` 或 `/* */` 注释掉的完整逻辑块
2. **入口不可达代码**（Unreachable Code）：非入口层的方法/类，从入口层出发通过静态调用链分析不可达

## 执行指令

### Part 1: 注释代码扫描

1. 搜索模式：
   - `//.*(if|for|while|return|throw)` — 注释掉的逻辑语句
   - `/* ... */` 包裹的代码块（超过 3 行的注释块）
   - `@Deprecated` 注解且注释中说明"待删除/不再使用"

2. 排除项：
   - 纯文档注释（`/** ... */` JavaDoc）
   - 开关型注释（`// TODO` / `// FIXME` — 标注为 low）
   - 单行字段/变量声明注释

3. 输出每条发现的：
   - 文件名 + 行号
   - 代码片段（前后各 2 行上下文）
   - 注释类型（逻辑注释 / 配置注释 / 废弃注解）

### Part 2: 入口不可达代码扫描

1. 从 Step 1 的入口层清单出发，构建调用链：
   - 入口方法 → 直接调用 → 间接调用 → ...
   - 被调用的方法标记为"可达"

2. 识别以下类别的"不可达风险"：
   - `public` 方法未被任何入口链调用
   - `@Service` / `@Component` 类未被注入到任何入口链的 Bean 中
   - `@Mapper` / `@Repository` 接口仅在未注入的 Service 中使用
   - 工具类（`XxxUtils`）完全未被引用

3. 输出每条发现的：
   - 文件 + 行号 + 方法签名
   - 不可达原因（未被注入 / 调用链断裂 / 仅被测试调用）
   - 风险程度（high: 核心业务类 > medium: 辅助Service > low: 纯工具类）

## 产出

```markdown
# 无效代码扫描结果

## 注释代码

| 文件 | 行号 | 类型 | 代码片段 | 风险 |
|------|------|------|---------|------|
| XxxService.java | 45-52 | 逻辑注释 | // if(order!=null){...} | medium |

## 入口不可达代码

| 文件 | 方法 | 原因 | 风险 |
|------|------|------|------|
| OldHandler.java | handle() | 未被任何入口链调用 | high |
```

## 产出

- 无效代码发现清单（`upgrade/{scene}_{date}/_workspace/code-constraint/deadcode-scan.md`）
