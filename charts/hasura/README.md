# hasura

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adminSecret | string | `"admin"` | Administrator secret. It is recommended to change this to something complex. |
| devMode | string | `"true"` | Development mode toggle. Set to `"false"` for production |
| enableConsole | string | `"true"` | Whether to enable the Hasura console. Set to `"false"` for production |
| image.pullPolicy | string | `"IfNotPresent"` | Pull Policy for deployment |
| image.repository | string | `"hasura/graphql-engine"` | Which Docker image to pull |
| image.tag | string | `"v1.3.2"` | Which image tag to use |
| ingress.annotations | object | `{"ingress.kubernetes.io/ssl-redirect":"false"}` | Annotations for the Ingress |
| ingress.host | string | `"chart-example.local"` | Hostname to expose for the Ingress |
| postgres.database | string | `"hasura"` | Name of database for Postgres |
| replicaCount | int | `1` | Number of instances to deploy |
| service.port | int | `8080` | Port that the server listens on |
| service.type | string | `"ClusterIP"` | Which service type to use |
