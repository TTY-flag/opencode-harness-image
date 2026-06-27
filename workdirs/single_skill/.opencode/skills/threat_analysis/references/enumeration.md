# 威胁分析枚举值定义

本文档定义威胁分析输出对象的所有枚举值，供分析过程中按需查阅。

---

## 第1章：价值资产 (Value Assets)

### 1.1 资产类型枚举

| 类型ID | 大类 | 资产类型名称 | 示例 |
|--------|--------|---------|------|
| `data` | 数据资产 | 数据库连接/模型定义/数据类 | 用户表、交易记录、日志 |
| `credential` | 凭据资产 | 硬编码密钥/配置文件/Secret引用 | API Key、数据库密码、OAuth Token |
| `key` | 密钥资产 | 证书文件/密钥生成代码/RSA/AES | 私钥文件、签名密钥、加密密钥 |
| `service` | 服务资产 | 服务入口/路由定义/Listener | 认证服务、支付网关、推理引擎 |
| `config` | 配置资产 | 配置文件/环境变量/启动参数 | 数据库连接串、服务端口、功能开关 |
| `algorithm` | 算法/逻辑资产 | 核心业务代码/决策逻辑 | 定价算法、风控规则、推荐模型 |
| `infra` | 基础设施资产 | Dockerfile/IaC/部署脚本 | K8s清单、CI/CD配置、容器镜像 |
| `other` | 其它资产 | 不在上述分类的资产类型 | 自定义资产类型 |

### 1.2 资产密级枚举

| 密级 | 定义 | 识别特征 |
|------|------|---------|
| `public` | 可对外公开 | README、公开API文档、静态资源 |
| `internal` | 仅内部使用 | 内部API、管理接口、内部服务通信 |
| `confidential` | 泄露造成重大损失 | 用户PII、交易数据、密钥材料 |
| `top_secret` | 泄露造成极严重后果 | 根密钥、CA私钥、核心算法源码 |
| `other` | 其它密级 | 不在上述分类的密级 | 自定义密级定义 |

### 1.3 资产存储位置枚举

| 位置类型 | 说明 |
|---------|------|
| `database` | 关系型/NoSQL数据库 |
| `file_system` | 本地文件/配置文件 |
| `memory` | 运行时内存/缓存 |
| `secret_store` | 密钥管理服务(KMS/Vault/K8s Secret) |
| `code_hardcoded` | 硬编码在源码中 |
| `env_variable` | 环境变量 |
| `log_storage` | 日志存储 |
| `cache` | Redis/Memcached等缓存 |
| `message_queue` | 消息队列中的数据 |
| `other` | 其它存储位置 | 不在上述分类的存储位置 | 自定义存储类型 |

---

## 第2章：攻击面 (Attack Surface)

攻击面 = 系统暴露的、可被攻击者触达的入口/途径。

### 2.1 网络入口攻击面

| 攻击面KEY | 攻击面名称 | 代码识别特征 |
|----------|-----------|-------------|
| `NET-API-PUBLIC` | 公开HTTP API | 无认证注解/无中间件校验的路由 |
| `NET-API-AUTHED` | 需认证HTTP API | 有认证注解/中间件的路由 |
| `NET-API-ADMIN` | 管理API | 路由含/admin/manage/角色=admin |
| `NET-API-UPLOAD` | 文件上传API | MultipartFile/multipart/form-data |
| `NET-API-DOWNLOAD` | 文件下载API | 文件流响应/Content-Disposition |
| `NET-API-SEARCH` | 搜索/查询API | 查询参数直接拼SQL/传入查询 |
| `NET-API-LOGIN` | 登录认证API | /login//auth/Token签发 |
| `NET-API-REGISTER` | 注册API | 用户创建/注册路由 |
| `NET-API-PWDRESET` | 密码重置API | 密码重置/找回路由 |
| `NET-API-OAUTH` | OAuth/SSO回调 | /callback//oauth/SAML路由 |
| `NET-API-WEBHOOK` | Webhook接收端 | POST接收外部回调 |
| `NET-API-GRAPHQL` | GraphQL端点 | GraphQL Schema/Resolver |
| `NET-WS` | WebSocket端点 | WS路由注册 |
| `NET-GRPC` | gRPC服务端 | .proto定义+服务实现 |
| `NET-RPC` | RPC服务端 | Dubbo/Thrift/gRPC服务注册 |
| `NET-DATABASE` | 数据库端口 | 连接配置中端口暴露 |
| `NET-CACHE` | 缓存端口 | Redis/Memcached连接配置 |
| `NET-MQ` | 消息队列端口 | Kafka/RabbitMQ连接配置 |
| `NET-DEBUG-PORT` | 调试端口 | JDWP/Node inspect/Python debug |
| `NET-OTHER` | 其它网络入口 | 不在上述分类的网络入口 | 自定义网络入口类型 |

