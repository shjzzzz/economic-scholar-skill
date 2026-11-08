---
name: econ-question
description: 把经济学想法收敛为可研究的问题、机制、假说和概念性理论框架。Use for 选题, 研究问题, 研究假设, 理论框架, 机制分析, conceptual model, propositions, competing predictions in an economics paper.
argument-hint: "<rough idea or literature map path> [--track applied|theory|theory+applied]"
user-invocable: true
---

# econ-question：选题、假说与理论框架

输入：想法或 `lit/lit-map.md`。输出（存入 `paper/<slug>/drafts/`）：`question.md`。

## 步骤
1. **一句话检验**：研究问题能否一句话说清"X 对 Y 的影响（在什么情境、用什么证据）"？不能就回到想法层面，参考 `references/idea-patterns.md` 的五类谜题（异常、矛盾、扩展、机制、范围）。
2. **估计对象（estimand）**：写明处理变量、结果变量、总体、时间窗口。
3. **理论框架**（选一个，见 `references/econ-frameworks.md`）：激励与弹性、信息摩擦、委托代理、市场结构、财政联邦制、信贷约束、行为偏差。
4. **机制链**：
   - 有模型：原语 → 假设 → 均衡/比较静态 → **可检验预测**。
   - 无模型：用文字写出渠道图（reduced-form channel map）。
5. **假说**：每条写清方向、符号、竞争性预测（对照表：若机制 A 成立会看到什么，若机制 B 成立会看到什么）。
6. **范围条件**：结论在什么条件下成立、在哪里不成立。

## 理论深度（硬边界）
只做概念框架：假设、程式化模型、≤3 个命题、可检验预测。**不证明定理。** 任何证明、比较静态推导、均衡论证都标注 `needs-human-review`，数值模拟只算证据不算证明。

## 人工确认点
选定哪个 RQ、哪套机制、证明是否正确——均由用户判断。把候选列成表，给出你的推荐和理由，等用户选定后写入 STATE.md 的"Decisions"。

## 路线
- **theory+applied**：先完成本阶段的模型与命题，再把可检验预测交给 `econ-identification`。
- **theory**：完成后直接进入 `econ-writing`。
