# postgres

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| claimSize | string | `"8Gi"` | How much disk space to allocate for the Postgres claim |
| database | string | `"postgres"` | Name of Postgres database |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy to use |
| image.repository | string | `"docker.io/bitnami/postgresql"` | Image name to use for Postgres |
| image.tag | string | `"11.9.0-debian-10-r16"` | Image tag to use for Postgres |
| password | string | `"postgres"` | Postgres password |
| podSecurityContext.fsGroup | int | `1001` | Group to use for container (non-root) |
| replicaCount | int | `1` | Number of StatefulSet Pod instances |
| resources.requests | object | `{"cpu":"250m","memory":"256Mi"}` | Limit resource allocations for requests |
| service.port | int | `5432` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| updateStrategy | string | `"RollingUpdate"` | Strategy when updating the StatefulSet for running instances |
| username | string | `"postgres"` | Postgres username |
