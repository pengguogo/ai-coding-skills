# Checkpoint: Step 3 质检报告终稿（Final）

> **审查级别**：L2（完整审查）— 结构、内容与全局一致性。
> **审查原则**：你是审查者，不是作者。必须重新打开终稿与 Step 2 缺口分析逐项核对。

## 审查时需打开的文件
- 终稿：`{BASE_DIR}/knowledge-recheck/knowledge-quality-report.md`
- 上游比对：`{WORKSPACE}/knowledge-recheck/02-knowledge-gap-analysis.md`
- 模板：`references/knowledge-quality-report-standard.md`

## 路径合规
- [ ] 终稿位于 `{BASE_DIR}/knowledge-recheck/` 下（或报告中已说明 fallback 至 `{WORKSPACE}/knowledge-recheck/`）
- [ ] 工作区根不存在误建的 `recheck/` 目录

## 章节完整性（对照 knowledge-quality-report-standard.md）
- [ ] §1 复检摘要（含总体判定 ✅/⚠️/❌）
- [ ] §2 复检范围与输入
- [ ] §3 流水线阶段完成度
- [ ] §4 知识库完整性（**4.1 code / 4.2 application / 4.3 business 分节**，及 4.4 三层一致性）
- [ ] §5 未归档需求与功能提示
- [ ] §6 知识库未更新功能清单
- [ ] §7 需求项追溯矩阵（**完整**，行数 = Step 1 需求项数）
- [ ] §7.1 追溯矩阵覆盖统计（100%）
- [ ] §8 检查清单逐项结论附录（全部 CK/AK/BK/PR ID）
- [ ] §9 建议后续动作（P0/P1）
- [ ] §10 待确认项汇总

## 内容一致性
- [ ] Step 2 §6.1、§10.1 覆盖统计均为 100%
- [ ] Step 2「未归档项清单」条目**全部**体现在 §5（逐条，无合并遗漏）
- [ ] Step 2「知识库未更新功能清单」条目**全部**体现在 §6（逐条）
- [ ] 报告 §7 追溯矩阵行数 = Step 2 §6 矩阵行数 = Step 1 需求项应检数量
- [ ] 总体判定与缺口数量一致：无 P0 缺口且 archive 完整 → 不得判 ❌
- [ ] 建议动作与缺口类型匹配

## 待确认项提取
- 终稿中所有 `[需人工确认]` 均在 §10 列出
- status_report 中 concerns 与终稿一致
