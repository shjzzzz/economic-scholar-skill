---
name: econ-analysis
description: 经济学实证分析：数据安全入库、清洗与描述统计、估计、表格与图形、脚本归档。Use for 数据清洗, 描述统计, 回归, 实证分析, 稳健性检验, regression tables, figures, robustness checks, 随机种子, data safety scan.
argument-hint: "<raw data path or analysis plan> [--stage safety|eda|estimate|robustness]"
user-invocable: true
---

# econ-analysis：数据与实证

```bash
E="${CLAUDE_PLUGIN_ROOT:-${ECON_PAPER_HOME:-.}}/scripts/econ.sh"
```
目录：`paper/<slug>/data/raw`（只读）、`data/processed`、`analysis/`（脚本）、`output/`（表图）。

## 步骤
1. **数据安全入库**：原始数据放入 `data/raw`，先扫描再读取。
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT:-.}/scripts/gates/safety-scan.sh" paper/<slug>/data/raw/<file>   # GREEN/YELLOW/RED
   ```
   RED/YELLOW 或含个人信息：停下，交用户决定（匿名化、仅本地统计、放弃）。含个人信息时只运行聚合代码，不打印原始行。数据守卫钩子（`scripts/guard/pretooluse-data-guard.sh`）注册方法见 `README.md`。
2. **清洗与描述**：缺失机制与处理见 `references/missing-data.md`，清洗规范见 `references/cleaning-guide.md`。输出样本构成表（Table 1）与变量定义；每个样本删除步骤记录删了多少、为什么。
3. **估计**：按 `econ-identification` 确定的策略写脚本；规范见 `references/analysis-standards.md`。
   - 所有随机步骤（自助法、模拟、抽样、随机划分）**固定种子**。
   - 脚本按序号命名并归档到 `analysis/`，每个表/图能追溯到一个脚本。
   - 解读**经济量级**（百分点、标准差、弹性），不只看显著性星号。
4. **稳健性**：安慰剂、替换样本、替换变量、替换聚类层级、替换估计量。
5. **复查脚本**：从干净环境重跑一遍，结果一致才算数。

## 闸门
```bash
bash "$E" seed paper/<slug>/analysis/        # 随机步骤是否固定种子（只检测"设了种子"，不检测"先于每次随机调用"）
```

## 人工确认点
结果的解读与取舍由用户判断。把"结果—含义—不能说什么"列给用户；不要把相关性写成因果。
