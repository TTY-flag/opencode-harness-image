# 威胁分析输出格式定义

本文档定义威胁分析输出的JSON结构，供SKILL.md引用。

---

## 单对象结构定义

### 1. 价值资产 (value_assets)

```json
{
  "asset_id": "VA-001",
  "name": "数据资产（资产类型名称，见references/enumeration.md第1.1章）",
  "description": "用户数据库-存储用户PII信息（业务场景描述）",
  "type": "data | credential | key | service | config | algorithm | infra",
  "classification": "public | internal | confidential | top_secret",
  "location": "database | file_system | memory | secret_store | code_hardcoded | env_variable | log_storage | cache | message_queue",
  "location_detail": "MySQL集群 - user_db.users表",
  "custodian": "用户服务",
  "protection_requirements": ["机密性", "完整性"],
  "code_evidence": ["src/models/User.java"]
}
```

### 2. 攻击面 (attack_surfaces)

```json
{
  "surface_id": "AS-001",
  "surface_name": "登录认证API（攻击面名称，见references/enumeration.md第2章）",
  "description": "用户登录入口-支持手机号/邮箱登录（业务场景描述）",
  "surfaces_type": "NET-API-LOGIN（攻击面KEY，见references/enumeration.md第2章）",
  "entry_type": "http_api | grpc_service | websocket | graphql | web_ui | cli_command | file_interface | message_consumer | scheduled_task | database_port | cache_port | debug_port",
  "auth_required": "none | token | session | certificate | api_key | oauth | basic | hmac | custom | unknown",
  "network_zone": "internet | dmz | intranet | cluster_internal | localhost",
  "exposure_mode": "public_api | authenticated_api | internal_api | admin_interface | debug_endpoint | health_check | metrics_endpoint",
  "trust_boundaries": [
    {
      "boundary_type": "encryption",
      "boundary_key": "BOUND-ENC-TLS（边界KEY，见references/enumeration.md第7章）",
      "description": "客户端→服务端：TLS 1.2加密",
      "strength": "strong | medium | weak | missing",
      "code_evidence": ["src/config/ssl.properties"]
    },
    {
      "boundary_type": "data",
      "boundary_key": "BOUND-DATA-DB-PLAINTEXT",
      "description": "应用→数据库：明文连接",
      "strength": "weak",
      "code_evidence": ["src/config/database.yml:10"]
    }
  ],
  "code_evidence": ["src/routes/auth.py:15"],
  "linked_assets": ["VA-001"]
}
```

**字段说明**：
- `surface_id`: 实例ID（如 AS-001），分析过程中分配
- `surface_name`: 攻击面名称（如"登录认证API"），来自enumeration.md第2章枚举名称
- `description`: 业务场景描述（如"用户登录入口-支持手机号/邮箱登录"）
- `surfaces_type`: 类型KEY（如 NET-API-LOGIN），来自enumeration.md预定义枚举
- `trust_boundaries[]`: 信任边界数组（按识别优先级排序）
  - `boundary_type`: 边界类型（encryption/data/service）
  - `boundary_key`: 边界KEY（如 BOUND-ENC-TLS），来自enumeration.md第7章
  - `description`: 边界描述
  - `strength`: 边界强度（strong/medium/weak/missing）
  - `code_evidence`: 代码证据

### 3. 控制点 (control_points)

```json
{
  "control_id": "CP-001",
  "name": "认证控制（控制类型名称，见references/enumeration.md第3.1章）",
  "description": "JWT Token验证-有效期24小时（业务场景描述）",
  "type": "authentication | authorization | input_validation | output_encoding | encryption | rate_limiting | session_management | logging | error_handling | cors_policy | csrf_protection | file_validation | sql_parameterization | secrets_management（向量KEY，见references/enumeration.md第3.1章）",
  "effectiveness": "strong | medium | weak | bypassed | missing | misconfigured",
  "deployment_layer": "network | gateway | middleware | application | data | infrastructure",
  "target": "所有API端点",
  "code_evidence": ["src/middleware/auth.py:20"],
  "protects": ["AS-001", "AS-002"],
  "bypass_methods": ["JWT算法混淆(none算法)"]
}
```

