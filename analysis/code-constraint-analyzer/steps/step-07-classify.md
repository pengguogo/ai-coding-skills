# Step 5: 分析归类与风险分级

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-05-checkpoint.md
- checkpoint-level: L2

## 参数

- input: Step 2/3/4 的三份扫描结果
- output: 按场景 + 风险级别分桶的发现分类表

## 执行指令

### 1. 合并三类扫描结果

将三份子代理产出合并为统一清单，每项标记来源（deadcode / redundant / duplicate）。

### 2. 风险二次评级

基于初分 + 影响面做二次评级：

**无效代码**：
| 初分 | 二次评级条件 |
|------|-------------|
| high | 核心交易链路或高频调用路径上 |
| medium | 一般业务 Service 层 |
| low | 工具类 / 未使用 import / 局部变量 |

**冗余代码**：
| 初分 | 二次评级条件 |
|------|-------------|
| high | N+1查询在核心链路上、资源未释放 |
| medium | 重复查询可合并、可合并异常捕获 |
| low | 无效判空、冗余日志 |

**重复代码**：
| 初分 | 二次评级条件 |
|------|-------------|
| high | 核心交易链路逻辑重复、关键计算公式分散 |
| medium | 相同工具方法分散、重复校验逻辑 |
| low | DTO转换重复、魔法值离散 |

### 3. 按场景拆桶

将发现按 3 个场景（deadcode / redundant / duplicate）× 3 个风险等级（high / medium / low）分桶。

每个桶单独准备数据，供 Step 6 设计 + Step 8 输出。

### 4. 数量控制与拆分策略

若单个 riskLevel 桶内发现 > 20 条，按子系统/模块进一步拆分为 `analysis_{riskLevel}_{module}.html`。

### 5. 输出

```markdown
# 分析归类结果

## 汇总

| 场景 | high | medium | low | 合计 |
|------|------|--------|-----|------|
| deadcode | N | N | N | N |
| redundant | N | N | N | N |
| duplicate | N | N | N | N |

## deadcode 分桶

### high（{N} 条）
| ID | 文件:行号 | 描述 | 二次评级理由 |
|----|----------|------|-------------|
| DC01 | ... | ... | ... |

### medium（{N} 条）

### low（{N} 条）

## redundant 分桶
...

## duplicate 分桶
...
```

## 产出

- 分桶后的发现分类表（`upgrade/{scene}_{date}/_workspace/code-constraint/classify-result.md`）
