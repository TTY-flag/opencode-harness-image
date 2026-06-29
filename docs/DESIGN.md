# OpenCode Harness Image 设计

## 目标

构建一个基于 `smanx/opencode` 的通用基础镜像，用同一个镜像承载多个 OpenCode harness 任务。具体任务不 COPY 进镜像，而是在 `docker run` 时挂载。

当前任务：

- `crop`
- `multi_langage`
- `single_skill`

## 镜像职责

镜像只做两件事：

1. 继承 `smanx/opencode:latest`。
2. 创建固定容器目录：`/scan/project`、`/scan/output`、`/scan/opencode`、`/scan/auth`。

镜像默认入口仍是：

```Dockerfile
ENTRYPOINT ["bash", "/entrypoint.sh"]
```

运行任务时，用户把 `workdirs/<task>/entrypoint.sh` 挂载到容器的 `/entrypoint.sh`，从而覆盖镜像内默认入口文件。任务运行逻辑直接写在各自的 `entrypoint.sh` 里，不再依赖镜像内的通用 runtime helper。

## 挂载约定

| 容器路径 | 用途 |
| --- | --- |
| `/entrypoint.sh` | 当前任务入口脚本 |
| `/scan/opencode` | 当前任务 bundle，包含 `.opencode` |
| `/scan/project` | 待扫描项目 |
| `/scan/output` | 输出目录 |
| `/scan/auth` | 可选 auth 挂载目录 |

任务入口会把：

```text
/scan/opencode/.opencode -> /root/.config/opencode
```

并设置：

```text
OPENCODE_CONFIG_DIR=/root/.config/opencode
OPENCODE_CONFIG=/root/.config/opencode/opencode.jsonc
```

复制时跳过 `node_modules`，避免覆盖基础镜像或子镜像中已有依赖。

## 运行模式

`HARNESS_MODE=harness` 默认模式：

1. 加载 `.opencode` 到 `/root/.config/opencode`。
2. 生成或复制 `auth.json`。
3. 如 `HARNESS_WEB=true`，直接调用 `opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT"` 启动 OpenCode Web。
4. 将初始提示词解析并导出为 `OPENCODE_INITIAL_PROMPT`。
5. 执行 `opencode run --dir /scan/project ... "$OPENCODE_INITIAL_PROMPT"`。
6. 发现 session URL 并写入 `/scan/output/runtime/run-info.json`。

初始提示词优先级：

1. `HARNESS_PROMPT_FILE`
2. `OPENCODE_INITIAL_PROMPT`
3. `HARNESS_PROMPT`

任务入口不内置默认提示词。harness 模式没有配置初始提示词时会直接退出，具体默认 prompt 只放在各任务 `run.txt` 的 `docker run` 模板里。

`HARNESS_MODE=web`：

1. 加载 `.opencode` 和 auth。
2. 直接调用 `opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT"`，只暴露 OpenCode Web。

`HARNESS_MODE=serve`：

加载配置后执行 `opencode serve`。

`HARNESS_MODE=shell`：

加载配置后进入 shell。

## Auth

优先级：

1. 如果存在 `/scan/auth/auth.json`，复制到 `~/.local/share/opencode/auth.json`。
2. 否则如果设置了 `HARNESS_AUTH_PROVIDER` 和 `HARNESS_AUTH_KEY`，自动生成 auth 文件。
3. 否则不生成 auth，由 OpenCode 自行处理。

## Dockerfile 形态

```Dockerfile
FROM smanx/opencode:latest

USER root
RUN mkdir -p /scan/project /scan/output /scan/opencode /scan/auth

WORKDIR /scan
EXPOSE 4096
ENTRYPOINT ["bash", "/entrypoint.sh"]
```

## run.txt 约定

每个任务目录必须提供 `run.txt`，包含：

- API key/provider 环境变量
- Web 端口映射
- `/entrypoint.sh` 挂载
- `/scan/opencode` 挂载
- `/scan/project` 挂载
- `/scan/output` 挂载

默认模型当前统一为：

```text
alibaba-cn/glm-5
```