### 4. 攻击向量 (attack_vectors)

```json
{
  "vector_id": "IV-001",
  "vector_type": "IV-SQL-UNION（向量KEY，见references/enumeration.md第4章）",
  "vector_name": "SQL Union注入",
  "vector_category": "注入类向量",
  "applicable_surfaces": ["AS-001", "AS-002"],
  "description": "构造UNION SELECT语句提取数据",
  "code_pattern": "SQL拼接特征（见references/language_patterns.md第6章）",
  "complexity": "trivial | low | medium | high",
  "controlled_by": ["CP-002", "CP-005"],
  "control_effectiveness": "strong | medium | weak | bypassed | missing",
  "code_evidence": ["src/controllers/LoginController.java:42"]
}
```

**字段说明**：
- `vector_id`: 实例ID（如 IV-001），分析过程中分配
- `vector_type`: 类型ID（如 IV-SQL-UNION），来自enumeration.md预定义枚举
- `applicable_surfaces`: 引用攻击面实例ID列表
- `controlled_by`: 覆盖该向量的控制点实例ID列表
- `control_effectiveness`: 控制点对该向量的整体有效性评估

### 5. 风险点 (risks)

```json
{
  "risk_id": "RK-001",
  "surface_id": "AS-001",
  "vector_id": "IV-001",
  "risk_type": "R-CONF-DATA-LEAK（风险KEY，见references/enumeration.md第5章）",
  "risk_name": "数据泄露",
  "risk_category": "vulnerability | misconfiguration | design_flaw | compliance_gap | dependency_risk",
  "level": "critical | high | medium | low | info",
  "description": "登录接口SQL注入导致用户数据库全量泄露",
  "impact": "机密性丧失：全量用户PII数据泄露",
  "controlled_by": ["CP-002"],
  "control_effectiveness": "strong | medium | weak | bypassed | missing",
  "exploitability": "无需认证+互联网可达",
  "evidence": ["src/controllers/LoginController.java:42"]
}
```

**字段说明**：
- `risk_id`: 实例ID（如 RK-001），分析过程中分配
- `risk_name`: 风险名称（如"数据泄露"），来自enumeration.md第5章枚举名称
- `risk_type`: 类型KEY（如 R-CONF-DATA-LEAK），来自enumeration.md预定义枚举
- `surface_id`: 引用攻击面实例ID
- `vector_id`: 引用攻击向量实例ID

### 6. 攻击链 (attack_chains)

```json
{
  "chain_id": "AC-001",
  "name": "SQL注入拖库链",
  "steps": [
    {
      "step_id": 1,
      "type": "entry",
      "attack_surface": "AS-001",
      "description": "攻击者访问公开登录页面"
    },
    {
      "step_id": 2,
      "type": "vector",
      "attack_vector": "IV-001",
      "description": "在username参数注入SQL Union语句"
    },
    {
      "step_id": 3,
      "type": "bypass",
      "control_point": "CP-002",
      "description": "绕过参数化查询（登录接口使用${}拼接而非#{})"
    },
    {
      "step_id": 4,
      "type": "reach",
      "value_asset": "VA-001",
      "description": "到达用户数据库，提取全部用户数据"
    },
    {
      "step_id": 5,
      "type": "impact",
      "risk": "RK-001",
      "level": "critical",
      "description": "全量用户数据泄露（机密性丧失）"
    }
  ]
}
```

**字段说明**：
- 所有引用均使用实例ID（AS-*, IV-*, CP-*, VA-*, RK-*）
- `risk` 字段引用风险实例ID，`level` 为风险等级

### 7. 攻击面-向量-风险映射表 (surface_risk_mapping)

映射表提供 **攻击面 → 攻击向量 → 风险 → 风险等级** 的完整关联视图，便于一目了然查看威胁全景。

