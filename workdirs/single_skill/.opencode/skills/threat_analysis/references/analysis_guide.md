# 娔胁分析指南

本文档提供代码仓威胁分析的方法论和最佳实践，供分析过程中按需查阅。

---

## 第1章：分层分析策略

### 1.1 分层扫描原则

**第一层：宏观扫描（低成本）**

| 扫描项 | 方法 | 目的 | 优先级 |
|--------|------|------|--------|
| 目录结构 | `ls/glob` | 了解代码仓组织结构 | P0 |
| 配置文件 | `glob *.xml/*.json/*.yml/*.env` | 识别技术栈/框架/敏感配置 | P0 |
| 依赖清单 | `glob pom.xml/package.json` | 识别第三方依赖和版本 | P0 |
| 路由定义 | `grep @Route/@app.route` | 枚举API端点 | P0 |
| 部署配置 | `glob Dockerfile/*.yaml` | 识别运行时配置 | P1 |

**第二层：热点深入（中成本）**

| 扫描项 | 方法 | 目的 | 触发条件 |
|--------|------|------|---------|
| 硬编码密钥 | `grep password/key/secret` | 识别凭据资产 | 第一层完成后 |
| 认证代码 | `grep auth/login/jwt` | 识别认证控制点 | 发现认证攻击面后 |
| SQL查询 | `grep SELECT/INSERT/UPDATE` | 识别注入风险 | 发现数据接口后 |
| 文件操作 | `grep file/upload/path` | 识别文件漏洞 | 发现文件接口后 |
| 加密代码 | `grep encrypt/crypto/hash` | 识别加密控制点 | 发现加密资产后 |

**第三层：精确定位（高成本）**

| 扫描项 | 方法 | 目的 | 触发条件 |
|--------|------|------|---------|
| 具体路由代码 | `Read`热点文件 | 分析单个路由完整逻辑 | 发现可疑攻击向量后 |
| 控制点代码 | `Read`认证/授权文件 | 评估控制有效性 | 发现攻击面后 |
| 漏洞触发点 | `Read`危险函数附近代码 | 构建攻击链 | 发现高风险向量后 |

### 1.2 token成本控制

| 策略 | 说明 |
|------|------|
| **仅读热点文件** | 不全量扫描所有代码文件 |
| **限制读取长度** | 每文件最多读取2000字符（前2000字符通常包含关键定义） |
| **分层触发** | 第二层仅在第一层发现可疑项后触发 |
| **按需深入** | 第三层仅在第二层发现高风险项后触发 |

---

## 第2章：技术栈推断规则

### 2.1 语言推断

| 文件特征 | 推断语言 |
|---------|---------|
| `*.java`文件/`pom.xml`/`build.gradle` | Java |
| `*.py`文件/`requirements.txt`/`setup.py` | Python |
| `*.go`文件/`go.mod` | Go |
| `*.js/*.ts`文件/`package.json` | Node.js (JavaScript/TypeScript) |
| `*.php`文件/`composer.json` | PHP |
| `*.rb`文件/`Gemfile` | Ruby |
| `*.cs`文件/`*.csproj` | C#/.NET |
| `*.c/*.cpp/*.h`文件 | C/C++ |
| `*.rs`文件/`Cargo.toml` | Rust |

### 2.2 框架推断

| 文件特征 | 推断框架 |
|---------|---------|
| `application.yml`/`@SpringBootApplication` | Spring Boot |
| `flask`/`@app.route`/`Flask` | Flask |
| `django`/`settings.py`/`urls.py` | Django |
| `fastapi`/`FastAPI`/`@app.get` | FastAPI |
| `gin`/`Gin`/`router.GET` | Gin |
| `express`/`app.get`/`package.json含express` | Express |
| `nestjs`/`@Controller`/`@Module` | NestJS |
| `react`/`React`/`jsx`/`tsx` | React (前端) |
| `vue`/`Vue`/`.vue`文件 | Vue (前端) |

### 2.3 数据库推断

| 文件特征 | 推断数据库 |
|---------|---------|
| `mysql`/`MySQL`/`3306`/`jdbc:mysql` | MySQL |
| `postgresql`/`PostgreSQL`/`5432`/`jdbc:postgresql` | PostgreSQL |
| `oracle`/`Oracle`/`1521` | Oracle |
| `sqlserver`/`SqlServer`/`1433` | SQL Server |
| `mongodb`/`MongoDB`/`27017` | MongoDB |
| `redis`/`Redis`/`6379` | Redis |
| `elasticsearch`/`Elasticsearch`/`9200` | Elasticsearch |
| `kafka`/`Kafka`/`9092` | Kafka |

