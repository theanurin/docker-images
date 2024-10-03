[![Docker Image Version](https://img.shields.io/docker/v/theanurin/protobuf?sort=date&label=Version)](https://hub.docker.com/r/theanurin/protobuf/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/protobuf?label=Image%20Size)](https://hub.docker.com/r/theanurin/protobuf/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/protobuf?label=Pulls)](https://hub.docker.com/r/theanurin/protobuf)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/protobuf?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/protobuf)

# Protocol buffers

[Protocol buffers](https://developers.google.com/protocol-buffers) are a language-neutral, platform-neutral extensible mechanism for serializing structured data.

# Image reason

`Protoc` is a native tool to generate protocol buffer binding. The image provide quick and straight forward way to generate necessary sources on any developer's workstation.

# Spec

## Environment variables

* `VERBOSE` = yes|no - Show executed shell commands. Default: **no**
* `DATA_IN` - Define input directory (where .proto files are placed) for entry point generator script. Default: **/data/in**
* `DATA_OUT` - Define output directory (where generated sources appears) for entry point generator script. Default: **/data/out**

## Volumes

* `/data/in` - Default location to .proto files
* `/data/out` - Default location to generated artifacts

# Inside

* [Alpine Linux 3.12.0](https://hub.docker.com/_/alpine)
* [Protocol Buffers v3.13.0](https://github.com/protocolbuffers/protobuf/releases/tag/v3.13.0)
* [NodeJS](https://nodejs.org/)
* Entry point shell script to simplify launch

# Launch

## Shell

* C# bindings (--target=csharp)

	```bash
	docker run --interactive --tty --rm --volume /path/to/proto:/data/in --volume /path/to/src.gen:/data/out theanurin/protobuf --target=csharp
	```

* TypeScript bindings (--target=typescript)

	```bash
	docker run --interactive --tty --rm --volume /path/to/proto:/data/in --volume /path/to/src.gen:/data/out theanurin/protobuf --target=typescript
	```

## As VSCode tasks

```json
{
	// See https://go.microsoft.com/fwlink/?LinkId=733558
	// for the documentation about the tasks.json format
	"version": "2.0.0",
	...
	"tasks": [
		...
		{
			"label": "Generate C# Proto",
			"group": "build",
			"type": "shell",
			"command": "docker run --interactive --tty --rm --mount type=bind,source=\"${workspaceFolder}/proto\",target=/data/in,readonly --volume \"${workspaceFolder}/gen.cs\":/data/out theanurin/protobuf --target=csharp",
			"problemMatcher": []
		},
		{
			"label": "Generate TypeScript Proto",
			"group": "build",
			"type": "shell",
			"command": "docker run --interactive --tty --rm --mount type=bind,source=\"${workspaceFolder}/proto\",target=/data/in,readonly --volume \"${workspaceFolder}/gen.ts\":/data/out theanurin/protobuf --target=typescript",
			"problemMatcher": []
		}
	],
	...
}
```

## As GitLab Pipeline Job

```yaml
# .gitlab-ci.yaml
# === Assume following ===
# Input dir:             ./proto (take a look on DATA_IN)
# Output C# dir:         ./gen.cs (take a look on DATA_OUT)
# Output TypeScript dir: ./gen.ts (take a look on DATA_OUT)

stages:
  ...
  - generate
  ...

proto:
  stage: generate
  image:
    name: theanurin/protobuf
    entrypoint: ["/bin/sh", "-c"]
  script:
    - mkdir -p ./gen.cs ./gen.ts 
    - DATA_IN=proto DATA_OUT=gen.cs /usr/local/bin/docker-entrypoint.sh --target=csharp
    - DATA_IN=proto DATA_OUT=gen.ts /usr/local/bin/docker-entrypoint.sh --target=typescript
  ...
```

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