### 2.2 配置暴露攻击面

| 攻击面KEY | 攻击面名称 | 代码识别特征 |
|----------|-----------|-------------|
| `CFG-DEBUG-MODE` | 调试模式 | DEBUG=True/dev mode/@Profile(dev) |
| `CFG-SWAGGER` | API文档暴露 | Swagger/OpenAPI路由未限制 |
| `CFG-ACTUATOR` | 监控端点暴露 | Spring Actuator端点开放 |
| `CFG-METRICS` | 指标端点 | Prometheus/Metrics路由 |
| `CFG-TRACE` | 链路追踪端点 | Zipkin/Jaeger UI |
| `CFG-CONSOLE` | 管理控制台 | H2 Console/Solo/Druid |
| `CFG-ENV-ENDPOINT` | 环境信息端点 | /env//info//configprops |
| `CFG-VERSION-LEAK` | 版本信息泄露 | Server Header/错误页版本 |
| `CFG-GIT-EXPOSED` | Git信息暴露 | .git目录可访问 |
| `CFG-BACKUP-FILE` | 备份文件暴露 | .bak/.old/.swp文件 |
| `CFG-CORS-WILDCARD` | CORS通配 | Access-Control-Allow-Origin: * |
| `CFG-DEFAULT-CRED` | 默认凭据 | 默认密码/初始密码未改 |
| `CFG-VERBOSE-ERROR` | 详细错误信息 | 堆栈信息返回给客户端 |
| `CFG-OTHER` | 其它配置暴露 | 不在上述分类的配置暴露 | 自定义配置暴露类型 |

### 2.3 数据接口攻击面

| 攻击面KEY | 攻击面名称 | 代码识别特征 |
|----------|-----------|-------------|
| `DATA-DB-QUERY` | 数据库查询接口 | SQL查询构建/ORM调用 |
| `DATA-FILE-READ` | 文件读取接口 | FileInputStream/文件路径参数 |
| `DATA-FILE-WRITE` | 文件写入接口 | FileOutputStream/文件上传 |
| `DATA-FILE-DELETE` | 文件删除接口 | Files.delete/删除路由 |
| `DATA-EXPORT` | 数据导出接口 | CSV/Excel/PDF导出 |
| `DATA-IMPORT` | 数据导入接口 | CSV/Excel/JSON导入解析 |
| `DATA-LOG-ACCESS` | 日志访问接口 | 日志查询/下载路由 |
| `DATA-SENSITIVE-FIELD` | 敏感字段接口 | 返回手机号/身份证/密码字段 |
| `DATA-OTHER` | 其它数据接口 | 不在上述分类的数据接口 | 自定义数据接口类型 |

### 2.4 认证授权攻击面

| 攻击面KEY | 攻击面名称 | 代码识别特征 |
|----------|-----------|-------------|
| `AUTH-LOGIN` | 登录入口 | 认证路由/Token签发 |
| `AUTH-REGISTER` | 注册入口 | 用户注册路由 |
| `AUTH-PWDRESET` | 密码重置入口 | 密码找回/重置路由 |
| `AUTH-TOKEN-REFRESH` | Token刷新入口 | Refresh Token路由 |
| `AUTH-OAUTH-CALLBACK` | OAuth回调入口 | OAuth callback URL |
| `AUTH-SESSION` | 会话管理入口 | Session创建/销毁 |
| `AUTH-MFA` | MFA入口 | 多因素认证路由 |
| `AUTHZ-ENDPOINT` | 授权检查端点 | 权限校验逻辑 |
| `AUTHZ-RESOURCE` | 资源级授权 | 对象级权限检查 |
| `AUTH-OTHER` | 其它认证授权入口 | 不在上述分类的认证授权入口 | 自定义认证授权类型 |

### 2.5 依赖与构建攻击面

| 攻击面KEY | 攻击面名称 | 代码识别特征 |
|----------|-----------|-------------|
| `DEP-PACKAGE` | 第三方包依赖 | package.json/pom.xml/requirements.txt |
| `DEP-NO-LOCK` | 无版本锁定 | 缺少lock文件 |
| `DEP-BUILD-SCRIPT` | 构建脚本 | Dockerfile/Makefile/Jenkinsfile |
| `DEP-CI-CD` | CI/CD流水线 | .gitlab-ci.yml/.github/workflows |
| `DEP-CONTAINER` | 容器镜像 | FROM基础镜像 |
| `DEP-IAC` | 基础设施代码 | Terraform/CloudFormation/K8s YAML |
| `DEP-OTHER` | 其它依赖构建 | 不在上述分类的依赖构建 | 自定义依赖构建类型 |

### 2.6 运行时攻击面