```json
{
  "surface_risk_mapping": [
    {
      "surface_id": "AS-001",
      "surface_name": "登录认证API",
      "surfaces_type": "NET-API-LOGIN",
      "auth_required": "none",
      "network_zone": "internet",
      "vector_risks": [
        {
          "vector_id": "IV-001",
          "vector_type": "IV-SQL-UNION",
          "vector_name": "SQL Union注入",
          "vector_category": "注入类向量",
          "complexity": "trivial",
          "controlled_by": ["CP-002"],
          "control_effectiveness": "weak",
          "risks": [
            {
              "risk_id": "RK-001",
              "risk_type": "R-CONF-DATA-LEAK",
              "risk_name": "数据泄露",
              "level": "critical",
              "impact": "全量用户PII数据泄露"
            },
            {
              "risk_id": "RK-002",
              "risk_type": "R-AVAIL-SERVICE-DOWN",
              "risk_name": "服务中断",
              "level": "high",
              "impact": "数据库崩溃导致服务不可用"
            }
          ]
        },
        {
          "vector_id": "IV-002",
          "vector_type": "IV-AUTH-BRUTE",
          "vector_name": "暴力破解",
          "vector_category": "认证类向量",
          "complexity": "low",
          "controlled_by": ["CP-003"],
          "control_effectiveness": "missing",
          "risks": [
            {
              "risk_id": "RK-003",
              "risk_type": "R-INT-IDENTITY-FORGE",
              "risk_name": "身份伪造",
              "level": "high",
              "impact": "攻击者冒充合法用户"
            }
          ]
        }
      ]
    },
    {
      "surface_id": "AS-002",
      "surface_name": "API配置端点",
      "surfaces_type": "CFG-ACTUATOR",
      "auth_required": "none",
      "network_zone": "internet",
      "vector_risks": [
        {
          "vector_id": "IV-003",
          "vector_type": "IV-HEAPDUMP",
          "vector_name": "堆转储利用",
          "vector_category": "配置类向量",
          "complexity": "trivial",
          "controlled_by": [],
          "control_effectiveness": "missing",
          "risks": [
            {
              "risk_id": "RK-004",
              "risk_type": "R-CONF-CRED-EXPOSE",
              "risk_name": "凭据暴露",
              "level": "critical",
              "impact": "内存中的密钥/密码泄露"
            }
          ]
        }
      ]
    }
  ]
}
```

**映射表字段说明**：

| 层级 | 字段 | 说明 |
|------|------|------|
| **攻击面层** | `surface_id` | 攻击面实例ID（关联 attack_surfaces 数组） |
| | `surface_name` | 攻击面名称 |
| | `surfaces_type` | 攻击面KEY（如 NET-API-LOGIN） |
| | `auth_required` | 认证要求（none/token/session等） |
| | `network_zone` | 网络区域（internet/intranet等） |
| **向量层** | `vector_id` | 攻击向量实例ID（关联 attack_vectors 数组） |
| | `vector_type` | 攻击向量KEY（如 IV-SQL-UNION） |
| | `vector_name` | 向量名称 |
| | `vector_category` | 向量类别 |
| | `complexity` | 利用复杂度 |
| | `controlled_by` | 覆盖该向量的控制点实例ID列表 |
| | `control_effectiveness` | 控制有效性评估 |
| **风险层** | `risk_id` | 风险实例ID（关联 risks 数组） |
| | `risk_type` | 风险KEY（如 R-CONF-DATA-LEAK） |
| | `risk_name` | 风险名称 |
| | `level` | 风险等级（critical/high/medium/low/info） |
| | `impact` | 影响描述 |

**设计说明**：
- 所有ID字段使用实例ID（AS-*, IV-*, RK-*），便于关联独立数组
- 类型ID字段（surfaces_type/vector_type/risk_type）保持enumeration.md预定义枚举值
- 保留独立数组（attack_surfaces/attack_vectors/risks）供单独查询
- 映射表提供完整关联视图，便于快速浏览威胁全景
- 一个攻击面可有多个向量，一个向量可产生多个风险

---

## 完整输出结构

### {产品名}-threat-analysis.json

JSON Schema完整定义见：`references/schemas/threat_analysis_schema.json`

以下为结构概览（详细字段说明见Schema文件）：

