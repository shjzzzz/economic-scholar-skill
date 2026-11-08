# Economics Journal Reference (theory & applied economics)

**Fact policy.** Only facts carrying a source below are stated as facts. Everything else is a scope description, never a number. Word limits, fees, acceptance rates, editors, and turnaround change: **re-verify every submission-process item on the journal's official page before relying on it** (the source skills say the same). Do not fill a blank from memory; write `待核实 / verify` instead.

Sources: `qje-skills` v1.1.0 (`qje-submission`, `qje-workflow`; QJE masthead re-verified 2026-06-22 by that skill) and `china-industrial-economics-skills` v1.1.0 (`resources/journal-profile.md`; verified 2026-05 against the 《中国工业经济》 投稿指南, 2021-03 ed.). Official-source maps ship in each package under `resources/official-source-map.md`.

For the full manuscript workflow of these two journals, route to the installed `qje-*` / `cie-*` skills (see `econ-workflow`); this file does not duplicate them.

---

## A. Profiled journals (sourced)

### QJE — Quarterly Journal of Economics
| Item | Fact | Source |
|---|---|---|
| Publisher / editing | Oxford University Press; edited at Harvard Dept. of Economics; founded 1886 | qje-submission |
| System | Editorial Express (`editorialexpress.com/qje`), not ScholarOne | qje-submission |
| Fee | No submission fee; optional OA charge only after acceptance | qje-submission |
| Initial submission | **Single PDF** (manuscript + tables + figures + appendices); no Word/LaTeX source/separate figures until acceptance | qje-submission |
| Review | Double-blind; full anonymization (no names, affiliations, acknowledgments; scrub PDF metadata; neutral self-citation) | qje-submission |
| Style | Author-date (Chicago); abstract target ~150 words; no hard page limit; extensive online appendix expected | qje-submission |
| Editors (as of 2026-06-22) | Barro, Katz, Nunn, Shleifer, Stantcheva — **re-check before submitting** | qje-submission |
| Desk decision | Roughly two weeks; acceptance ~1–4%, desk-reject ~60%+ (skill's estimates) | qje-submission |
| Taste | Big conceptual question + clean, credible evidence; light conceptual frame preferred over heavy structural model | qje-theory-model |

### 《中国工业经济》 (China Industrial Economics)
| Item | Fact | Source |
|---|---|---|
| Sponsor | 中国社会科学院工业经济研究所; monthly; ISSN 1006-480X; CN 11-3536/F | journal-profile |
| System | https://ciejournal.ajcass.com/ (online submission) | journal-profile |
| Fee | 不收版面费、审稿费 | journal-profile |
| Length | ~2.5万字 (≥18 pages at 39 lines × 42 chars, 五号宋体) | 投稿指南 2021-03 |
| 摘要 | 中文 450–500 字, 创新点占 70% 以上; 关键词 3–5 个; 英文摘要对应 | 投稿指南 |
| 体例 | 页下注 (当页脚注, ①②…); 参考文献 "实引" 制 (文内引用与文末一一对应, 不引新闻/网站); 三级标题 "一、1.（1）" | 投稿指南 |
| 篇幅结构 | 模型与公式 ≤ 全文 50%; 原创性/边际贡献 ≥ 95% | 投稿指南 |
| Review | 双向匿名; 审理期一般 ≥ 60 个法定工作日; 重复率 ≤ 5% | 投稿指南 |
| Data/code | 初审通过需提供原始数据与处理过程及程序代码; 录用后提供数据、程序与完整结果 | 投稿指南 |
| Taste | 理论顶天、实践立地; 实证工程化: 干净识别 + 稳健性做满 + 机制 + 异质性 + 可落地政策含义 | cie-workflow |

---

## B. Other target journals (names and scope only — verify everything on the official page)

**General-interest, international.** American Economic Review; Econometrica; Journal of Political Economy; Review of Economic Studies (with QJE: the "top-5"). Also: Review of Economics and Statistics; Journal of the European Economic Association; Economic Journal; AEJ: Applied / Policy / Macro / Micro.

**Theory-leaning outlets.** Econometrica; Theoretical Economics; Journal of Economic Theory; Games and Economic Behavior; RAND Journal of Economics. (Theory-first papers usually fit these rather than QJE, per `qje-theory-model`.)

**Field journals.** Public/tax: Journal of Public Economics; National Tax Journal. Labor: Journal of Labor Economics; Journal of Human Resources. Development: Journal of Development Economics. Urban/regional: Journal of Urban Economics. Finance: Journal of Finance; Journal of Financial Economics. IO: RAND Journal of Economics; Journal of Industrial Economics. Environment/energy: JEEM; Journal of Environmental Economics and Management. Econometrics: Journal of Econometrics; Journal of Business & Economic Statistics. Macro/money: Journal of Monetary Economics.

**中文核心 / CSSCI（经济学）.** 经济研究; 管理世界; 中国工业经济; 经济学（季刊）; 世界经济; 金融研究; 中国社会科学; 数量经济技术经济研究; 财贸经济; 财政研究; 税务研究. For 《中国工业经济》 use the `cie-*` skills; for the others, fetch the current 投稿须知 and do not assume 《中国工业经济》 rules (实引制、页下注 etc.) carry over.

No ranking, acceptance rate, fee, or word limit is asserted for Section B. Rank by the 8-dimension rubric in SKILL.md Step 1 plus the user's own judgment.

---

## C. Ladders (suggested routing after rejection; judgment, not fact)

```
TOP-5 → field top → field journal:
  QJE / AER / JPE / Econometrica / REStud → JEEA / ReStat / EJ → field journal (JPubE, JLE, JDE, JUE, JF ...)
THEORY:
  Econometrica / REStud → Theoretical Economics / JET → GEB / RAND
APPLIED MICRO (policy shock):
  QJE / AER → AEJ: Applied / Policy → JPubE / JLE / JDE
CHINA:
  经济研究 / 管理世界 / 中国工业经济 → 世界经济 / 金融研究 / 财贸经济 / 数量经济技术经济研究 → 专业核心刊
```

## D. Econ-specific submission norms to check (all journals)
- Data & code availability: many journals require a replication package at acceptance; route to `qje-replication-package` / `econ-replication`. State any restricted-data access conditions.
- Pre-registration / trial registry for randomized experiments (e.g., AEA RCT Registry): state registry ID if an RCT. Observational work needs none.
- Conflicts of interest / funding disclosure; IRB statement for human-subjects work.
- JEL codes and keywords where the system asks for them.
- Anonymization differs by journal (QJE double-blind; 《中国工业经济》 双向匿名): confirm per journal.
