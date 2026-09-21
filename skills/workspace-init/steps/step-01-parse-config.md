# Step 1: 解析 repos.txt 清单

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`repos.txt`]
- output_file: `(console)`
- domain_context: 工作区初始化的仓库清单解析与格式校验

## 执行指令

1. 在工作区根目录查找 repos.txt
   - 不存在 → STATUS_REPORT: BLOCKED，提示用户参照 references/repos-template.md 创建
2. 逐行解析：跳过空行和 # 注释行
3. 按 Tab 分隔优先；若无 Tab，则按空白分隔
4. 提取列：name / type / url / branch / eta_min（可选）
5. 逐行校验：
   a. name 非空
   b. type 为 app 或 kb
   c. url 格式合法（以 http:// 或 https:// 开头）
   d. branch 可为空（标注"将使用默认分支策略：main → master"）
   e. eta_min 若存在须为正整数
6. 检查 name 无重复
7. 输出结构化清单（控制台）：

   | 序号 | name | type | url | branch | eta_min | 备注 |
   |------|------|------|-----|--------|---------|------|

8. 若有格式错误行，列出错误并标注行号
9. 汇总：有效行 N 条，错误行 M 条
