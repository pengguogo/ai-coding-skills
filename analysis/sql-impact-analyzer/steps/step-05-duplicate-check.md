# Step 5: 重复数据影响分析与验证脚本

## 元信息

- execution-mode: inline

## 参数

- input: Step 1 的 SQL + Step 2 的代码引用 + Step 4 的关联模型
- output: 重复数据影响分析 + check SQL 脚本

## 执行指令

### Part 1: 重复数据影响分析

#### 1.1 订正 SQL 自身的去重

分析订正 SQL 是否可能产生重复数据：

| 检查项 | 说明 |
|--------|------|
| UPDATE 重复 | WHERE 条件是否可能匹配多条已存在记录 |
| INSERT 重复 | 是否可能插入重复主键/唯一索引的记录 |
| 复合 key | 目标表是否有复合主键，SET 的字段是否是主键的一部分 |

#### 1.2 关联表的重复/冗余

分析字段变更后，关联表是否会产生重复：

| 检查项 | 触发条件 | 示例 |
|--------|---------|------|
| EOD 重复生成 | 日期字段修改后，EOD 按新日期重新生成计划，但旧日期的计划未删除 | 修改 next_cycle_date 后 EOD 生成新期次计划，旧计划残留 |
| 状态导致重复 | 状态回退后，关联记录再次生成 | status 从 D→A，计费流程再次生成费用记录 |
| 扣款重复 | 扣款状态重置后，同一笔被扣两次 | 扣款标记从 Y→N，下次批量扣款重复处理 |
| 记账重复 | GL 分录重复入账 | 会计日期回退导致同一交易的 GL 分录重新生成 |

#### 1.3 历史数据一致性

| 检查项 | 说明 |
|--------|------|
| 快照数据 | 是否有快照表/流水表记录历史状态，订正后历史与当前不一致 |
| 对账差异 | 订正前后的对账文件是否会产生差异 |
| 统计口径 | 报表/BI 按时间窗口统计是否会因日期变更而重复计数 |

### Part 2: Check 验证脚本

#### 2.1 订正前检查 SQL

生成执行前的检查脚本（人工在 SQL 客户端执行确认）：

```sql
-- ============================================
-- 订正前检查：确认影响行数
-- ============================================

-- 1. 确认订正 SQL 的影响行数（替换 {WHERE条件} 为实际条件）
SELECT COUNT(*) AS affected_rows
FROM {target_table}
WHERE {WHERE_条件};

-- 2. 确认目标记录当前状态
SELECT * FROM {target_table}
WHERE {WHERE_条件}
ORDER BY {key_field};

-- 3. 检查关联表数据量
SELECT COUNT(*) AS related_rows
FROM {related_table}
WHERE {关联条件};
```

#### 2.2 订正后验证 SQL

生成执行后的人工验证脚本：

```sql
-- ============================================
-- 订正后验证：确认结果正确性
-- ============================================

-- 1. 确认 SET 字段值已更新
SELECT {key_field}, {set_field1}, {set_field2}, last_change_date
FROM {target_table}
WHERE {WHERE_条件};

-- 2. 确认非目标记录未被误改（WHERE 条件反向）
SELECT COUNT(*) AS other_rows
FROM {target_table}
WHERE NOT ({WHERE_条件})
  AND last_change_date = DATE_FORMAT(NOW(), '%Y%m%d');

-- 3. 检查关联表是否有重复记录
SELECT {关联key}, COUNT(*) AS cnt
FROM {related_table}
GROUP BY {关联key}
HAVING COUNT(*) > 1;

-- 4. 抽查关联数据一致性
SELECT a.{key_field}, a.{set_field}, b.{related_field}
FROM {target_table} a
JOIN {related_table} b ON {关联条件}
WHERE {WHERE_条件};
```

#### 2.3 回滚 SQL

生成应急回滚脚本（基于订正前 SELECT 的结果填充）：

```sql
-- ============================================
-- 回滚脚本（由人工根据订正前查询结果填充）
-- ============================================
-- UPDATE {target_table}
-- SET {field1} = {original_value1},
--     {field2} = {original_value2},
--     last_change_date = {original_date}
-- WHERE {主键条件};
```

### 3. 产出

```markdown
## 重复数据影响分析

### 订正 SQL 重复风险

| SQL# | 风险类型 | 说明 | 影响行数预估 | 风险 |
|------|---------|------|------------|------|
| 1 | 无 | WHERE 主键匹配唯一记录 | 1 | ✅ |

### 关联表重复风险

| 关联表 | 风险场景 | 触发的 EOD/Job | 可能产生的重复 | 风险 |
|--------|---------|---------------|-------------|------|
| loan_plan | next_cycle_date 修改后 EOD 生成新计划 | EOD:genNextPlan() | 旧日期计划残留 | ❌ |
| repayment | amount 修改后费用重算 | EOD:calcFee() | 费用记录重复 | ⚠️ |

### Check 脚本

| 脚本类型 | SQL 文件路径 | 用途 |
|----------|-------------|------|
| 订正前检查 | {WORKSPACE}/sql-impact/check_before.sql | 确认影响行数+当前状态 |
| 订正后验证 | {WORKSPACE}/sql-impact/check_after.sql | 验证结果+查重复+抽查 |
| 回滚脚本 | {WORKSPACE}/sql-impact/rollback.sql | 应急回滚参考 |
```

## 产出

- 重复数据影响分析
- 3 份 SQL Check 脚本（check_before / check_after / rollback）
