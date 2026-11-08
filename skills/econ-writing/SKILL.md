---
name: econ-writing
description: 经济学论文写作：按章节起草、修改、润色，支持国际期刊英文与中文 CSSCI 风格。Use for 写引言, 写论文, 写结果, 摘要, 修改, 润色, drafting or revising any section of an economics paper, journal voice, 中文论文写作.
argument-hint: "<section: intro|theory|data|empirics|results|discussion|abstract|full> [draft|revise|polish] [--journal <name>] [--lang en|zh]"
user-invocable: true
---

# econ-writing：写作

```bash
E="${CLAUDE_PLUGIN_ROOT:-${ECON_PAPER_HOME:-.}}/scripts/econ.sh"
```

## 步骤
1. **读材料，不凭印象写**：`lit/lit-map.md`、`drafts/question.md`、`drafts/identification.md`、`output/` 的表图。缺哪个就说缺，不编。
2. **定结构与篇幅**：论文结构见 `references/paper-structure.md`；各节标准与字数预算见 `references/section-standards.md`；目标期刊的要求取自 `econ-submit/references/econ-journals.md`，**不凭记忆**。
3. **起草**：流程见 `references/writing-protocol.md`，文风见 `references/academic-writing.md`，方法部分示例见 `references/methods-prose-examples.md`。
   - 引言：问题 → 为什么重要 → 做了什么 → 发现（带量级）→ 与最接近文献的区别 → 路线图。
   - 每个数字来自 `output/` 的表图，写明表号；每条引用来自已核实的 `refs.bib`。
   - 中文稿：避免翻译腔；术语一致（如"双重差分"不与"DID"混用，首次出现注明）。
4. **保存**：每次写文件前取版本化路径，不覆盖旧稿。
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT:-.}/scripts/gates/version-check.sh" paper/<slug>/drafts <stem>   # 打印 SAVE_PATH=...
   ```
5. **润色**：只改表达，不改论证、数字、引用。润色前后各存一版。

## 人工确认点
论证是否站得住、文风是否像作者本人，由用户判断。用户改稿后，若反复纠正同类措辞，记录反馈（见 `econ-paper` 的反馈流程），不要靠自己下次"记得"。

## 写完后
交给 `econ-verify`；未核验前不得宣称"已核实"。
