# repos.txt 模板（复制到工作区根目录并命名为 \`repos.txt\`）

用于描述需要 clone/更新的仓库清单。技能只读取**工作区根目录**的 \`repos.txt\`，因此这里的内容用于你在工作区根目录复制粘贴。

\`\`\`text
# repos.txt 模板（复制到“工作区根目录”并重命名为 repos.txt 才会被技能读取）
#
# 格式：TSV（Tab 分隔）优先；也允许多个空格分隔
# 行格式：name<TAB>type<TAB>url<TAB>branch[<TAB>eta_min]
#
# 字段说明：
# - name：克隆到根目录下的目录名（也作为项目目录名），例如 aiclaim-upload
# - type：app 或 kb
# - url：git clone 地址（建议为以 .git 结尾的 http(s) 地址）
# - branch：要切换的分支名（可留空；留空时默认尝试 main，再尝试 master）
# - eta_min：可选；预计拉取/更新耗时分钟，用于放宽等待预期
#
# 允许内容：
# - 空行
# - 以 # 开头的注释行
#

name<TAB>type<TAB>url<TAB>branch<TAB>eta_min
# my-kb-repo<TAB>kb<TAB>https://example.com/group/my-kb-repo.git<TAB>main<TAB>2
# my-app-repo<TAB>app<TAB>https://example.com/group/my-app-repo.git<TAB>develop<TAB>2
\`\`\`