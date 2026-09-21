# Reference 文档地图

渐进式阅读：**先读本页 → 再读核心约束 → 按需打开其他文件**。不要一次加载全部 reference。

## 每层只解决一件事

| 文件 | 唯一职责 | 何时打开 |
|------|----------|----------|
| [android-coding-standard.md](android-coding-standard.md) | **编码约束与执行原则**（tech_stack、清单、架构原则、UI/数据/安全、动手前澄清、手术式修改） | 每次写代码**必读** |
| [official-android-developer-guide-basics.md](official-android-developer-guide-basics.md) | **Google 开发者指南常用基础**（组件、Intent、Manifest、资源、权限、Jetpack/Gradle 速查） | 需查平台概念/配置时 |
| [reference.md](reference.md) | **包结构 + 类型命名表**（无示例代码） | 新建类/文件时 |
| [design-patterns-examples.md](design-patterns-examples.md) | **设计模式对照示例**（Java/Kotlin） | 实现 MVVM/Repository 等模式时 |
| [official-android-java-style.md](official-android-java-style.md) | AOSP Java 风格精要 | `tech_stack=java` 且需核对格式/异常/import |
| [official-kotlin-style.md](official-kotlin-style.md) | Kotlin 风格精要 | `tech_stack=kotlin` 且需核对格式/命名 |
| [official-android-architecture.md](official-android-architecture.md) | 官方分层/UDF/SSOT 精要 | 设计模块边界或争论架构时 |
| [official-compose-api-guidelines.md](official-compose-api-guidelines.md) | Compose API 命名与 Modifier 规则 | 写 Composable 库或公共 UI 组件时 |

## 渐进披露顺序（实现 task-split.md 单条任务）

```
1. android-coding-standard.md     ← 原则 + 约束 + 是否澄清疑问
2. official-android-developer-guide-basics.md  ← 仅当涉及 Manifest/权限/组件/资源/构建
3. reference.md                   ← 仅当涉及新路径/新类名
4. design-patterns-examples.md    ← 仅当任务明确用到某模式
5. official-* 之一（architecture/java/kotlin/compose）← 仅当争议点需要展开
```

## 调用关系（仅必要链接）

```
SKILL.md（工作流）
    → android-coding-standard.md（约束核心）
        → official-android-developer-guide-basics.md | reference.md | design-patterns-examples.md | official-*.md（按需）
```

**禁止**：为实现任务而通读所有 `official-*.md`；禁止在多个文件重复维护同一条规则（以 `android-coding-standard.md` 为准，其余只展开细节）。

## 与 task-split.md 的关系

- **任务范围与验收标准**：只来自 `{TASK}/task-split.md`（上游 `task-split` 技能产出）
- **怎么写才算合规**：来自 `android-coding-standard.md` 及本目录按需文件
