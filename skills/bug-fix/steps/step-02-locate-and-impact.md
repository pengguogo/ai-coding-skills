# Step 2: 定向定位与影响面分析

## 元信息

- agent: bug-analyzer
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{WORKSPACE}/bugfix/01-intake-and-triage.md`]
- baseline_files: `[按 Step 1 基线来源取：设计文档 {DESIGN}/（按 bug_type 取 architecture/backend/frontend-design.md）+ {REQ}/requirement.md + {TASK}/task-split.md；或退化 {KNOWLEDGE}/business/ + {KNOWLEDGE}/application/]`
- repo_paths: `[用户指定的涉及仓库根路径数组，标注 frontend/backend]`
- knowledge_root: `{CODE_KNOWLEDGE}`
- output_file: `{WORKSPACE}/bugfix/02-locate-and-impact.md`
- reference_files: [`references/bug-triage-standard.md`]
- bug_level: `[Step 1 判定级别]`
- bug_type: `[Step 1 判定类型]`
- domain_context: 先读基线确立预期行为，再定位实际代码偏离基线的根因，产影响面清单与纯逻辑标注

## 执行指令

注入 `bug-analyzer` 角色定义后执行，强调：

1. 读 `baseline_files` 相关章节，提炼「预期行为」并标注出处（设计章节 / REQ 编号 / 知识库文件）；无设计基线时显式标注。
2. 按布局判定读知识库（目录 index → 单文件 → 平铺分册；前端 frontend-project.md 直读），命中后只展开相关域文件，禁止全量、禁止无 index 即中止。
3. 在 `repo_paths` 内按 `bug_level` 追调用链；前端纯样式跳过调用链。
4. 定位根因 = 代码实际行为 vs 预期行为基线的偏差，「报错表象 → 根因」因果链引用基线出处，精确到文件+行号。
5. 产影响面清单（直接/间接/数据），不含允许改动清单。
6. 标注 `root-cause-pure-logic`（根因函数是否不依赖 IO）。

## Summary 配置

- output: `{WORKSPACE}/bugfix/summaries/02-locate-and-impact.summary.md`
- must-include:
  - 根因（文件+行号）+ 报错表象→根因因果链
  - 预期行为基线出处（设计章节 / REQ 编号 / 知识库文件 / 无设计基线）
  - 影响面清单（直接/间接/数据）
  - root-cause-pure-logic（是/否）
- must-exclude:
  - 源码大段摘录
  - 允许改动清单（属 Step 3）
- max-length: 800

## STATUS_REPORT

由 bug-analyzer 产出，含 `baseline-source` / `root-cause-pure-logic` / `root-cause-confidence` 等字段。
