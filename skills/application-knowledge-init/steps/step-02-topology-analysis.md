# Step 2: 逆向推导架构拓扑与编号体系

## 元信息

- agent: architect
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1

## Summary 配置

- output: `{WORKSPACE}/app/summaries/02-topology.summary.md`
- must-include:
  - AG 清单表格（编号+名称）
  - APP 清单表格（编号+名称+所属 AG）
  - AC 清单索引（编号+名称+所属 APP）
  - DO 清单索引（编号+名称）
  - 集成点索引（提供方+消费方+方式）
  - S-* 映射索引（编号+场景名+涉及 APP）
- must-exclude:
  - 详细调用链分析过程
  - Mermaid 图源码
  - 组件依赖明细
- max-length: 1200

## 参数

- input_files: [`{WORKSPACE}/app/01-scope.md`]
- input_files_subagent: [`{WORKSPACE}/app/summaries/01-scope.summary.md`]
- output_file: `{WORKSPACE}/app/02-topology.md`
- domain_context: |
    基于子系统摘要逆向推导系统架构拓扑（不做正向设计决策）。
    编号规则：APP-* 从 APP-01 连续递增，先后端再前端。
    前端应用必须按终端形态拆分为独立 AG。
    S-*/DO-* 若 business 基线存在则直接引用，否则基于代码基线推导。

## 执行指令

### 1. 应用组（AG）划分
- 后端应用按业务域或子系统分组
- 前端应用必须按终端形态拆分为独立的 AG

### 2. 可部署应用（APP）划分
- APP-* 编号从 APP-01 开始连续递增，不得跳号
- 编号顺序：先后端应用，再前端应用

### 3. 应用组件（AC）识别
- AC 通常对应代码中的顶层 package 或 Maven 子模块

### 4. 跨系统集成点识别
- 明确提供方和消费方，区分集成方式（API/MQ/共享库等）

### 5. 端到端调用链分析
- 每个核心业务场景一条调用链，时序图从前端入口开始绘制

### 6. S-* 业务场景映射
- business 基线存在：直接引用其 S-* 编号
- 不存在：基于代码基线推导，粒度与包/模块对齐

### 7. 前后端串联分析
- 从前端代码基线（frontend-project.md）中提取 API 路径族
- 将路径族映射到后端应用与能力域
- 路径族与后端能力的映射必须有代码基线依据

### 8. DO-* 数据对象清单
- 从应用侧视角识别核心数据对象
- 若 business 基线存在：DO-* 编号必须与 business 侧一致
- 若不存在：基于代码基线推导

### 关键约束
- 这是逆向推导，不是正向设计——如实描述代码基线中的现状
- 不臆造不存在的 AG/APP/AC 及调用关系
- 无基线的外部服务不推断内部结构