---

## 第3章：攻击面枚举方法

### 3.1 API端点枚举流程

```
步骤1: 识别路由注册文件
  - Java: @RequestMapping/@GetMapping/@PostMapping注解
  - Python: @app.route/@router.get装饰器
  - Go: router.GET/router.POST方法调用
  - Node.js: app.get/app.post方法调用

步骤2: 提取路由信息
  - 路径: /api/v1/users
  - 方法: GET/POST/PUT/DELETE
  - 参数: @RequestParam/@PathParam/req.query/req.body

步骤3: 判断认证要求
  - 有认证注解 → auth_required = token/session/oauth
  - 无认证注解 → auth_required = none
  - 不确定 → auth_required = unknown

步骤4: 判断网络区域
  - 路由在@RestController/无特殊标记 → internet
  - 路由含/internal/private标记 → intranet
  - 路由含/admin标记 → intranet/admin_interface
```

### 3.2 配置暴露枚举流程

```
步骤1: 识别配置文件
  - glob: application.yml, .env, settings.py, config.json

步骤2: 检查调试配置
  - DEBUG=true → CFG-DEBUG-MODE
  - spring.h2.console.enabled=true → CFG-CONSOLE
  - management.endpoints.web.exposure.include=* → CFG-ACTUATOR

步骤3: 检查CORS配置
  - Access-Control-Allow-Origin: * → CFG-CORS-WILDCARD

步骤4: 检查默认凭据
  - admin/admin → CFG-DEFAULT-CRED
```

### 3.3 运行时攻击面枚举流程

```
步骤1: 识别Dockerfile
  - USER root → RUN-PRIVILEGED
  - EXPOSE端口 → NET-DEBUG-PORT等

步骤2: 识别K8s清单
  - privileged: true → RUN-PRIVILEGED
  - hostNetwork: true → RUN-HOST-NETWORK
  - hostPath挂载 → RUN-HOST-PATH
  - env中含SECRET → RUN-ENV-SECRET

步骤3: 识别CI/CD配置
  - .gitlab-ci.yml/.github/workflows/*.yml
  - 检查密钥泄露 → DEP-CI-CD
```

---

## 第4章：控制点评估方法

### 4.1 认证控制评估

| 评估维度 | 检查项 | 有效→无效判定 |
|---------|--------|--------------|
| **覆盖完整性** | 是否覆盖所有需认证的端点 | 全覆盖→部分覆盖→关键端点缺失 |
| **实现正确性** | JWT签名是否校验/Session是否有效 | 正确校验→仅校验格式→无校验 |
| **绕过可能性** | 是否存在认证跳过逻辑 | 无绕过路径→复杂绕过→简单绕过→直接绕过 |
| **强度** | 是否支持MFA/强密码策略 | MFA+强密码→单一认证→弱认证 |

**有效性判定标准**：

| effectiveness | 判定条件 |
|---------------|---------|
| `strong` | 全覆盖+正确实现+无已知绕过+支持MFA |
| `medium` | 全覆盖+正确实现+无简单绕过路径 |
| `weak` | 部分覆盖或存在简单绕过路径 |
| `bypassed` | 存在已知的绕过路径（如debug端点跳过认证） |
| `missing` | 应有认证但未实现 |

### 4.2 授权控制评估

| 评估维度 | 检查项 |
|---------|--------|
| **权限注解完整性** | 是否所有敏感操作都有权限注解 |
| **角色定义合理性** | RBAC是否按最小权限原则设计 |
| **IDOR防护** | 是否检查资源归属关系 |
| **越权路径** | 是否存在直接访问他人资源的路径 |

### 4.3 输入校验评估

| 评估维度 | 检查项 |
|---------|--------|
| **校验覆盖** | 是否所有用户输入都经过校验 |
| **校验类型** | 是否使用框架校验(Joi/Pydantic)还是手动校验 |
| **校验强度** | 是否仅校验类型还是校验内容/长度/格式 |
| **绕过可能性** | 是否存在绕过校验的路径 |

---

## 第5章：攻击向量匹配方法

### 5.1 匹配流程

