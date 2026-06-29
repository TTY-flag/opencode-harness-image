# Workdir Bundles

这些目录是运行时挂载的任务 bundle。镜像保持同一个：

```text
opencode-harness-image:base
```

运行时把对应任务入口挂到 `/entrypoint.sh`，并把整个任务目录挂到 `/scan/opencode`：

```text
-v "$PWD/workdirs/crop/entrypoint.sh:/entrypoint.sh:ro"
-v "$PWD/workdirs/crop:/scan/opencode:ro"
```

当前 bundle：

- `crop`
- `multi_langage`
- `single_skill`

每个 bundle 内的 `run.txt` 是可直接改路径使用的命令模板。harness 模式下，任务入口会把初始提示词导出为 `OPENCODE_INITIAL_PROMPT` 后再启动 `opencode run`；需要覆盖时优先设置 `OPENCODE_INITIAL_PROMPT`，也可以继续使用兼容变量 `HARNESS_PROMPT` 或 `HARNESS_PROMPT_FILE`。
