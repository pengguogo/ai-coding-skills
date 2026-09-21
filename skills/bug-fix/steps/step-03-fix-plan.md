# Step 3: 修复方案与影响面冻结 [改前门禁]

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{WORKSPACE}/bugfix/02-locate-and-impact.md`, `[Step 1 命中的基线文件]`]
- output_file: `{BASE_DIR}/bug/<id>-<slug>-fix-plan.md`（持久留底，含 `## 修复方案` 锚点）
- reference_files: [`references/bug-triage-standard.md`, `references/fix-plan-template.md`]
- domain_context: 基于根因与预期行为基线决策修复方案、冻结允许改动范围、产验证计划、做越界检查

## 执行指令

本步是 Phase locate-and-plan 末步，`halt-after: true` → 完成后输出改前确认门禁交付报告。**本步产出 `{BASE_DIR}/bug/<id>-<slug>-fix-plan.md` 为持久留底（不随 `_workspace` 清理），是改前确认门禁呈现给用户的方案依据；`{BASE_DIR}/bug/` 目录若不存在由本步首次写入时创建（与 `design/`、`task/` 平级）。**

1. **修复方案**（含 `## 修复方案` 章节锚点，供 L3 code-reviewer 引用）：每条修复决策须引用应然基线出处，证明对齐意图而非主观发挥：

   | # | 修复决策 | 对应根因(文件:行号) | 基线出处 | 偏离类型 |
   |---|---|---|---|---|

   基线出处取值：设计章节（如 `backend-design.md#4.2`）/ REQ 编号 / 知识库文件 / `[无设计基线-代码现状推断]`（仅 Step 1 判为无设计基线时允许）。

2. **允许改动文件清单（冻结基线）**——三列：仓库 / 角色 / 文件路径（相对仓库根）。纯逻辑 bug 的新增单测文件须纳入（位于标准测试目录）。

3. **关联风险与影响**——列间接影响（调用链上下游）/ 数据影响 / 兼容性风险 / 回归风险点 / 同源缺陷（同一根因函数是否多处调用需一并处理），供改前门禁让用户看清波及面。

4. **受影响模块与建议编译命令**（供 Step 5 注入 build-verifier）。

5. **验证计划**：静态因果自证必做；纯逻辑根因且有测试框架 → 单测计划+命令；纯逻辑但无测试框架 → 标 `[无测试基建]` 降级；运行时类根因 → 人工回归点清单。

6. **越界检查**——命中任一 → STATUS_REPORT `BLOCKED`，输出「升级 fullstack-design + task-split」并终止：
   - 需新增/变更对外接口签名或 DTO 字段
   - 需 DDL 结构变更
   - 需引入新模块/新依赖/新状态机（调整已有依赖版本不算越界，但强制 L3）
   - 修复涉及文件数 > 8（阈值见 references）

7. 若 Step 1 判为无设计基线，方案顶部置顶风险横幅 `⚠️ [无设计基线，修复基于代码现状推断，须人工确认预期行为]`。

## 产出结构

完整字段骨架见 `references/fix-plan-template.md`，章节顺序：头部元信息（关联需求/级别/类型/根因结论）→ 修复方案表 → 允许改动文件清单 → 关联风险与影响 → 受影响模块与编译命令 → 验证计划 → 越界检查。

## STATUS_REPORT

越界命中 → `BLOCKED`；否则 `OK`。完成后 Scheduler Halt，输出改前确认门禁交付报告。
