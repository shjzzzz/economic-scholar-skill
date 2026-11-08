# econ-paper

经济学文献与论文全流程 skills（Claude Code plugin）：文献 → 选题 → 识别 → 实证 → 写作 → 核验 → 投稿。
8 个 skill，一个入口 `scripts/econ.sh`，闸门脚本可单独运行。

```bash
claude --plugin-dir .                    # 本地试用（在仓库根目录）
bash scripts/econ.sh doctor               # 包自检
bash scripts/econ.sh init my-paper applied en
bash scripts/econ.sh test                 # 包内测试
```

## Skill 用法

### 怎么调用
安装后（见下方“安装”）两种方式任选：
- **自然语言**：直接说“帮我写引言”“检查这篇稿子的引用”，Claude 会按 skill 的 `description` 触发匹配的 skill。
- **显式调用**：`/econ-paper:<skill名> <参数>`，例如 `/econ-paper:econ-writing intro draft --lang zh`。参数格式见下表。

不确定从哪开始，先用 `/econ-paper:econ-paper`（总入口）：它只做路由和记账（`init` / `status` / `next`），告诉你当前处于哪个阶段、下一步该调哪个 skill。

### 八个 skill
| 阶段 | skill | 做什么 | 参数示例 |
|---|---|---|---|
| 总入口 | `econ-paper` | 路由、项目状态、验收 | `init my-paper applied zh` / `status` / `next` |
| 1 文献 | `econ-literature` | 检索、筛选、综述、研究缺口；产出 `search-log.tsv`、`lit-map.md`、`refs.bib` | `"企业所得税征管与避税" --scope targeted --lang zh` |
| 2 选题 | `econ-question` | 想法 → 研究问题、机制、假说、概念框架 | `"rough idea" --track applied` |
| 3 识别 | `econ-identification` | 选识别策略（DiD/RD/IV/合成控制等）、功效分析、识别论证 | `"RQ + 数据描述" --strategy did` |
| 4 实证 | `econ-analysis` | 数据安全入库、清洗、描述统计、估计、稳健性、表图、脚本归档 | `data/raw.csv --stage safety` |
| 5 写作 | `econ-writing` | 分章起草、修改、润色，英文国际刊或中文 CSSCI 风格 | `results revise --journal 财政研究 --lang zh` |
| 6 核验 | `econ-verify` | 引用真实性、识别要素是否被提及、数字与表图一致、四态账本 | `paper/my-paper/drafts/ms.md refs.bib` |
| 7 投稿 | `econ-submit` | 选刊、格式清单、投稿信、审稿风险预演、逐条回复、复现包 | `referee-sim ms.md --journal 经济研究` |

### 典型流程（以应用实证论文为例）
1. `bash scripts/econ.sh init my-paper applied zh`：建 `paper/my-paper/` 和 `STATE.md`。
2. 依次走 文献 → 选题 → 识别 → 实证 → 写作；每个阶段完成后，把闸门输出存到 `paper/my-paper/output/logs/`，再在 `STATE.md` 打勾。
3. 定稿前跑 `econ-verify`，投稿前用 `econ-submit`。
4. 已有稿件可以跳过前面阶段，直接调用需要的那个 skill。

### 使用时要知道的规则
- 不伪造引用：核实不了的写 `[CITATION NEEDED]`。
- 期刊的字数、版面费、录用率等不凭记忆，取自 `skills/econ-submit/references/econ-journals.md` 或官网。
- 状态措辞只有四种：automated-check-passed / AI-assessed / human-confirmed / not-yet-verified。自动检查只证明“提到了”，不证明“做对了”。
- 理论只写到概念框架；证明一律标 needs-human-review。
- 不覆盖原文件和旧稿，用户上传的数据只读。
- 若已安装 `qje-*` 或 `cie-*` skill，会在对应阶段叠加使用（对应关系见 `bash scripts/econ.sh map` 的 `ext` 列）。

### 脱离 Claude 单独运行的闸门
```bash
bash scripts/econ.sh map                                   # 阶段 → skill → 闸门 → 人工确认
bash scripts/econ.sh bib refs.bib                          # 参考文献库检查
bash scripts/econ.sh seed scripts/                         # 分析脚本是否固定随机种子
bash scripts/econ.sh verify ms.md refs.bib                 # 稿件自动核验，写回执
bash scripts/econ.sh status ms.md                          # 当前文件内容的四态状态
bash scripts/econ.sh mark ms.md <item> human-confirmed <who>   # 人工确认
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

