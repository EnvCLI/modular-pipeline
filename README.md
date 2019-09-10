# Modular CI Pipeline

## description

Contains the following components:

| Component | Description |
| ------------- | ------------- |
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

A list of all supported stages can be found [HERE](stages/README.md)!

## actions

A list of all supported actions can be found [HERE](actions/README.md)!
