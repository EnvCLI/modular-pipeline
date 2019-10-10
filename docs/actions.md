# Actions

## Global Properties

| Environment | Default | Description |
| ------------- | ------------- | ------------- |
| ARTIFACT_DIR | dist | The scripts will put all generated artifacts into this directory. |
| ARTIFACT_BUILD_ARCHS | linux_amd64 | build archs - valid values are: [linux_386,linux_amd64,linux_armv7,linux_armv8,windows_386,windows_amd64,darwin_386,darwin_amd64] |
| TMP_DIR | tmp | The scripts will put all temporary files into this directory. |
| CONTAINER_REPO | $NCI_CONTAINERREGISTRY_REPOSITORY | |
| CONTAINER_TAG | $NCI_COMMIT_REF_RELEASE | |
| HTTP_PROXY |  | |
| HTTPS_PROXY |  | |
| PROXY_HOST |  | |
| PROXY_PORT |  | |
| JAVA_PROXY_OPTS | generated | generated jvm arguments to set the above proxy server |

## Action List

| Category | Name | Description |
| ------------- | ------------- | ------------- |
| debug | [ci-debug](actions/action-ci-debug) | Will prepare the environment for pipeline execution, for example by downloading the needed docker images / etc. |
| golang | [go-run](actions/action-go-run) | |
| golang | [go-test](actions/action-go-test) | |
| golang | [go-build](actions/action-go-build) | |
| java | [java-test](actions/action-java-test) | |
| java | [java-build](actions/action-java-build) | |
| python | [python-run](actions/action-python-run) | |
| python | [python-build](actions/action-python-build) | |
| html | [html-test](actions/action-html-test) | |
| optimize | [optimize-upx](actions/action-optimize-upx) | |
| bintray | [bintray-publish](actions/action-bintray-publish) | |
| helm | [helm-deploy](actions/action-helm-deploy) | |
| swarm | [swarm-deploy](actions/action-swarm-deploy) | |
