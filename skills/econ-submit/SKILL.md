---
name: econ-submit
description: 经济学论文投稿与返修：选期刊、格式与材料清单、投稿信、审稿风险预演、逐条回复审稿意见、复现包。Use for 投稿, 选期刊, cover letter, 审稿意见, 返修, R&R, referee response, replication package, 经济研究/管理世界/中国工业经济/QJE/AER 投稿准备.
argument-hint: "<select-journal|format|cover-letter|referee-sim|respond|replication> [manuscript path] [--journal <name>]"
user-invocable: true
---

# econ-submit：投稿与返修

```bash
E="${CLAUDE_PLUGIN_ROOT:-${ECON_PAPER_HOME:-.}}/scripts/econ.sh"
```

## 铁律
期刊的字数限制、版面费、录用率、编辑、审稿周期等事实：**只取自 `references/econ-journals.md` 的有出处条目或期刊官网页面**，用 WebFetch 打开官网核对后引用并附链接。文件中只列了范围的期刊，必须去官网核实；不凭记忆。

## 模式
1. **select-journal**：按贡献类型（理论/实证/政策）、方法、读者、篇幅匹配候选期刊，给出 3–5 个并说明取舍。依据来自 `references/econ-journals.md` 与官网，不给"录用概率"。
2. **format**：对照期刊官网要求逐项检查（篇幅、摘要、参考文献格式、匿名化、数据与代码政策），输出清单并标注每项来源。
3. **cover-letter**：贡献一段话 + 与期刊的契合 + 声明（原创、一稿一投、利益冲突、数据可得性）。不夸大。
4. **referee-sim**：模拟 3 位审稿人（方法、理论、领域/政策）找出稿件最大风险，按严重程度排序并给修改路线。这是模拟，不代表真实审稿结论。
5. **respond**：先把审稿意见分类（必须改 / 可解释 / 不同意），再逐条回复。模板见 `references/response-templates.md`，常见问题见 `references/common-concerns.md`。每条回复指明稿件中的具体修改位置；不同意要给证据，不绕开。
6. **replication**：脚本、数据说明、运行顺序、环境、README；检查每个表图都有产生它的脚本。

## 人工确认点
最终投哪家、投稿信与回复信的定稿、是否同意某条审稿意见——用户签字。提交前先用 `econ-verify` 跑一遍并汇报四态。
