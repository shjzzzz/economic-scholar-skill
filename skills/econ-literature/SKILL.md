---
name: econ-literature
description: 经济学文献检索、筛选、综述与研究缺口定位，产出可核验的参考文献库。Use for 文献综述, literature review, 找文献, 研究缺口, positioning vs frontier papers, building refs.bib, or checking citations for an economics paper.
argument-hint: "<research question or topic> [--scope landscape|targeted|rapid] [--lang en|zh]"
user-invocable: true
---

# econ-literature：文献阶段

产出（存入 `paper/<slug>/lit/`）：`search-log.tsv`（检索记录）、`lit-map.md`（文献地图）、`refs.bib`（每条有 DOI 或 URL）。
范围：`landscape` 40–80 篇；`targeted`（为引言服务）15–30 篇；`rapid` 10–20 篇。

```bash
E="${CLAUDE_PLUGIN_ROOT:-${ECON_PAPER_HOME:-.}}/scripts/econ.sh"
```

## 步骤
1. **界定问题**：一句话研究问题 + 中英文关键词（含同义词、政策名称、制度术语）。
2. **检索顺序**：本地文献库（Zotero/BibTeX，见 `.env` 的 `SCHOLAR_ZOTERO_DIR`/`SCHOLAR_BIB_PATH`）→ CrossRef / OpenAlex / Semantic Scholar / Google Scholar / RePEc·NBER·SSRN（WebSearch、WebFetch）→ 参考文献链追踪（前向与后向引用）。中文题目另查 CNKI 与《经济研究》《管理世界》《中国工业经济》目录。检索策略见 `references/search-strategies.md`。
3. **记录**：每次检索与每篇入选论文追加一行到 `search-log.tsv`（来源、查询、日期、DOI/URL、取舍理由）。无记录的论文不得进入综述。
4. **精读抽取**（每篇一行）：问题、设定/样本、识别策略、主要发现、效应量级、局限。读不到全文就只依据摘要，并在该行标 `abstract-only`。
5. **综合成图**（写作方法见 `references/synthesis-guide.md`）：已确立 / 有争议 / 无效应的发现；机制清单；方法演进；**缺口**；本文相对 3–5 篇前沿论文的贡献陈述。
6. **核验**：把入选论文写入 `refs.bib`，然后运行
   ```bash
   bash "$E" bib paper/<slug>/lit/refs.bib          # 重复键、缺 doi/url、年份异常
   bash "$E" verify paper/<slug>/lit/lit-map.md paper/<slug>/lit/refs.bib   # 引用存在性
   ```
   FAIL 项逐条修复；查不到的条目删除或标 `[CITATION NEEDED]`，不得保留。

## 人工确认点
研究缺口是否真的成立，由用户判断。把缺口写成"本文声称的缺口 + 最接近的三篇论文为何没填上"，交用户确认后再进入 `econ-question`。

## 禁止
- 凭记忆写作者、年份、期刊、结论。每一个事实都要有检索结果支撑。
- 把工作论文当作已发表论文引用（`bib-check` 会 WARN）。
