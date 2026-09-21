---
name: code-constraint-analyzer
description: |
  扫描 Java 代码库，识别无效代码、冗余代码、重复代码，治理异常处理与 Debug 日志，按场景与风险等级分级，输出含分析报告、优化方案与单测覆盖的 HTML 文档。
  触发词：代码约束分析、代码质量扫描、deadcode、冗余代码、重复代码、异常处理治理、debug日志治理、code constraint analyzer。
---

# 代码约束分析（Code Constraint Analyzer）

## 何时使用

- 代码质量巡检：发现无效代码、冗余逻辑、重复模式
- 异常治理：区分系统异常(可重试)和业务异常(不可重试)，发现吞没/误分类/无重试
- Debug日志治理：按关键链路×量级矩阵决策移除/升级/保留
- 技术债清偿阶段，需要系统化优化建议和改造方案
- 重构前评估：量化"哪些代码需要清理 / 哪些逻辑可以简化 / 哪些模块可以抽取"

## 核心能力

- 五场景并行扫描：无效代码 / 冗余代码 / 重复代码 / 异常处理 / Debug 日志各自独立 subagent
- 异常二分法：外部调用异常必须区分系统异常(重试可恢复)→业务异常(不可重试)
- Debug矩阵决策：关键链路×量级二维矩阵 → 移除/改info/改trace/保留
- 风险分级：high(核心链路) / medium(性能/可维护性) / low(代码整洁)
- 分析+方案一体化：定位证据→风险分析→优化方案(before/after)→单测覆盖
- HTML 自包含报告(浏览器直接查看，内联 CSS)

## 执行原则

- **一次扫描**：只扫描一次代码库，按五场景分流结果
- **入口层锚定**：从HTTP/RPC/MQ/Scheduled/扩展点出发做可达性分析
- **异常二分法**：系统异常(重试可恢复) vs 业务异常(不可重试)
- **日志矩阵决策**：关键链路×量级矩阵 → 保留/升级/移除
- **证据可追溯**：每项发现标注文件名+行号+代码片段
- **方案可落地**：before/after代码+单测覆盖方案

## 路径与产出约定

- **输出位置**：`upgrade/{scene}_{date}/`
- **输出命名**：`analysis_{riskLevel}.html`
  - scene: `deadcode` / `redundant` / `duplicate` / `exception` / `debugLog`
  - date: `YYYYMMDD`
  - riskLevel: `high` / `medium` / `low`

## 执行入口

---

## Phases

### Phase: intake

- Step 1: steps/step-01-intake.md

### Phase: scan

- Step 2: steps/step-02-deadcode-scan.md
- Step 3: steps/step-03-redundant-scan.md
- Step 4: steps/step-04-duplicate-scan.md
- Step 5: steps/step-05-exception-governance.md
- Step 6: steps/step-06-debuglog-governance.md

### Phase: classify

- Step 7: steps/step-07-classify.md

### Phase: design

- Step 8: steps/step-08-solution-design.md

### Phase: verify

- Step 9: steps/step-09-quality-check.md

### Phase: output

- Step 10: steps/step-10-report-generation.md

---

## 交付物

- `upgrade/{scene}_{date}/analysis_{riskLevel}.html`（最多 15 份 HTML 报告）

## Agent 职责矩阵

| 步骤 | 执行方式 | 做什么 |
|------|----------|--------|
| Step 1 输入收集 | inline | 确定代码库路径、技术栈、入口层定位 |
| Step 2 无效代码扫描 | subagent: deadcode-scanner | 注释代码 + 入口不可达代码 |
| Step 3 冗余代码扫描 | subagent: redundancy-scanner | N+1查询、重复调用、可简化逻辑 |
| Step 4 重复代码扫描 | subagent: duplication-scanner | 重复逻辑块、可抽取共用模块 |
| Step 5 异常处理扫描 | subagent: exception-scanner | 系统/业务异常分类，吞没/误分类/无重试 |
| Step 6 Debug日志扫描 | subagent: debuglog-scanner | 关键链路×量级矩阵，移除/升级/敏感检测 |
| Step 7 分析归类 | inline | 五场景合并→风险分级→按场景拆桶 |
| Step 8 方案设计 | inline | 高中风险项出优化方案+单测方案 |
| Step 9 质量校验 | subagent: scan-verifier | 独立验证：问题真实性、漏检、分级合理性 |
| Step 10 报告生成 | inline | 按模板生成HTML报告并落盘 |
