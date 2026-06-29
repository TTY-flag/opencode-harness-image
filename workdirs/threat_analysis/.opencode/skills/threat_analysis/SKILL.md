---
name: threat-analysis
description: 从代码仓进行威胁分析，识别价值资产、暴露面、控制点、攻击面和风险点。输出包含攻击面-攻击向量-攻击面风险-风险等级的四层映射关系及攻击链。

触发条件（满足任一即触发）:
- 用户明确请求：威胁分析、代码安全分析、attack surface、threat modeling、安全风险评估、漏洞分析
- 代码仓路径输入：用户提供代码仓库路径并要求安全相关分析
- 检测到典型攻击面模式：
  - 登录/注册/密码重置接口
  - 文件上传/下载接口
  - 数据库查询接口
  - 外部API调用/SSRF场景
  - 反序列化场景
  - 命令执行/模板渲染场景
- 用户描述安全事件：数据泄露、凭据暴露、服务中断、远程代码执行、容器逃逸等
---

# 代码仓威胁分析器

## 启动交互

**Step 0：自我介绍与参数读取**

```
👋 你好！我是代码仓威胁分析器

┌─────────────────────────────────────────────┐
│  定位：代码仓威胁分析专家                     │
│  输入：代码仓库路径                           │
│  输出：攻击面-向量-风险-等级 四层映射          │
└─────────────────────────────────────────────┘

✨ 我能做什么：

  • 从代码仓识别价值资产 → 标注密级和存储位置
  • 从代码仓枚举攻击面 → 网络入口/配置暴露/数据接口
  • 从代码仓识别控制点 → 评估有效性（强/中/弱/缺失）
  • 关联攻击向量 → 注入/认证绕过/越权/SSRF等~120种
  • 映射风险等级 → 机密性/完整性/可用性/合规/业务
  • 构建攻击链 → 入口→绕过控制→到达资产→风险

📋 请提供以下参数：

  必填：
    - 代码仓路径：待分析的代码仓库路径
      示例：D:/projects/my-app 或 /home/user/service
  
  可选：
    - 输出路径：分析结果输出目录（默认为代码仓同目录）
      示例：D:/reports/ 或 /home/user/analysis/
    - 排除目录：不分析的目录（默认：vendor,node_modules,.git,build,dist,target）
    - 重点目录：优先分析的目录

请输入代码仓路径：
```

**用户输入处理**：

| 输入内容 | 解析逻辑 |
|---------|---------|
| 单路径如 `D:/projects/app` | `code_repo_path = D:/projects/app`，`output_path = D:/projects/app-threat-analysis/` |
| 双路径如 `代码仓=D:/app, 输出=D:/reports` | 分别解析 `code_repo_path` 和 `output_path` |
| 仅代码仓路径 | 输出路径默认为 `{code_repo_path父目录}/{产品名}-threat-analysis/` |

**参数确认输出**：

```
=== 参数确认 ===

代码仓路径：D:/projects/my-app
输出路径：D:/projects/my-app-threat-analysis/
排除目录：vendor, node_modules, .git, build, dist, target
产品名称：my-app（从目录名推断）

请确认（输入 y 继续，或修改参数）：
```

---

## 整体工作流

```
 阶段0           阶段1          阶段2          阶段3          阶段4          阶段5
 结构识别        资产识别       攻击面枚举     控制点识别     风险关联       输出成果

 扫描目录树      扫描密钥/凭据  扫描路由/端口  扫描认证/授权  攻击面×向量    生成JSON
 配置文件        敏感数据定义   接口/配置      校验/加密      →风险→等级    生成MD
 依赖清单        核心服务       依赖/运行时    审计/限流      攻击链构建
```

---

## 数据流转策略

### 各阶段输出数据结构

| 阶段 | 输出数据 | 被后续阶段引用 |
|------|---------|---------------|
| 阶段0 | `tech_stack` 对象 | 阶段1-5（技术栈信息） |
| 阶段1 | `value_assets[]` 数组 | 阶段2（linked_assets）、阶段4（攻击链reach步骤） |
| 阶段2 | `attack_surfaces[]` 数组 | 阶段3（protects）、阶段4（攻击链entry步骤、向量匹配） |
| 阶段3 | `control_points[]` 数组 | 阶段4（bypass步骤、controlled_by字段） |
| 阶段4 | `attack_vectors[]`、`risks[]`、`attack_chains[]`、`surface_risk_mapping[]` | 阶段5（合并输出） |

