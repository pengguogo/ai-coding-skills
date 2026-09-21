# 知识库就绪度评估标准

Step 0 Phase C 在知识库拉取与结构校验通过后执行，**不阻塞**后续需求分析，但须写入 `{KNOWLEDGE}/_workspace/product-req/00-kb-readiness.md` 并在控制台摘要输出。

## 层级状态判定

对每个层级扫描 `{KNOWLEDGE}/` 下对应目录：

| 状态 | 判定条件 |
|------|---------|
| `present` | 目录存在，且含至少 1 个 `.md` 文件 |
| `empty` | 目录存在，但无 `.md` 文件 |
| `absent` | 目录不存在 |

### 扫描范围

| 层级 | 路径 | 备注 |
|------|------|------|
| code | `knowledge/code/` | 有子目录时统计各 `<项目名>/` 下 `.md` |
| application | `knowledge/application/` | 直接统计 `.md` |
| business | `knowledge/business/` | 直接统计 `.md` |
| custom | `knowledge/custom/` | 可选层 |

## 综合就绪度

| 等级 | 条件 | 对 Step 1 的建议 |
|------|------|-----------------|
| `ready` | `business` 为 present；或 `application` 与 `code` 均为 present | 可充分做知识库对照 |
| `partial` | 仅 1 个主层（code / application / business）为 present | 对照有限；术语以材料为准，缺口标注 `[知识库待补充]` |
| `minimal` | 各主层均为 empty 或 absent（仅 custom 或无内容） | 等同无知识库分析；Step 1 跳过深度对照，不 Halt |

## 产出模板

```markdown
# 知识库就绪度评估

评估时间：<ISO8601>
OCSPEC_ROOT: <路径>

| 层级 | 路径 | 状态 | .md 文件数 | 备注 |
|------|------|------|-----------|------|
| code | knowledge/code/ | present/empty/absent | N | |
| application | knowledge/application/ | ... | N | |
| business | knowledge/business/ | ... | N | |
| custom | knowledge/custom/ | ... | N | |

KNOWLEDGE_READINESS: ready | partial | minimal

## 建议
- <对 Step 1 知识库对照的具体建议>
- <若 minimal/partial，建议后续运行 code/application/business-knowledge-init 或 project-archive>
```

## 与 knowledge-recheck 的关系

本评估为**轻量、非阻塞**的就绪检查，不替代 `knowledge-recheck` 的全量缺口报告。
