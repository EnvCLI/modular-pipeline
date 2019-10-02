# Stages

## All Stages

| Stage | Description |
| ------------- | ------------- |
| [prepare](stages/stage-prepare) | Will prepare the environment for pipeline execution, for example by downloading the needed docker images / etc. |
| [build](stages/stage-build) | |
| [test](stages/stage-test) | |
| [package](stages/stage-package) | |
| [audit](stages/stage-audit) | |
| [publish](stages/stage-publish) | |
| [deploy](stages/stage-deploy) | |
| [performance](stages/stage-performance) | |
| [cleanup](stages/stage-cleanup) | |

## Configuration

You can set the properties required by the stages in `.ci/env` to make them available locally and on ci execution.

```bash
PROJECT_TYPE=java-service
DEPLOYMENT_TYPE=none
```

## Project Types

Project types follow the spec `name-type`.

Names:

- golang
- java
- container

Types:
- cli
- service
- library

## Deployment Types

- swarm
- helm
- bintray