### KEY和ID编号规则

系统采用**双 ID 体系**：类型KEY（枚举）+ 实例ID（数字编号）

#### 类型KEY（预定义枚举，来自 enumeration.md）

| 对象 | KEY前缀 | 来源章节 | 字段用途 |
|------|--------|---------|---------|
| 攻击面KEY | `NET-*`, `CFG-*`, `DATA-*`, `AUTH-*`, `DEP-*`, `RUN-*` | enumeration.md第2章`攻击面KEY` | `attack_surfaces[].surfaces_type` |
| 攻击向量KEY | `IV-*` | enumeration.md第4章`向量KEY` | `attack_vectors[].vector_type` |
| 风险KEY | `R-CONF-*`, `R-INT-*`, `R-AVAIL-*`, `R-COMP-*`, `R-BIZ-*` | enumeration.md第5章`风险KEY` | `risks[].risk_type` |

#### 实例ID（分析过程中分配）

| 对象 | ID前缀 | 编号规则 | 字段名 | 示例 |
|------|--------|---------|--------|------|
| 价值资产 | `VA-*` | 按识别顺序递增 | asset_id | VA-001, VA-002 |
| 攻击面 | `AS-*` | 按识别顺序递增 | surface_id | AS-001, AS-002 |
| 控制点 | `CP-*` | 按识别顺序递增 | control_id | CP-001, CP-002 |
| 攻击向量 | `IV-*` | 按匹配顺序递增（与类型KEY前缀相同，但带序号） | vector_id | IV-001, IV-002 |
| 风险点 | `RK-*` | 按生成顺序递增 | risk_id | RK-001, RK-002 |
| 攻击链 | `AC-*` | 按构建顺序递增 | chain_id | AC-001, AC-002 |

#### 双ID组合示例

```json
{
  "surface_id": "AS-001",           // 实例ID（编号）
  "surfaces_type": "NET-API-LOGIN"       // 类型KEY（枚举）
}

{
  "vector_id": "IV-001",            // 实例ID（编号）
  "vector_type": "IV-SQL-UNION"     // 类型KEY（枚举）
}

{
  "risk_id": "RK-001",              // 实例ID（编号）
  "risk_type": "R-CONF-DATA-LEAK"   // 类型KEY（枚举）
}
```

#### ID编号一致性要求

- 后续阶段引用ID时，使用前阶段已分配的实例ID
- 禁止重复编号
- 禁止跳号
- 同类型对象编号连续递增（VA-001, VA-002, VA-003...）

### 最终输出时机

**阶段5统一生成输出文件**：

1. 阶段5开始时，确认以下数据已完整：
   - `tech_stack` ✓
   - `value_assets[]` ✓
   - `attack_surfaces[]` ✓
   - `control_points[]` ✓
   - `attack_vectors[]` ✓
   - `risks[]` ✓
   - `attack_chains[]` ✓
   - `surface_risk_mapping[]` ✓

2. 组装完整JSON结构（见 output_schema.md）

3. 计算统计数据：
   - `statistics.total_*`: 各数组长度
   - `statistics.risk_distribution`: 遍历 risks 数组统计各级别数量
   - `statistics.surface_risk_summary`: 从映射表提取

4. 写入 `{产品名}-threat-analysis.json`

5. 生成 `{产品名}-threat-report.md`

### 推荐数据管理方式

**内存变量 + 最后统一输出**：

- 优势：跨阶段引用便利、修改灵活、ID统一管理、攻击链/映射表构建高效
- 适用场景：各阶段强依赖、需要构建关联结构（攻击链、映射表）

### 中间输出容错机制

**阶段中断时输出中间JSON**：

若分析过程中中断（如token耗尽），可在阶段末输出中间JSON供后续恢复：

```json
{
  "_intermediate": true,
  "_completed_stages": [0, 1, 2],
  "_current_stage": 3,
  "_next_step": "控制点识别-认证控制扫描",
  "tech_stack": {...},
  "value_assets": [...],
  "attack_surfaces": [...],
  "_partial_control_points": [...]
}
```

**恢复分析时**：
1. 读取中间JSON
2. 检查 `_completed_stages` 确定已完成阶段
3. 从 `_current_stage` 继续分析
4. 合并中间数据到最终输出
5. 最终输出时移除 `_intermediate` 等标记字段

