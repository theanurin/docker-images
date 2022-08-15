# Docker Images

This is workspace branch of Docker Images multi project repository based on [orphan](https://git-scm.com/docs/git-checkout#Documentation/git-checkout.txt---orphanltnew-branchgt) branches.

| Branch                                   | Description                                                                                                          |
|------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| [luksoid](../../tree/luksoid)            | A command line tool to help users to use LUKS-encrypted partition image without Linux host.                          |
| [sqlmigration](../../tree/sqlmigration)  | Database Migration Manager based on plain SQL scripts.                                                               |
| [sqlrunner](../../tree/sqlrunner)        | Provide ability to run series of SQL scripts against variours databases like MSSQL, MySQL, PostgreSQL, SQLite, etc.  |

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
