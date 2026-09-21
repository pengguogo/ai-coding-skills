# 小节评审配置（Android）

> 供 Step 2 小节评审步骤注入 `code-reviewer`（仅 **`Android-{N}`** 批次执行）。

## 检查项清单

| 参数 | 值 |
|------|-----|
| checklist_file | `skills/fullstack-code-review/references/p0/p0-android-checklist.md` |
| review_strategy | `full`（小节评审始终全量 P0） |
| design_doc | `{DESIGN}/frontend-android.md`（Android 分端设计文件，经入口 `frontend-design.md` 定位） |

## 白名单修复规则（L1.5）

传入 `whitelist_rules` 时启用自动修复，否则只读审查：

| # | 问题类型 | 修正动作 | 检查项 |
|---|---------|---------|--------|
| 1 | 缺少 AI-Generate 标记 | 补充 `// AI-Generate`（Kotlin/Java）或 `<!-- AI-Generate -->`（XML） | CC-AI-01 |
| 2 | 主线程耗时操作 | 移至后台线程/协程（viewModelScope 等） | AD-ANR-01 |
| 3 | 资源/监听未释放 | 补充 close/unregister，Fragment 置空 Binding | AD-LIFE-01 / AD-LIFE-02 |
| 4 | 硬编码敏感信息 | 替换为 BuildConfig 或安全存储 | CC-SEC-01 |

## 设计章节定位

从 `00-task-groups.md` Android 主分类表读取 design 章节。

## 变更文件范围

仅审查 `01-task-group-log-Android-{N}.md` 中的 Android 变更文件；`BE-*`、`FE-*`、`iOS-*`、`HMOS-*`、`H5-*` 批次不执行本配置。
