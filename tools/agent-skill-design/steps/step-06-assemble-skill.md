# Step 6: 组装 SKILL.md

## 元信息

- execution-mode: inline

## 参数

- input: Step 1-5 的完整产出
- reference: `references/skill-template.md`
- output: 目标技能的 SKILL.md + 完整技能目录

## 执行指令

### 1. 汇总所有设计决策

从前面步骤提取以下信息填入 `references/skill-template.md` 的对应占位符：

| 占位符 | 来源 |
|--------|------|
| `{skill-name}` | Step 1 需求澄清 → 技能标识 |
| `{技能中文标题}` | Step 1 需求澄清 → 核心功能 |
| `{场景1/2/3}` | Step 1 需求澄清 → 触发场景 |
| `{能力1/2/3/4}` | Step 2 阶段设计 → 步骤摘要 |
| `{原则名1/2/3}` | Step 1 需求澄清 → 关键约束 |
| `{模板文件名}` | Step 5 产出模板 → 模板路径 |
| `{产出文件名}` | Step 1 需求澄清 → 输出命名 |
| `{阶段N}` | Step 2 阶段设计 → Phases 划分 |
| `{步骤名}` | Step 2 阶段设计 → Steps 列表 |
| `agent-name` | Step 3 代理设计 → 子代理名 |
| 责任矩阵 | Step 3 代理设计 → 执行模式表 |

### 2. 按模板组装

1. 打开 `references/skill-template.md`
2. 逐段替换占位符为实际内容
3. 生成目标技能的 SKILL.md 文件

### 3. 验证 SKILL.md 完整性

- [ ] frontmatter 含 `name` 和 `description`
- [ ] description 含功能说明 + 触发条件 + 触发词
- [ ] Phases 中每个 Step 路径指向的 `steps/*.md` 文件已创建
- [ ] 每个 subagent 步骤对应的 `agents/*.md` 文件已创建（若有）
- [ ] 每个校验点对应的 `checkpoints/*.md` 文件已创建（若有）
- [ ] 规范来源中引用的 `references/*` 文件已创建（若有）
- [ ] 交付物命名规则与 Step 1 一致

### 4. 生成完整目录结构

确认目标技能目录包含以下所有文件：

```
{skill-name}/
├── SKILL.md                  ← 本步骤产出
├── README.md                 ← 可选，后续手工补充
├── steps/
│   ├── step-01-*.md          ← Step 2 设计的步骤
│   ├── step-02-*.md
│   └── ...
├── checkpoints/
│   └── step-0N-checkpoint.md ← Step 4 设计的校验清单
├── references/
│   └── *-template.*          ← Step 5 设计的模板
└── agents/
    └── *.md                  ← Step 3 设计的子代理指令
```

### 5. 输出完成确认

```
## 组装完成

### 目标技能
- 名称：{skill-name}
- 路径：c:\Users\zhangtao811\.kiro\skills\{skill-name}/
- SKILL.md：已生成（验证通过）

### 文件清单
| 文件 | 状态 |
|------|------|
| SKILL.md | ✅ |
| steps/step-01-*.md | ✅ |
| ... | ✅ |

### 使用方式
向 AI 对话发送触发词即可激活此技能。
```

## 产出

- 目标技能的完整 SKILL.md
- 完整技能目录结构（所有 step/checkpoint/reference/agent 文件）