---

## 阶段0：代码仓结构识别

**执行逻辑**：

1. 验证 `code_repo_path` 是否存在
2. 扫描目录树，识别技术栈
3. 读取关键配置文件和依赖清单

**参考文件**：读取 `references/language_patterns.md` 第10章 `## 第10章：依赖文件识别` 和第11章 `## 第11章：配置文件识别` 获取依赖文件和配置文件识别规则。

**输出**：`tech_stack` 对象

```json
{
  "languages": ["Java", "Python"],
  "frameworks": ["Spring Boot", "Flask"],
  "databases": ["MySQL", "Redis"],
  "middleware": ["Kafka"],
  "entry_files": ["src/main/Application.java", "app.py"],
  "dir_structure": "简要描述",
  "excluded_dirs": ["vendor", "node_modules"]
}
```

---

## 阶段1：价值资产识别

**执行逻辑**：

分层扫描，先宏观后深入：

| 扫描项 | grep关键词 | 输出 |
|--------|-----------|------|
| 硬编码密钥 | `password|secret|key|token|api_key|credential` | `credential`/`key` 类型资产 |
| 数据库配置 | `jdbc:|database|mysql|postgresql|mongo` | `data` 类型资产 |
| 敏感数据模型 | `phone|email|idcard|ssn|password|银行卡` | `data` 类型资产（含PII标注） |
| 核心服务 | `@Service|class.*Service|def.*service` | `service` 类型资产 |
| 加密代码 | `encrypt|decrypt|AES|RSA|crypto` | `key`/`algorithm` 类型资产 |

**参考文件**：
- 读取 `references/language_patterns.md` 第9章 `## 第9章：敏感数据识别规则` 获取敏感数据识别规则
- 读取 `references/enumeration.md` 第1章 `## 第1章：价值资产 (Value Assets)` 获取资产类型/密级/位置枚举

**输出格式**：读取并严格参考 `references/output_schema.md` 第1节 `### 1. 价值资产 (value_assets)`。
**输出对象**：`value_assets[]` 数组，并保存在内存里。

---

## 阶段2：攻击面枚举

**执行逻辑**：

