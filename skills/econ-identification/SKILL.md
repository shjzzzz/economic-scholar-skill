---
name: econ-identification
description: 因果识别策略选择与研究设计（DiD、交错DiD、RD、IV、合成控制、Bartik、bunching、DML）及功效分析。Use for 识别策略, 因果推断, 双重差分, 断点回归, 工具变量, identification strategy, staggered DiD, power analysis, writing the identification argument.
argument-hint: "<RQ + data description> [--strategy did|staggered-did|rd|iv|sc|shift-share|bunching|dml]"
user-invocable: true
---

# econ-identification：识别策略与设计

```bash
E="${CLAUDE_PLUGIN_ROOT:-${ECON_PAPER_HOME:-.}}/scripts/econ.sh"
```

输出（存入 `paper/<slug>/drafts/`）：`identification.md`（策略、假设、检验、威胁与对策、功效）。

## 步骤
1. **画因果图**（`references/dag-patterns.md`）：处理、结果、混淆、中介、碰撞变量。
2. **选策略**（决策表与 13 种策略的假设/诊断/R·Stata 代码在 `references/strategies.md`，补充工具在 `references/identification-toolkit.md`、`references/matching-weighting.md`）：

| 变异来源 | 首选 | 必须陈述并检验 |
|---|---|---|
| 政策在不同时间/地区推行 | DiD / 事件研究 | 平行趋势、预期效应、**异质性稳健估计量** |
| 门槛规则 | RD | 带宽选择、密度（操纵）检验、协变量连续性 |
| 外生冲击影响处理 | IV | 排他性、第一阶段强度、弱工具变量 |
| 单个/少数处理单位 | 合成控制 | 预处理拟合、安慰剂 |
| 份额×冲击 | shift-share | 份额外生或冲击外生 |
3. **交错 DiD 的硬规则**：使用 Callaway–Sant'Anna、Borusyak–Jaravel–Spiess 或 Sun–Abraham；若用双向固定效应，必须写出理由并附 Goodman-Bacon 分解。示例代码：`references/did-cs-workflow.R`。
4. **写出识别假设**：每条假设对应一个可做的检验和一个无法检验的部分。
5. **功效/最小可检测效应**：给出样本量与效应量的关系。
6. **标准误**：写明聚类层级及理由。

## 闸门
```bash
bash "$E" verify paper/<slug>/drafts/identification.md    # econ-checklist：DiD/RD/IV/聚类/稳健性是否被提及
```
`PASS` 只表示"提到了"，不表示做对了；输出末尾的 `HUMAN-REVIEW` 行必须逐条交给用户。

## 人工确认点
识别是否真有效（预处理趋势是否平、工具变量是否可信）由用户判断；用 `mark identification` 记录 ai-assessed 或 human-confirmed，见 `econ-verify`。
