# Checkpoint: Step 2 识别项目属性 + 技术栈探测 + scan-plan 生成

> **审查级别**：L1（轻量审查）— 只检查结构和内容维度，一致性和完整性延迟到步骤 5 的 L2 审查。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。

## 审查时需打开的文件
- 产出文件：`{WORKSPACE}/code/02-tech-detect.md`
- scan-plan 文件：`{CODE_KNOWLEDGE}/scan-plan.md`

## 项目属性判断
- [ ] 项目属性判断有依据（前端/后端/一体化/移动端/跨端/小程序特征均已按优先级检查）
- [ ] 判断依据来自实际文件特征，非凭印象
- [ ] Android Gradle 与后端 Gradle 已按「后端入口」定义区分，未将纯 Android 误判为后端

## 技术栈信息
- [ ] 技术栈信息来自实际构建配置文件（pom.xml/build.gradle/build.xml/package.json/移动端平台工程配置/pubspec 等）
- [ ] 技术栈清单包含：语言、框架、ORM（前端可填不适用）、构建工具
- [ ] **项目类型匹配结果正确（这些类型之一：Spring Boot 单体/Spring Cloud 微服务/Dubbo 服务/传统 SSM/SSH/前端项目/ Android|鸿蒙|iOS 客户端 / 跨端-Flutter|ReactNative / 小程序 / 混合未知 之一）**

## 注册表探针结果
- [ ] 注册表探针结果完整（子集中每行有状态：命中/SKIPPED）
- [ ] 非子集行标记 SKIPPED(不在技术栈范围)
- [ ] 无遗漏的注册表行（每行都有明确状态）
- [ ] **前端类项目（Web / Android|鸿蒙|iOS / 跨端 / 小程序）：已标注不走本注册表，交由 Step 4；未错误加载后端接口/数据模型/外部依赖探针为必扫项**
- [ ] **探针执行优化已应用（全局文件统计缓存、批量匹配、合并 grepSearch）**

## DDL 路径发现
- [ ] **DDL 路径自动发现已执行**（grepSearch 匹配 CREATE TABLE）
- [ ] 非标准路径（如 init_script_tpb/）已纳入扫描范围

## scan-plan.md
- [ ] scan-plan.md 已生成且格式正确
- [ ] 包含 YAML front matter（project、scan_date、scan_type）
- [ ] 表头为：序号、扫描项、命中规则、扫描范围、预估目标数、策略、状态、实际产出数
- [ ] "扫描范围"填 grepSearch 实际命中路径，非预设固定路径名
- [ ] 策略选择基于实际文件统计

## 脚本环境检测
- [ ] 脚本环境检测已执行（PowerShell 可用性）
- [ ] 若 PowerShell 不可用，脚本扫描项已标记为 AI 直接扫描

## 待确认项提取
审查完成后，从产出中提取以下内容作为待确认项：
- 待确认清单（§6）中的每一条
- 产出正文中所有 [需人工确认] 标记
- 状态报告中的 concerns / missing-context