```
对每个攻击面:
  1. 分析其代码特征
  2. 对照攻击向量枚举表(references/enumeration.md第4章)
  3. 匹配适用向量

匹配规则:
  - SQL拼接(${}/f-string) → IV-SQL-UNION/IV-SQL-ERROR/IV-SQL-BLIND
  - Runtime.exec()/os.system() → IV-CMD-PIPE
  - eval()/exec() → IV-EVAL-INJECT
  - 用户输入进模板引擎 → IV-SSTI-*
  - 无认证登录接口 → IV-AUTH-BRUTE/IV-AUTH-NO-RATE-LIMIT
  - JWT校验缺失 → IV-JWT-NONE-ALG/IV-JWT-WEAK-KEY
  - 无权限检查 → IV-IDOR-READ/IV-IDOR-WRITE
  - 文件上传无类型校验 → IV-FILE-EXT-BYPASS/IV-FILE-WEBSHELL
  - URL参数可控 → IV-SSRF-BASIC
  - 硬编码密钥 → IV-HARDCODED-KEY
```

### 5.2 代码特征→向量映射速查表

| 代码特征 | 匹配向量 |
|---------|---------|
| `${param}` in SQL | IV-SQL-UNION/IV-SQL-ERROR/IV-SQL-BLIND |
| `Runtime.exec(input)` | IV-CMD-PIPE |
| `eval(user_input)` | IV-EVAL-INJECT |
| `pickle.loads(data)` | IV-DESER-PYTHON |
| `ObjectInputStream` | IV-DESER-JAVA |
| `Fastjson.parse(text)` + autoType | IV-DESER-FASTJSON |
| `filename = path + user_input` | IV-PATH-TRAVERSAL |
| `upload(file)` 无类型检查 | IV-FILE-WEBSHELL |
| `http.get(user_url)` | IV-SSRF-BASIC |
| `password = "hardcoded123"` | IV-HARDCODED-KEY |
| `DEBUG = True` | IV-DEBUG-EXPLOIT |
| `verify = False` | IV-CERT-BYPASS |
| 无 `@login_required` | IV-AUTH-BRUTE |
| 无 `if user.id == resource.owner_id` | IV-IDOR-READ |

---

## 第6章：风险等级判定方法

### 6.1 判定流程

```
步骤1: 确定可利用性
  - 认证要求: none(无需认证)/token(低权限)/admin(高权限)
  - 网络区域: internet(公网)/intranet(内网)/localhost(本机)
  - 利用复杂度: trivial(简单)/medium(中等)/high(复杂)

步骤2: 确定影响程度
  - 资产密级: top_secret/confidential/internal/public
  - 影响范围: 全量数据/敏感数据/有限数据/信息泄露
  - 影响类型: RCE/权限提升/数据泄露/服务中断/信息泄露

步骤3: 应用判定矩阵
  - 对照 references/enumeration.md 第6章判定矩阵

步骤4: 检查提升/降低条件
  - 满足提升条件 → 等级提升一级
  - 满足降低条件 → 等级降低一级

步骤5: 输出最终等级
  - critical/high/medium/low/info
```

### 6.2 快速判定规则

| 条件组合 | 风险等级 |
|---------|---------|
| 无需认证 + 互联网可达 + RCE/全量泄露 | **critical** |
| 无需认证 + 互联网可达 + 权限提升/敏感泄露 | **critical** |
| 低权限认证 + 互联网可达 + RCE/全量泄露 | **critical** |
| 无需认证 + 互联网可达 + 有限数据泄露 | **high** |
| 低权限认证 + 内网可达 + RCE | **high** |
| 高权限认证 + 内网可达 + RCE | **medium** |
| 无需认证 + 互联网可达 + 信息泄露 | **medium** |
| 需复杂条件 + 任何影响 | **low** 或更低 |

---

## 第7章：攻击链构建方法

### 7.1 攻击链结构

攻击链描述攻击者从入口到达资产造成风险的完整路径：

```
步骤类型枚举:
  - entry: 入口（攻击面）
  - vector: 攻击向量
  - bypass: 绕过控制点
  - reach: 到达资产
  - impact: 造成风险

典型链路:
  entry → vector → bypass → reach → impact
```

### 7.2 构建流程

```
步骤1: 选择高风险(critical/high)风险项
步骤2: 回溯其关联的攻击面和攻击向量
步骤3: 检查路径上的控制点
  - 控制点有效性 = strong → 无bypass步骤
  - 控制点有效性 = weak/missing → 添加bypass步骤
步骤4: 识别到达的资产
步骤5: 描述最终风险影响
步骤6: 输出完整攻击链
```

### 7.3 攻击链示例

