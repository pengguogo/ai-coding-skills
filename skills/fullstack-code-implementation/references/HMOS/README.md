# Reference 文档地图（HMOS 鸿蒙）

渐进式阅读：**先读本页 → 再读核心约束 → 按需打开其他文件**。不要一次加载全部 reference。

## 每层只解决一件事

| 文件 | 唯一职责 | 何时打开 |
|------|----------|----------|
| [hmos-coding-standard.md](hmos-coding-standard.md) | **编码约束与执行原则**（tech_stack、清单、架构原则、UI/数据/安全、动手前澄清、手术式修改） | 每次写代码**必读** |
| [architecture.md](architecture.md) | **架构分层与模块职责**（Stage 模型、HAP/HAR 模块组织、分层规范） | 需查模块划分/分层职责时 |
| [reference.md](reference.md) | **目录结构 + 类型命名表**（无示例代码） | 新建类/文件时 |
| [design-patterns.md](design-patterns.md) | **设计模式对照示例**（ArkTS） | 实现 MVVM/Repository 等模式时 |
| [security-performance.md](security-performance.md) | **安全、性能与内存** | 涉及存储安全、列表性能、并发或内存时 |
| [examples.md](examples.md) | **常见错误快速正反对比** | 需要快速确认某个写法对不对时 |

## 渐进披露顺序（实现 task-split.md 单条任务）

```
1. hmos-coding-standard.md         ← 原则 + 约束 + 是否澄清疑问
2. architecture.md                 ← 仅当涉及模块划分/新建模块
3. reference.md                    ← 仅当涉及新路径/新类名
4. design-patterns.md              ← 仅当任务明确用到某模式
5. security-performance.md         ← 仅当涉及安全/性能/并发
6. examples.md                     ← 仅当需快速正反确认
```

## 调用关系（仅必要链接）

```
SKILL.md（工作流）
    → hmos-coding-standard.md（约束核心）
        → architecture.md | reference.md | design-patterns.md | security-performance.md | examples.md（按需）
```

**禁止**：为实现任务而通读所有文件；禁止在多个文件重复维护同一条规则（以 `hmos-coding-standard.md` 为准，其余只展开细节）。

## 与 task-split.md 的关系

- **任务范围与验收标准**：只来自 `{TASK}/task-split.md`（上游 `task-split` 技能产出）
- **怎么写才算合规**：来自 `hmos-coding-standard.md` 及本目录按需文件
