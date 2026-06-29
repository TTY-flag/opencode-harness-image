# OpenCode Harness Image

这个工程构建一个基于 `smanx/opencode` 的通用基础镜像。镜像本身不内置具体扫描任务；运行时通过挂载不同的 `workdirs/<task>` 来决定行为。

## 构建

```bash
docker build -t opencode-harness-image:base .
```

## 运行模型

每个任务目录都有自己的 `entrypoint.sh` 和 `.opencode`。运行编排逻辑直接写在各自的
`entrypoint.sh` 里，后续不同 harness 可以独立修改结束条件和流程：

```text
workdirs/crop
workdirs/multi_langage
workdirs/threat_analysis
```

运行时需要同时挂载：

```text
workdirs/<task>/entrypoint.sh -> /entrypoint.sh
workdirs/<task>               -> /scan/opencode
待扫描项目                    -> /scan/project
输出目录                      -> /scan/output
```

`/entrypoint.sh` 会覆盖基础镜像原本的入口。任务入口需要启动 Web 时，直接调用
`opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT"`。

## 模式

- `HARNESS_MODE=harness`：默认，加载任务 `.opencode`，启动 Web，并执行 `opencode run`。
- `HARNESS_MODE=web`：只加载 `.opencode` 和 auth，然后暴露 OpenCode Web。
- `HARNESS_MODE=serve`：加载配置后执行 `opencode serve`。
- `HARNESS_MODE=shell`：加载配置后进入 shell，便于调试。

## 初始提示词

harness 模式下必须在 `docker run` 时配置初始提示词。任务入口不会内置默认 prompt，只会在启动 `opencode run` 前把外部配置解析并写入 `OPENCODE_INITIAL_PROMPT`：

1. `HARNESS_PROMPT_FILE`：从文件读取，优先级最高。
2. `OPENCODE_INITIAL_PROMPT`：推荐的直接配置方式。
3. `HARNESS_PROMPT`：兼容旧变量。

每个任务目录的 `run.txt` 提供对应的 `docker run` 模板。