| 扫描项 | 方法 | 输出攻击面类型 |
|--------|------|---------------|
| HTTP路由 | grep路由注解/装饰器 | `NET-API-*` 系列 |
| gRPC服务 | 识别.proto和实现 | `NET-GRPC` |
| WebSocket | 识别WS路由 | `NET-WS` |
| 数据库端口 | 配置文件端口 | `NET-DATABASE` |
| 调试配置 | grep DEBUG/debug=true | `CFG-DEBUG-MODE` |
| Swagger/Actuator | grep swagger/actuator | `CFG-SWAGGER`/`CFG-ACTUATOR` |
| CORS配置 | grep CORS/* | `CFG-CORS-WILDCARD` |
| 文件上传接口 | grep MultipartFile/upload | `NET-API-UPLOAD` |
| 认证接口 | grep login/auth/oauth | `AUTH-*` 系列 |
| 依赖清单 | glob依赖文件 | `DEP-PACKAGE` |
| Dockerfile/K8s | glob部署文件 | `RUN-*` 系列 |

**参考文件**：
- 读取 `references/language_patterns.md` 第1章 `## 第1章：路由识别规则` 获取路由识别规则
- 读取 `references/language_patterns.md` 第12章 `## 第12章：部署配置识别` 获取调试端点识别规则
- 读取 `references/enumeration.md` 第2章 `## 第2章：攻击面 (Attack Surface)` 获取攻击面完整枚举（6类57个）

**输出格式**：读取并严格参考 `references/output_schema.md` 第2节 `### 2. 攻击面 (attack_surfaces)`。
**输出对象**：`attack_surfaces[]` 数组，并保存在内存里。

### 2.1 信任边界识别

**识别逻辑**：

对每个攻击面，识别其相关信任边界：

| 边界类型 | grep关键词 | 输出边界KEY |
|---------|-----------|-------------|
| 加密边界 | `http://|ssl.verify=False|insecure|verify=False` | `BOUND-ENC-PLAINTEXT` |
| 加密边界 | `https://|SSLContext|TLS|ssl_enabled` | `BOUND-ENC-TLS` |
| 加密边界 | `client_cert|mtls|双向认证|client_certificate` | `BOUND-ENC-MTLS` |
| 数据边界 | `jdbc:mysql://(非useSSL)|redis://(无密码)` | `BOUND-DATA-DB-PLAINTEXT` |
| 数据边界 | `useSSL=true|require_ssl|ssl-mode=VERIFY_IDENTITY` | `BOUND-DATA-DB-TLS` |
| 数据边界 | `redis://(有密码)|requirepass` | `BOUND-DATA-CACHE-AUTH` |
| 服务边界 | `internal_api|内部调用|免签|skip_auth` | `BOUND-SVC-INTERNAL-TRUST` |
| 服务边界 | `service_token|内部JWT|internal-auth` | `BOUND-SVC-INTERNAL-AUTH` |

**参考文件**：
- 读取 `references/enumeration.md` 第7章 `## 第7章：信任边界` 获取边界完整枚举（3类15个）

**边界强度判定**：

| strength | 判定条件 |
|----------|---------|
| `strong` | mTLS、端到端加密、服务间签名校验 |
| `medium` | TLS加密、数据库SSL连接、Redis密码 |
| `weak` | 明文传输敏感数据、数据库明文连接 |
| `missing` | 应加密但未加密、应有认证但未配置 |

**输出内容**：填充 `attack_surfaces[].trust_boundaries[]` 数组，按优先级排序（P0加密→P1数据→P2服务）。

---

## 阶段3：控制点识别

**执行逻辑**：

| 控制类型 | grep关键词 |
|---------|-----------|
| 认证控制 | `@PreAuthorize|@login_required|jwt|auth|token|session` |
| 授权控制 | `@RolesAllowed|permission|role|checkRole|hasRole` |
| 输入校验 | `@Valid|@NotNull|validate|validator|check|verify|Joi|zod` |
| 加密控制 | `encrypt|AES|TLS|SSL|crypto|hashlib` |
| 速率限制 | `rate|limit|throttle|RateLimiter` |
| 日志审计 | `log|logger|audit|trace|record` |
| CORS | `cors|Access-Control-Allow-Origin` |
| 错误处理 | `catch|exception|handle|try|rescue` |

**参考文件**：
- 读取 `references/language_patterns.md` 第2章 `## 第2章：认证识别规则`、第3章 `## 第3章：授权识别规则`、第4章 `## 第4章：输入校验识别规则` 获取认证/授权/校验识别规则
- 读取 `references/enumeration.md` 第3章 `## 第3章：控制点 (Control Points)` 获取控制类型/有效性枚举

**控制有效性评估逻辑**：

| effectiveness | 判定条件 |
|---------------|---------|
| `strong` | 全覆盖+正确实现+无已知绕过 |
| `medium` | 全覆盖+正确实现+无简单绕过 |
| `weak` | 部分覆盖或存在简单绕过 |
| `bypassed` | 存在已知绕过路径 |
| `missing` | 应有但未实现 |

**输出格式**：读取并严格参考 `references/output_schema.md` 第3节。
**输出对象**：`control_points[]` 数组，并保存在内存里。

---

## 阶段4：风险关联分析

**执行逻辑**：

### 4.1 攻击向量匹配

对每个攻击面，根据代码特征匹配适用攻击向量。

**匹配流程**：

```
步骤1: 对每个攻击面，分析其代码特征
步骤2: 对照 references/enumeration.md 第4章的攻击向量枚举
步骤3: 匹配适用向量（基于攻击面surfaces_type + 代码特征）
步骤4: 检查该向量是否被控制点覆盖 → 记录 control_ids
步骤5: 生成 attack_vectors 数组
```

**参考文件**：
- 读取 `references/language_patterns.md` 第5章 `## 第5章：加密识别规则`、第6章 `## 第6章：SQL识别规则`、第7章 `## 第7章：命令执行识别规则`、第8章 `## 第8章：文件操作识别规则` 获取SQL/命令/加密/文件操作识别规则
- 读取 `references/enumeration.md` 第4章 `## 第4章：攻击向量 (Attack Vectors)` 获取攻击向量完整枚举（11类~120个）

**匹配速查表**（见 `references/analysis_guide.md` 第5.2节）：

| 代码特征 | 匹配向量 |
|---------|---------|
| `${param}` in SQL | `IV-SQL-UNION` |
| `Runtime.exec(input)` | `IV-CMD-PIPE` |
| `eval(user_input)` | `IV-EVAL-INJECT` |
| `pickle.loads(data)` | `IV-DESER-PYTHON` |
| 无认证登录接口 | `IV-AUTH-BRUTE` |
| 无权限检查 | `IV-IDOR-READ` |

**输出格式**：读取并严格参考 `references/output_schema.md` 第4节。

**输出内容**：`attack_vectors[]`数组，保存在内存里；
每个攻击向量包含：
- `vector_id`: 向量实例ID（如 IV-001）
- `vector_type`: 向量类型KEY（如 IV-SQL-UNION，来自enumeration.md第4章）
- `vector_name`: 向量名称
- `vector_category`: 向量所属类别
- `applicable_surfaces`: 适用攻击面实例ID列表
- `code_pattern`: 代码特征描述
- `complexity`: 利用复杂度
- `controlled_by`: 覆盖该向量的控制点实例ID列表
- `control_effectiveness`: 控制点对该向量的有效性评估

### 4.2 风险点生成

对每个攻击面+向量组合，评估成功利用后的风险。

#### 4.2.1 风险点识别流程

**识别逻辑**：

```
步骤1: 遍历 attack_vectors 数组
步骤2: 对每个向量，分析其可达资产（通过攻击面.linked_assets）
步骤3: 评估向量成功利用后对该资产的影响
步骤4: 根据影响维度匹配风险KEY（见enumeration.md第5章）
步骤5: 生成风险点实例，分配risk_id
```

**风险维度映射**：

| 影响类型 | 风险KEY前缀 | 示例风险KEY | 适用场景 |
|---------|------------|-------------|----------|
| 机密性丧失 | R-CONF-* | R-CONF-DATA-LEAK | 数据泄露、凭据暴露、源码泄露 |
| 完整性丧失 | R-INT-* | R-INT-DATA-TAMPER | 数据篡改、身份伪造、代码注入 |
| 可用性丧失 | R-AVAIL-* | R-AVAIL-SERVICE-DOWN | 服务中断、RCE、容器逃逸 |
| 合规违规 | R-COMP-* | R-COMP-PRIVACY | 隐私合规违规、审计缺失 |
| 业务损失 | R-BIZ-* | R-BIZ-FINANCIAL-LOSS | 资金损失、声誉损害、法律风险 |

**向量→风险映射规则**：
如下只做启发参考，不是全量：

| 向量KEY | 主要风险KEY | 影响描述 |
|---------|-------------|----------|
| IV-SQL-UNION | R-CONF-DATA-LEAK, R-AVAIL-SERVICE-DOWN | 数据泄露（机密性）+ 服务中断（可用性） |
| IV-CMD-PIPE | R-AVAIL-RCE, R-INT-CODE-INJECT | 远程代码执行（可用性）+ 代码注入（完整性） |
| IV-AUTH-BRUTE | R-INT-IDENTITY-FORGE | 身份伪造（完整性） |
| IV-IDOR-READ | R-CONF-DATA-LEAK | 数据泄露（机密性） |
| IV-IDOR-WRITE | R-INT-DATA-TAMPER | 数据篡改（完整性） |
| IV-FILE-WEBSHELL | R-AVAIL-RCE, R-INT-CODE-INJECT | 远程代码执行（可用性）+ 代码注入（完整性） |
| IV-PRIVILEGE-POD | R-AVAIL-CONTAINER-ESCAPE, R-CONF-CRED-EXPOSE | 容器逃逸（可用性）+ 凭据暴露（机密性） |
| IV-SSRF-CLOUD-META | R-CONF-CRED-EXPOSE | 云元数据泄露导致凭据暴露（机密性） |

**参考文件**：
- 读取 `references/enumeration.md` 第5章 `## 第5章：攻击面风险 (Surface Risks)` 获取风险完整枚举（5维度~45个）


#### 4.2.2 风险等级判定

**参考文件**：
- 读取 `references/enumeration.md` 第6章 `## 第6章：风险等级 (Risk Levels)` 获取判定矩阵和升降级条件

**判定矩阵**：

```
影响 \ 可利用性    无需认证    低权限认证    高权限认证    需复杂条件
─────────────────────────────────────────────────────────────
RCE/全量泄露        critical    critical     high         high
权限提升/敏感泄露    critical    high         medium       medium
部分数据泄露        high        medium       medium       low
服务部分影响        medium      medium       low          low
信息泄露           medium      low          low          info
```
**参考文件**：
- 读取 `references/enumeration.md` 第5章 `## 第5章：攻击面风险 (Surface Risks)` 获取风险完整枚举（5维度~45个）



**输出格式**：读取并严格参考 `references/output_schema.md` 第5节。
**输出对象**：`risks[]` 数组，并保存在内存里。-
每个风险点包含以下字段：

| 字段 | 说明 | 示例 |
|------|------|------|
| risk_id | 风险实例ID | RK-001 |
| surface_id | 关联攻击面实例ID | AS-001 |
| vector_id | 关联攻击向量实例ID | IV-001 |
| risk_type | 风险KEY | R-CONF-DATA-LEAK |
| risk_category | 风险类别 | vulnerability |
| level | 风险等级（待判定） | critical/high/medium/low/info |
| description | 风险描述 | 登录接口SQL注入导致用户数据库全量泄露 |
| impact | 影响描述 | 机密性丧失：全量用户PII数据泄露 |
| controlled_by | 覆盖该风险的控制点实例ID列表 | ["CP-002"] |
| control_effectiveness | 控制有效性评估 | weak |
| exploitability | 可利用性描述 | 无需认证+互联网可达 |
| evidence | 代码证据 | ["src/controllers/LoginController.java:42"] |

#### 4.2.3 边界强度对风险等级的影响

**升降级规则**：

| 边界状态 | 风险等级调整 | 示例 |
|---------|-------------|------|
| 存在 `strength=missing` 边界 | **提升一级** | 明文传输敏感数据 → high提升为critical |
| 存在 `strength=weak` 边界 | **提升一级** | 数据库明文连接 → medium提升为high |
| 存在 `strength=strong` 边界 | **降低一级** | mTLS加密 → critical降低为high |
| 多个弱边界叠加 | **最多提升两级** | 明文+无认证 → 最多提升两级 |

**边界优先级排序**：

风险报告中按边界强度排序：
- `missing` → 最优先标注
- `weak` → 其次标注
- `medium` → 正常标注
- `strong` → 可省略（或单独列出"已有强边界"）

**判定流程**：

```
步骤1: 根据判定矩阵确定初始风险等级
步骤2: 检查该攻击面的trust_boundaries[]
步骤3: 统计missing/weak/strong边界数量
步骤4: 应用升降级规则
步骤5: 输出最终风险等级 + 边界影响说明
```

**示例**：

```
原风险等级：high (SQL注入 + 公网可达)

边界检查：
- 加密边界：BOUND-ENC-TLS (medium) → 无影响
- 数据边界：BOUND-DATA-DB-PLAINTEXT (weak) → 提升一级

最终风险等级：critical
边界影响说明：数据库明文连接导致内网嗅探风险提升
```

### 4.3 攻击链构建

对 `critical`/`high` 风险项，构建完整攻击链。

**参考文件**：
- 读取 `references/analysis_guide.md` 第7章 `## 第7章：攻击链构建方法` 获取攻击链构建方法

**攻击链步骤类型**：
- `entry`: 入口（攻击面）
- `vector`: 攻击向量
- `bypass`: 绕过控制点
- `reach`: 到达资产
- `impact`: 造成风险

**输出格式**：读取并严格参考 `references/output_schema.md` 第6节。
**输出对象**：`attack_chains[]`，并保存在内存里。

### 4.4 映射表生成

生成 **攻击面 → 攻击向量 → 风险 → 风险等级** 的完整映射表。

**生成逻辑**：

```
步骤1: 遍历所有攻击面
步骤2: 对每个攻击面，获取其关联的攻击向量列表
步骤3: 对每个向量，获取其产生的风险列表及等级
步骤4: 填充 controlled_by（覆盖该向量的控制点）和 control_effectiveness
步骤5: 生成 surface_risk_mapping 数组
```

**映射表作用**：
- 提供完整威胁全景视图，一目了然
- 每个攻击面下直接看到：向量→风险→等级→控制点评估

**输出格式**：读取并严格参考 `references/output_schema.md` 第7节`### 7. 攻击面-向量-风险映射表 (surface_risk_mapping)`。
**输出对象**：`surface_risk_mapping[]`，并保存在内存里。

### 4.5 质量检查（阶段4验收）

**快速自检**：

在阶段4完成后、进入阶段5前，执行以下快速检查：

| 检查项 | 验证条件 | 不满足处理 |
|--------|---------|-----------|
| 向量数量 | `attack_vectors.length > 0` | 回补阶段4.1向量匹配 |
| 风险数量 | `risks.length > 0` | 回补阶段4.2风险生成 |
| 映射表完整 | `surface_risk_mapping.length == attack_surfaces.length` | 回补阶段4.4映射表生成 |
| 攻击链覆盖 | critical/high风险均有对应attack_chain | 回补阶段4.3攻击链构建 |

**输出格式**：

```
=== 阶段4质量检查 ===

✓ attack_vectors: {数量}个
✓ risks: {数量}个
✓ surface_risk_mapping: {数量}个（覆盖{攻击面数量}个攻击面）
✓ attack_chains: {数量}条（覆盖{critical/high数量}个高风险）

检查通过，进入阶段5。
```

**不满足处理**：标注缺失项，返回对应阶段补充后重新检查。

---

## 阶段5：输出成果

**前置条件检查**：

阶段5开始前，确认内存中以下数据已完整并通过质量检查：

| 前置条件 | 验证方法 |
|---------|---------|
| `tech_stack` 对象完整 | languages/frameworks/databases 均有值 |
| `value_assets[]` 数组完整 | 每个资产有 asset_id/type/classification |
| `attack_surfaces[]` 数组完整 | 每个攻击面有 surface_id/surfaces_type/trust_boundaries |
| `control_points[]` 数组完整 | 每个控制点有 control_id/type/effectiveness |
| `attack_vectors[]` 数组完整 | 每个向量有 vector_id/vector_type/applicable_surfaces |
| `risks[]` 数组完整 | 每个风险有 risk_id/surface_id/vector_id/level |
| `attack_chains[]` 数组完整 | critical/high风险均有攻击链 |
| `surface_risk_mapping[]` 数组完整 | 覆盖所有攻击面，每项有 vector_risks[] |

**质量检查清单**：

| 检查项 | 检查逻辑 | 不满足影响 |
|--------|---------|-----------|
| ID编号连续 | VA/AS/CP/IV/RK编号无跳号（如 VA-001,VA-002 无 VA-003） | 引用可能失效 |
| 跨对象引用一致 | risks[].surface_id 在 attack_surfaces[] 中存在 | 报告关联断裂 |
| 向量覆盖完整 | 每个 attack_surface 至少有1个 linked_vector | 威胁全景缺失 |
| 攻击链覆盖 | level=critical/high 的 risks[] 均有 attack_chain | 关键路径缺失 |
| 边界标注完整 | 每个 attack_surface 有 trust_boundaries[] | 边界分析缺失 |
| 控制点标注 | 有控制的向量标注了 controlled_by | 控制评估缺失 |

**输出检查报告**：

```
=== 阶段5前置质量检查 ===

[数据完整性]
✓ tech_stack: 完整
✓ value_assets: {数量}个，完整
✓ attack_surfaces: {数量}个，完整
✓ control_points: {数量}个，完整
✓ attack_vectors: {数量}个，完整
✓ risks: {数量}个，完整
✓ attack_chains: {数量}条，完整
✓ surface_risk_mapping: {数量}项，完整

[质量检查]
✓ ID编号连续：{编号范围}
✓ 跨对象引用一致：检查{数量}个风险点引用，均有效
✓ 向量覆盖完整：surface_risk_mapping中{数量}个攻击面均有向量、风险关联
✓ 攻击链覆盖：{数量}个critical/high风险均有攻击链
✓ 边界标注完整：{数量}个攻击面均有trust_boundaries
✓ 控制点标注：{数量}个向量中有{数量}个标注了controlled_by

检查通过，开始生成输出文件。
```

**不满足处理**：输出缺失项详情，停止阶段5执行，提示返回对应阶段补充。

**输出文件**：

| 文件 | 说明 |
|------|------|
| `{产品名}-threat-analysis.json` | 完整JSON（机器消费） |
| `{产品名}-threat-report.md` | 可读报告（人阅读） |

**输出位置**：`output_path` 参数指定的目录。

**JSON完整结构**：严格参考 `references/output_schema.md`中 `## 完整输出结构` 章节。JSON Schema定义见 `references/schemas/threat_analysis_schema.json`。

内存中各阶段累积的对象，按以下关系填入最终JSON：

| 内存对象 | 填入JSON的位置 | 来源阶段 |
|---------|---------------|---------|
| `value_assets[]` | value_assets字段 | 阶段1 |
| `attack_surfaces[]` | attack_surfaces字段 | 阶段2 |
| `control_points[]` | control_points字段 | 阶段3 |
| `attack_vectors[]` | attack_vectors字段 | 阶段3 |
| `risks[]` | risks字段 | 阶段4 |
| `attack_chains[]` | attack_chains字段 | 阶段4 |
| `surface_risk_mapping[]` | surface_risk_mapping字段 | 阶段4 |
| `trust_boundaries[]` |attack_surfaces字段中trust_boundaries子项（与攻击面同级） | 阶段2 |

**ID引用关系**：各数组内的实例ID（VA-*/AS-*/CP-*/IV-*/RK-*/AC-*）在跨数组引用时使用，确保映射关系可追溯。

