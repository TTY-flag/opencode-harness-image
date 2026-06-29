# 输出目录说明

本目录用于存放威胁分析执行过程中生成的中间数据和最终输出。

## 输出文件

运行 `opencode SKILL.md` 后，在本目录或用户指定的输出路径生成：

| 文件 | 说明 |
|------|------|
| `{产品名}-threat-analysis.json` | 完整结构化JSON，供下游工具消费 |
| `{产品名}-threat-report.md` | 人类可读的威胁分析报告 |

## JSON内容

包含以下对象：

- `meta`: 元信息（产品名、路径、技术栈）
- `value_assets`: 价值资产清单
- `attack_surfaces`: 攻击面枚举
- `attack_vectors`: 攻击向量列表
- `control_points`: 控制点识别
- `risks`: 风险点列表
- `attack_chains`: 攻击链构建
- `statistics`: 统计汇总

## Markdown报告结构

1. 执行摘要
2. 关键发现
3. 风险详情
4. 攻击面详情
5. 攻击链
6. 控制点评估
7. 价值资产清单
8. 修复建议
9. 附录