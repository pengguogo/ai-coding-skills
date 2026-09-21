# Step 1: 终审上下文收集

## 元信息

- agent: input-analyzer
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{TASK}/task-split.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{WORKSPACE}/review/review-log.md`]
- input_files_subagent: [`{TASK}/task-split.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{WORKSPACE}/review/review-log.md`]
- output_file: `{WORKSPACE}/review/01-review-context.md`
- domain_context: 为终审收集变更范围、设计基线和小节评审结果，产出结构化的终审上下文摘要

## Summary 配置

- output: `{WORKSPACE}/review/summaries/01-review-context.summary.md`
- must-include:
  - 后端模块清单（含模块名、文件数、小节评审状态、检查策略）
  - 前端功能点清单（含功能点名、文件数、小节评审状态、检查策略）
  - Android 模块清单（若存在 Android 任务，含模块名、文件数、小节评审状态、检查策略）
  - iOS 模块清单（若存在 iOS 任务，含模块名、文件数、小节评审状态、检查策略）
  - 小节评审覆盖度摘要（已通过/有遗留/未评审的模块数量）
  - 待全局确认清单（从 review-log.md 顶部提取）
- must-exclude:
  - 设计文档原文
  - 代码文件内容
  - 任务完整性对比详情
- max-length: 800

## 产出结构（extraction_schema）

```markdown
# 终审上下文

## 1. 变更范围概览

| 维度 | 数量 |
|------|------|
| 后端模块 | {N} |
| 前端功能点 | {M} |
| Android 模块 | {P}（无则填 0） |
| iOS 模块 | {Q}（无则填 0） |
| 总变更文件 | {K} |

## 2. 后端模块清单

| 序号 | 模块名 | task-split 编号 | 变更文件数 | 小节评审状态 | 检查策略 |
|------|--------|----------------|-----------|------------|---------|
| 1 | {模块名} | {编号} | {N} | ✅ 已通过 / ⚠️ 有遗留 / ❌ 未评审 | supplement / recheck / full |

## 3. 前端功能点清单

| 序号 | 功能点名 | task-split 编号 | 变更文件数 | 小节评审状态 | 检查策略 |
|------|---------|----------------|-----------|------------|---------|
| 1 | {功能点名} | {编号} | {N} | ✅ 已通过 / ⚠️ 有遗留 / ❌ 未评审 | supplement / recheck / full |

## 3b. Android 模块清单（仅当存在 Android 任务清单时输出）

| 序号 | 模块名 | task-split 编号 | 变更文件数 | 小节评审状态 | 检查策略 |
|------|--------|----------------|-----------|------------|---------|
| 1 | {模块名} | {编号} | {N} | ✅ 已通过 / ⚠️ 有遗留 / ❌ 未评审 | supplement / recheck / full |

## 3c. iOS 模块清单（仅当存在 iOS 任务清单时输出）

| 序号 | 模块名 | task-split 编号 | 变更文件数 | 小节评审状态 | 检查策略 |
|------|--------|----------------|-----------|------------|---------|
| 1 | {模块名} | {编号} | {N} | ✅ 已通过 / ⚠️ 有遗留 / ❌ 未评审 | supplement / recheck / full |

## 4. 小节评审覆盖度摘要

| 状态 | 后端模块数 | 前端功能点数 | Android 模块数 | iOS 模块数 |
|------|----------|------------|---------------|-----------|
| ✅ 已通过 | {N} | {M} | {P} | {Q} |
| ⚠️ 有遗留 | {N} | {M} | {P} | {Q} |
| ❌ 未评审 | {N} | {M} | {P} | {Q} |

## 5. 待全局确认清单

| 编号 | 来源小节 | 问题简述 | 状态 |
|------|---------|---------|------|

## 6. 任务完整性对比

| task-split 任务 | 状态 | 说明 |
|----------------|------|------|
| {任务名} | ✅ 已实现 / ❌ 未实现 / ⚠️ 部分实现 | {说明} |
```

## 执行指令

1. 读取 `{TASK}/task-split.md`，提取后端主分类清单、前端功能点清单，以及 **Android 任务清单（若存在「## Android 任务清单」章节）、iOS 任务清单（若存在「## iOS 任务清单」章节）**
2. 读取 `{DESIGN}/backend-design.md` 和前端入口索引 `{DESIGN}/frontend-design.md`（经其定位各分端设计文件 `frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`），建立设计基线索引（接口清单、模型清单、流程清单）
3. 读取 `{WORKSPACE}/review/review-log.md`（若存在），提取小节评审结果：
   - 每个小节的"小节摘要"中的结论（✅ 通过 / ❌ 需人工处理）
   - 每个小节的 blocking/important 未解决数
   - 顶部"待全局确认清单"
   - 抽查校验：随机抽查 1-2 个小节的发现表格，验证摘要数量与发现行数一致
4. 确定每个模块/功能点的检查策略：
   - 已通过小节评审 → `supplement`（跳过 P0，补充 P1）
   - 有遗留问题 → `recheck`（复核遗留 + P1）
   - 未经小节评审 → `full`（完整 P0 + P1）
   - 摘要数据存疑 → 视为未评审，使用 `full` 策略
5. 对比 task-split 任务清单与实际代码变更，标记未实现/部分实现的任务
6. 若 review-log.md 不存在，所有模块使用 `full` 策略，标注 `[无小节评审记录]`
7. 若 task-split.md 不含 Android 任务清单，则「Android 模块清单」章节标注「本需求无 Android 端」，Step 3b 将被跳过
8. 若 task-split.md 不含 iOS 任务清单，则「iOS 模块清单」章节标注「本需求无 iOS 端」，Step 3c 将被跳过
9. 不写任何审查结论，只做信息收集和结构化
