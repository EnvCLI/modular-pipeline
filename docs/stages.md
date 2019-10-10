# Stages

Stages are a collection of scripts to allow building projects with a set of predefined actions based on a few configuration properties.

The following stages are available:

- prepare
- build
- test
- package
- audit
- publish
- deploy
- performance
- cleanup

## Configuration Properties

| Environment | Default | Affected Stages | Description |
| ------------- | ------------- | ------------- | ------------- |
| PROJECT_TYPE | none | build, test | The PROJECT_TYPE decides how a project is build and tested. |
| PACKAGE_TYPE | none | package | The PACKAGE_TYPE decides how a project should be packaged. |
| PUBLISH_TYPE | none | publish | The PUBLISH_TYPE decides how a project is packaged and published. |
| DEPLOYMENT_TYPE | none | deploy | The DEPLOYMENT_TYPE decides how a project is deployed. |
| DEPLOYMENT_VARIANT | none | deploy | The DEPLOYMENT_VARIANT defines the kind of service that gets deployed (cron, webservice, ...) |
| DEPLOYMENT_STRATEGY | none | deploy | The DEPLOYMENT_STRATEGY defines if deployments happen automatically or manually |

Please take note that `none` is a valid value and can be used to skip those stages, ie. if you only want to make a deployment of a image from dockerhub.

## PROJECT_TYPE

| Value | Description |
| ------------- | ------------- |
| container | Container projects generally get build by their dockerfile. |
| shell | Pure ShellScript Project. |
| java | Java-based projects (maven/gradle) |
| python | Python 3 projects |
| golang | Golang projects |
| hugo | A hugo project |

## PACKAGE_TYPE

| Value | Description |
| ------------- | ------------- |
| container | Build a container image for the project. |

## PUBLISH_TYPE

| Value | Description |
| ------------- | ------------- |
| containerregistry | Publish a container to a registry. |
| nexus | Publish binary files / archives to nexus 3. |
| bintray | Publish binary files / archives to bintray. |
| githubrelease | Publish binary files / archives to github releases. |

## DEPLOYMENT_TYPE

| Value | Description |
| ------------- | ------------- |
| swarm | Use a docker swarm stack to deploy the workload. |
| helm | Use helm charts to deploy a kubernetes workload. |
| ansible | Use ansible to deploy the workload. |

## DEPLOYMENT_VARIANT

| Value | Description |
| ------------- | ------------- |
| http | A http/https-based service |
| job | A cronjob that is scheduled for execution |
| worker | A worker without any endpoints that processes tasks |

## DEPLOYMENT_STRATEGY

| Value | Description |
| ------------- | ------------- |
| manual-master | Manual deployments from master branch |
