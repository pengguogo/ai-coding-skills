# Step 6: 汇总判定与终审交付

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-06-checkpoint.md
- checkpoint-level: L2

## 参数

- input_files:
  - `{WORKSPACE}/review/summaries/01-review-context.summary.md`
  - `{WORKSPACE}/review/summaries/02-global-compliance.summary.md`
  - `{WORKSPACE}/review/summaries/03-backend-review.summary.md`
  - `{WORKSPACE}/review/summaries/03b-android-review.summary.md`（若存在 Android 模块）
  - `{WORKSPACE}/review/summaries/03c-ios-review.summary.md`（若存在 iOS 模块）
  - `{WORKSPACE}/review/summaries/04-frontend-review.summary.md`
  - `{WORKSPACE}/review/summaries/05-impact-analysis.summary.md`
  - `{WORKSPACE}/review/review-log.md`
- input_files_subagent:
  - `{WORKSPACE}/review/summaries/01-review-context.summary.md`
  - `{WORKSPACE}/review/summaries/02-global-compliance.summary.md`
  - `{WORKSPACE}/review/summaries/03-backend-review.summary.md`
  - `{WORKSPACE}/review/summaries/03b-android-review.summary.md`（若存在 Android 模块）
  - `{WORKSPACE}/review/summaries/03c-ios-review.summary.md`（若存在 iOS 模块）
  - `{WORKSPACE}/review/summaries/04-frontend-review.summary.md`
  - `{WORKSPACE}/review/summaries/05-impact-analysis.summary.md`
  - `{WORKSPACE}/review/review-log.md`
- reference_sections:
  - `references/common/review-log-template.md`（终审章节模板）
  - `references/common/commit-suggestion-template.md`
- output_files:
  - 终审章节追加到 `{WORKSPACE}/review/review-log.md`
  - `{WORKSPACE}/review/commit-suggestion.md`（仅通过时生成）
- domain_context: 终审汇总判定，基于各步骤 Summary 产出最终结论和交付物
- whitelist_rules: null  # 终审不修改代码

## 执行指令

### 1. 汇总统计

从各步骤 Summary 中提取发现统计，汇总为以下表格：

| 来源 | blocking | important |
|------|----------|-----------|
| 小节评审（review-log.md） | 发现数 / 已修复数 / 未解决数 | 同左 |
| 全局设计合规（Step 2 Summary） | 发现数 | 发现数 |
| 后端模块审查（Step 3 Summary） | 发现数 | 发现数 |
| Android 模块审查（Step 3b Summary，若有） | 发现数 | 发现数 |
| iOS 模块审查（Step 3c Summary，若有） | 发现数 | 发现数 |
| 前端功能点审查（Step 4 Summary） | 发现数 | 发现数 |
| 影响分析（Step 5 Summary） | 发现数 | 发现数 |

### 2. 最终判定

| 条件 | 判定 |
|------|------|
| 0 blocking 未解决 + important 未解决 ≤ 2 | ✅ 通过 |
| 0 blocking 未解决 + important 未解决 3~5 | ⚠️ 有条件通过 |
| 存在 blocking 未解决，或 important 未解决 > 5 | ❌ 不通过 |

### 3. 追加终审结论到 review-log.md

按 `review-log-template.md` 的终审章节模板，将以下内容追加到 `review-log.md` 的 `<!-- APPEND_HERE -->` 标记前：
- 全局设计合规检查结果（从 Step 2 Summary 提取）
- 跨模块检查结果（从 Step 2 Summary 提取 CC-ARCH-04/05）
- 全局确认清单复核结果（从 Step 5 Summary 提取）
- 影响分析摘要（从 Step 5 Summary 提取四维度状态）
- 终审发现（汇总 Step 2/3/3b/3c/4/5 中所有 blocking/important 发现，统一编号为 RF-{序号}）
- 汇总统计
- 最终判定
- 后续动作

追加完成后，更新评审元信息中的"当前状态"为"已完成"。

### 4. 生成 commit-suggestion.md（仅通过时）

若最终判定为 ✅ 通过 或 ⚠️ 有条件通过：
- 按 `commit-suggestion-template.md` 生成 commit 建议
- 按功能模块拆分 commit
- 列出完整文件清单（从 Step 1 Summary 的变更范围提取）
- 标注人工确认事项

若最终判定为 ❌ 不通过：
- 不生成 commit-suggestion.md
- 在 review-log.md 后续动作中标注"修复终审发现的问题后触发增量复核"