**统计数据**：`metadata.summary` 中的计数值（如攻击面总数、风险点总数等）从对应数组长度自动计算，无需手动维护。

**Markdown报告结构**：严格参考 `references/output_schema.md`中 `## Markdown报告结构` 章节。

---

## 参考文件索引

| 文件路径 | 内容 | 使用时机 |
|---------|------|---------|
| `references/enumeration.md` | 枚举值定义（攻击面/向量/风险/等级） | 阶段1-4需要枚举值时 |
| `references/language_patterns.md` | 代码识别规则（路由/认证/校验/加密等） | 阶段0-3识别代码特征时 |
| `references/analysis_guide.md` | 分析方法论（分层策略/评估方法） | 需要分析方法指导时 |
| `references/output_schema.md` | 输出JSON/Markdown结构定义 | 阶段5生成输出时 |
| `references/schemas/threat_analysis_schema.json` | JSON Schema定义（字段完整说明） | 阶段5生成JSON时 |
| `references/security_model.md` | 安全模型参考 | 需要安全模型框架时 |
| `references/languages/` | 各语言安全参考（Java/Python/Go等） | 分析特定语言代码时 |
| `references/security/` | 各安全领域参考（认证/加密/注入等） | 分析特定安全领域时 |

---

## 渐进式加载原则

