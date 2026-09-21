---
name: workspace-init
description: 开发空间初始化：读取工作区根目录 repos.txt（TSV：name/type/url/branch），在根目录按 name 自动 clone/更新并切换分支；初始化结束后必须校验各仓库是否就绪，异常时尝试安全修复，无法修复则输出可执行的手动清单。触发词：空间初始化、工作区初始化、初始化环境、一键拉代码、按清单 clone、切换分支、准备开发环境、检查 clone 结果。
---

# 空间初始化（Workspace Init）

## 何时使用

- 用户需要从 repos.txt 批量 clone/更新多个仓库到工作区根目录
- 新机器或新工作区的初始化
- 已有工作区的批量更新（切换分支、拉取最新代码）
- 用户要求检查已有仓库的状态并修复异常
- 触发词：空间初始化、工作区初始化、初始化环境、一键拉代码、按清单 clone、切换分支、准备开发环境、检查 clone 结果

## 核心能力

- 读取 `repos.txt` 批量 clone 或更新多个仓库
- 幂等切换分支、fetch/pull，并校验仓库状态
- 安全处理异常仓库，输出可执行的手动修复清单
- 遵守不 reset、不删除、不覆盖非 git 目录的安全边界

## 执行原则

- **自动化执行**：按 repos.txt 逐行执行 clone/更新/切分支/pull，无需人工逐步操作
- **不产出额外文件**：除 git 创建的各 `<name>` 仓库目录外，不落盘任何文件（无日志、无标记文件、无辅助脚本）；过程与结果仅在控制台输出
- **不依赖脚本**：直接使用 git 命令完成所有操作
- **幂等执行**：重复运行不产生破坏性副作用（目录存在则 fetch+checkout，不存在则 clone）
- **安全边界**：不执行 `reset --hard`、不删除目录、不覆盖非 git 目录、不自动 merge、不写入凭据

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/repos-template.md` | repos.txt 格式模板与示例 |

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

> **注意**：workspace-init 可能在 agents/ 和 commands/ 尚未同步到编辑器之前被触发（它是流水线第一步）。`{COMMANDS_ROOT}` / `{AGENTS_ROOT}` 按 scheduler-protocol §10 三级回退策略解析。

**读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 后，按下方步骤声明开始执行。**

## 与其他技能的关系

- 下游：`code-knowledge-init` 依赖 workspace-init 完成后的仓库目录
- 并行：`spec-skills-refresh` 可在 workspace-init 之前或之后独立执行

> 上述为默认上下游关系；用户亦可单独指定使用本技能，提供输入后直接执行。

## Phases

### Phase: init（初始化）
halt-after: true

- Step 1: steps/step-01-parse-config.md
- Step 2: steps/step-02-clone-update.md
- Step 3: steps/step-03-verify-repair.md

## 交付物

- 工作区根目录下各 `<name>/` 仓库目录（由 repos.txt 驱动，持久化）
- 控制台输出：执行报告（通过/已修复/失败汇总 + 手动清单，非持久化）
