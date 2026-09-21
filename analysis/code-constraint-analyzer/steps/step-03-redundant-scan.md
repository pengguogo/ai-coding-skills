# Step 3: 冗余代码扫描

## 元信息

- execution-mode: subagent
- agent: redundancy-scanner
- checkpoint-level: L1

## 参数

- input: Step 1 的代码库路径 + 技术栈信息
- output: 冗余代码发现清单（按风险初分级）

## 目的

扫描逻辑可简化的冗余代码，包括但不限于：

1. **N+1 查询**：循环内逐条查询数据库 `for(...){ mapper.selectById(id) }`
2. **重复 DB/缓存调用**：同一方法内多次调用同一查询（未缓存结果）
3. **无效判空**：已被 `@NonNull` / `@NotNull` 标记的参数再做空判断
4. **资源未释放**：`try-finally` 缺失或 `close()` 不在 finally 中
5. **不必要的装箱/拆箱**：`Integer.valueOf(int)` 或循环内的 `new BigDecimal()`
6. **循环内拼接 SQL**：`for(...){ sql += "OR id=" + id }` 应改用 IN 子句
7. **可合并的异常捕获**：多个 `catch` 块执行相同逻辑
8. **冗余日志**：循环内每次迭代打 INFO 日志

## 执行指令

对每种冗余模式使用对应搜索策略：

| 冗余模式 | 搜索策略 | 风险基线 |
|----------|---------|---------|
| N+1 查询 | `grep` `for\s*\(` → 检测循环体内是否有 `mapper.` / `dao.` 调用 | high |
| 重复查询 | 同一方法内出现 2 次以上相同 `mapper.select*` | medium |
| 无效判空 | `@NotNull` + `if (x == null)` | low |
| 资源未释放 | `new.*Stream\|Reader\|Writer\|Connection` 未在 try-with-resources 或 finally 中 close | high |
| 循环内 SQL 拼接 | `for.*\+.*sql\|StringBuilder.*append.*sql` | high |
| 可合并异常捕获 | `catch.*\{.*\}[\s\S]*?catch.*\{.*\}` 内容相同 | medium |
| 冗余日志 | `for.*
.*log\.info` | low |

## 产出

```markdown
# 冗余代码扫描结果

| 文件 | 行号 | 冗余类型 | 代码片段 | 优化方向 | 风险 |
|------|------|---------|---------|---------|------|
| OrderService.java | 67-72 | N+1查询 | for(Order o:list){ dao.findById(o.getId()) } | 改用 batchSelectByIds | high |
```

## 产出

- 冗余代码发现清单（`upgrade/{scene}_{date}/_workspace/code-constraint/redundant-scan.md`）
