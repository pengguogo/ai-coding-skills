# Step 4: ER 模型关联影响分析

## 元信息

- execution-mode: inline

## 参数

- input: Step 1 的表名 + Step 2 的 Entity/DDL 信息
- output: ER 模型影响图 + 关联字段分析

## 执行指令

### 1. 构建 ER 关联模型

基于目标表及其关联表，构建数据模型关系图：

1. **提取目标表结构**：从 Entity 类和 Mapper XML 提取目标表的所有字段
2. **识别外键关联**：提取 @OneToMany / @ManyToOne / @JoinColumn / 外键约束
3. **识别隐式关联**：提取代码中通过 loan_no / contract_no 等业务 key 做 JOIN 的关联
4. **识别级联影响**：提取 @Cascade / ON DELETE CASCADE / ON UPDATE CASCADE

### 2. 标记受影响字段（橙色高亮）

对每个关联表，分析字段变更的传导影响：

| 标记规则 | 说明 | CSS |
|----------|------|-----|
| 🔶 直接受影响 | 目标表变更字段在关联表中有对应字段（同名或语义对应） | `.field-impact` 橙色底色 |
| 🔸 间接受影响 | 关联表的计算逻辑引用目标表字段作为输入 | `.field-indirect` 浅橙底色 |
| ⚪ 不受影响 | 字段变更不涉及该关联路径 | 无标记 |

### 3. 生成 ER 图 HTML

产出可嵌入报告的 HTML 表格（非图片，可直接嵌入报告）：

```html
<div class="er-diagram">
    <!-- 中心节点：目标表 -->
    <table class="er-table">
        <caption>目标表：{table_name}</caption>
        <tr><th>字段</th><th>类型</th><th>本次变更</th><th>关联</th></tr>
        {目标表字段行}
    </table>

    <!-- 关联节点 -->
    {每个关联表重复}
    <div class="er-relation">
        <span class="er-arrow">→ {关联方式(job_name/loan_no/...)} →</span>
        <table class="er-table">
            <caption>关联表：{related_table}</caption>
            <tr><th>字段</th><th>类型</th><th>影响</th><th>说明</th></tr>
            {关联表字段行，橙色标记受影响字段}
        </table>
    </div>
</div>
```

### 4. 输出字段关联矩阵

```markdown
## ER 模型关联影响

### 关联表清单

| 关联表 | 关联方式 | 关联字段 | 影响字段 | 影响等级 |
|--------|---------|---------|---------|---------|
| loan_plan | loan_no | next_cycle_date | next_deal_date | 🔶 直接 |
| repayment | loan_no + seq_no | amount | should_repay_amount | 🔶 直接 |
| gl_journal | loan_no + due_date | due_date | last_change_date | 🔸 间接 |

### 字段影响详情

| 源字段 | 关联表 | 关联字段 | 影响路径 | 风险 |
|--------|--------|---------|---------|------|
| amount | repayment | should_repay_amount | EOD:calcRepayAmount() 读取 amount 计算应还 | ⚠️ |
| next_cycle_date | loan_plan | next_deal_date | EOD:genNextPlan() WHERE next_cycle_date=... | ❌ |
```

## 产出

- ER 关联影响分析（`{WORKSPACE}/sql-impact/04-er-impact.md`）
