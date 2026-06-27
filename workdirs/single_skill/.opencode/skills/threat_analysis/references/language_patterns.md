# 代码识别规则参考

本文档提供不同编程语言/框架中安全相关代码特征的识别规则，供分析过程中按需查阅。

---

## 第1章：路由识别规则

### 1.1 Java路由识别

| 框架 | 识别特征 | 示例 |
|------|---------|------|
| **Spring MVC** | `@RequestMapping`/`@GetMapping`/`@PostMapping`/`@RestController` | `@GetMapping("/api/users")` |
| **Spring Boot** | 同Spring MVC + `application.yml`路由配置 | `spring.mvc.servlet.path` |
| **Jersey/JAX-RS** | `@Path`/`@GET`/`@POST`/`@Produces` | `@Path("/users")` |
| **Struts** | `struts.xml`/`@Action` | `<action name="login">` |
| **Servlet** | `web.xml`/`@WebServlet` | `<servlet-mapping>` |

**grep关键词**：
```
@RequestMapping|@GetMapping|@PostMapping|@PutMapping|@DeleteMapping|@PatchMapping
@Path|@GET|@POST|@Produces|@Consumes
@RestController|@Controller
@WebServlet|servlet-mapping
```

### 1.2 Python路由识别

| 框架 | 识别特征 | 示例 |
|------|---------|------|
| **Flask** | `@app.route`/`@blueprint.route` | `@app.route('/api/users')` |
| **Django** | `urls.py`/`path()`/`re_path()` | `path('users/', views.users)` |
| **FastAPI** | `@app.get`/`@app.post`/`@router.get` | `@app.get("/users")` |
| **Tornado** | `Application`路由列表/`(r"/api", Handler)` | `handlers = [(r"/api", Handler)]` |
| **Starlette** | `@app.route`/`Route` | `Route('/users', endpoint)` |

**grep关键词**：
```
@app\.route|@blueprint\.route|@router\.|path\(|re_path\(
@app\.get|@app\.post|@app\.put|@app\.delete
Route\(|handlers\s*=|Application\(
```

### 1.3 Go路由识别

| 框架 | 识别特征 | 示例 |
|------|---------|------|
| **Gin** | `router.GET`/`router.POST`/`r.Handle` | `router.GET("/users", handler)` |
| **Echo** | `e.GET`/`e.POST`/`e.Route` | `e.GET("/users", handler)` |
| **HttpRouter** | `router.Handle` | `router.Handle("GET", "/users", handler)` |
| **Chi** | `r.Get`/`r.Post`/`r.Route` | `r.Get("/users", handler)` |
| **标准net/http** | `http.HandleFunc`/`http.Handle` | `http.HandleFunc("/api", handler)` |

**grep关键词**：
```
router\.GET|router\.POST|router\.PUT|router\.DELETE
e\.GET|e\.POST|\.HandleFunc|http\.Handle
r\.Get|r\.Post|r\.Route|Route\(
```

### 1.4 Node.js路由识别

| 框架 | 识别特征 | 示例 |
|------|---------|------|
| **Express** | `app.get`/`app.post`/`router.get` | `app.get('/api/users', handler)` |
| **Koa** | `router.get`/`app.use` | `router.get('/users', handler)` |
| **Fastify** | `fastify.get`/`fastify.route` | `fastify.get('/users', handler)` |
| **NestJS** | `@Controller`/`@Get`/`@Post` | `@Controller('users') @Get()` |
| **Hapi** | `server.route` | `server.route({ method: 'GET', path: '/users' })` |

**grep关键词**：
```
app\.get|app\.post|app\.put|app\.delete|router\.get|router\.post
@Controller|@Get|@Post|@Put|@Delete
server\.route|fastify\.get|fastify\.route
```

### 1.5 PHP路由识别

