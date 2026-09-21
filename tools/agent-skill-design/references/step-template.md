# Step 模板

> 复制此模板创建新的步骤文件，替换 `{...}` 占位符。

---

```
# Step {N}: {步骤中文名}

## 元信息

- execution-mode: {inline | subagent}
- agent: {agent-name}  ← subagent 模式时填写，inline 模式下可删除此行
- checkpoint: checkpoints/step-0N-checkpoint.md  ← 有质量校验点时填写，否则可删除此行

## 参数

- input: {输入来源（前置步骤产出 / 用户输入 / 工作区文件）}
- output: {本步骤产出物描述}

## 执行指令

{详细的执行步骤，用编号列表，描述每一步要做什么、用什么工具、注意什么}

### 1. {子步骤1}

{具体操作说明}

### 2. {子步骤2}

{具体操作说明}

---

## 产出

- {产出物1}
- {产出物2}
```