| 攻击面KEY | 攻击面名称 | 代码识别特征 |
|----------|-----------|-------------|
| `RUN-PRIVILEGED` | 特权容器 | privileged: true/CAP_SYS_ADMIN |
| `RUN-HOST-NETWORK` | 宿主网络 | hostNetwork: true |
| `RUN-HOST-PATH` | 宿主路径挂载 | hostPath/volume挂载/ |
| `RUN-ENV-SECRET` | 环境变量密钥 | Secret以ENV注入 |
| `RUN-LOG-SENSITIVE` | 敏感日志 | 日志打印密码/Token |
| `RUN-RESOURCE-LIMIT` | 资源限制缺失 | 无limits/无超时 |
| `RUN-OTHER` | 其它运行时 | 不在上述分类的运行时攻击面 | 自定义运行时类型 |

### 2.7 入口点类型枚举 (entry_type)

| 类型 | 说明 |
|------|------|
| `http_api` | HTTP API端点 |
| `grpc_service` | gRPC服务 |
| `websocket` | WebSocket端点 |
| `graphql` | GraphQL端点 |
| `web_ui` | Web页面 |
| `cli_command` | CLI命令 |
| `file_interface` | 文件接口 |
| `message_consumer` | 消息消费者 |
| `scheduled_task` | 定时任务 |
| `database_port` | 数据库端口 |
| `cache_port` | 缓存端口 |
| `debug_port` | 调试端口 |
| `other` | 其它入口类型 | 不在上述分类的入口类型 | 自定义入口类型 |

### 2.8 认证要求枚举 (auth_required)

| 值 | 含义 |
|----|------|
| `none` | 无需认证（完全开放） |
| `token` | Bearer Token认证 |
| `session` | Session/Cookie认证 |
| `certificate` | 客户端证书认证（mTLS） |
| `api_key` | API Key认证 |
| `oauth` | OAuth2/OIDC认证 |
| `basic` | HTTP Basic认证 |
| `hmac` | HMAC签名认证 |
| `custom` | 自定义认证机制 |
| `unknown` | 无法判断 |
| `other` | 其它认证方式 | 不在上述分类的认证方式 | 自定义认证机制 |

### 2.9 网络区域枚举 (network_zone)

| 区域 | 含义 |
|------|------|
| `internet` | 互联网直接可达 |
| `dmz` | DMZ区域 |
| `intranet` | 内网可达 |
| `cluster_internal` | 集群内部（K8s Service） |
| `localhost` | 仅本机回环 |
| `other` | 其它网络区域 | 不在上述分类的网络区域 | 自定义网络区域 |

### 2.10 暴露模式枚举 (exposure_mode)

| 模式 | 含义 |
|------|------|
| `public_api` | 公开API |
| `authenticated_api` | 需认证API |
| `internal_api` | 内部服务API |
| `admin_interface` | 管理接口 |
| `debug_endpoint` | 调试端点 |
| `health_check` | 健康检查 |
| `metrics_endpoint` | 监控指标端点 |
| `other` | 其它暴露模式 | 不在上述分类的暴露模式 | 自定义暴露模式 |

---

## 第3章：控制点 (Control Points)

### 3.1 控制类型枚举

| 类型KEY | 类型名 | 识别方式 |
|--------|--------|---------|
| `authentication` | 认证控制 | 认证中间件/拦截器/装饰器 |
| `authorization` | 授权控制 | 权限注解/RBAC代码/ACL |
| `input_validation` | 输入校验 | 校验注解/校验函数/Schema |
| `output_encoding` | 输出编码 | 编码函数/模板自动转义 |
| `encryption` | 加密控制 | 加密函数/TLS配置/密钥管理 |
| `rate_limiting` | 速率限制 | 限流中间件/注解 |
| `session_management` | 会话管理 | Session配置/Token管理 |
| `logging` | 日志审计 | 日志记录代码/AOP |
| `error_handling` | 错误处理 | 异常捕获/全局异常处理器 |
| `cors_policy` | CORS策略 | CORS中间件/配置 |
| `csrf_protection` | CSRF防护 | CSRF Token/SameSite Cookie |
| `file_validation` | 文件校验 | 文件类型检查/大小限制 |
| `sql_parameterization` | SQL参数化 | ORM/预编译语句 |
| `secrets_management` | 密钥管理 | 密钥存储方式 |
| `other` | 其它控制类型 | 不在上述分类的控制类型 | 自定义控制类型 |

### 3.2 控制有效性枚举

| 等级 | 含义 | 判定依据 |
|------|------|---------|
| `strong` | 有效控制 | 覆盖完整、实现正确、无已知绕过 |
| `medium` | 部分有效 | 覆盖不完整、存在已知绕过但利用难度高 |
| `weak` | 控制薄弱 | 覆盖不足、容易绕过、实现有缺陷 |
| `bypassed` | 已被绕过 | 代码中存在已知绕过路径 |
| `missing` | 控制缺失 | 应有但未实现 |
| `misconfigured` | 配置错误 | 存在但配置不当 |
| `other` | 其它有效性 | 不在上述分类的有效性状态 | 自定义有效性评估 |

