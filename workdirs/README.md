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

每个 bundle 内的 `run.txt` 是可直接改路径使用的命令模板。
