# Step 3: 参与者与数据模型分析

## 元信息

- execution-mode: subagent
- agent: data-model-analyzer
- input: Step 2 的场景与用例清单 + Step 1 的数据实体基线
- output: 参与者列表 + 实体汇总 + ER 关系

## 执行指令

### 1. 识别参与者 (Actors)

从用例清单中提取所有参与者，分类为：

| 类型 | 说明 | 样式 |
|------|------|------|
| 主要参与者 | 发起用例的系统/角色 | `class="pill actor"` |
| 协作系统 | 被调用的外部/下游系统 | `class="pill actor"` |

对每个参与者列出：名称、类型、职责与说明。

### 2. 汇总数据实体

从 Step 1 的数据实体基线中提取，按以下结构整理：

```
| 实体/表 | 主键 | 关键字段 | 说明 |
|----------|------|----------|------|
| cif_client | client_no | cust_type, kyc_level, ... | 客户主档 |
```

### 3. 推导 ER 关系

分析实体间的关联关系：
- 1:1 关系（`||--||`）
- 1:N 关系（`||--o{`）
- 标注外键字段

用 Mermaid `erDiagram` 绘制 ER 图。**每个实体必须展开属性块**（不能只画裸关系连线），块内含主键(PK)/外键(FK) + 关键字段 + 中文注释，与实体汇总表一致：

```
erDiagram
    MB_ACCT ||--o{ MB_ACCT_BALANCE : "余额"
    MB_ACCT["MB_ACCT · 贷款账户(聚合根)"] {
      string internalKey PK "内部主键"
      string clientNo "客户号"
      string acctStatus "账户状态"
    }
    MB_ACCT_BALANCE["MB_ACCT_BALANCE · 账户余额"] {
      string internalKey PK "内部主键"
      string amtType PK "金额类型(PRI/BAL/OSL)"
      decimal totalAmount "余额"
    }
```

枚举取值直接写进注释（如 `amtType(PRI/BAL/OSL)`）。

### 4. 标注数据访问模式

对每个实体标注在各用例中的读/写模式：
- 读（消费）：`<span class="rw rw-r">读</span>`
- 写（改动）：`<span class="rw rw-w">写</span>`
- 读写：`<span class="rw rw-rw">读写</span>`

### 5. 输出格式

```
## 参与者列表
| 参与者 | 类型 | 职责与说明 |
|--------|------|------------|
| 编排引擎 | 主要 | 桥接网关，发起... |

## 实体汇总
| 实体/表 | 主键 | 关键字段 | 说明 |
|----------|------|----------|------|

## ER 图
erDiagram
    ...

## 数据访问模式
| 实体 | 访问用例 | 模式 |
|------|----------|------|
```

## 校验

完成后执行 `checkpoints/step-03-checkpoint.md` 自检