### 3.3 控制部署层枚举

| 层级 | 说明 |
|------|------|
| `network` | 网络层（防火墙/WAF/网络策略） |
| `gateway` | 网关层（API Gateway/Ingress） |
| `middleware` | 中间件层（认证中间件/拦截器） |
| `application` | 应用层（业务代码中的校验逻辑） |
| `data` | 数据层（加密/脱敏/访问控制） |
| `infrastructure` | 基础设施层（容器安全/IaC策略） |
| `other` | 其它部署层 | 不在上述分类的部署层 | 自定义部署层 |

---

## 第4章：攻击向量 (Attack Vector)

攻击向量 = 利用攻击面的具体技术手段。

### 4.1 注入类向量

| 向量KEY | 向量名称 | 适用攻击面 | 代码识别特征 |
|--------|---------|-----------|-------------|
| `IV-SQL-UNION` | SQL Union注入 | NET-API-SEARCH/DATA-DB-QUERY | ${}拼接SQL |
| `IV-SQL-ERROR` | SQL报错注入 | NET-API-SEARCH/DATA-DB-QUERY | 动态SQL+错误回显 |
| `IV-SQL-BLIND` | SQL盲注 | NET-API-SEARCH/DATA-DB-QUERY | SQL拼接无回显 |
| `IV-CMD-PIPE` | 命令管道注入 | NET-API-PUBLIC/DATA-FILE-READ | Runtime.exec()/os.system() |
| `IV-SSTI-JINJA` | Jinja2模板注入 | NET-API-PUBLIC | Jinja2渲染用户输入 |
| `IV-SSTI-FREEMARKER` | Freemarker注入 | NET-API-PUBLIC | Freemarker渲染用户输入 |
| `IV-EXPRESSION-SPEL` | SpEL注入 | NET-API-PUBLIC | SpEL表达式解析用户输入 |
| `IV-XSS-REFLECTED` | 反射型XSS | NET-API-PUBLIC | 输入直接返回HTML |
| `IV-XSS-STORED` | 存储型XSS | NET-API-PUBLIC | 用户输入存储后渲染 |
| `IV-XXE-PARSER` | XXE注入 | NET-API-PUBLIC/DATA-IMPORT | XML解析器未禁用外部实体 |
| `IV-LDAP-INJECT` | LDAP注入 | AUTH-LOGIN | LDAP查询拼接 |
| `IV-NOSQL-INJECT` | NoSQL注入 | NET-API-SEARCH/DATA-DB-QUERY | MongoDB查询拼接 |
| `IV-OTHER-INJECT` | 其它注入向量 | 不在上述分类的注入向量 | 自定义注入向量类型 |

### 4.2 认证类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-AUTH-BRUTE` | 暴力破解 | AUTH-LOGIN | 对登录接口尝试大量密码组合 |
| `IV-AUTH-CREDENTIAL-STUFFING` | 凭据填充 | AUTH-LOGIN | 使用泄露账号密码批量尝试 |
| `IV-AUTH-DEFAULT-CRED` | 默认凭据 | AUTH-LOGIN/CFG-DEFAULT-CRED | 使用默认密码登录 |
| `IV-AUTH-NO-RATE-LIMIT` | 无速率限制 | AUTH-LOGIN/AUTH-PWDRESET | 无限次尝试不被锁定 |
| `IV-JWT-NONE-ALG` | JWT算法混淆 | AUTH-LOGIN | 将算法改为none绕过签名 |
| `IV-JWT-WEAK-KEY` | JWT弱密钥 | AUTH-LOGIN | 暴力破解HS256密钥 |
| `IV-SESSION-FIXATION` | 会话固定 | AUTH-SESSION | 登录前后SessionID不变 |
| `IV-PWDRESET-TOKEN-LEAK` | 重置Token泄露 | AUTH-PWDRESET | 重置链接通过Referer泄露 |
| `IV-OAUTH-REDIRECT` | OAuth重定向 | AUTH-OAUTH-CALLBACK | 篡改redirect_uri |
| `IV-OAUTH-CSRF` | OAuth CSRF | AUTH-OAUTH-AUTHORIZE | state参数缺失/未校验 |
| `IV-OTHER-AUTH` | 其它认证向量 | 不在上述分类的认证向量 | 自定义认证向量类型 |