| 框架 | 识别特征 | 示例 |
|------|---------|------|
| **Laravel** | `Route::get`/`Route::post`/routes/*.php | `Route::get('/users', Controller::class)` |
| **Symfony** | `routes.yaml`/`@Route`注解 | `@Route("/users", name="users")` |
| **CodeIgniter** | `config/routes.php`/`$route['users']` | `$route['users'] = 'UserController'` |
| **Yii** | `UrlManager`配置 | `'urlManager' => ['rules' => [...]` |

**grep关键词**：
```
Route::|@Route|routes\.yaml|routes\.php
\$route\[|urlManager|rules
```

### 1.6 C#/.NET路由识别

| 框架 | 识别特征 | 示例 |
|------|---------|------|
| **ASP.NET Core** | `[HttpGet]`/`[Route]`/`MapControllers` | `[HttpGet("api/users")]` |
| **ASP.NET MVC** | `RouteConfig.cs`/`[Route]` | `routes.MapRoute(name, url)` |

**grep关键词**：
```
\[HttpGet\]|\[HttpPost\]|\[Route\]|MapRoute|MapControllers
```

---

## 第2章：认证控制识别规则

### 2.1 Java认证识别

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Spring Security** | `@PreAuthorize`/`@Secured`/`SecurityConfig` | `@PreAuthorize("hasRole('ADMIN')")` |
| **JWT** | `JwtTokenUtil`/`JwtAuthenticationFilter`/`JWT`相关类 | `jwtTokenUtil.generateToken()` |
| **OAuth** | `OAuth2AuthenticationProcessingFilter`/`@EnableOAuth2` | `OAuth2AuthorizationServerConfig` |
| **Session** | `HttpSession`/`session.getAttribute` | `session.setAttribute("user", user)` |
| **Basic Auth** | `BasicAuthenticationFilter` | `.httpBasic()` |

**grep关键词**：
```
@PreAuthorize|@Secured|@RolesAllowed|SecurityConfig|WebSecurityConfigurerAdapter
JwtTokenUtil|JwtAuthenticationFilter|JWT|TokenProvider
OAuth2|@EnableOAuth2|AuthorizationServer|ResourceServer
HttpSession|session\.|setAttribute|getAttribute
httpBasic|BasicAuthentication
```

### 2.2 Python认证识别

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Flask-Login** | `@login_required`/`current_user`/`LoginManager` | `@login_required` |
| **JWT** | `@jwt_required`/`create_access_token`/Flask-JWT-Extended | `@jwt_required()` |
| **Django Auth** | `@login_required`/`AuthenticationForm`/`LoginView` | `@login_required` |
| **FastAPI OAuth** | `OAuth2PasswordBearer`/`get_current_user` | `oauth2_scheme = OAuth2PasswordBearer()` |
| **Session** | `session`对象/Flask `session` | `session['user_id']` |

**grep关键词**：
```
@login_required|current_user|LoginManager|user_loader
@jwt_required|create_access_token|jwt_required|JWT
OAuth2PasswordBearer|get_current_user|HTTPBearer
session\[|flask\.session|django\.contrib\.auth
```

### 2.3 Go认证识别

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **JWT** | `jwt-go`/`ParseToken`/`GenerateToken` | `token, err := jwt.Parse(tokenString)` |
| **Middleware** | `AuthMiddleware`/`func AuthRequired` | `r.Use(AuthMiddleware)` |
| **Session** | `gorilla/sessions`/`session.Values` | `session.Values["user_id"]` |
| **Basic Auth** | `BasicAuth`中间件 | `r.Use(BasicAuth)` |

**grep关键词**：
```
jwt\.Parse|jwt\.NewWithClaims|Token|Claims
AuthMiddleware|AuthRequired|\.Use\(Auth
session\.Values|gorilla/sessions|store\.Get
BasicAuth|BasicAuthForRealm
```

### 2.4 Node.js认证识别

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Express中间件** | `authMiddleware`/`isAuthenticated`/`passport` | `app.use(authMiddleware)` |
| **JWT** | `jsonwebtoken`/`jwt.verify`/`jwt.sign` | `jwt.verify(token, secret)` |
| **Passport** | `passport.authenticate`/`passport.use` | `passport.authenticate('jwt')` |
| **Session** | `express-session`/`session`/`req.session` | `req.session.user` |

**grep关键词**：
```
authMiddleware|isAuthenticated|verifyToken|checkAuth
jwt\.verify|jwt\.sign|jsonwebtoken|verifyToken
passport\.authenticate|passport\.use|passport-jwt
express-session|req\.session|session\.
```

---

## 第3章：授权控制识别规则

### 3.1 Java授权识别

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Spring Security** | `@PreAuthorize`/`hasRole`/`hasAuthority`/`@PostAuthorize` | `@PreAuthorize("hasRole('ADMIN')")` |
| **RBAC** | `RoleService`/`checkRole`/`hasPermission` | `if (user.getRole() == "ADMIN")` |
| **ACL** | `AclService`/`hasPermission`/`checkPermission` | `aclService.hasPermission(user, object)` |
| **IDOR防护** | `checkOwnership`/`getById(user.id)` | `if (resource.ownerId == user.id)` |

**grep关键词**：
```
@PreAuthorize|@PostAuthorize|hasRole|hasAuthority|hasPermission
checkRole|getRole|isAdmin|isSuperUser|RoleService
checkPermission|AclService|hasAccess|canAccess
checkOwnership|ownerId|belongsTo|belongsToUser
```

### 3.2 Python授权识别

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Django权限** | `@permission_required`/`user.has_perm`/`PermissionMixin` | `@permission_required('app.can_edit')` |
| **Flask权限** | `@roles_required`/`@permissions_required`/Flask-Principal | `@roles_required('admin')` |
| **自定义检查** | `if user.role ==`/`check_permission(user)` | `if current_user.role == 'admin'` |
| **IDOR防护** | `if obj.user_id == current_user.id` | `if post.author == current_user` |

**grep关键词**：
```
@permission_required|has_perm|PermissionMixin|permission_classes
@roles_required|@permissions_required|RoleRequired|PermissionRequired
user\.role|current_user\.role|check_permission|is_admin
\.user_id|\.author|\.owner|belongsTo|ownership
```

### 3.3 Go授权识别

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **中间件** | `func RoleRequired(role)`/`func PermissionCheck` | `r.Use(RoleRequired("admin"))` |
| **手动检查** | `if user.Role == "admin"` | `if user.Role != "admin" { return 403 }` |
| **IDOR防护** | `if resource.OwnerID == userID` | `if post.UserID != currentUser.ID` |

**grep关键词**：
```
RoleRequired|PermissionCheck|CheckPermission|RequireRole
\.Role\s*==|\.Role\s*!=|isAdmin|isSuperUser
\.OwnerID|\.UserID|\.AuthorID|belongsTo|ownership
```

---

## 第4章：输入校验识别规则

### 4.1 Java输入校验

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Bean Validation** | `@Valid`/`@NotNull`/`@Size`/`@Pattern`/`@Email` | `@Valid UserDTO user` |
| **手动校验** | `if (input == null)`/`StringUtils.isEmpty`/`Validator` | `if (username == null || username.isEmpty())` |
| **正则校验** | `Pattern.compile`/`matcher.matches` | `Pattern.matches("[a-z]+", input)` |

**grep关键词**：
```
@Valid|@NotNull|@NotEmpty|@NotBlank|@Size|@Pattern|@Email|@Min|@Max
StringUtils\.isEmpty|Objects\.isNull|\.isEmpty\(|\.isBlank\(
Pattern\.compile|matcher\.matches|regex|validate|Validator
```

### 4.2 Python输入校验

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Django Form** | `Form`/`ModelForm`/`clean_`/`validators` | `class UserForm(forms.Form)` |
| **Pydantic** | `BaseModel`/`Field`/`validator`/`@validate_arguments` | `class UserSchema(BaseModel)` |
| **Flask-WTF** | `WTForm`/`validators=[DataRequired]` | `username = StringField(validators=[DataRequired()])` |
| **手动校验** | `if not input`/`validate()`/`is_valid` | `if not username or len(username) < 3:` |

**grep关键词**：
```
class.*Form\(forms\.Form\)|class.*ModelForm|clean_|validators
BaseModel|Field\(|@validator|@validate_arguments|constr|conint
WTForm|validators=|DataRequired|Length|Regexp
if not |if .* is None|validate\(|is_valid|\.strip\(|\.lower\()
```

### 4.3 Go输入校验

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **validator库** | `go-playground/validator`/`validate.Struct` | `validate.Struct(user)` |
| **手动校验** | `if input == ""`/`len(input) < 3` | `if username == "" || len(username) < 3` |
| **正则校验** | `regexp.MatchString`/`regexp.Compile` | `regexp.MatchString("^[a-z]+$", input)` |

**grep关键词**：
```
validate\.Struct|validator\.New|binding\.Validate
if .* == ""|if len\(.*\) <|if .* == nil|\.Valid\(
regexp\.MatchString|regexp\.Compile|regex
```

### 4.4 Node.js输入校验

| 类型 | 识别特征 | 示例 |
|------|---------|------|
| **Joi** | `Joi.object`/`Joi.string`/`validateAsync` | `Joi.object({ username: Joi.string().required() })` |
| **Zod** | `z.object`/`z.string`/`.parse` | `z.object({ username: z.string() })` |
| **express-validator** | `body('field').isEmail`/`validationResult` | `body('email').isEmail()` |
| **手动校验** | `if (!input)`/`input === undefined`/`validate` | `if (!username || username.length < 3)` |

**grep关键词**：
```
Joi\.object|Joi\.string|Joi\.number|validateAsync|validate\(
z\.object|z\.string|z\.number|\.parse|\.safeParse
body\(|param\(|query\(|\.isEmail|\.isInt|\.notEmpty|validationResult
if \(!|if .* === undefined|if .* === null|validate\(|\.length
```

---

## 第5章：加密控制识别规则

### 5.1 加密函数识别

| 语言 | 安全加密函数 | 不安全函数 |
|------|-------------|-----------|
| **Java** | `AES/GCM/NoPadding`/`Cipher.getInstance("AES")` | `DES`/`ECB`/`MD5`/`SHA1` |
| **Python** | `AES.new(key, AES.MODE_GCM)`/`hashlib.sha256` | `hashlib.md5`/`DES`/`RC4` |
| **Go** | `crypto/aes`/`crypto/sha256` | `crypto/md5`/自定义弱加密 |
| **Node.js** | `crypto.createCipheriv('aes-256-gcm')` | `crypto.createHash('md5')`/`crypto.createCipher('des')` |

**grep关键词（安全）**：
```
AES|aes-256|GCM|CBC|HMAC|SHA256|SHA512|SHA-256|sha256
bcrypt|scrypt|argon2|PBKDF2
RSA|rsa|ECDSA|ed25519
TLS|tls\.|https|SSLContext
```

**grep关键词（不安全）**：
```
MD5|md5|SHA1|sha1|DES|des|RC4|rc4|ECB|ecb
hashlib\.md5|crypto\.createHash\('md5'\)|MessageDigest\.getInstance\("MD5"\)
Cipher\.getInstance\("DES"\)|crypto\.createCipher\('des'\)
```

### 5.2 证书校验识别

| 语言 | 安全配置 | 不安全配置 |
|------|---------|-----------|
| **Java** | `SSLContext.init`/`X509TrustManager` | `TrustManager`返回true/`.verify=False` |
| **Python** | `ssl.create_default_context`/`CERT_REQUIRED` | `ssl._create_unverified_context`/`verify=False` |
| **Go** | `tls.Config`/`InsecureSkipVerify=false` | `InsecureSkipVerify: true` |
| **Node.js** | `rejectUnauthorized: true` | `rejectUnauthorized: false` |

**grep关键词（不安全）**：
```
InsecureSkipVerify|verify\s*=\s*False|verify\s*=\s*false|rejectUnauthorized\s*=\s*false
TrustManager|checkServerTrusted|checkClientTrusted|\.verify\s*=\s*False
_create_unverified_context|CERT_NONE|ssl\.PROTOCOL_SSLv
```

### 5.3 硬编码密钥识别

**grep关键词**：
```
password\s*=\s*["'][^"']{8,}["']|secret\s*=\s*["'][^"']{8,}["']|key\s*=\s*["'][^"']{8,}["']|token\s*=\s*["'][^"']{8,}["']
api_key\s*=\s*["']|apikey\s*=\s*["']|api-key\s*=\s*["']|access_key\s*=\s*["']
private_key\s*=\s*["']|privatekey\s*=\s*["']|encryption_key\s*=\s*["']
Authorization\s*=\s*["']Bearer\s+["']|Bearer\s+[A-Za-z0-9\-_]{20,}
AWS_ACCESS_KEY|AWS_SECRET|aws_access_key_id|aws_secret_access_key
DATABASE_PASSWORD|DB_PASSWORD|MONGO_PASSWORD|REDIS_PASSWORD
```

---

## 第6章：SQL查询识别规则

### 6.1 安全SQL（参数化）

| 语言 | 安全特征 | 示例 |
|------|---------|------|
| **Java (MyBatis)** | `#{param}`/预编译占位符 | `SELECT * FROM users WHERE id = #{id}` |
| **Java (JPA/Hibernate)** | `:param`/`setParameter`/Criteria API | `WHERE id = :id` |
| **Java (JDBC)** | `PreparedStatement`/`setString` | `ps.setString(1, username)` |
| **Python (ORM)** | Django ORM/SQLAlchemy/参数化查询 | `User.objects.filter(id=id)` |
| **Go** | `?`占位符/`db.Query`参数化 | `db.Query("SELECT * WHERE id=?", id)` |
| **Node.js** | `$1`/`?`占位符/ORM | `db.query('SELECT * WHERE id=$1', [id])` |

### 6.2 不安全SQL（拼接）

| 语言 | 不安全特征 | 示例 |
|------|---------|------|
| **Java** | `${param}`/字符串拼接 | `WHERE id = ${id}`/`"WHERE id = " + id` |
| **Python** | `%s`/f-string/字符串拼接 | `f"WHERE id = {id}"`/`"WHERE id = " + id` |
| **Go** | 字符串拼接 | `"WHERE id = " + id` |
| **Node.js** | 字符串拼接 | `"WHERE id = " + id`/`\`WHERE id = ${id}\`` |

**grep关键词（不安全）**：
```
\$\{|\$\(|f".*{.*}".*sql|f'.*{.*}'.*sql
\.format\(.*sql|"WHERE.*"\s*\+|'WHERE.*'\s*\+|WHERE.*\s*\+\s*
SELECT.*\+|INSERT.*\+|UPDATE.*\+|DELETE.*\+
executeQuery\(.*\+|query\(.*\+|exec\(.*\+
```

---

## 第7章：命令执行识别规则

### 7.1 命令执行函数

| 语言 | 函数 | 危险等级 |
|------|------|---------|
| **Java** | `Runtime.exec()`/`ProcessBuilder` | 高危 |
| **Python** | `os.system()`/`os.popen()`/`subprocess.Popen(shell=True)` | 高危 |
| **Python** | `eval()`/`exec()`/`compile()` | 极高危 |
| **Go** | `exec.Command()`/`os/exec` | 高危 |
| **Node.js** | `child_process.exec()`/`execSync()`/`spawn(shell=true)` | 高危 |
| **PHP** | `system()`/`exec()`/`shell_exec()`/`passthru()`/`popen()` | 高危 |

**grep关键词**：
```
Runtime\.exec|ProcessBuilder|exec\(|execCommand
os\.system|os\.popen|subprocess\.Popen|subprocess\.call|shell\s*=\s*True
eval\(|exec\(|compile\(|__import__
exec\.Command|exec\.CommandContext|os/exec
child_process\.exec|execSync|spawn\(.*shell.*true|exec\(
system\(|exec\(|shell_exec|passthru|popen\(|proc_open
```

---

## 第8章：文件操作识别规则

### 8.1 文件上传识别

| 语言 | 函数/注解 | 示例 |
|------|---------|------|
| **Java** | `MultipartFile`/`@RequestPart`/`FileUpload` | `@PostMapping MultipartFile file` |
| **Python** | `request.files`/`FileStorage`/`save()` | `request.files['file'].save(path)` |
| **Go** | `multipart.File`/`FormFile`/`Receive()` | `file, handler, _ := r.FormFile("file")` |
| **Node.js** | `multer`/` formidable`/`fs.writeFile` | `upload.single('file')`/`req.file` |

**grep关键词**：
```
MultipartFile|@RequestPart|FileUpload|uploadFile
request\.files|FileStorage|\.save\(|save_to|upload_to
FormFile|multipart\.File|Receive|ReceiveFile|SaveUploadedFile
multer|formidable|req\.file|req\.files|fs\.writeFile
```

### 8.2 文件路径拼接识别

| 语言 | 不安全特征 | 示例 |
|------|---------|------|
| **所有语言** | 用户输入直接拼接到文件路径 | `path + filename`/`dir + "/" + user_input` |

**grep关键词（不安全）**：
```
\.path\s*\+|\.dir\s*\+|\.filename\s*\+|\.file\s*\+
request\..*\s*\+.*path|input.*\s*\+.*path|param.*\s*\+.*path
getPath\s*\+|getFileName\s*\+|\.join\(.*input|\.join\(.*request
f".*{.*path}"|f'.*{.*path}'|\$\{.*path\}
```

---

## 第9章：敏感数据识别规则

### 9.1 PII字段识别

| 字段类型 | 识别特征 |
|---------|---------|
| **手机号** | `phone`/`mobile`/`tel`/`cellphone`/`phoneNumber`/`手机` |
| **身份证** | `idcard`/`identity`/`id_number`/`身份证`/`ssn`/`SSN` |
| **邮箱** | `email`/`mail`/`邮箱` |
| **姓名** | `name`/`username`/`realname`/`姓名`/`姓名` |
| **地址** | `address`/`addr`/`地址`/`street`/`location` |
| **银行卡** | `card_number`/`cardno`/`bankcard`/`银行卡` |
| **密码** | `password`/`pwd`/`passwd`/`密码`/`pass` |

**grep关键词**：
```
phone|mobile|tel|cellphone|phoneNumber|手机号
idcard|identity|id_number|身份证|ssn|SSN|identity_card
email|mail|邮箱|EmailAddress
password|pwd|passwd|密码|pass|secret
card_number|cardno|bankcard|银行卡|credit_card
address|addr|地址|street|location
realname|姓名|given_name|family_name
```

### 9.2 日志敏感信息识别

**grep关键词**：
```
log\.|logger\.|logging\.|print\(|printf\(|console\.log|console\.error
logger\.info\(.*password|log\.debug\(.*token|log\.error\(.*secret
System\.out\.print.*password|System\.err\.print.*secret
print\(.*password|printf\(.*token|console\.log\(.*key
```

---

## 第10章：依赖文件识别

| 语言 | 依赖文件 | 说明 |
|------|---------|------|
| **Java/Maven** | `pom.xml` | Maven项目配置 |
| **Java/Gradle** | `build.gradle`/`gradle.properties` | Gradle项目配置 |
| **Python** | `requirements.txt`/`setup.py`/`pyproject.toml` | Python依赖 |
| **Python** | `Pipfile`/`Pipfile.lock` | Pipenv依赖 |
| **Node.js** | `package.json`/`package-lock.json` | npm依赖 |
| **Node.js** | `yarn.lock` | yarn依赖 |
| **Go** | `go.mod`/`go.sum` | Go模块依赖 |
| **PHP** | `composer.json`/`composer.lock` | Composer依赖 |
| **Ruby** | `Gemfile`/`Gemfile.lock` | Ruby gem依赖 |
| **Rust** | `Cargo.toml`/`Cargo.lock` | Cargo依赖 |
| **C#** | `*.csproj`/`packages.config` | NuGet依赖 |

---

## 第11章：配置文件识别

| 语言/框架 | 配置文件 | 关键配置项 |
|----------|---------|-----------|
| **Java/Spring** | `application.yml`/`application.properties` | `server.port`/`spring.security`/数据库配置 |
| **Java/Spring Boot** | `application-{profile}.yml` | 环境特定配置 |
| **Python/Django** | `settings.py` | `SECRET_KEY`/`DATABASES`/`DEBUG` |
| **Python/Flask** | `config.py`/`.env` | `SECRET_KEY`/`DATABASE_URI` |
| **Go** | `config.yaml`/`.env` | 服务配置/密钥配置 |
| **Node.js** | `.env`/`config.json` | 环境变量/配置 |
| **PHP/Laravel** | `.env` | `APP_KEY`/`DB_PASSWORD` |
| **通用** | `.env`/`.env.local`/`.env.production` | 环境变量 |

---

## 第12章：部署配置识别

| 类型 | 文件 | 关键检查项 |
|------|------|-----------|
| **Docker** | `Dockerfile` | `USER`/`EXPOSE`/`ENV`/`RUN`特权命令 |
| **Docker Compose** | `docker-compose.yml` | `privileged`/`volumes`/`environment` |
| **Kubernetes** | `*.yaml`/`*.yml` | `privileged`/`hostNetwork`/`hostPath`/`runAsUser`/`allowPrivilegeEscalation` |
| **Terraform** | `*.tf` | 安全组/网络策略/IAM配置 |
| **CI/CD** | `.gitlab-ci.yml`/`.github/workflows/*.yml` | 密钥泄露/构建脚本/权限配置 |

**grep关键词（不安全）**：
```
privileged\s*:\s*true|hostNetwork\s*:\s*true|hostPID\s*:\s*true|hostIPC\s*:\s*true
hostPath:|volumeMounts:.*path.*:/|runAsUser\s*:\s*0
allowPrivilegeEscalation\s*:\s*true|capabilities:.*add.*:.*SYS_ADMIN|SYS_ADMIN|ALL
USER root|EXPOSE.*:|ENV.*PASSWORD|ENV.*SECRET|ENV.*KEY
\.ssh|\.bash_history|\.git|\.aws|credentials
```

---

## 第13章：调试端点识别

| 框架/类型 | 端点 | 识别特征 |
|----------|------|---------|
| **Spring Actuator** | `/actuator/*` | `management.endpoints.web.exposure.include` |
| **Swagger** | `/swagger-ui.html`/`/v2/api-docs` | `@EnableSwagger2`/`Docket` |
| **GraphQL Playground** | `/graphql` | `graphql-playground`/`graphiql` |
| **H2 Console** | `/h2-console` | `spring.h2.console.enabled=true` |
| **Druid** | `/druid/*` | `druid.servlet.enabled` |
| **Debug Mode** | - | `DEBUG=True`/`debug=true`/`@Profile("dev")` |

**grep关键词**：
```
actuator|swagger-ui|swagger|api-docs|graphql-playground|graphiql
h2-console|druid|debug\s*=\s*True|DEBUG\s*=\s*True|debug\s*=\s*true
@EnableSwagger2|@Profile\("dev"\)|spring\.profiles\.active\s*=\s*dev
management\.endpoints\.web\.exposure\.include\s*=\s*\*
exposure\.include\s*=\s*\*|expose-all
```