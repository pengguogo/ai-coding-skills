# Step 4: 前端文档扫描与生成

## 元信息

- agent: code-scanner
- checkpoint: checkpoints/step-04-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{WORKSPACE}/code/01-scan-target.md`, `{WORKSPACE}/code/02-tech-detect.md`, `{CODE_KNOWLEDGE}/scan-plan.md`]
- input_files_subagent: [`{WORKSPACE}/code/summaries/01-scan-target.summary.md`, `{WORKSPACE}/code/summaries/02-tech-detect.summary.md`, `{CODE_KNOWLEDGE}/scan-plan.md`]
- output_file: `{CODE_KNOWLEDGE}/frontend-project.md`
- reference_sections: [`references/frontend/project_init_standard.md`]
- domain_context: |
    执行前端代码扫描并生成 frontend-project.md。
    前端类项目不走后端扫描规则注册表；统一 AI 直接扫描（grepSearch + readCode），按 project_init_standard.md 生成。
    一体化项目按「传统一体化项目适配」；Android/鸿蒙/iOS 按「移动端客户端项目适配」；
    Flutter/React Native/小程序按「跨端与小程序项目适配」。

## 执行指令

1. 确认项目类型（与 Step 2 一致）。本步骤不加载后端注册表；扫描范围与产出结构以 `project_init_standard.md` 为准。
2. 按类型确定扫描范围：
   - 现代前端（Web）：`src/` 下 pages/views/components/services/store/router
   - 传统一体化前端：webapp/、static/、resources/templates/ 等
   - Android：`settings.gradle(.kts)`、`build.gradle(.kts)`、`libs.versions.toml`、`AndroidManifest.xml`、`app/src/main/java|kotlin/`、`res/`、`assets/`、`res/navigation/`
   - 鸿蒙：`build-profile.json5`、`hvigorfile.ts`、`oh-package.json5`、`module.json5`、`entry/src/main/ets/`、`resources/`
   - iOS：`.xcodeproj`、`.xcworkspace`、`Package.swift`、`Podfile`、`Info.plist`、`Assets.xcassets`、`*.swift`/`*.m`/`*.mm`、Storyboard/XIB
   - Flutter：`pubspec.yaml`、`lib/`
   - React Native：`package.json`、JS/TS 源码与 `android/`/`ios/` 原生目录（按需）
   - 小程序：`app.json`/`project.config.json`、`pages/`、`components/`
3. AI 直接扫描并写入 `frontend-project.md`：业务总览、业务功能模块与路由/界面入口、核心业务流程、接口调用清单、目录结构、技术栈、UI 风格与组件参考、项目开发约束（细则见 project_init_standard）
4. 分段写入（每段 ≤300 行）
5. 写入后门禁校验：文档条目数 vs 扫描提取条目数偏差 > 5% → 阻断；空说明 > 0 → 回头补全
6. 在 scan-plan.md 中回写本步骤进度：可增加「前端文档生成」行（策略 AI 直接扫描、状态 DONE、实际产出数取模块/接口等关键计数），或更新 Step 2 已注明的「前端路径：Step 4」状态；**不**将前端扫描项写入后端注册表体系

### 合理性检查（前端扫描同样适用）
扫描完成后执行以下检查（不通过则修正后重检）：
- 覆盖率：产出条目 / grepSearch 命中数 < 0.80 → 逐条归因，修正后重跑
- 字段完整度：非空非占位字段 / 总字段 < 0.30 → 判断是项目特征还是提取 bug
- 禁止以 [需人工确认] 替代未完成的修复
- [需人工确认] 占比不超 20%，能力范围内（grepSearch 可匹配）的禁止标注

### 关键约束
- 前端统一走 AI 直接扫描，无需脚本；**不走**后端扫描规则注册表
- 一体化、Android/鸿蒙/iOS、跨端（Flutter/RN）、小程序不因缺少 package.json 而跳过前端文档生成
- 移动端须从实际工程配置提取 SDK、构建、签名、权限和依赖；不得记录密钥、证书口令、Provisioning Profile 敏感内容
- 技术栈类型须含下游可识别的平台/跨端/小程序关键词；架构模式写入 §六，不写入技术栈类型
- 分离项目不得强行补齐不属于当前工程的一端文档