### 4.3 授权类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-IDOR-READ` | IDOR越权读取 | AUTHZ-RESOURCE | 替换资源ID读取他人数据 |
| `IV-IDOR-WRITE` | IDOR越权写入 | AUTHZ-RESOURCE | 替换资源ID修改他人数据 |
| `IV-HORIZONTAL-ESCALATION` | 横向越权 | AUTHZ-ENDPOINT | 同角色不同用户间越权 |
| `IV-VERTICAL-ESCALATION` | 垂直提权 | AUTHZ-ENDPOINT/AUTHZ-ROLE | 普通用户执行管理员操作 |
| `IV-MASS-ASSIGNMENT` | 批量赋值 | NET-API-PUBLIC/NET-API-AUTHED | 请求体注入角色/权限字段 |
| `IV-API-UNAUTH` | API未授权 | NET-API-AUTHED | 绕过认证直接访问API |
| `IV-OTHER-AUTHZ` | 其它授权向量 | 不在上述分类的授权向量 | 自定义授权向量类型 |

### 4.4 反序列化/执行类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-DESER-JAVA` | Java反序列化 | NET-API-PUBLIC/DATA-IMPORT | ObjectInputStream反序列化恶意对象 |
| `IV-DESER-PYTHON` | Python反序列化 | NET-API-PUBLIC/DATA-IMPORT | pickle.loads()执行任意代码 |
| `IV-DESER-FASTJSON` | Fastjson RCE | NET-API-PUBLIC | autoType开启+Gadget Chain |
| `IV-JNDI-INJECT` | JNDI注入 | NET-API-PUBLIC | lookup参数可控加载远程类 |
| `IV-EVAL-INJECT` | eval注入 | NET-API-PUBLIC | eval()/exec()执行用户输入 |
| `IV-TEMPLATE-INJECT` | 模板注入 | NET-API-PUBLIC | 模板引擎执行服务端代码 |
| `IV-OTHER-DESER` | 其它反序列化向量 | 不在上述分类的反序列化向量 | 自定义反序列化向量类型 |

### 4.5 文件操作类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-FILE-EXT-BYPASS` | 扩展名绕过 | NET-API-UPLOAD | 双扩展名/大小写/空字节截断 |
| `IV-FILE-MIME-SPOOF` | MIME伪造 | NET-API-UPLOAD | 修改Content-Type绕过校验 |
| `IV-FILE-WEBSHELL` | WebShell上传 | NET-API-UPLOAD | 上传可执行脚本文件 |
| `IV-PATH-TRAVERSAL` | 路径遍历 | DATA-FILE-READ/DATA-FILE-WRITE | ../跳出目录 |
| `IV-ZIP-SLIP` | Zip Slip | NET-API-UPLOAD | 压缩文件名含../ |
| `IV-OTHER-FILE` | 其它文件操作向量 | 不在上述分类的文件操作向量 | 自定义文件操作向量类型 |

### 4.6 SSRF类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-SSRF-BASIC` | 基础SSRF | NET-API-PUBLIC | URL参数可控访问内网 |
| `IV-SSRF-PROTOCOL` | 协议绕过 | NET-API-PUBLIC | file:///gopher:///dict:// |
| `IV-SSRF-CLOUD-META` | 云元数据 | NET-API-PUBLIC | 访问169.254.169.254 |
| `IV-JDBC-INJECT` | JDBC注入 | DATA-DB-QUERY | 连接字符串参数注入 |
| `IV-OTHER-SSRF` | 其它SSRF向量 | 不在上述分类的SSRF向量 | 自定义SSRF向量类型 |

### 4.7 加密/配置类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-HARDCODED-KEY` | 硬编码密钥利用 | RUN-ENV-SECRET/CFG-DEFAULT-CRED | 从源码提取硬编码密钥 |
| `IV-WEAK-CRYPTO` | 弱加密利用 | NET-API-AUTHED | 使用DES/RC4/MD5可被破解 |
| `IV-CERT-BYPASS` | 证书校验绕过 | NET-API-PUBLIC | SSL验证被禁用 |
| `IV-CORS-EXPLOIT` | CORS利用 | CFG-CORS-WILDCARD | 利用通配CORS窃取数据 |
| `IV-DEBUG-EXPLOIT` | 调试端点利用 | CFG-DEBUG-MODE/CFG-ACTUATOR | 访问调试接口获取敏感信息 |
| `IV-INFO-LEAK-ERROR` | 错误信息利用 | CFG-VERBOSE-ERROR | 从错误堆栈提取路径/版本 |
| `IV-HEAPDUMP` | 堆转储利用 | CFG-ACTUATOR | 下载heapdump提取内存密钥 |
| `IV-OTHER-CRYPTO` | 其它加密/配置向量 | 不在上述分类的加密/配置向量 | 自定义加密/配置向量类型 |