```json
{
  "meta": {
    "product_name": "产品名",
    "code_repo_path": "代码仓路径",
    "analysis_date": "ISO日期",
    "tech_stack": {
      "languages": [],
      "frameworks": [],
      "databases": [],
      "middleware": []
    },
    "excluded_dirs": [],
    "focus_dirs": []
  },
  "value_assets": [
    "见第1节价值资产结构"
  ],
  "attack_surfaces": [
    "见第2节攻击面结构"
  ],
  "attack_vectors": [
    "见第4节攻击向量结构"
  ],
  "control_points": [
    "见第3节控制点结构"
  ],
  "risks": [
    "见第5节风险点结构"
  ],
  "attack_chains": [
    "见第6节攻击链结构（仅critical/high风险）"
  ],
  "surface_risk_mapping": [
    "见第7节映射表结构（完整攻击面→向量→风险→等级映射）"
  ],
  "statistics": {
    "total_assets": 0,
    "total_surfaces": 0,
    "total_vectors": 0,
    "total_controls": 0,
    "total_risks": 0,
    "assets_summary": [
      {
        "asset_type": "data",
        "asset_name": "数据资产"
      }
    ],
    "surface_risk_summary": [
      {
        "surface_type": "NET-API-LOGIN",
        "surface_name": "登录认证API",
        "surface_count": 2,
        "vector_count": 3,
        "risk_count": 5,
        "risk_distribution": {
          "critical": 0,
          "high": 0,
          "medium": 0,
          "low": 0,
          "info": 0
        }
      }
    ],
    "vector_summary": [
      {
        "vector_type": "IV-SQL-UNION",
        "vector_name": "SQL Union注入",
        "vector_count": 2
      }
    ],
    "top_risks": [
      {
        "risk_id": "RK-001",
        "description": "登录接口SQL注入导致数据泄露",
        "level": "critical",
        "surface_id": "AS-001",
        "vector_id": "IV-001"
      }
    ]
  }
}
```

**输出结构说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `attack_surfaces` | 数组 | 独立攻击面详情，供单独查询 |
| `attack_vectors` | 数组 | 独立攻击向量详情，供单独查询 |
| `risks` | 数组 | 独立风险详情，供单独查询 |
| `attack_chains` | 数组 | 仅critical/high风险的完整攻击路径 |
| `surface_risk_mapping` | 数组 | **完整映射表**：攻击面→向量→风险→等级 |
| `statistics.assets_summary` | 数组 | 按资产类型汇总（类型KEY+名称） |
| `statistics.surface_risk_summary` | 数组 | 按攻击面类型汇总（类型KEY+名称+数量+向量数+风险数+风险分布） |
| `statistics.vector_summary` | 数组 | 按向量类型汇总（类型KEY+名称+数量） |
| `statistics.top_risks` | 数组 | Top风险列表（按等级排序） |

---

## Markdown报告结构

### {产品名}-threat-report.md

