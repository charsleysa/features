# Dev Container Features

## Contents

### `flyctl`

Running `flyctl version` inside the built container will print the current flyctl version.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/charsleysa/features/flyctl:1": {
            "version": "latest"
        }
    }
}
```

```bash
$ flyctl version

flyctl v0.2.45 linux/amd64 Commit: cf1ef68cacf7105b3d497e86c52d91e907e68a6d BuildDate: 2024-04-30T05:09:14Z
```

## Repo and Feature Structure

Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder.  Each Feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`. 

```
├── src
│   ├── flyctl
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
|   ├── ...
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
...
```

An [implementing tool](https://containers.dev/supporting#tools) will composite [the documented dev container properties](https://containers.dev/implementors/features/#devcontainer-feature-json-properties) from the feature's `devcontainer-feature.json` file, and execute in the `install.sh` entrypoint script in the container during build time.  Implementing tools are also free to process attributes under the `customizations` property as desired.