### 4.8 业务逻辑类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-PRICE-TAMPER` | 价格篡改 | NET-API-AUTHED | 修改价格/数量参数 |
| `IV-STATE-BYPASS` | 状态机绕过 | NET-API-AUTHED | 跳过流程必经步骤 |
| `IV-DOUBLE-PAY` | 双重支付 | NET-API-AUTHED | 并发请求重复支付 |
| `IV-COUPON-REUSE` | 优惠券重复使用 | NET-API-AUTHED | 同一优惠券多次使用 |
| `IV-OTHER-BIZ` | 其它业务逻辑向量 | 不在上述分类的业务逻辑向量 | 自定义业务逻辑向量类型 |

### 4.9 供应链类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-DEP-CVE` | 已知CVE利用 | DEP-PACKAGE | 利用依赖包已知漏洞 |
| `IV-DEP-TYPOSQUAT` | 命名混淆攻击 | DEP-PACKAGE | 安装名字相似的恶意包 |
| `IV-DEP-NO-LOCK` | 版本劫持 | DEP-NO-LOCK | 无锁文件导致安装恶意版本 |
| `IV-OTHER-DEP` | 其它供应链向量 | 不在上述分类的供应链向量 | 自定义供应链向量类型 |

### 4.10 运行时/内存类向量

| 向量KEY | 向量名称 | 适用攻击面 | 攻击手段描述 |
|--------|---------|-----------|-------------|
| `IV-PRIVILEGE-POD` | 特权容器逃逸 | RUN-PRIVILEGED | 从特权容器逃逸到宿主 |
| `IV-HOST-PATH-MOUNT` | 宿主路径泄露 | RUN-HOST-PATH | 读取宿主文件系统 |
| `IV-ENV-SECRET-LEAK` | 环境变量泄露 | RUN-ENV-SECRET | 通过/proc/1/environ读取 |
| `IV-LOG-SENSITIVE` | 日志敏感信息 | RUN-LOG-SENSITIVE | 从日志提取密码/Token |
| `IV-RACE-CONDITION` | 竞态条件利用 | NET-API-AUTHED | 并发请求利用TOCTOU |
| `IV-INTEGER-OVERFLOW` | 整数溢出利用 | NET-API-AUTHED | 边界值触发溢出 |
| `IV-BUFFER-OVERFLOW` | 缓冲区溢出 | NET-API-PUBLIC | 原生代码缓冲区越界 |
| `IV-OTHER-RUNTIME` | 其它运行时向量 | 不在上述分类的运行时向量 | 自定义运行时向量类型 |

### 4.11 攻击复杂度枚举

| 等级 | 含义 |
|------|------|
| `trivial` | 无需认证/特殊条件，直接可达 |
| `low` | 需要普通用户权限或简单绕过 |
| `medium` | 需要特定条件组合或中等技术能力 |
| `high` | 需要多步利用或高级技术 |
| `other` | 其它复杂度 | 不在上述分类的复杂度 | 自定义复杂度评估 |

---

## 第5章：攻击面风险 (Attack Surface Risk)

攻击面风险 = 成功利用攻击面后可能造成的危害。

### 5.1 机密性风险 (Confidentiality)

| 风险KEY | 风险名称 | 风险描述 |
|--------|---------|---------|
| `R-CONF-DATA-LEAK` | 数据泄露 | 敏感数据被未授权访问/提取 |
| `R-CONF-CRED-EXPOSE` | 凭据暴露 | 密码/密钥/Token被获取 |
| `R-CONF-SOURCE-LEAK` | 源码泄露 | 应用源代码被获取 |
| `R-CONF-CONFIG-LEAK` | 配置泄露 | 系统配置信息被获取 |
| `R-CONF-LOG-LEAK` | 日志泄露 | 日志中的敏感信息被获取 |
| `R-CONF-USER-PII` | 用户隐私泄露 | 个人身份信息被获取 |
| `R-CONF-KEY-MATERIAL` | 密钥材料泄露 | 加密密钥/证书私钥被获取 |
| `R-CONF-TRAFFIC-SNIFF` | 流量窃听 | 通信内容被中间人截获 |
| `R-CONF-OTHER` | 其它机密性风险 | 不在上述分类的机密性风险 | 自定义机密性风险类型 |

### 5.2 完整性风险 (Integrity)

| 风险KEY | 风险名称 | 风险描述 |
|--------|---------|---------|
| `R-INT-DATA-TAMPER` | 数据篡改 | 数据被未授权修改 |
| `R-INT-PRICE-MANIPULATE` | 价格篡改 | 交易金额/价格被修改 |
| `R-INT-CONFIG-TAMPER` | 配置篡改 | 系统配置被修改 |
| `R-INT-CODE-INJECT` | 代码注入 | 恶意代码被植入系统 |
| `R-INT-LOG-TAMPER` | 日志篡改 | 审计日志被修改/删除 |
| `R-INT-FILE-OVERWRITE` | 文件覆盖 | 关键文件被覆盖 |
| `R-INT-STATE-HIJACK` | 状态劫持 | 业务状态被非法转换 |
| `R-INT-IDENTITY-FORGE` | 身份伪造 | 攻击者冒充合法用户 |
| `R-INT-OTHER` | 其它完整性风险 | 不在上述分类的完整性风险 | 自定义完整性风险类型 |

