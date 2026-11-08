---
name: econ-verify
description: 论文核验：引用是否伪造或不存在、识别要素是否被提及、数字与表图是否一致，并维护四态验证账本。Use before sharing or submitting an economics manuscript, for 核对引用, 检查稿件, verification status, consistency between tables and text, 稿件自查.
argument-hint: "<manuscript path> [refs.bib]  |  status <manuscript>  |  mark <manuscript> <item> <state> <who>"
user-invocable: true
---

# econ-verify：核验与四态账本

```bash
E="${CLAUDE_PLUGIN_ROOT:-${ECON_PAPER_HOME:-.}}/scripts/econ.sh"
bash "$E" verify <manuscript> [refs.bib]     # 跑自动闸门，写回执（含文件 sha256）
bash "$E" status <manuscript>                # 当前文件内容对应的四态
bash "$E" mark <manuscript> <item> <ai-assessed|human-confirmed> <who>
```
回执：`output/logs/verify-<稿件名>.ndjson`，只追加。**稿件一改，旧结果自动失效**（显示为 stale 并被忽略），所以改稿后必须重跑。

## 自动闸门做什么、不做什么
| 检查 | 能证明 | 不能证明 |
|---|---|---|
| `econ-checklist` | DiD/RD/IV/聚类/稳健性/量级被提到 | 方法用得对 |
| `citation-fabrication` | 正文引用在参考文献中有对应、无可疑年份、无重复 | 文献真实存在 |
| `citation-existence`（需 .bib） | 作者-年份引用在 .bib 中有条目 | 条目内容属实、支持该论断 |

此外手动补两项：`bash scripts/gates/verify-claims.sh <稿件>` 统计 `CLAIM-*` 标记；`bash "$E" bib <refs.bib>` 检查文献库。标准见 `references/verification-standards.md`。

## 四种状态（只能用这四个词）
1. **automated-check-passed**：脚本通过（仅说明"提到了/格式对"）。
2. **AI-assessed**：由 AI 读过并判断，需写明依据。
3. **human-confirmed**：用户亲自确认，记录姓名。
4. **not-yet-verified**：尚未验证。

四个永远不会被自动通过的项：`identification`、`proofs`、`citation-support`、`formal-write`。
先用 `status` 看清哪些是 not-yet-verified，逐项交给用户；用户确认后再 `mark ... human-confirmed <姓名>`。AI 自己读过判断的，只能 `mark ... ai-assessed`，不能写成 human-confirmed。

## 报告方式
最终汇报按四态分组列出，不用"已验证""没问题"之类笼统说法；列出仍待人工确认的项。
