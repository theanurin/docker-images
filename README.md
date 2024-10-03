# Docker Images

Set of my images <https://hub.docker.com/u/theanurin>

## Repository

This is workspace branch of Docker Images multi project repository based on [orphan](https://git-scm.com/docs/git-checkout#Documentation/git-checkout.txt---orphanltnew-branchgt) branches.

| Branch                                                                | Description                                                                                                                                                                     |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [configuration-templates](../../tree/configuration-templates)         | Set of template processors that run against configuration properties.                                                                                                           |
| [devel.postgres](../../tree/devel.postgres)                           | PostgreSQL for development and testing purposes.                                                                                                                                |
| [fluentd](../../tree/luentd/)                                         | Fluentd is an open source data collector for unified logging layer.                                                                                                             |
| [gentoo-sources-bundle](../../tree/gentoo-sources-bundle)             | Gentoo stage3 based image with set of packages to make ability to compile kernel in few commands via Docker.                                                                    |
| [jekyll](../../tree/jekyll)                                           | Jekyll - Transform your plain text into static websites and blogs.                                                                                                              |
| [litecoin](../../tree/litecoin)                                       | Litecoin Full Node                                                                                                                                                              |
| [luksoid](../../tree/luksoid)                                         | A command line tool to help users to use LUKS-encrypted partition image without Linux host.                                                                                     |
| [mkdocs](../../tree/mkdocs)                                           | Fast, simple and downright gorgeous static site generator that's geared towards building project documentation.                                                                 |
| [openldap](../../tree/openldap)                                       | OpenLDAP is an open source implementation of the Lightweight Directory Access Protocol                                                                                          |
| [pgadmin4](../../tree/pgadmin4)                                       | pgAdmin is the most popular and feature rich Open Source administration and development platform for PostgreSQL.                                                                |
| [portainer](../../tree/portainer)                                     | Portainer accelerates container adoption. It reduces operational complexity and addresses the security challenges of running containers in Docker, Swarm, Nomad and Kubernetes. |
| [protobuf](../../tree/protobuf)                                       | Protocol buffers are a language-neutral, platform-neutral extensible mechanism for serializing structured data.                                                                 |
| [redis-commander](../../tree/redis-commander)                         | Redis web management tool written in node.js                                                                                                                                    |
| [sqlmigrationbuilder](../../tree/sqlmigrationbuilder)                 | Database Migration Manager builder(compiler). See more in [official documentation](https://docs.freemework.org/sql.misc.migration).                                             |
| [sqlmigrationrunner](../../tree/sqlmigrationrunner)                   | Database Migration Manager runner. See more in [official documentation](https://docs.freemework.org/sql.misc.migration).                                                        |
| [sqlmigrationrunner-postgres](../../tree/sqlmigrationrunner-postgres) | Deprecated. Use `sqlmigrationrunner` instead.                                                                                                                                   |
| [sqlrunner](../../tree/sqlrunner)                                     | Provide ability to run series of SQL scripts against various databases like MSSQL, MySQL, PostgreSQL, SQLite, etc.                                                              |
| [subversion](../../tree/subversion)                                   | Apache Subversion is a software versioning and revision control system.                                                                                                         |
| [tonos-cli](../../tree/tonos-cli)                                     | TON OS command line tool                                                                                                                                                        |
| [traefik](../../tree/traefik)                                         | Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy.                                                                               |
| [zclassic](../../tree/zclassic)                                       | ZClassic Full Node                                                                                                                                                              |

## Get Started

1. Clone the repository
   ```shell
   git clone git@github.com:theanurin/docker-images.git
   ```
1. Enter into cloned directory
   ```shell
   cd docker-images
   ```
1. Initialize [worktree](https://git-scm.com/docs/git-worktree) by execute following commands
   ```shell
   for BRANCH in $(cat README.md | tail -n +5 | grep -E -i '^\| \[([-\.a-z0-9]+)\]' | awk -F'[][]' '{print $2}'); do git worktree add "${BRANCH}" "${BRANCH}"; done
   ```
1. Open VSCode Workspace
   ```shell
   code "Docker-Images.code-workspace"
   ```

## Notes

### Add new orphan branch

```shell
NEW_BRANCH=...
git worktree add --detach "./${NEW_BRANCH}"
cd "./${NEW_BRANCH}"
git checkout --orphan "${NEW_BRANCH}"
git reset --hard
git commit --allow-empty -m "Initial Commit"
git push origin "${NEW_BRANCH}":"${NEW_BRANCH}"
```

### Get list of Docker image tags

```shell
skopeo --override-os linux inspect docker://docker.io/theanurin/mkdocs | jq -r '.RepoTags[]' | tee tags.local.txt
```

### Copy Docker images (multi-arch)

```shell
cat tags.local.txt | while read TAG; do echo $TAG; skopeo copy --all docker://docker.io/zxteamorg/jekyll:$TAG docker://docker.io/theanurin/jekyll:$TAG; done

cat tags.local.txt | while read TAG; do echo $TAG; skopeo copy --all docker://docker.io/zxteamorg/messenger-bridge:$TAG docker://docker.io/theanurin/messenger-bridge:$TAG; done
```

### Diff not synced tags

```shell
skopeo --override-os linux inspect docker://docker.io/zxteamorg/jekyll | jq -r '.RepoTags[]' > tags.local.1
skopeo --override-os linux inspect docker://docker.io/theanurin/jekyll | jq -r '.RepoTags[]' > tags.local.2
diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" tags.local.2 tags.local.1 | tee tags.local.txt
```
