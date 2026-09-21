# Agent: cross-verifier

## 任务

校验 Step 5 生成的 `{domain}_arch.html` 与 Step 6 生成的所有 flow HTML 之间的引用一致性和内容一致性。

## 输入

- `{domain}_arch.html` 文件路径
- 所有 `{场景}/UC-{CODE}-{NN}_flow.html` 文件路径列表

## 校验策略

### 1. 引用检查

- 解析 arch HTML 中的 JS MAP 对象，提取 `{UC-ID: 场景名}` 映射
- 验证每个 UC-ID 在 flow 目录下存在对应文件 `{场景名}/UC-ID_flow.html`
- 验证每个 flow 页的 `.back-link` 正确指向 `../{domain}_arch.html`
- 验证 flow 页的 `.nav-link` 指向的 `../../../code/...` 路径（不要求一定存在，但需标注）

### 2. 内容检查

- 提取 arch 页用例清单中的编号、名称、核心说明
- 提取 flow 页的 UC_ID、UC_NAME 和说明
- 逐条比对一致性

### 3. 格式检查

- 检查 ocspec 根下、与 `knowledge/` 同级的 `{OCSPEC_ROOT}/common/` 下 case.css、mermaid.min.js 是否已落盘
- 检查各页面引用前缀按深度可解析：总览 `../../common/`、领域 `../../../common/`、flow `../../../../common/`、code `../../../../common/`
- 检查 Mermaid 初始化参数

## 输出格式

```
## 跨文档一致性校验报告

### 引用检查
| 检查项 | 结果 | 说明 |
|--------|------|------|
| arch→flow 文件映射 | ✅/❌ | |
| JS MAP 场景名 vs 目录名 | ✅/❌ | |
| flow .back-link 有效性 | ✅/❌ | |
| flow 关联链接有效性 | ✅/⚠️ | |

### 内容检查
| 检查项 | 结果 | 说明 |
|--------|------|------|
| 用例编号一致性 | ✅/❌ | |
| 用例名称一致性 | ✅/❌ | |
| 参与者一致性 | ✅/❌ | |
| 实体一致性 | ✅/❌ | |

### 格式检查
| 检查项 | 结果 | 说明 |
|--------|------|------|
| common 落盘 | ✅/❌ | |
| CSS/JS 引用路径 | ✅/❌ | |
| Mermaid 参数 | ✅/❌ | |

### 总结
- 通过：N 项
- 需修正：N 项
- 建议：...
```

## 约束

- 只做校验，不修改文件
- 无法自动修复的标注 `[需人工确认]`
