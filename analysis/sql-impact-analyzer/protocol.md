# sql-impact-analyzer — 状态机实例

> 本文件为 Skill 自包含状态机实例。
> 通用规则见下方「附录 A：通用调度规则」。本文件自包含全部调度规则。
> 本文件仅定义 **sql-impact-analyzer** 专用的 Phase/Step 拓扑与策略。

## 基础配置

| 属性 | 值 |
|------|-----|
| base-dir-scope | requirement（可选独立执行） |
| halt-policy | none |
| Phase 数 | 3 |
| Step 数 | 9 |
| Template Step | 否 |
| 条件 Phase | 否 |

> 3 Phase 连续执行，在 output Phase 停止。Step 5 独立 subagent L2 交叉校验。XLSX 内嵌副本与此一致

## Phase/Step 拓扑

| Phase | Halt | Step | Agent | 执行模式 | Checkpoint | 类型 |
|-------|------|------|-------|----------|------------|------|
| analysis | → 否 | 1 | - | 直接执行 | L1 | static |
| analysis | → 否 | 2 | - | 独立 Subagent | L1 | static |
| analysis | → 否 | 3 | - | 直接执行 | L1 | static |
| analysis | → 否 | 4 | - | 直接执行 | L1 | static |
| verification | → 否 | 5 | general-task-execution | 独立 Subagent | L2 | static |
| output | ⏸ 是 | 6 | - | 直接执行 | L1 | static |

## Checkpoint 等级分布

| 等级 | 步骤数 | 适用步骤 |
|------|--------|----------|
| L1 | 5 | Step 1, 2, 3, 4, 6 |
| L2 | 1 | Step 5 |

## 等待点（Halt Point）

- ⏸ Phase "output" 的 Step 6 之后

## 本地 Agent

- `agents/quality-checker.md`

## 状态转移

```
Init → 解析路径变量 → 读取 SKILL.md →
  ├─ [analysis] Exec(Step 1) → Check(1) → Exec(Step 2) → Check(2) → Exec(Step 3) → Check(3) → Exec(Step 4) → Check(4) → Exec(Step 5) → Check(5) → Exec(Step 6) → Check(6) → Exec(Step 7) → Check(7) → Next
  │  （用户确认后继续）
  ├─ [verification] Exec(Step 8) → Check(8) → Next
  │  （用户确认后继续）
  ├─ [output] Exec(Step 9) → Check(9) → Halt ⏸
  └─ 全部完成 → 输出交付报告 → 结束
```

## 与主协议的关系

本文件是自包含的 Skill 状态机实例，已内联所有通用调度规则。

- **本文件独有**：Phase/Step 拓扑、Checkpoint 等级分布、Halt 策略、本地 Agent 清单
- **通用规则**：见下方「附录 A：通用调度规则」

Scheduler 运行时优先使用本文件。