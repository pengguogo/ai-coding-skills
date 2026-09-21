# Step 3b: Android 模块级审查

> 本步骤与 Step 3（后端）、Step 4（前端）无数据依赖，Scheduler 可并行执行。
> **条件执行**：仅当 `01-review-context.md` 存在「Android 模块清单」且非空时执行；否则 Scheduler 跳过本步骤。

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-03b-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: android-module
- instance-source: `{WORKSPACE}/review/01-review-context.md#Android模块清单`
- context-budget: 4000
- complexity-estimate:
  - simple: 800
  - medium: 1500
  - complex: 3000
  - default: 1500

## 参数

- input_files: [`{WORKSPACE}/review/01-review-context.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-android.md`, `{DESIGN}/backend-design.md`]
- input_files_subagent: [`{WORKSPACE}/review/summaries/01-review-context.summary.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-android.md`, `{DESIGN}/backend-design.md`]
- reference_sections:
  - `references/android/android-review-checklist.md`（blocking + important 级别）
  - `references/android/android-quality-checklist.md`（与当前模块相关的子类）
  - `references/common/cross-cutting-review.md`（模块级检查项）
  - `references/p0/p0-android-checklist.md`（P0 基线，用于确定跳过范围）
- output_file_per_instance: `{WORKSPACE}/review/03b-android-review-${instance-id}.md`
- output_file: `{WORKSPACE}/review/03b-android-review.md`
- review_strategy: 由 01-review-context.md 中该模块的"检查策略"字段决定（supplement / recheck / full）
- task_group_id: ${instance-id}
- domain_context: Android 模块级代码审查，对照设计文档和检查项清单审查代码质量
- whitelist_rules: null  # 终审不修改代码，不传入白名单规则

## Summary 配置

- output: `{WORKSPACE}/review/summaries/03b-android-review.summary.md`
- must-include:
  - 各模块审查结论汇总表（模块名、审查策略、blocking 数、important 数、设计偏差数）
  - 总计 blocking/important 发现数量
  - 标注 [需全局确认] 的发现数量
- must-exclude:
  - 代码文件内容
  - 逐条发现详情（保留在完整产出中）
  - 设计文档原文
- max-length: 500
- merge-rule: Scheduler 合并各实例 Summary 时，将每个实例的模块汇总行合并为一张总表

## 产出结构

```markdown
# Android 审查：{模块名}

## 审查范围
- 模块：{模块名}
- task-split 编号：{编号}
- 变更文件（{N} 个）：{文件路径列表}
- 对照设计：frontend-android.md §{章节号}（经入口 frontend-design.md 定位）
- 审查策略：{supplement / recheck / full}

## 设计一致性复核
| 设计项 | 状态 | 说明 |
|--------|------|------|

## 审查发现
| 编号 | 严重性 | 文件:行号 | 检查项 | 问题描述 | 确信度 | 修复建议 |
|------|--------|----------|--------|---------|--------|---------|

## 模块摘要
- blocking: {发现数}
- important: {发现数}
- design-deviations: {数量}
- [需全局确认]: {数量}
- [需人工确认]: {数量}
```

## 执行指令

1. 从 `01-review-context.md` 读取当前模块的检查策略和小节评审状态
2. **确定检查范围**：
   - `supplement` 策略：跳过 P0 级检查项（小节评审已覆盖），执行 P1 级检查项
   - `recheck` 策略：复核小节评审遗留的 blocking/important 问题 + 执行 P1 级检查项
   - `full` 策略：执行全部 P0 + P1 级检查项
3. 读取当前模块的所有变更文件（Android 仓库内）
4. 经入口 `frontend-design.md` 定位并打开 `frontend-android.md`，找到对应功能点的设计章节
5. **设计一致性复核**：
   - 接口契约：Retrofit Service 路径、方法、参数/返回类型与 backend-design.md 一致（AQ-NET-04 / CC-ARCH-04）。并行场景下直接读取后端代码文件作为对比基线
   - 数据模型：data class / Entity 字段覆盖设计文档所有字段
   - 状态与流转：ViewModel 的 UiState、状态切换与设计一致
   - 界面与交互：Activity/Fragment/Compose 结构、用户操作流程与设计一致
6. **检查项审查**：按确定的检查范围逐文件扫描（命名/架构/空安全/生命周期/线程/权限/安全）
7. **标注确信度**：每个发现标注高/中/低，低确信度标注 `[需人工确认]`
8. 跨模块才能判断的问题标注 `[需全局确认]`
9. 发现编号使用 `R{task_group_id}-{序号}`
10. 不修改代码，只输出发现