```markdown
# {产品名} 威胁分析报告

## 执行摘要

| 项目 | 内容 |
|------|------|
| 分析日期 | {analysis_date} |
| 代码仓路径 | {code_repo_path} |
| 技术栈 | {languages}, {frameworks}, {databases}, {middleware} |
| 分析范围 | 排除目录：{excluded_dirs} |

### 发现概览

| 指标 | 数量 |
|------|------|
| 价值资产 | {total_assets} |
| 攻击面 | {total_surfaces} |
| 控制点 | {total_controls} |
| 攻击向量 | {total_vectors} |
| 风险点 | {total_risks} |

#### 资产类型分布

| 资产类型 | 类型名称 | 数量 |
|---------|---------|------|
| data | 数据资产 | {count} |
| credential | 凭据资产 | {count} |
| key | 密钥资产 | {count} |
| ... | ... | ... |

#### 向量类型分布

| 向量类型KEY | 向量名称 | 数量 |
|------------|---------|------|
| IV-SQL-UNION | SQL Union注入 | {count} |
| IV-AUTH-BRUTE | 暴力破解 | {count} |
| ... | ... | ... |

#### 按攻击面类型的风险分布

| 攻击面类型 | 类型名称 | 攻击面数 | 向量数 | 风险数 | Critical | High | Medium | Low | Info |
|-----------|---------|---------|--------|--------|----------|------|--------|-----|------|
| NET-API-LOGIN | 登录认证API | 2 | 3 | 5 | 1 | 2 | 1 | 1 | 0 |
| CFG-ACTUATOR | 监控端点暴露 | 1 | 1 | 2 | 1 | 0 | 1 | 0 | 0 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

### 关键发现（Top风险）

按风险等级排序，列出 Top 5-10 高风险项：

| 风险ID | 风险描述 | 等级 | 攻击面 | 向量 |
|--------|---------|------|--------|------|
| RK-001 | 登录接口SQL注入导致用户数据库全量泄露 | **critical** | AS-001 | IV-001 |
| RK-002 | Actuator端点暴露导致内存密钥泄露 | **critical** | AS-002 | IV-003 |
| ... | ... | ... | ... | ... |

---

## 价值资产清单

| 资产ID | 类型名称 | 业务描述 | 类型KEY | 密级 | 存储位置 | 保护要求 | 代码证据 |
|--------|---------|---------|---------|------|---------|---------|---------|
| VA-001 | 数据资产 | 用户数据库-存储用户PII信息 | data | confidential | database | 机密性、完整性 | src/models/User.java |
| VA-002 | 凭据资产 | API密钥-第三方服务调用认证 | credential | top_secret | env_variable | 机密性 | src/config/env.properties |
| VA-003 | 服务资产 | 用户服务-用户管理核心模块 | service | internal | memory | 可用性 | src/services/UserService.java |
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## 攻击面详情

### 按类别分组

#### 网络入口攻击面 (NET-*)

| 攻击面ID | 类型名称 | 业务描述 | 类型KEY | 认证要求 | 网络区域 | 关联向量数 | 关联风险数 | 最高风险等级 |
|----------|---------|---------|---------|---------|---------|-----------|-----------|-------------|
| AS-001 | 登录认证API | 用户登录入口-支持手机号/邮箱登录 | NET-API-LOGIN | token | internet | 2 | 3 | **critical** |
| AS-002 | 公开搜索API | 商品搜索接口-无认证公开访问 | NET-API-SEARCH | none | internet | 1 | 2 | **high** |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

#### 配置暴露攻击面 (CFG-*)

| 攻击面ID | 类型名称 | 业务描述 | 类型KEY | 认证要求 | 网络区域 | 关联向量数 | 关联风险数 | 最高风险等级 |
|----------|---------|---------|---------|---------|---------|-----------|-----------|-------------|
| AS-005 | 监控端点暴露 | Spring Actuator端点-未做访问控制 | CFG-ACTUATOR | none | internet | 1 | 1 | **critical** |
| AS-006 | API文档暴露 | Swagger文档接口-接口详情公开 | CFG-SWAGGER | none | internet | 1 | 1 | **medium** |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

### 信任边界详情

对每个攻击面，展示其信任边界分析：

#### AS-001 (登录认证API - 用户登录入口)

| 边界类型 | 边界KEY | 描述 | 强度 | 代码证据 | 对风险影响 |
|---------|---------|------|------|---------|-----------|
| 加密边界 | BOUND-ENC-TLS | 客户端→服务端：TLS 1.2加密 | medium | src/config/ssl.properties | 无影响 |
| 数据边界 | BOUND-DATA-DB-PLAINTEXT | 应用→数据库：明文连接 | **weak** | src/config/database.yml:10 | **风险提升：high→critical** |

---

## 攻击向量详情

按向量类别分组展示：

### 注入类向量

| 向量ID | 向量KEY | 名称 | 适用攻击面 | 利用复杂度 | 控制点覆盖 | 控制有效性 | 代码证据 |
|--------|---------|------|-----------|-----------|-----------|-----------|---------|
| IV-001 | IV-SQL-UNION | SQL Union注入 | AS-001, AS-002 | trivial | CP-002 | weak | src/controllers/LoginController.java:42 |
| IV-002 | IV-CMD-PIPE | 命令管道注入 | AS-003 | low | 无 | **missing** | src/utils/ExecUtil.java:15 |
| ... | ... | ... | ... | ... | ... | ... | ... |

### 认证类向量

| 向量ID | 向量KEY | 名称 | 适用攻击面 | 利用复杂度 | 控制点覆盖 | 控制有效性 | 代码证据 |
|--------|---------|------|-----------|-----------|-----------|-----------|---------|
| IV-005 | IV-AUTH-BRUTE | 暴力破解 | AS-001 | low | CP-003 | **missing** | src/routes/auth.py:15 |
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## 风险详情

按风险等级排序，每项包含完整信息：

### Critical 级风险

#### RK-001：登录接口SQL注入导致用户数据库全量泄露

| 字段 | 内容 |
|------|------|
| **风险等级** | **critical** |
| **风险类型** | R-CONF-DATA-LEAK（数据泄露） |
| **关联攻击面** | AS-001 (登录认证API - 用户登录入口) |
| **关联攻击向量** | IV-001 (IV-SQL-UNION) |
| **影响描述** | 机密性丧失：全量用户PII数据泄露（手机号、身份证、密码哈希） |
| **可利用性** | 无需认证 + 互联网可达 |
| **控制点评估** | CP-002（参数化查询）：有效性 weak（存在拼接绕过） |
| **边界影响** | BOUND-DATA-DB-PLAINTEXT (weak) → 风险从high提升至critical |
| **代码证据** | src/controllers/LoginController.java:42 |

### High 级风险

#### RK-003：暴力破解导致身份伪造

| 字段 | 内容 |
|------|------|
| **风险等级** | **high** |
| **风险类型** | R-INT-IDENTITY-FORGE（身份伪造） |
| **关联攻击面** | AS-001 (登录认证API - 用户登录入口) |
| **关联攻击向量** | IV-005 (IV-AUTH-BRUTE) |
| **影响描述** | 完整性丧失：攻击者冒充合法用户访问系统 |
| **可利用性** | 无需认证 + 互联网可达 + 无速率限制 |
| **控制点评估** | CP-003（速率限制）：有效性 missing |
| **代码证据** | src/routes/auth.py:15 |

---

## 攻击链详情

对 critical/high 级风险，展示完整攻击路径：

### AC-001：SQL注入拖库链

```
攻击链目标：窃取用户数据库全量数据

