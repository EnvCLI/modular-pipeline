# GitHub Workflow Files

Place the workflow files into `.github/workflow` to use them.

## Useful resources for modifications

This should help you modify workflow files by providing a few useful links to the documentation:

- [Overview](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-workflows)
- [YAML Syntax](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions)
- [Expresssion Syntax](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/contexts-and-expression-syntax-for-github-actions)
- [Operators](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/contexts-and-expression-syntax-for-github-actions#operators)

## Notes

### Global variables

It's possible to set variables for all subsequent steps by running:

```bash
echo ::set-env name=PROJECT_TYPE::$PROJECT_TYPE
```

### Docker-in-Docker

We can't use containers right now, as its not possible to run multiple commands using run in a container.
We need to use docker-in-docker as the paths inside the container will be different than on the host vm, so that the mounts actually work.

```yaml
# container - pipeline
container:
  image: docker.io/envcli/modular-pipeline:latest
  env:
    DOCKER_HOST: "tcp://dind:2375"
    # SCRIPT_LOG_LEVEL: "TRACE"
  volumes:
    - cache:/cache
services:
  dind:
    image: docker.io/docker:19.03.5-dind
    env:
      DOCKER_TLS_CERTDIR: ""
    ports:
      - 2375:2375
    options: "--privileged -v /home/runner/work:/__w"
```
