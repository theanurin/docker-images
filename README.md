# Docker Images

This is workspace branch of Docker Images multi project repository based on [orphan](https://git-scm.com/docs/git-checkout#Documentation/git-checkout.txt---orphanltnew-branchgt) branches.

| Branch                                                         | Description                                                                                                          |
|----------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| [configuration-templates](../../tree/configuration-templates)  | Set of template processors that run against configuration properties                                                 |
| [devel.postgres-13](../../tree/devel.postgres-13)              | PostgreSQL for development and testing purposes                                                                      |
| [luksoid](../../tree/luksoid)                                  | A command line tool to help users to use LUKS-encrypted partition image without Linux host                           |
| [mkdocs](../../tree/mkdocs)                                    | Fast, simple and downright gorgeous static site generator that's geared towards building project documentation.      |
| [openldap](../../tree/openldap)                                | OpenLDAP is an open source implementation of the Lightweight Directory Access Protocol                               |
| [sqlmigration](../../tree/sqlmigration)                        | Database Migration Manager based on plain SQL scripts                                                                |
| [sqlrunner](../../tree/sqlrunner)                              | Provide ability to run series of SQL scripts against various databases like MSSQL, MySQL, PostgreSQL, SQLite, etc    |
| [subversion](../../tree/subversion)                            | Contrib. Apache Subversion is a software versioning and revision control system                                      |

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
	for BRANCH in $(cat README.md | tail -n +3 | grep -E '^\| \[([a-z]+)\]' | awk -F'[][]' '{print $2}'); do git worktree add "${BRANCH}" "${BRANCH}"; done
	```
1. Open VSCode Workspace
	```shell
	code "Docker-Images.code-workspace"
	```

## Notes

Add new orphan branch

```shell
NEW_ORPHAN_BRANCH=mybranch
git switch --orphan  "${NEW_ORPHAN_BRANCH}"
git commit --allow-empty -m "Initial Commit"
git push origin "${NEW_ORPHAN_BRANCH}"
```
