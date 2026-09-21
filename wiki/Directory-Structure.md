# 目录结构

```text
ai-coding-skills/
├── skills/       # 19 个核心技能
├── analysis/     # 3 个专项分析技能
├── arch/         # 业务领域架构技能
├── tools/        # 技能设计元技能
├── agents/       # 共享执行角色
├── commands/     # Scheduler 协议与初始化脚本
├── wiki/         # Wiki 文档
├── README.md     # English overview
└── README.zh.md  # 中文完整说明
```

典型技能目录由 `SKILL.md`、`steps/`、`checkpoints/`、`references/`、可选私有 `agents/` 与脚本组成。共享 Agent 位于仓库根目录 `agents/`，共享调度协议位于 `commands/`。
