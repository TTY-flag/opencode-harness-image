# Threat Analysis — 代码仓威胁分析 Skill

## 定位

从代码仓库识别安全威胁，输出结构化的威胁分析成果。

## 输入

- 代码仓路径（必填）
- 输出路径（可选）

## 输出

- 价值资产清单（类型名称+业务描述）
- 攻击面枚举（枚举名称+业务描述）
- 控制点识别（类型名称+业务描述）
- 攻击向量分析（枚举名称+业务描述）
- 风险点分析（枚举名称+业务描述）
- 攻击链构建（完整攻击路径）
- 信任边界分析

## 核心特性

| 特性 | 说明 |
|------|------|
| **分层分析** | 先宏观扫描目录/配置/依赖，再按热点深入关键代码 |
| **四层映射** | 攻击面→攻击向量→风险→风险等级 |
| **攻击链** | entry→vector→bypass→reach→impact |
| **信任边界** | 加密边界/数据边界/服务边界三层分析 |
| **快速模式** | 仅需路径输入，其余自动完成 |
| **双输出格式** | JSON（机器消费）+ Markdown（人阅读）|
| **枚举约束** | 名称字段使用标准枚举值，description字段自由描述 |

## 输出格式

```
{产品名}-threat-analysis/
├─ {产品名}-threat-analysis.json    # 完整JSON
└─ {产品名}-threat-report.md        # 可读报告
```

## JSON结构概览

```json
{
  "meta": { ... },
  "value_assets": [
    {
      "asset_id": "VA-001",
      "name": "数据资产",           // 枚举类型名称
      "description": "用户数据库...",  // 业务场景描述
      "type": "data",               // 类型KEY
      ...
    }
  ],
  "attack_surfaces": [
    {
      "surface_id": "AS-001",
      "surface_name": "登录认证API",  // 枚举名称
      "description": "用户登录入口...", // 业务描述
      "surfaces_type": "NET-API-LOGIN", // 类型KEY
      "trust_boundaries": [ ... ],  // 信任边界
      ...
    }
  ],
  "control_points": [ ... ],
  "attack_vectors": [ ... ],
  "risks": [ ... ],
  "attack_chains": [ ... ],
  "surface_risk_mapping": [ ... ],  // 攻击面→向量→风险映射表
  "statistics": {
    "assets_summary": [ ... ],      // 资产类型汇总
    "surface_risk_summary": [ ... ], // 攻击面类型风险汇总
    "vector_summary": [ ... ],      // 向量类型汇总
    "top_risks": [ ... ]
  }
}
```

## 使用方法

```bash
# 基本用法
opencode SKILL.md

# 在prompt中指定参数
"分析 D:/projects/my-app 的安全威胁"

# 指定输出路径
"分析 /home/user/service 的威胁，输出到 /home/reports/"
```

## 执行流程

```
阶段0: 代码仓结构识别 → tech_stack
阶段1: 价值资产识别 → value_assets[]
阶段2: 攻击面枚举 + 信任边界 → attack_surfaces[] + trust_boundaries[]
阶段3: 控制点识别 + 攻击向量 → control_points[] + attack_vectors[]
阶段4: 风险关联分析 → risks[] + attack_chains[] + surface_risk_mapping[]
阶段5: 输出成果 → JSON + Markdown
```

## 枚举体系

| 对象 | 枚举数量 | 其他类型 |
|------|---------|---------|
| 价值资产类型 | 7个基础类型 + `other` | 每类均有扩展选项 |
| 攻击面 | 6大类57个 + 各类`OTHER` | NET-/CFG-/DATA-/AUTH-/DEP-/RUN- |
| 攻击向量 | 11大类约120个 + 各类`OTHER` | 注入/认证/授权/文件/SSRF等 |
| 风险类型 | 5维度约45个 + 各维度`OTHER` | 机密性/完整性/可用性/合规/业务 |
| 风险等级 | 5级固定（无other） | critical/high/medium/low/info |
| 信任边界 | 加密5+数据6+服务4 + 各类`OTHER` | BOUND-ENC-/DATA-/SVC- |

详见: `references/enumeration.md`

## 参考文件

```
references/
├─ enumeration.md          # 枚举值定义（含other扩展）
├─ output_schema.md        # 输出结构定义（JSON/Markdown）
├─ language_patterns.md    # 代码识别规则（路由/认证/校验/加密）
├─ analysis_guide.md       # 分析方法论（分层策略/评估方法）
├─ schemas/
│  └─ threat_analysis_schema.json  # JSON Schema定义
├─ security_model.md       # 安全模型参考
├─ languages/              # 语言安全参考（Java/Python/Go/Node.js等）
└─ security/               # 安全领域参考（认证/加密/注入等）
```

## 字段命名规范

| 对象 | name字段 | 类型KEY字段 | 业务描述字段 |
|------|---------|------------|-------------|
| value_assets | `name` | `type` | `description` |
| attack_surfaces | `surface_name` | `surfaces_type` | `description` |
| control_points | `name` | `type` | `description` |
| attack_vectors | `vector_name` | `vector_type` | `description` |
| risks | `risk_name` | `risk_type` | `description` |

所有name字段使用enumeration.md定义的标准枚举名称，description字段为业务场景的自由描述。

## 版本信息

- 版本: 1.0
- 创建日期: 2026-06-16
- 最后更新: 2026-06-22
- 基于讨论结果实现