**不一次性加载所有参考文件，按需读取**：

- 阶段0：仅读取 `language_patterns.md` 第10-11章
- 阶段1：仅读取 `language_patterns.md` 第9章 + `enumeration.md` 第1章
- 阶段2：仅读取 `language_patterns.md` 第1章、第12章 + `enumeration.md` 第2章
- 阶段3：仅读取 `language_patterns.md` 第2-4章 + `enumeration.md` 第3章
- 阶段4：仅读取 `language_patterns.md` 第5-8章 + `enumeration.md` 第4-6章 + `analysis_guide.md` 第5-7章
- 阶段5：仅读取 `output_schema.md`

---

## 容错策略

| 异常情况 | 处理方法 |
|---------|---------|
| 代码仓路径不存在 | 报错退出，提示用户检查路径 |
| 无配置文件 | 从代码推断技术栈 |
| 无依赖清单 | 标注 `no_dependency_file`，跳过供应链分析 |
| 无路由定义 | 从代码结构推断入口文件 |
| 无法判断认证机制 | `auth_required = "unknown"` |
| 无法判断控制有效性 | `effectiveness = "medium"`（保守估计） |
| 无法判断资产密级 | `classification = "internal"`（保守估计） |

---

## Token成本控制

| 策略 | 说明 |
|------|------|
| 分层扫描 | 第一层仅扫描目录/配置，第二层按热点深入 |
| 仅读热点文件 | 不全量扫描所有代码文件 |
| 限制读取长度 | 每文件最多读取2000字符 |
| 按需深入 | 高风险项才触发第三层精确定位 |

---

## 快速判定速查

| 场景 | 风险等级 |
|------|---------|
| 公网无需认证 + SQL注入 + 全量数据 | **critical** |
| 公网无需认证 + 文件上传 + WebShell | **critical** |
| 公网无需认证 + SSRF + 云元数据 | **critical** |
| 公网需低权限认证 + IDOR + 敏感数据 | **high** |
| 内网无需认证 + RCE | **high** |
| 公网需认证 + 配置泄露 | **medium** |
| 仅本机 + 命令注入 | **medium** |
| 公网 + 信息泄露（版本信息） | **low** |
| 需复杂条件 + 有限影响 | **low** 或 **info** |