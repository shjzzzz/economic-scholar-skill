# econ-paper

经济学文献与论文全流程 skills（Claude Code plugin）：文献 → 选题 → 识别 → 实证 → 写作 → 核验 → 投稿。
8 个 skill，一个入口 `scripts/econ.sh`，闸门脚本可单独运行。

```bash
claude --plugin-dir .                    # 本地试用（在仓库根目录）
bash scripts/econ.sh doctor               # 包自检
bash scripts/econ.sh init my-paper applied en
bash scripts/econ.sh test                 # 包内测试
```

## 数据守卫（可选）
`scripts/guard/pretooluse-data-guard.sh` 是 PreToolUse 钩子，依赖 `jq` 与 `python3`，拒绝读取未通过安全扫描的原始数据。
在 `~/.claude/settings.json` 的 `hooks.PreToolUse` 中注册，matcher 为 `Read|Grep|Glob|Bash|NotebookRead|NotebookEdit`，command 指向该脚本的绝对路径。
安全状态文件为项目内 `.claude/safety-status.json`；没有它时的行为见脚本头部注释。

## 安装（作为插件市场）
```
/plugin marketplace add shjzzzz/economic-scholar-skill
/plugin install econ-paper@shjzzzz
```

## 自迭代闭环
- 工作地图：`bash scripts/econ.sh map`；验收标准：`bash scripts/econ.sh accept`（`references/acceptance.tsv`，`confirmed=no` 为待用户确认的提案）。
- 用户指出错误：`bash scripts/econ.sh feedback add --skill <s> --kind one-off|rule --what "…" --to check|sample|tool|prompt|none [--ref 文件]`。长期规则优先落到坏样例（`tests/samples/` + `expected.tsv`）或闸门，最后才写进提示词。
- 下一轮入口：`feedback triage`（哪些反馈还没被机制化；重复出现的标 RECURRING）、`regress`（好/坏样例结论不变）、`test`。
- 四态：automated-check-passed / AI-assessed / human-confirmed / not-yet-verified。自动检查只证明"提到了"，不证明"做对了"。

## 来源与改动
闸门脚本与 references 取自原仓库（`scripts/gates/{econ-checklist,verify-*,econ-verify-all,version-check,feedback-log,safety-scan}.sh`、`scripts/guard/*` 原样复制）；
新增：`econ.sh`、`doctor`、`bib-check`、`seed-check`、`accept-check`、`feedback-triage`、`regress-samples`、`init-project`。
旧的 35 skill 套件（含社会学/质性/多智能体编排/trace 机制）已从主线移除，完整保留在标签 `legacy-v1.0.0`：`git checkout legacy-v1.0.0`。