### 5.3 可用性风险 (Availability)

| 风险KEY | 风险名称 | 风险描述 |
|--------|---------|---------|
| `R-AVAIL-SERVICE-DOWN` | 服务中断 | 系统服务不可用 |
| `R-AVAIL-DOS` | 拒绝服务 | 服务被恶意请求淹没 |
| `R-AVAIL-RCE` | 远程代码执行 | 攻击者获得系统控制权 |
| `R-AVAIL-OOM` | 内存耗尽 | 系统内存被耗尽 |
| `R-AVAIL-DISK-FULL` | 磁盘耗尽 | 磁盘空间被占满 |
| `R-AVAIL-FILE-DELETE` | 文件删除 | 关键文件被删除 |
| `R-AVAIL-CRASH` | 进程崩溃 | 应用进程崩溃 |
| `R-AVAIL-CONTAINER-ESCAPE` | 容器逃逸 | 攻击者逃逸到宿主机 |
| `R-AVAIL-OTHER` | 其它可用性风险 | 不在上述分类的可用性风险 | 自定义可用性风险类型 |

### 5.4 合规性风险 (Compliance)

| 风险KEY | 风险名称 | 风险描述 |
|--------|---------|---------|
| `R-COMP-PRIVACY` | 隐私合规违规 | 违反数据保护法规(GDPR/PIPL) |
| `R-COMP-AUDIT-TRAIL` | 审计缺失 | 关键操作无审计记录 |
| `R-COMP-ENCRYPTION` | 加密合规违规 | 不符合加密标准 |
| `R-COMP-ACCESS-CONTROL` | 访问控制违规 | 不符合最小权限原则 |
| `R-COMP-OTHER` | 其它合规性风险 | 不在上述分类的合规性风险 | 自定义合规性风险类型 |

### 5.5 业务风险 (Business)

| 风险KEY | 风险名称 | 风险描述 |
|--------|---------|---------|
| `R-BIZ-FINANCIAL-LOSS` | 直接经济损失 | 资金被盗/交易被篡改 |
| `R-BIZ-REPUTATION` | 声誉损害 | 安全事件导致品牌受损 |
| `R-BIZ-LEGAL` | 法律风险 | 因安全违规面临法律诉讼 |
| `R-BIZ-OPERATIONAL` | 运营中断 | 业务流程被破坏 |
| `R-BIZ-ESCALATION` | 攻击面扩大 | 单点突破导致横向扩散 |
| `R-BIZ-OTHER` | 其它业务风险 | 不在上述分类的业务风险 | 自定义业务风险类型 |

### 5.6 风险类别枚举

| 类别ID | 类别名 | 说明 |
|--------|--------|------|
| `vulnerability` | 漏洞风险 | 代码缺陷导致的安全漏洞 |
| `misconfiguration` | 配置风险 | 安全配置不当 |
| `design_flaw` | 设计缺陷 | 架构/设计层面的安全缺陷 |
| `compliance_gap` | 合规缺失 | 不符合安全规范/标准 |
| `dependency_risk` | 依赖风险 | 第三方组件引入的风险 |
| `other` | 其它风险类别 | 不在上述分类的风险类别 | 自定义风险类别 |

---

## 第6章：风险等级 (Risk Level)

### 6.1 风险等级定义

| 等级 | 分值 | 定义 | 判定标准 |
|------|------|------|---------|
| `critical` | 9.0-10.0 | 系统性灾难风险 | 远程无需认证+RCE/核心数据泄露/服务完全瘫痪 |
| `high` | 7.0-8.9 | 严重风险 | 需低权限认证+敏感数据泄露/权限提升/业务逻辑绕过 |
| `medium` | 4.0-6.9 | 中等风险 | 需特定条件+有限数据泄露/服务部分影响 |
| `low` | 0.1-3.9 | 低风险 | 需高权限/复杂条件+影响有限/信息泄露 |
| `info` | 0 | 观测项 | 当前无直接利用路径但值得关注 |

### 6.2 判定矩阵

```
影响 \ 可利用性    无需认证    低权限认证    高权限认证    需复杂条件
─────────────────────────────────────────────────────────────
RCE/全量泄露        critical    critical     high         high
权限提升/敏感泄露    critical    high         medium       medium
部分数据泄露        high        medium       medium       low
服务部分影响        medium      medium       low          low
信息泄露           medium      low          low          info
```

### 6.3 风险等级提升条件

满足以下任一条件，等级提升一级：

