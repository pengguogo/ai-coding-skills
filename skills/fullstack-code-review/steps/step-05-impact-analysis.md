# Step 5: 全局影响分析

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-05-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files:
  - `{WORKSPACE}/review/01-review-context.md`
  - `{WORKSPACE}/review/review-log.md`
  - `{TASK}/task-split.md`
  - `{DESIGN}/backend-design.md`
  - `{DESIGN}/architecture-design.md`
  - `{DESIGN}/frontend-design.md`
- input_files_subagent:
  - `{WORKSPACE}/review/summaries/01-review-context.summary.md`
  - `{WORKSPACE}/review/review-log.md`
  - `{TASK}/task-split.md`
  - `{DESIGN}/backend-design.md`
  - `{DESIGN}/architecture-design.md`
  - `{DESIGN}/frontend-design.md`
- reference_sections:
  - `references/common/impact-analysis-checklist.md`（IA-* 全量）
- output_file: `{WORKSPACE}/review/05-impact-analysis.md`
- domain_context: 全局影响分析，评估改动范围、向后兼容、回滚方案和可观测性
- whitelist_rules: null  # 终审不修改代码

## Summary 配置

- output: `{WORKSPACE}/review/summaries/05-impact-analysis.summary.md`
- must-include:
  - 四个维度的检查结论（改动范围、向后兼容、回滚方案、可观测性）
  - 每个维度的状态（✅ / ❌ / ⏭️）
  - blocking/important 发现数量
  - 全局确认清单复核结论
- must-exclude:
  - 检查项原文
  - 设计文档引用原文
  - 详细的示例代码
- max-length: 600

## 产出结构

```markdown
# 全局影响分析

## 1. 全局确认清单复核

| 编号 | 来源小节 | 问题简述 | 终审判定 | 说明 |
|------|---------|---------|---------|------|
| {编号} | #{N} | {简述} | ✅ 确认无问题 / ❌ 确认为问题 | {说明} |

## 2. 改动范围分析（IA-SCOPE）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| IA-SCOPE-01 调用链上游影响 | ✅ / ❌ / ⏭️ | {说明} |
| IA-SCOPE-02 调用链下游影响 | ✅ / ❌ / ⏭️ | {说明} |
| IA-SCOPE-03 共享组件影响 | ✅ / ❌ / ⏭️ | {说明} |
| IA-SCOPE-04 数据库变更影响 | ✅ / ❌ / ⏭️ | {说明} |

## 3. 向后兼容（IA-COMPAT）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| IA-COMPAT-01 接口向后兼容 | ✅ / ❌ / ⏭️ | {说明} |
| IA-COMPAT-02 数据库向后兼容 | ✅ / ❌ / ⏭️ | {说明} |
| IA-COMPAT-03 MQ 消息兼容 | ✅ / ❌ / ⏭️ | {说明} |
| IA-COMPAT-04 配置项兼容 | ✅ / ❌ / ⏭️ | {说明} |

## 4. 回滚与应急（IA-ROLLBACK）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| IA-ROLLBACK-01 代码可回滚 | ✅ / ❌ / ⏭️ | {说明} |
| IA-ROLLBACK-02 数据库可回滚 | ✅ / ❌ / ⏭️ | {说明} |
| IA-ROLLBACK-03 功能开关 | ✅ / ❌ / ⏭️ | {说明} |
| IA-ROLLBACK-04 灰度发布支持 | ✅ / ❌ / ⏭️ | {说明} |

## 5. 可观测性（IA-OBSERVE）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| IA-OBSERVE-01 关键路径日志 | ✅ / ❌ / ⏭️ | {说明} |
| IA-OBSERVE-02 监控指标覆盖 | ✅ / ❌ / ⏭️ | {说明} |
| IA-OBSERVE-03 告警规则配置 | ✅ / ❌ / ⏭️ | {说明} |

## 5b. 移动端影响（IA-MOBILE，仅当存在 Android/iOS 变更时输出）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| IA-MOBILE-01 接口对存量客户端兼容 | ✅ / ❌ / ⏭️ | {说明} |
| IA-MOBILE-02 本地存储迁移（Room / CoreData） | ✅ / ❌ / ⏭️ | {说明} |
| IA-MOBILE-03 最低版本与 API 兼容（minSdk / Deployment Target） | ✅ / ❌ / ⏭️ | {说明} |
| IA-MOBILE-04 强制更新与灰度 | ✅ / ❌ / ⏭️ | {说明} |

## 6. 影响分析发现

| 编号 | 严重性 | 检查项 | 问题描述 | 修复建议 |
|------|--------|--------|---------|---------|
| RI-001 | {级别} | {IA-*} | {描述} | {建议} |

## 7. 影响分析摘要

- blocking: {发现数}
- important: {发现数}
- 全局确认清单：{已复核数} / {确认为问题数}
- 四维度状态：改动范围 {✅/❌} | 向后兼容 {✅/❌} | 回滚方案 {✅/❌} | 可观测性 {✅/❌}
```

## 执行指令

### 1. 全局确认清单复核

- 从 `review-log.md` 顶部读取"待全局确认清单"
- 逐项复核，结合全局视角给出终审判定：
  - ✅ 确认无问题
  - ❌ 确认为问题（升级为影响分析发现）

### 2. 全局影响分析（IA-*）

加载 `impact-analysis-checklist.md`，按以下维度执行全局影响分析：

| 维度 | 检查项范围 | 审查基线 |
|------|-----------|---------|
| 改动范围 | IA-SCOPE-01~04 | task-split.md 依赖关系 |
| 向后兼容 | IA-COMPAT-01~04 | backend-design.md 对外接口 |
| 回滚方案 | IA-ROLLBACK-01~04 | backend-design.md 风险评估 |
| 可观测性 | IA-OBSERVE-01~03 | backend-design.md 监控与告警 |
| 移动端影响（条件） | IA-MOBILE-01~04 | frontend-ios.md / frontend-android.md / frontend-hmos.md（经入口 frontend-design.md 定位）+ backend-design.md §3.2 |

> **IA-MOBILE 条件执行**：仅当本需求存在 iOS/Android/HMOS 等移动端原生变更（01-review-context.md 含对应端模块清单）时执行；否则该维度全部标注 ⏭️ 并说明"本需求无移动端变更"。

### 3. 输出规则

- 发现编号使用 `RI-{序号}`（I = Impact）
- 不适用的检查项标注 ⏭️ 并说明原因
- 不修改代码，只输出发现
