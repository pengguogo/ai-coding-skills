# Step 3: 质检报告组装与交付 [强制停止]

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-03-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/knowledge-recheck/01-intake-and-scope.md`, `{WORKSPACE}/knowledge-recheck/02-knowledge-gap-analysis.md`, `{WORKSPACE}/knowledge-recheck/summaries/01-intake-and-scope.summary.md`, `{WORKSPACE}/knowledge-recheck/summaries/02-knowledge-gap-analysis.summary.md`]
- input_files_subagent: [`{WORKSPACE}/knowledge-recheck/summaries/01-intake-and-scope.summary.md`, `{WORKSPACE}/knowledge-recheck/summaries/02-knowledge-gap-analysis.summary.md`, `{WORKSPACE}/knowledge-recheck/02-knowledge-gap-analysis.md`]
- output_file: `{BASE_DIR}/knowledge-recheck/knowledge-quality-report.md`
- reference_files: [`references/knowledge-quality-report-standard.md`]
- status_report_file: `{WORKSPACE}/knowledge-recheck/03-status-report.md`
- upstream_compare: [`{WORKSPACE}/knowledge-recheck/02-knowledge-gap-analysis.md`]

## 执行指令

### 1. 输出路径自检

1. 确认 Init 已输出 `[路径解析]`，`{BASE_DIR}`、`{OCSPEC_ROOT}` 已解析
2. 终稿写入 `{BASE_DIR}/knowledge-recheck/knowledge-quality-report.md`；若 `{BASE_DIR}` 无法确定，写入 `{WORKSPACE}/knowledge-recheck/knowledge-quality-report.md` 并在报告 §1 说明
3. **禁止**：工作区根 `recheck/`、写入 `{KNOWLEDGE}/` 或业务仓库

### 2. 按模板组装

打开 `references/knowledge-quality-report-standard.md`，按章节结构合并 Step 1、Step 2 产出，生成完整质检报告。须包含：

- 复检摘要与总体判定（✅ 通过 / ⚠️ 部分通过 / ❌ 不通过）
- 流水线阶段完成度表
- 知识库各层完整性结论（**§4.1 code / §4.2 application / §4.3 business 分节** + §4.4 三层一致性）
- **未归档需求/功能提示**（醒目小节，含建议执行 `project-archive`；**逐条**列出，禁止合并）
- **知识库未更新功能清单**（**缺失层级**须标注 code / application / business；**逐条**列出）
- **需求项追溯矩阵（完整版，100% 覆盖；code / app / biz 三列均须填写）**
- **检查清单逐项结论附录**（全部 CK/AK/BK/PR 检查项 ID）
- 建议后续动作清单（按优先级 P0/P1 排序）

### 3. 全局一致性校验

- Step 2 覆盖统计均为 100%；若非 100% → **不得落盘终稿**，返回 Step 2 补全
- Step 2 中每条「未归档项」「知识库未更新项」均出现在报告对应章节
- 报告 §7 追溯矩阵行数 = Step 1 需求项应检数量；code-scope 时 §10 反查行数 = Step 1 代码范围应检数量
- 建议动作与缺口类型匹配（未归档 → project-archive；知识缺失 → knowledge-init 或 archive 融合）
- 判定与证据一致，无无依据的 ❌

### 4. 修正与落盘

- 术语与 Step 1 需求项索引一致
- 无法自动确认项保留 `[需人工确认]`
- 状态报告写入 `{WORKSPACE}/knowledge-recheck/03-status-report.md`，不写入终稿

### 5. 待确认项清零检查

终稿中 `[需人工确认]` 须在 §10 待确认项汇总 中逐条列出；存在待确认项时 status 为 `DONE_WITH_CONCERNS`