| 提升条件 | 说明 |
|---------|------|
| 互联网直接可达 | 攻击面暴露在公网 |
| 无需认证即可利用 | 攻击向量无需任何凭据 |
| 核心资产关联 | 可触达confidential/top_secret级资产 |
| 控制缺失 | 对应安全控制为missing/bypassed |
| 已有在野利用 | CVE已有公开利用代码 |
| 横向扩散可能 | 突破后可进一步渗透 |

### 6.4 风险等级降低条件

满足以下任一条件，等级降低一级：

| 降低条件 | 说明 |
|---------|------|
| 仅内网可达 | 攻击面不暴露公网 |
| 需要多因素认证 | MFA/客户端证书等 |
| 存在有效缓解控制 | 对应控制为strong |
| 利用条件苛刻 | 需要特定版本/配置/时序 |
| 影响范围有限 | 仅影响非敏感数据/非核心功能 |

---

## 第7章：信任边界

信任边界 = 系统组件间的安全控制边界，用于评估攻击者跨边界的能力。

### 7.1 边界类型枚举

| 边界类型 | 边界KEY前缀 | 说明 | 示例 |
|---------|------------|------|------|
| 加密边界 | `BOUND-ENC-*` | 通信加密强度 | TLS/mTLS/明文 |
| 数据边界 | `BOUND-DATA-*` | 应用到数据存储的连接 | 应用→数据库/应用→缓存 |
| 服务边界 | `BOUND-SVC-*` | 服务间信任关系 | 服务A→服务B/服务→第三方API |

### 7.2 加密边界枚举

| 边界KEY | 边界名称 | 代码识别特征 |
|---------|---------|-------------|
| `BOUND-ENC-PLAINTEXT` | 明文传输 | http:// (非https)、禁用SSL验证 |
| `BOUND-ENC-TLS` | TLS加密 | https://、SSL/TLS配置 |
| `BOUND-ENC-MTLS` | 双向TLS | 客户端证书验证、mTLS配置 |
| `BOUND-ENC-E2E` | 端到端加密 | 应用层加密(如AES)、数据入库前加密 |
| `BOUND-ENC-MISSING` | 加密缺失 | 应加密但未加密的敏感数据传输 |
| `BOUND-ENC-OTHER` | 其它加密边界 | 不在上述分类的加密边界 | 自定义加密边界类型 |

### 7.3 数据边界枚举

| 边界KEY | 边界名称 | 代码识别特征 |
|---------|---------|-------------|
| `BOUND-DATA-DB-PLAINTEXT` | 数据库明文连接 | jdbc:mysql:// (非SSL)、无加密配置 |
| `BOUND-DATA-DB-TLS` | 数据库TLS连接 | jdbc:mysql://?useSSL=true |
| `BOUND-DATA-CACHE-PLAINTEXT` | 缓存明文连接 | Redis无密码/无TLS |
| `BOUND-DATA-CACHE-AUTH` | 缓存认证连接 | Redis密码配置 |
| `BOUND-DATA-MQ-PLAINTEXT` | 消息队列明文 | Kafka无SASL/无TLS |
| `BOUND-DATA-MQ-AUTH` | 消息队列认证 | Kafka SASL_PLAINTEXT/SASL_SSL |
| `BOUND-DATA-OTHER` | 其它数据边界 | 不在上述分类的数据边界 | 自定义数据边界类型 |

### 7.4 服务边界枚举

| 边界KEY | 边界名称 | 代码识别特征 |
|---------|---------|-------------|
| `BOUND-SVC-INTERNAL-TRUST` | 内部服务信任传递 | 服务间调用无认证、内部API免签 |
| `BOUND-SVC-INTERNAL-AUTH` | 内部服务认证调用 | 服务间JWT/API Key校验 |
| `BOUND-SVC-EXTERNAL-NO-CHECK` | 外部API无校验 | 调用第三方API无签名/无校验 |
| `BOUND-SVC-EXTERNAL-SIGNED` | 外部API签名调用 | HMAC签名、API Key校验 |
| `BOUND-SVC-OTHER` | 其它服务边界 | 不在上述分类的服务边界 | 自定义服务边界类型 |

### 7.5 边界强度枚举

| strength | 含义 | 对风险等级影响 |
|----------|------|---------------|
| `strong` | 强边界 | 降低一级 |
| `medium` | 中等边界 | 无影响 |
| `weak` | 弱边界 | 提升一级 |
| `missing` | 边界缺失 | 提升一级 + 优先标注 |
| `other` | 其它边界强度 | 不在上述分类的边界强度 | 自定义边界强度评估 |

### 7.6 边界识别优先级

按风险影响排序：

| 优先级 | 边界类型 | 优先原因 |
|--------|---------|---------|
| P0 | 加密边界 | 明文传输敏感数据 = 直接泄露风险 |
| P1 | 数据边界 | 数据库明文连接 = 内网嗅探风险 |
| P2 | 服务边界 | 服务间无认证 = 内部横向渗透风险 |

