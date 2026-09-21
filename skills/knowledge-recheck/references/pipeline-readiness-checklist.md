# 流水线就绪与归档检查清单（`knowledge-recheck`）

检查 `{BASE_DIR}` 下各阶段产出是否存在，并判定是否**具备归档条件**或**已完成归档**。

**执行要求**：下表 **每一个** PR-* 检查项均须执行并写入 Step 2 §7 结论表，**禁止**跳过。

## 需求目录产出检查

| 检查项 ID | 路径 | 通过标准 | 严重度 |
|-----------|------|---------|--------|
| PR-01 | `{REQ}/requirement.md` | present 且含需求项清单 | P0（requirement-doc 模式） |
| PR-02 | `{DESIGN}/backend-design.md` | 有后端实现预期时 present | P1 |
| PR-03 | `{DESIGN}/frontend-design.md` | 有前端实现预期时 present | P1 |
| PR-04 | `{TASK}/task-split.md` | 进入编码前应有；复检时可 partial | P1 |
| PR-05 | `{WORKSPACE}/review/review-log.md` 或 `{BASE_DIR}/review/` | 可选；缺失标注 partial | P2 |
| PR-06 | `{ARCHIVE}/code-archive.md` | 代码已交付时应 present | **P0** |
| PR-07 | `{ARCHIVE}/appliaction-archive.md` | 同上 | **P0** |
| PR-08 | `{ARCHIVE}/business-archive.md` | 同上 | **P0** |

## 归档就绪判定

**已实现但未归档**（须写入报告 §5）：

1. `{TASK}/task-split.md` 或 design 存在，且代码范围/仓库中有对应实现证据
2. `{ARCHIVE}/` 下三件套**任一 absent** 或文件为空
3. → 建议动作：**执行 `project-archive`**

**尚未到归档阶段**（not-applicable）：

- 仅有 requirement.md，无 design/task/代码 → archive 缺失 **不判 P0**，标注「流水线未达归档阶段」

## 代码实现证据（用于判定是否应已归档）

| 证据来源 | 说明 |
|---------|------|
| 用户指定代码范围 | 指定路径下存在本次需求相关变更 |
| `{CODE_KNOWLEDGE}` 与 design 对照 | 接口/模块已在代码库存在 |
| git 变更（若可访问） | 与 task-split 任务对应的文件已修改 |

无法确认代码是否已实现 → 标注 `[需人工确认]`，**不强行判未归档 P0**。

## 流水线阶段状态汇总

| 阶段 | 最低就绪条件 | complete 条件 |
|------|-------------|---------------|
| 需求成稿 | requirement.md present | 含完整需求项 |
| 系统设计 | 至少一份 design present（按范围） | backend+frontend design 齐全（全栈需求） |
| 任务拆分 | task-split present | 任务与 design 对齐 |
| 代码实现 | 代码证据存在 | task 主项已实现 |
| 代码评审 | review-log present（可选） | 终审通过或无 blocking |
| 统一归档 | archive 三件套 present | 三件套非空且与需求/design 可追溯 |

## 与 project-archive 的关系

本技能**不替代** `project-archive`，仅检测并提示：

- 未归档 → 报告建议用户启动 `project-archive`
- 已归档但知识库未融合 → 报告 §6 列出具体缺口，建议重跑 archive 融合步骤或手动核对 step-03-fusion-and-check
