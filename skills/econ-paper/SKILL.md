---
name: econ-paper
description: 经济学论文全流程总入口：从文献到投稿的路由、项目状态与验收。Use when starting or continuing an economics paper (applied, theory, or both), asking "what next on my paper", or when the user mentions 文献综述/选题/识别策略/实证/写作/投稿/返修 for an economics paper. 先读本 skill，再进入阶段 skill。
argument-hint: "[init <slug> | status | next]  — track: applied | theory | theory+applied; lang: en | zh"
user-invocable: true
---

# econ-paper：经济学论文全流程路由

只路由与记账，不替代阶段 skill。七个阶段，每阶段有一个 skill、一个自动闸门、一个人工确认点。

```bash
E="${CLAUDE_PLUGIN_ROOT:-${ECON_PAPER_HOME:-.}}/scripts/econ.sh"   # 之后所有 skill 都用 $E
bash "$E" doctor          # 首次使用先跑：换行符、文件引用是否完好
bash "$E" init <slug> [applied|theory|theory+applied] [en|zh]   # 建 paper/<slug>/ 和 STATE.md
bash "$E" map             # 阶段 → skill → 输入 → 输出 → 闸门 → 人工确认
```

## 阶段与 skill

| # | 阶段 | skill | 自动闸门 | 必须人工确认 |
|---|---|---|---|---|
| 1 | 文献 | `econ-literature` | `bib-check`、引用存在性 | 研究缺口是否成立 |
| 2 | 选题与假说/理论框架 | `econ-question` | - | 选定 RQ；证明 = needs-human-review |
| 3 | 识别策略与设计 | `econ-identification` | `econ-checklist` | 识别是否真有效 |
| 4 | 数据与实证 | `econ-analysis` | `safety-scan`、`seed-check` | 结果解读 |
| 5 | 写作 | `econ-writing` | `version-check` | 论证与文风 |
| 6 | 核验 | `econ-verify` | `econ verify` 全套 | identification / proofs / citation-support |
| 7 | 投稿与返修 | `econ-submit` | - | 期刊事实以官网为准；最终签字 |

路线判断（只在真正含糊时才问用户）：
- 政策冲击、面板/企业/家庭数据、DiD/RD/IV、"X 对 Y 的影响" → **applied**
- 模型、均衡、比较静态、命题、机制设计 → **theory**
- 模型推出可检验预测、再用数据检验 → **theory+applied**（先 2，再 3-4）
- 中文 CSSCI（经济研究/管理世界/中国工业经济）→ lang=zh；国际期刊 → lang=en。若已安装 `qje-*` / `cie-*` skill，在对应阶段叠加使用（见 feature-map 的 ext 列）；未安装就说明并用本包。

## 不可违反的规则
1. **不伪造引用。** 每条文献必须经工具或检索核实，核实不了的写 `[CITATION NEEDED]`。
2. **期刊的字数、版面费、录用率、编辑等事实，不凭记忆。** 取自 `econ-submit/references/econ-journals.md` 或官网页面。
3. **状态措辞只用四种：** automated-check-passed / AI-assessed / human-confirmed / not-yet-verified。自动检查只证明"提到了"，不证明"做对了"。
4. **理论深度止于概念框架**（假设、程式化模型、≤3 个命题、可检验预测）。证明一律报告为 needs-human-review。
5. **不覆盖原文件与旧稿。** 写文件前用 `scripts/gates/version-check.sh`；用户上传的数据只读。
6. **阶段打勾要有证据**：闸门输出保存到 `paper/<slug>/output/logs/`，再在 STATE.md 打勾。

## 反馈如何进入下一轮
用户指出错误时：`bash "$E" feedback add --skill <s> --kind one-off|rule --what "…" --to check|sample|tool|prompt|none [--ref 文件]`。
单次要求记 one-off；长期规则优先落到坏样例（`tests/samples/` + `expected.tsv`）或闸门，最后才写进提示词。
`bash "$E" feedback triage` 列出尚未机制化的反馈；`bash "$E" regress` 与 `bash "$E" test` 保证改动不退化。

验收标准清单：`references/acceptance.tsv`（`bash "$E" accept` 查看哪些有真实检查、哪些只有人工或文字）。
