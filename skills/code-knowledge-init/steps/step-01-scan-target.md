# Step 1: 扫描工作区目录，列出候选代码库

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## Summary 配置

- output: `{WORKSPACE}/code/summaries/01-scan-target.summary.md`
- must-include:
  - 候选代码库清单表格（目录名+构建工具+路径）
  - 用户选择结果（选中的目标列表）
  - monorepo 判断结果
- must-exclude:
  - 目录扫描的详细过程
- max-length: 500

## 参数

- input_files: [工作区根目录（目录扫描）]
- output_file: `{WORKSPACE}/code/01-scan-target.md`
- domain_context: 为代码知识还原确定扫描目标，扫描工作区识别候选代码库
- extraction_schema: |
    # 扫描目标确定

    ## 1. 候选代码库清单
    | 序号 | 目录名 | 构建工具 | 路径 | 备注 |
    |------|--------|---------|------|------|

    ## 2. Monorepo 判断
    - 是否为 monorepo：[是/否]
    - 判断依据：[...]

    ## 3. 用户选择
    - 选中目标：[目标列表]
    - 并行策略：[单目标/多目标并行/分批并行]

    ## 4. 待确认清单
    | 序号 | 问题 | 影响范围 |
    |------|------|---------|

## 执行指令

**路径前置（Scheduler 已完成 Init）**：`{OCSPEC_ROOT}`、`{KNOWLEDGE}`、`{WORKSPACE}` 已由 `[路径解析]` 确定（无候选时仅 Init §1.2.2 可兜底新建，本步骤**不得**再建 `ocspec-*`）。若存在与 `OCSPEC_ROOT` 不一致的并行 `ocspec-*` → **BLOCKED**。

1. 优先使用用户明确指定的仓库根、模块根或子工程根
2. 若用户未指定，扫描当前工作区根下的所有一级目录，将命中下列**任一**工程信号的目录列为候选代码库（**排除** `.cursor`、`ocspec-*` 目录本身）：

   | 工程信号 | 构建工具列填写 | 备注列可标注 |
   |---------|---------------|-------------|
   | `pom.xml` / `build.xml` | Maven / Ant | 后端或一体化候选 |
   | `build.gradle` / `build.gradle.kts` / `settings.gradle(.kts)` | Gradle | 后端或 Android 候选；若同时存在 `AndroidManifest.xml` 备注「疑似 Android」 |
   | `package.json` | npm/pnpm/yarn（按锁文件） | Web / 跨端 / 小程序候选 |
   | `AndroidManifest.xml` +（`settings.gradle(.kts)` 或 Android Gradle Plugin） | Gradle | Android 客户端 |
   | `oh-package.json5` / `build-profile.json5` / `module.json5` | Hvigor | 鸿蒙客户端 |
   | `.xcodeproj` / `.xcworkspace` / `Podfile` / `Package.swift` | Xcode / SPM / CocoaPods | iOS 客户端 |
   | `pubspec.yaml`（含 `flutter`） | Flutter | 跨端-Flutter 候选 |
   | 小程序：`project.config.json` / `app.json`（微信）等 | 小程序工具链 | 小程序候选 |

3. 列出候选清单并询问用户选择（支持多选，逗号分隔）
4. 若是 monorepo 或多模块仓库，先识别当前任务真正对应的工程根，不得将子模块误判为独立工程；同仓多端（如 `android/` + `ios/` + `web/`）应分别列为候选或在备注标明子工程路径
5. 确定并行策略：2-3 个目标可并行，4+ 个分批
6. 按 extraction_schema 的结构写入 output_file
7. 产出末尾附加 STATUS_REPORT

### 关键约束
- 候选代码库清单必须来自实际目录扫描，不得凭印象列举
- 若存在多个候选工程且无法判断归属，应列出候选并标注 [需人工确认]
- 不做项目属性识别（由 Step 2 负责）
- **禁止**在本步骤创建 ocspec 根；若 Init 已兜底新建，仅在摘要中引用，不在待确认清单中当作本步骤行为
