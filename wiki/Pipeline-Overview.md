# 流水线总览

```text
知识流水线:
workspace-init → code-knowledge-init → application-knowledge-init → business-knowledge-init

需求与设计:
prototype-derivation（可选）
  → requirement-analysis | product-requirement-analysis
  → fullstack-design → task-split

实现与交付:
task-split → fullstack-code-implementation → fullstack-code-review → project-archive
```

`knowledge-recheck` 与 `bug-fix` 为横切技能，可按需独立运行。`analysis/`、`arch/`、`tools/` 下的技能为自包含专项单元，共享 Scheduler 协议，但不要求进入主流水线。

所有编排均由 `commands/scheduler-protocol.md` 解释并驱动。