┌─────────────────────────────────────────────────────────────────────────┐
│ Step 1: entry - 攻击者访问公开登录页面                                      │
│         攻击面：AS-001 (登录认证API - 用户登录入口)                         │
│         位置：src/routes/auth.py:15                                       │
├─────────────────────────────────────────────────────────────────────────┤
│ Step 2: vector - 在username参数注入SQL Union语句                          │
│         向量：IV-001 (IV-SQL-UNION)                                       │
│         手段：admin' UNION SELECT * FROM users--                          │
├─────────────────────────────────────────────────────────────────────────┤
│ Step 3: bypass - 绕过参数化查询                                            │
│         控制点：CP-002（参数化查询）                                        │
│         绕过原因：登录接口使用${username}拼接而非#{username}                │
├─────────────────────────────────────────────────────────────────────────┤
│ Step 4: reach - SQL语句执行，到达用户数据库                                 │
│         资产：VA-001 (数据资产 - 用户数据库)                                │
│         数据库：MySQL - user_db.users表                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ Step 5: impact - 全量用户数据泄露                                          │
│         风险：RK-001 (R-CONF-DATA-LEAK)                                   │
│         等级：critical                                                    │
│         影响：机密性丧失 - 全量用户PII数据泄露                              │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 控制点评估

### 控制点清单

| 控制点ID | 类型名称 | 业务描述 | 类型KEY | 有效性 | 部署层 | 保护对象 | 绕过方法 | 代码证据 |
|----------|---------|---------|---------|--------|--------|---------|---------|---------|
| CP-001 | 认证控制 | JWT Token验证-有效期24小时 | authentication | medium | middleware | AS-001, AS-002 | JWT算法混淆(none算法) | src/middleware/auth.py:20 |
| CP-002 | 输入校验 | 参数化查询-登录接口SQL防护 | sql_parameterization | **weak** | application | AS-001 | ${}拼接而非#{} | src/controllers/LoginController.java:42 |
| CP-003 | 速率限制 | 速率限制-防止暴力破解(未实现) | rate_limiting | **missing** | gateway | AS-001 | 未实现 | - |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

