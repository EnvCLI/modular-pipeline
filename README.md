# Modular CI Pipeline

## description

Contains the following components:

| Component | Description |
| ------------- | ------------- | ------------- |
| [stages](docs/stage.md) | Stages split the actions into multiple sections and execute them on demand, based on provided environment variables |
| [actions](docs/actions.md) | Actions are specified steps that are run in a pipeline, for example java-build, java-test, etc. |

## usage

### host

```bash
curl https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/install.sh | sudo bash
```

### docker

- [DockerHub](https://hub.docker.com/r/envcli/modular-pipeline)
- Image: envcli/modular-pipeline

## stages

| Stage | Description |
| ------------- | ------------- | ------------- |
| [prepare](docs/stage/prepare.md) | Will prepare the environment for pipeline execution, for example by downloading the needed docker images / etc. |
| [build](docs/stage/prepare.md) | |
| [test](docs/stage/prepare.md) | |
| [package](docs/stage/prepare.md) | |
| [audit](docs/stage/audit.md) | |
| [deploy](docs/stage/prepare.md) | |
| [review](docs/stage/prepare.md) | |
| [staging](docs/stage/prepare.md) | |
| [canary](docs/stage/prepare.md) | |
| [production](docs/stage/prepare.md) | |
| [incremental](docs/stage/prepare.md) | |
| [performance](docs/stage/prepare.md) | |
| [cleanup](docs/stage/prepare.md) | |

## actions

| Category | Name | Description |
| ------------- | ------------- | ------------- |
| debug | [ci-debug](actions/ci-debug) | Will prepare the environment for pipeline execution, for example by downloading the needed docker images / etc. |
| golang | [go-test](actions/go-test) | |
| golang | [go-build](actions/go-build) | |
| java | [java-test](actions/java-test) | |
| java | [java-build](actions/java-build) | |
| optimize | [optimize-upx](actions/optimize-upx) | |

## License
