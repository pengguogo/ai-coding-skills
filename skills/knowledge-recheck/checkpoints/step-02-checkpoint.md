# Checkpoint: Step 2 知识库覆盖与缺口分析

> **审查级别**：L1（轻量审查）— 只检查结构和内容维度。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件与 reference 清单逐项核对。

## 审查时需打开的文件
- 产出文件：`{WORKSPACE}/knowledge-recheck/02-knowledge-gap-analysis.md`
- 比对清单：`references/knowledge-coverage-checklist.md`、`references/pipeline-readiness-checklist.md`
- 上游：`{WORKSPACE}/knowledge-recheck/01-intake-and-scope.md`

## 结构检查
- [ ] 包含章节：流水线阶段完成度
- [ ] 包含章节：knowledge/code 覆盖
- [ ] 包含章节：knowledge/application 覆盖（§4，非空或明确 missing 说明）
- [ ] 包含章节：knowledge/business 覆盖（§5，非空或明确 missing 说明）
- [ ] 包含章节：知识库三层一致性（§5.1）
- [ ] 包含章节：需求项 × 知识库追溯矩阵
- [ ] 包含章节：追溯矩阵覆盖统计（§6.1）
- [ ] 包含章节：检查清单逐项结论（§7，含全部 CK/AK/BK/PR ID）
- [ ] 包含章节：未归档项清单
- [ ] 包含章节：知识库未更新功能清单
- [ ] code-scope / hybrid 时包含：代码范围反查 + §10.1 覆盖统计

## 内容检查
- [ ] 流水线表中 archive 三件套行存在且状态有证据路径
- [ ] **完整覆盖**：§6 追溯矩阵行数 = Step 1 需求项应检数量（§4.1 或 §3 索引行数）
- [ ] **完整覆盖**：§6.1「是否 100%」= 是
- [ ] **完整覆盖**：§7 检查清单表包含 references 中**全部** CK/AK/BK/PR（及 CU，若 applicable）检查项 ID，无遗漏
- [ ] **完整覆盖**：code-scope / hybrid 时 §10 反查行数 = Step 1 代码范围应检数量；§10.1「是否 100%」= 是
- [ ] 若 Step 1 显示 design/task 已 present 但 archive 任一 absent → 未归档项清单**逐条**列出受影响需求项/功能（禁止「等多项」合并描述）
- [ ] **三层分别检查**：§3/§4/§5 均存在；禁止仅有 §3 code 而无 application/business 结论
- [ ] §7 检查清单包含**全部** CK-*、AK-*、BK-* ID（及 applicable PR/CU）
- [ ] §6 追溯矩阵 **code / app / biz** 三列均逐行填写，禁止仅填 code 列
- [ ] §9「缺失层级」使用 `code` / `application` / `business` 枚举，禁止笼统写「知识库」
- [ ] §10 代码反查表含 **code / app / biz 知识** 分列（code-scope / hybrid）
- [ ] 每条缺口有证据路径或 `[需人工确认]` 说明
- [ ] 未归档项建议动作含 `project-archive`（若存在未归档项）
- [ ] 知识库未更新项的建议动作合理（project-archive / code-knowledge-init 等）
- [ ] **未修改** knowledge/ 与业务代码（只读分析）

## 待确认项提取
- 追溯矩阵中综合状态为 partial/missing 且标注 `[需人工确认]` 的项
- code-scope 反查中「需求文档是否覆盖」为未知的项
