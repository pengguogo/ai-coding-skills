# Step 2: 全局设计合规检查

## 元信息

- agent: code-reviewer
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{WORKSPACE}/review/01-review-context.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-web.md`, `{DESIGN}/frontend-ios.md`, `{DESIGN}/frontend-android.md`, `{DESIGN}/frontend-hmos.md`, `{DESIGN}/frontend-h5.md`, `{TASK}/task-split.md`]
- input_files_subagent: [`{WORKSPACE}/review/summaries/01-review-context.summary.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{DESIGN}/frontend-web.md`, `{DESIGN}/frontend-ios.md`, `{DESIGN}/frontend-android.md`, `{DESIGN}/frontend-hmos.md`, `{DESIGN}/frontend-h5.md`, `{TASK}/task-split.md`]
- reference_sections: [`references/common/cross-cutting-review.md`]
- reference_scope: 只加载 CC-DESIGN-* + CC-ARCH-01 + CC-ARCH-02
- output_file: `{WORKSPACE}/review/02-global-compliance.md`
- review_strategy: full
- task_group_id: GLOBAL
- domain_context: 全局设计合规检查，对比设计文档与代码实现的全局一致性
- whitelist_rules: null  # 终审不修改代码，不传入白名单规则

## Summary 配置

- output: `{WORKSPACE}/review/summaries/02-global-compliance.summary.md`
- must-include:
  - 设计项覆盖度汇总（后端/前端/Android/iOS 各类设计项的覆盖率）
  - 架构合规检查结论（CC-ARCH-01/02 状态）
  - blocking/important 发现数量
  - 未实现/部分实现的任务数量
- must-exclude:
  - 设计文档原文
  - 代码文件内容
  - 抽样复核详情
- max-length: 500

## 产出结构

```markdown
# 全局设计合规检查

## 1. 设计项覆盖度汇总

### 后端设计项覆盖
| 设计项类型 | 设计文档定义数 | 代码已实现数 | 覆盖率 | 未覆盖项 |
|-----------|-------------|------------|--------|---------|

### 前端设计项覆盖
| 设计项类型 | 设计文档定义数 | 代码已实现数 | 覆盖率 | 未覆盖项 |
|-----------|-------------|------------|--------|---------|

### iOS 设计项覆盖（仅当已生成 `frontend-ios.md` 时输出）
| 设计项类型 | 设计文档定义数 | 代码已实现数 | 覆盖率 | 未覆盖项 |
|-----------|-------------|------------|--------|---------|

### Android 设计项覆盖（仅当已生成 `frontend-android.md` 时输出）
| 设计项类型 | 设计文档定义数 | 代码已实现数 | 覆盖率 | 未覆盖项 |
|-----------|-------------|------------|--------|---------|

### HMOS 设计项覆盖（仅当已生成 `frontend-hmos.md` 时输出）
| 设计项类型 | 设计文档定义数 | 代码已实现数 | 覆盖率 | 未覆盖项 |
|-----------|-------------|------------|--------|---------|

### H5 设计项覆盖（仅当已生成 `frontend-h5.md` 时输出）
| 设计项类型 | 设计文档定义数 | 代码已实现数 | 覆盖率 | 未覆盖项 |
|-----------|-------------|------------|--------|---------|

## 2. 任务完整性对比

| task-split 任务 | 设计文档对应 | 代码实现状态 | 说明 |
|----------------|------------|------------|------|

## 3. 架构合规检查

| 检查项 | 状态 | 说明 |
|--------|------|------|
| CC-ARCH-01 新增文件符合模块边界 | ✅ / ❌ | {说明} |
| CC-ARCH-02 模块间依赖方向正确 | ✅ / ❌ | {说明} |

## 4. 抽样复核

> 从已通过小节评审的模块中随机抽取 1-2 个，复核其 P0 级检查结果。

| 小节 | 抽样文件 | 复核结果 | 说明 |
|------|---------|---------|------|

## 5. 发现

| 编号 | 严重性 | 范围 | 检查项 | 问题描述 | 修复建议 |
|------|--------|------|--------|---------|---------|
```

## 执行指令

1. 读取 `01-review-context.md`，获取后端模块清单、前端功能点清单、Android 模块清单（若有）、iOS 模块清单（若有）和任务完整性对比
2. 加载 `cross-cutting-review.md` 中的 CC-DESIGN-* 和 CC-ARCH-01/02 检查项
3. **设计项覆盖度汇总复核**：
   - 从设计文档提取所有接口定义、领域模型、业务流程（前端经入口 `frontend-design.md` 定位各分端设计文件 `frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`）
   - 对比代码实现，统计覆盖率（后端/前端(PC Web)/iOS/Android/HMOS/H5 分别统计）
   - 汇总小节评审中各小节的设计一致性检查结果
4. **任务完整性对比**：
   - 对比 task-split 任务清单与 01-review-context.md 中的实现状态
   - 标记未实现或部分实现的任务
5. **架构合规检查**：
   - CC-ARCH-01：检查新增文件是否在正确的模块目录下
   - CC-ARCH-02：检查模块间依赖方向是否正确
6. **抽样复核**：
   - 从已通过小节评审的模块中随机抽取 1-2 个
   - 重新扫描其代码文件的 P0 级检查项
   - 验证小节评审结论是否可靠
7. 发现编号使用 `RG-{序号}`（G = Global）
8. 不修改代码，只输出发现
