# Step 7: 增量复核

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-07-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files:
  - `{WORKSPACE}/review/review-log.md`
  - `{DESIGN}/backend-design.md`
  - `{DESIGN}/frontend-design.md`
- input_files_subagent: （同 input_files）
- reference_sections:
  - `references/p0/p0-backend-checklist.md`
  - `references/p0/p0-frontend-checklist.md`
  - `references/p0/p0-android-checklist.md`
  - `references/p0/p0-ios-checklist.md`
- output_file: `{WORKSPACE}/review/07-incremental-recheck.md`
- domain_context: 增量复核，验证终审发现的问题是否已修复，并对修复涉及的文件做 P0 快扫
- whitelist_rules: null  # 增量复核不修改代码

## 产出结构

```markdown
# 增量复核 #{轮次}（{YYYY-MM-DD}）

## 1. 复核范围

| 维度 | 数量 |
|------|------|
| 待复核发现 | {N} |
| 修复涉及文件 | {M} |

## 2. 旧发现复核

| 原编号 | 原检查项 | 修复文件 | 复核结果 | 说明 |
|--------|---------|---------|---------|------|
| RF-001 | {检查项} | {文件路径} | ✅ 已修复 / ❌ 未修复 / ⚠️ 部分修复 | {说明} |

## 3. 修复文件 P0 快扫

> 对修复涉及的文件执行 P0 级检查，防止修复引入新问题。

| 编号 | 严重性 | 文件:行号 | 检查项 | 问题描述 | 确信度 | 修复建议 |
|------|--------|----------|--------|---------|--------|---------|

> 无新发现时写：修复文件 P0 快扫无新发现。

## 4. 复核摘要

- 旧发现：{待复核数} / {已修复数} / {未修复数}
- 新发现（P0 快扫）：blocking {N} / important {M}
- 复核结论：✅ 全部通过 / ❌ 仍有未解决
```

## 执行指令

### 1. 提取待复核发现

- 读取 `review-log.md` 终审章节（或上一轮增量复核章节）
- 提取所有未解决的 blocking 和 important 发现
- 记录每个发现的编号、检查项、涉及文件

### 2. 确定修复范围

- 对每个待复核发现，读取对应的代码文件
- 确定修复涉及的文件集合（去重）

### 3. 旧发现复核

对每个待复核发现：
1. 读取对应文件的当前代码
2. 按原检查项的判断标准重新审查
3. 判定：✅ 已修复 / ❌ 未修复 / ⚠️ 部分修复
4. 部分修复须说明剩余问题

### 4. 修复文件 P0 快扫

对修复涉及的所有文件：
1. 判断文件类型（后端 / 前端 / Android / iOS）
2. 后端文件：执行 `p0-backend-checklist.md` 全部 18 项
3. 前端文件：执行 `p0-frontend-checklist.md` 全部 14 项
4. Android 文件（.kt/.java/Android XML）：执行 `p0-android-checklist.md` 全部 14 项
5. iOS 文件（.swift/.m/.h）：执行 `p0-ios-checklist.md` 全部 14 项
6. 只扫描修复涉及的文件，不扫描其他文件
7. 新发现编号使用 `RR{轮次}-{序号}`（R = Recheck）

### 5. 复核判定

| 条件 | 结论 |
|------|------|
| 旧发现全部 ✅ 已修复 + P0 快扫 0 blocking | ✅ 全部通过 → 触发 Step 6 重新执行 |
| 存在 ❌ 未修复 或 P0 快扫有 blocking | ❌ 仍有未解决 → 等待下一轮修复 |
| 当前轮次 ≥ 3 且仍有未解决 | ❌ 超过最大轮次，强制要求人工介入 |

### 6. 追加复核结论到 review-log.md

将增量复核章节追加到 `review-log.md` 的 `<!-- APPEND_HERE -->` 标记前。

若复核结论为 ✅ 全部通过：
- 更新评审元信息中的"当前状态"为"复核通过，待重新判定"
- 后续动作标注"触发 Step 6 重新执行汇总判定"

若复核结论为 ❌ 仍有未解决：
- 后续动作标注"修复剩余问题后再次触发增量复核"
