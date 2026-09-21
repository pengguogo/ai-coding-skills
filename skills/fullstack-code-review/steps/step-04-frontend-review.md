# Step 4: 前端功能点级审查

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-04-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: frontend-feature
- instance-source: `{WORKSPACE}/review/01-review-context.md#前端功能点清单`
- context-budget: 4000
- complexity-estimate:
  - simple: 800
  - medium: 1500
  - complex: 3000
  - default: 1500

## 参数

- input_files: [`{WORKSPACE}/review/01-review-context.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-web.md`, `{DESIGN}/backend-design.md`]
- input_files_subagent: [`{WORKSPACE}/review/summaries/01-review-context.summary.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-web.md`, `{DESIGN}/backend-design.md`]
- reference_sections:
  - `references/frontend/frontend-review-checklist.md`（blocking + important 级别）
  - `references/frontend/frontend-quality-checklist.md`（与当前功能点相关的子类）
  - `references/common/cross-cutting-review.md`（模块级检查项）
  - `references/p0/p0-frontend-checklist.md`（P0 基线，用于确定跳过范围）
- output_file_per_instance: `{WORKSPACE}/review/04-frontend-review-${instance-id}.md`
- output_file: `{WORKSPACE}/review/04-frontend-review.md`
- review_strategy: 由 01-review-context.md 中该功能点的"检查策略"字段决定（supplement / recheck / full）
- task_group_id: ${instance-id}
- domain_context: 前端功能点级代码审查，对照设计文档和检查项清单审查代码质量
- whitelist_rules: null  # 终审不修改代码，不传入白名单规则

## Summary 配置

- output: `{WORKSPACE}/review/summaries/04-frontend-review.summary.md`
- must-include:
  - 各功能点审查结论汇总表（功能点名、审查策略、blocking 数、important 数、设计偏差数）
  - 总计 blocking/important 发现数量
  - 标注 [需全局确认] 的发现数量
- must-exclude:
  - 代码文件内容
  - 逐条发现详情（保留在完整产出中）
  - 设计文档原文
- max-length: 500
- merge-rule: Scheduler 合并各实例 Summary 时，将每个实例的功能点汇总行合并为一张总表

## 产出结构

```markdown
# 前端审查：{功能点名}

## 审查范围
- 功能点：{功能点名}
- task-split 编号：{编号}
- 变更文件（{N} 个）：{文件路径列表}
- 对照设计：frontend-design.md §{章节号}
- 审查策略：{supplement / recheck / full}

## 设计一致性复核
| 设计项 | 状态 | 说明 |
|--------|------|------|

## 审查发现
| 编号 | 严重性 | 文件:行号 | 检查项 | 问题描述 | 确信度 | 修复建议 |
|------|--------|----------|--------|---------|--------|---------|

## 功能点摘要
- blocking: {发现数}
- important: {发现数}
- design-deviations: {数量}
- [需全局确认]: {数量}
- [需人工确认]: {数量}
```

## 执行指令

1. 从 `01-review-context.md` 读取当前功能点的检查策略和小节评审状态
2. **确定检查范围**：
   - `supplement` 策略：跳过 P0 级检查项（小节评审已覆盖），执行 P1 级检查项
   - `recheck` 策略：复核小节评审遗留的 blocking/important 问题 + 执行 P1 级检查项
   - `full` 策略：执行全部 P0 + P1 级检查项
3. 读取当前功能点的所有变更文件
4. 定位 `frontend-design.md` 中对应的设计章节
5. **设计一致性复核**：
   - 组件结构：组件划分、路由配置与设计一致
   - 接口调用：API 路径、参数、响应处理与后端设计一致（CC-ARCH-04）。并行场景下直接读取后端代码文件（而非 Step 3 产出）作为对比基线
   - 交互流程：用户操作流程与设计文档时序/流程图一致
6. **检查项审查**：按确定的检查范围逐文件扫描
7. **标注确信度**：每个发现标注高/中/低，低确信度标注 `[需人工确认]`
8. 跨模块才能判断的问题标注 `[需全局确认]`
9. 发现编号使用 `R{task_group_id}-{序号}`
10. 不修改代码，只输出发现