```json
{
  "chain_id": "AC-001",
  "name": "SQL注入拖库链",
  "steps": [
    {
      "step_id": 1,
      "type": "entry",
      "attack_surface": "AS-001",
      "description": "攻击者访问公开登录页面 /api/v1/login"
    },
    {
      "step_id": 2,
      "type": "vector",
      "attack_vector": "IV-SQL-UNION",
      "description": "在username参数注入: admin' UNION SELECT * FROM users--"
    },
    {
      "step_id": 3,
      "type": "bypass",
      "control_point": "CP-002",
      "description": "绕过参数化查询: 登录接口使用${username}拼接而非#{username}"
    },
    {
      "step_id": 4,
      "type": "reach",
      "value_asset": "VA-001",
      "description": "SQL语句执行,到达用户数据库users表"
    },
    {
      "step_id": 5,
      "type": "impact",
      "risk": "R-CONF-DATA-LEAK",
      "level": "critical",
      "description": "全量用户PII数据泄露(手机号/身份证/密码哈希)"
    }
  ]
}
```

---

## 第8章：报告生成指南

### 8.1 Markdown报告结构

```
# {产品名} 威胁分析报告

## 执行摘要
- 分析日期: YYYY-MM-DD
- 代码仓路径: /path/to/repo
- 技术栈: Java/Spring Boot/MySQL
- 发现概览: 发现X个攻击面、Y个风险点
- 风险分布: Critical X个、High Y个、Medium Z个

## 关键发现
按风险等级列出Top5-10风险项

## 风险详情
按风险等级排序,列出所有风险项详情

## 攻击面详情
按类别分组列出攻击面

## 攻击链
绘制critical/high级别攻击链

## 控制点评估
列出识别到的控制点和有效性评估

## 修复建议
按优先级排序列出修复建议

## 附录
- 技术栈详情
- 价值资产清单
- 统计数据
```

### 8.2 JSON报告结构

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
    }
  },
  "value_assets": [],
  "attack_surfaces": [],
  "attack_vectors": [],
  "control_points": [],
  "risks": [],
  "attack_chains": [],
  "statistics": {
    "total_assets": 0,
    "total_surfaces": 0,
    "total_vectors": 0,
    "total_controls": 0,
    "total_risks": 0,
    "risk_distribution": {
      "critical": 0,
      "high": 0,
      "medium": 0,
      "low": 0,
      "info": 0
    }
  }
}
```

---

## 第9章：最佳实践

### 9.1 分析顺序

推荐按以下顺序分析,效率最高:

```
1. 目录结构 → 识别技术栈
2. 配置文件 → 识别暴露面/密钥
3. 依赖清单 → 识别供应链风险
4. 路由定义 → 枚举攻击面
5. 认证代码 → 评估认证控制
6. 授权代码 → 评估授权控制
7. 输入校验 → 评估校验控制
8. SQL查询 → 识别注入风险
9. 文件操作 → 识别文件漏洞
10. 命令执行 → 识别RCE风险
11. 部署配置 → 识别运行时风险
```

### 9.2 风险优先级排序

```
优先分析:
  - 无需认证的公开API
  - 登录/认证相关接口
  - 文件上传/下载接口
  - SQL查询接口
  - 命令执行代码

次优先分析:
  - 内部API
  - 配置文件
  - 依赖CVE
  - 加密代码

最后分析:
  - 日志代码
  - 异常处理
  - 非核心功能
```

### 9.3 避免误判

| 常见误判 | 正确判断 |
|---------|---------|
| 所有SQL都判定为注入 | 仅拼接SQL才是注入风险,参数化SQL安全 |
| 所有文件操作都是漏洞 | 有校验的文件操作安全 |
| 看到eval就判定为漏洞 | eval处理用户输入才是漏洞 |
| 看到密码字符串就判定为硬编码密钥 | 配置文件中的密码可能是正常配置项 |
| 看到DEBUG配置就判定为风险 | 仅生产环境DEBUG开启才是风险 |

---

## 第10章：容错处理

### 10.1 文件缺失处理

| 缺失情况 | 处理方法 |
|---------|---------|
| 无配置文件 | 从代码推断技术栈 |
| 无依赖清单 | 标注`no_dependency_file`,不分析供应链风险 |
| 无部署配置 | 不分析运行时攻击面 |
| 无路由定义 | 从代码结构推断入口文件 |

### 10.2 无法判断的处理

| 无法判断的情况 | 处理方法 |
|---------------|---------|
| 认证机制不明确 | auth_required = "unknown" |
| 控制点有效性不确定 | effectiveness = "medium"(保守估计) |
| 资产密级不确定 | classification = "internal"(保守估计) |
| 网络区域不确定 | network_zone = "internet"(保守估计) |