---
name: agent-skill-design
description: |
  Agent Skill 设计器（元技能）。借鉴 sql-impact-analyzer 的分阶段/分步骤/校验驱动/模板引用设计模式，
  系统化引导完成任意技能的 5W1H 需求澄清、Phase/Step 阶段划分、agent 执行模式分配、质量校验机制搭建、产出模板设计与 SKILL.md 自动组装。
  适用场景：当用户要设计一个新的 Agent Skill，或要把一个模糊的想法转化为结构化的技能定义时使用。
  触发词：agent skill 设计、设计 agent 技能、创建技能模板、技能设计、agent 技能、Agent-Skill-Design。
---

# Agent Skill 设计器

## 何时使用

- 用户有一个模糊的技能想法，需要系统化梳理为可执行的技能定义
- 用户想参照 `sql-impact-analyzer` 的分阶段设计模式来设计一个新技能
- 需要设计一个包含多个阶段、步骤、子代理、校验点的复杂技能
- 已有简单技能的 SKILL.md，需要升级为完整的 Phase/Step 架构

## 核心能力

- 需求澄清：将用户的模糊想法转化为结构化的 5W1H 规格清单
- 阶段划分：按自然边界将任务拆分为 Phase/Step，理清数据流
- 代理分配：决策每个步骤用 inline 还是 subagent，设计子代理指令
- 质量机制：在关键节点设置校验点，定义审查级别和重试策略
- 模板设计：为最终交付物设计格式模板和占位符映射
- 自动组装：基于所有设计决策自动生成完整的 SKILL.md 和目录结构

## 执行原则

- **模板驱动（强制）**：先使用 `references/skill-template.md` 确定最终 SKILL.md 的骨架，再逐步填充
- **阶段自然分割**：不做过度拆分，按输入→处理→校验→输出的自然边界划分 Phase
- **校验内建**：每个关键结论步骤之后必须跟一个校验步骤（或内置校验清单）
- **代理最小化**：只在需要独立搜索或独立验证时使用 subagent，其余保持 inline
- **占位符统一**：模板中的所有插入点使用 `{SNAKE_CASE}` 格式，避免命名冲突
- **产出目录全量生成**：目标技能目录必须包含 SKILL.md + 所有引用的 step/checkpoint/reference/agent 文件

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/skill-template.md` | SKILL.md 填充模板（含占位符速查表） |
| `references/step-template.md` | Step 文件模板 |
| `references/checkpoint-template.md` | Checkpoint 文件模板 |
| `references/agent-template.md` | Agent 指令文件模板 |

## 路径与产出约定

- **目标技能输出位置**：`c:\Users\zhangtao811\.kiro\skills/{skill-name}/`
- **目标技能命名规则**：`{skill-name}` 使用 kebab-case 格式
  - 示例：`sql-impact-analyzer`、`code-review-checker`
  - 无法确定时使用 `custom-skill`
- **产出目录结构**：
  ```
  {skill-name}/
  ├── SKILL.md
  ├── steps/
  ├── checkpoints/
  ├── references/
  └── agents/
  ```

## 执行入口

按以下步骤顺序执行。Step 2-5 之间无强依赖，可在完成 Step 2 后并行设计 Step 3-5。

---

## Phases

### Phase: requirement

- Step 1: steps/step-01-requirement-clarification.md

### Phase: design

- Step 2: steps/step-02-phase-design.md
- Step 3: steps/step-03-agent-design.md
- Step 4: steps/step-04-quality-mechanism.md
- Step 5: steps/step-05-output-template.md

### Phase: assembly

- Step 6: steps/step-06-assemble-skill.md

---

## 交付物

- `{skill-name}/SKILL.md`（目标技能根目录）
- `{skill-name}/steps/*.md`（步骤定义文件）
- `{skill-name}/checkpoints/*.md`（质量校验清单）
- `{skill-name}/references/*`（产出模板文件）
- `{skill-name}/agents/*.md`（子代理定义文件）
- `{skill-name}/README.md`（技能说明文档）

## Agent 职责矩阵

| 步骤 | 执行方式 | 做什么 |
|------|----------|--------|
| Step 1 需求澄清 | inline | 提取 5W1H、确定输入输出契约、定义触发词和约束 |
| Step 2 阶段设计 | inline | 将任务拆分为 Phase/Step、设计步骤间数据流 |
| Step 3 代理设计 | inline | 分配 inline/subagent 模式、定义子代理指令要点 |
| Step 4 质量机制 | inline | 设计校验点位置和审查级别、编写校验清单 |
| Step 5 产出模板 | inline | 设计最终交付物的格式模板和占位符映射表 |
| Step 6 组装 SKILL.md | inline | 汇总所有设计决策、按模板填充、生成完整技能目录 |
