# Step 4: 交接组装与质量自检

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-04-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/prototype/01-source-inventory.md`, `{WORKSPACE}/prototype/02-rule-extraction.md`, `{WORKSPACE}/prototype/03-conflict-log.md`]
- input_files_subagent: [`{WORKSPACE}/prototype/01-source-inventory.md`, `{WORKSPACE}/prototype/02-rule-extraction.md`, `{WORKSPACE}/prototype/03-conflict-log.md`]
- output_file: `{REQ}/prototype-derivation.md`
- reference_files: [`references/prototype-derivation-reference.md`]
- status_report_file: `{WORKSPACE}/prototype/04-status-report.md`
- upstream_compare: [`{WORKSPACE}/prototype/01-source-inventory.md`, `{WORKSPACE}/prototype/02-rule-extraction.md`]

## 执行指令

### 1. 输出路径自检

1. 确认 Init 已解析 `{OCSPEC_ROOT}`（工作区下 `ocspec-*`，见 scheduler-protocol §1.2.1）
2. 交付物位于 `{OCSPEC_ROOT}/requirements/<需求英文名>_<yyyymmdd>/requirement/` 下
3. 禁止工作区根 `_workspace/`、根 `requirements/`、用工作区名新建的并行 `ocspec-*`

### 2. 按顺序组装

将中间产出合并为完整的推导交付文档。合并时必须剥离每个文件末尾的 `<!-- STATUS_REPORT -->` 块。

```
# [需求名称] — 原型推导交付物

## 1. 推导索引表
（从 01-source-inventory.md 提取）

## 2. 页面角色矩阵
（从 01-source-inventory.md 提取）

## 3. 推导明细
（从 02-rule-extraction.md 提取，按模块组织）

## 4. 冲突/决策日志
（从 03-conflict-log.md 提取）

## 5. 笔误与命名待统一
（从 03-conflict-log.md 提取）

## 6. 交接说明

### 6.1 可写入正式规格的成熟内容
### 6.2 须产品决策后写入
### 6.3 依赖其他模块
### 6.4 建议
```

### 3. 质量自检（推导 Pass 质量清单）

- [ ] 每个 P0 主题至少对应一个已点名的主原型来源
- [ ] 已完成页面角色矩阵，区分主规则页、状态页、入口页、动作页、后管页、纯图页、无可见文本页
- [ ] 表格与枚举规则已收录，或已写明暂缓原因
- [ ] 已按「忽略 CSS 隐藏节点」规则处理，未将 `display:none` / `visibility:hidden` 内容误写入需求
- [ ] 对总表页已做支撑页补检，未用汇总页替代状态页/操作页细则
- [ ] 冲突已列出，未凭主观合并
- [ ] 非文字类视觉已标出待干系人确认
- [ ] 已完成至少一次跨页一致性核对（时效、入口、类型、结果、状态映射）

### 4. 全局一致性校验

- 术语在全文中是否一致（模块名、页面名、状态名）
- 推导索引表中的模块在推导明细中均有对应章节
- 冲突日志中的来源页在推导索引表中可追溯
- 格式规范：表格列完整、Markdown 语法正确

### 5. 交接说明编写

明确哪些规则已稳定、哪些待决策、哪些依赖其他模块。建议正式规格对关键规则做条文内化。

### 6. 待确认项清零检查

扫描终稿全文，搜索残留标记：`[需与产品确认]`、`[需人工确认]`、`<!-- STATUS_REPORT -->`。如有残留，状态必须为 `DONE_WITH_CONCERNS`。

状态报告写入 `{WORKSPACE}/prototype/04-status-report.md`，不写入终稿。
