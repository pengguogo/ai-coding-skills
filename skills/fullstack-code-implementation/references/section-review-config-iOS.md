# 小节评审配置（iOS）

> 供 Step 2 小节评审步骤注入 `code-reviewer`（仅 **`iOS-{N}`** 批次执行）。

## 检查项清单

| 参数 | 值 |
|------|-----|
| checklist_file | `skills/fullstack-code-review/references/p0/p0-ios-checklist.md` |
| review_strategy | `full`（小节评审始终全量 P0） |
| design_doc | `{DESIGN}/frontend-ios.md`（iOS 分端设计文件，经入口 `frontend-design.md` 定位） |

## 白名单修复规则（L1.5）

传入 `whitelist_rules` 时启用自动修复，否则只读审查：

| # | 问题类型 | 修正动作 | 检查项 |
|---|---------|---------|--------|
| 1 | 缺少 AI-Generate 标记 | 补充 `// AI-Generate` 注释 | CC-AI-01 |
| 2 | 强引用循环 | delegate 属性 `strong` → `weak`；闭包补 `[weak self]` | IO-MEM-01 |
| 3 | 主线程外更新 UI | 包裹 `DispatchQueue.main.async {}` / `dispatch_get_main_queue()` | IQ-THREAD-02 |
| 4 | 硬编码敏感信息 | 替换为配置引用或 Keychain | CC-SEC-01 |

## 设计章节定位

从 `00-task-groups.md` iOS 主分类表读取 design 章节。

## 变更文件范围

仅审查 `01-task-group-log-iOS-{N}.md` 中的 iOS 变更文件；`BE-*`、`FE-*`、`Android-*`、`HMOS-*`、`H5-*` 批次不执行本配置。
