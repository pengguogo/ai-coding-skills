# Step 4: 终局自检 + 编译/构建闸门 [强制停止]

## 元信息

- agent: build-verifier
- checkpoint: checkpoints/step-04-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/code/00-task-groups.md`, `{WORKSPACE}/code/section-review-progress.tsv`, `{WORKSPACE}/review/review-log.md`, `{WORKSPACE}/code/01-task-group-execution-log.md`]
- output_file: `{WORKSPACE}/code/04-verify-and-gate-report.md`
- reference_files: [`references/backend/coding-standard.md`, `references/frontend/coding_standard.md`, `references/iOS/ios-coding-guideline.md`, `references/Android/android-coding-standard.md`, `references/HMOS/hmos-coding-standard.md`]

## 执行指令

全部批次 `user_confirmed=yes` 且 `gate_status=CLEARED` 后执行。

### Part 1：批次进度核对

核对 `section-review-progress.tsv` 与执行队列；非 skipped 批次须评审通过且已确认。

### Part 2：全量代码自检

对照 task-split 与 review-log 做全量变更自检摘要。

### Part 3：后端编译闸门

记录命令、结果、产物。

### Part 4：前端构建闸门

lint / typecheck / build。

### Part 5：iOS 编译闸门

xcodebuild clean build（或 Scheme 指定的构建命令）。记录命令、结果、产物。

### Part 6：Android 编译闸门

gradle assembleDebug（或项目指定的构建命令）。记录命令、结果、产物。

### Part 7：HMOS 编译闸门

hvigorw assembleHap（或项目指定的 DevEco Studio 构建命令）。记录命令、结果、产物。

### 产出结构

```markdown
# 终局自检 + 编译/构建闸门报告

## 1. 批次进度（按执行队列）
## 2. 全量任务覆盖
## 3. 后端编译闸门
## 4. 前端构建闸门
## 5. iOS 编译闸门
## 6. Android 编译闸门
## 7. HMOS 编译闸门
## 8. 总结（是否建议触发 fullstack-code-review 终审）
```

### 关键约束

- 不替代各批次 Step 2 小节评审。
- 完成后 Scheduler Halt，输出 `final-gate` 交付报告。