### 控制有效性统计

| 有效性 | 数量 | 占比 |
|--------|------|------|
| strong | {strong_count} | {strong_pct}% |
| medium | {medium_count} | {medium_pct}% |
| weak | {weak_count} | {weak_pct}% |
| bypassed | {bypassed_count} | {bypassed_pct}% |
| missing | {missing_count} | {missing_pct}% |

---

## 威胁全景映射表

提供攻击面→向量→风险→等级的完整视图：

| 攻击面 | 向量KEY | 向量名称 | 风险KEY | 风险名称 | 等级 | 控制覆盖 |
|--------|---------|---------|---------|---------|------|---------|
| AS-001 (登录认证API) | IV-SQL-UNION | SQL Union注入 | R-CONF-DATA-LEAK | 数据泄露 | **critical** | CP-002 (weak) |
| AS-001 (登录认证API) | IV-SQL-UNION | SQL Union注入 | R-AVAIL-SERVICE-DOWN | 服务中断 | high | CP-002 (weak) |
| AS-001 (登录认证API) | IV-AUTH-BRUTE | 暴力破解 | R-INT-IDENTITY-FORGE | 身份伪造 | high | **无 (missing)** |
| AS-002 (监控端点暴露) | IV-HEAPDUMP | 堆转储利用 | R-CONF-CRED-EXPOSE | 凭据暴露 | **critical** | **无 (missing)** |
| ... | ... | ... | ... | ... | ... | ... |

---

## 附录

### A. 技术栈详情

```json
{
  "languages": ["Java", "Python"],
  "frameworks": ["Spring Boot", "Flask"],
  "databases": ["MySQL", "Redis"],
  "middleware": ["Kafka"],
  "entry_files": ["src/main/Application.java", "app.py"],
  "dir_structure": "标准Maven项目结构",
  "excluded_dirs": ["vendor", "node_modules", ".git", "build", "dist", "target"]
}
```

### B. 统计数据

```json
{
  "total_assets": 5,
  "total_surfaces": 8,
  "total_vectors": 12,
  "total_controls": 6,
  "total_risks": 18,
  "assets_summary": [
    {"asset_type": "data", "asset_name": "数据资产"},
    {"asset_type": "credential", "asset_name": "凭据资产"},
    {"asset_type": "service", "asset_name": "服务资产"}
  ],
  "surface_risk_summary": [
    {
      "surface_type": "NET-API-LOGIN",
      "surface_name": "登录认证API",
      "surface_count": 2,
      "vector_count": 3,
      "risk_count": 5,
      "risk_distribution": {"critical": 1, "high": 2, "medium": 1, "low": 1, "info": 0}
    },
    {
      "surface_type": "CFG-ACTUATOR",
      "surface_name": "监控端点暴露",
      "surface_count": 1,
      "vector_count": 1,
      "risk_count": 2,
      "risk_distribution": {"critical": 1, "high": 0, "medium": 1, "low": 0, "info": 0}
    }
  ],
  "vector_summary": [
    {"vector_type": "IV-SQL-UNION", "vector_name": "SQL Union注入", "vector_count": 3},
    {"vector_type": "IV-AUTH-BRUTE", "vector_name": "暴力破解", "vector_count": 2},
    {"vector_type": "IV-HEAPDUMP", "vector_name": "堆转储利用", "vector_count": 1}
  ],
  "top_risks": [
    {"risk_id": "RK-001", "description": "登录接口SQL注入导致数据泄露", "level": "critical", "surface_id": "AS-001", "vector_id": "IV-001"}
  ]
}
```

### C. 分析配置

| 配置项 | 值 |
|--------|------|
| 分析模式 | standard |
| 排除目录 | vendor, node_modules, .git, build, dist, target |
| 重点目录 | src/controllers, src/routes |
| 分析耗时 | {duration} |
```