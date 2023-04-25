#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import json
import requests

def format_build_item(kernel_version, stability, latestly, docker_tag, docker_platform):
	'''
	Format build item: <kernel_version>:<stable|testing>:<latest|non-latest>:<docker_tag>:<docker_platform>
	'''
	return ":".join([kernel_version, stability, latestly, docker_tag, docker_platform])

deployed_tags_data = requests.get("https://registry.hub.docker.com/v2/repositories/theanurin/gentoo-sources-bundle/tags").json()
deployed_tags = list(map(lambda s: s['name'], deployed_tags_data['results']))

build_items = []
manifest_items = []
manifest_latest = []
isFirstStableAmd64 = True
isFirstStableX86 = True
isFirstStableArm32 = True
isFirstStableArm64 = True

url="https://packages.gentoo.org/packages/sys-kernel/gentoo-sources"

# Make a GET request to fetch the raw HTML content
html_content = requests.get(url).text

# Parse the html content
soup = BeautifulSoup(html_content, "html.parser")

htmlTables = soup.find_all('table')
for htmlTable in htmlTables:
	htmlTableHead = htmlTable.thead
	if htmlTableHead is None:
		continue

	htmlTableHeadRow = next((x for x in htmlTableHead.children if x.name == "tr"), None)
	if htmlTableHeadRow is None:
		continue

	htmlTableHeadColumns = [x.contents[0] for x in htmlTableHeadRow.children if x.name == "th"]
	isVersionTable = htmlTableHeadColumns[0] == "Version"
	if not isVersionTable:
		continue

	try:
		index_amd64 = htmlTableHeadColumns.index("amd64")
		index_x86 = htmlTableHeadColumns.index("x86")
		index_arm32 = htmlTableHeadColumns.index("arm")
		index_arm64 = htmlTableHeadColumns.index("arm64")
	except:
		continue;

	htmlTableBody = htmlTable.tbody
	if htmlTableBody is None:
		raise Exception()

	for htmlTableBodyRow in htmlTableBody.children:
		if htmlTableBodyRow.name != "tr":
			continue

		htmlTableBodyColumns = [x for x in htmlTableBodyRow.children if x.name == "td"]

		htmlTableBodyColumnVersion = htmlTableBodyColumns[0]
		htmlTableBodyColumnAmd64 = htmlTableBodyColumns[index_amd64]
		htmlTableBodyColumnX86 = htmlTableBodyColumns[index_x86]
		htmlTableBodyColumnArm32 = htmlTableBodyColumns[index_arm32]
		htmlTableBodyColumnArm64 = htmlTableBodyColumns[index_arm64]

		kernelVersion = htmlTableBodyColumnVersion.strong.a.contents[0]

		if not kernelVersion.startswith("5.15"):
			continue;

		isTestingAmd64 = "kk-keyword-testing" in htmlTableBodyColumnAmd64["class"]
		isTestingX86 = "kk-keyword-testing" in htmlTableBodyColumnX86["class"]
		isTestingArm32 = "kk-keyword-testing" in htmlTableBodyColumnArm32["class"]
		isTestingArm64 = "kk-keyword-testing" in htmlTableBodyColumnArm64["class"]

		isStableAmd64 = "kk-keyword-stable" in htmlTableBodyColumnAmd64["class"]
		isStableX86 = "kk-keyword-stable" in htmlTableBodyColumnX86["class"]
		isStableArm32 = "kk-keyword-stable" in htmlTableBodyColumnArm32["class"]
		isStableArm64 = "kk-keyword-stable" in htmlTableBodyColumnArm64["class"]

		build_item_manifest_tags = []
		# Use stable ONLY
		if isStableAmd64:
			if isFirstStableAmd64:
				if "amd64-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "latest", "amd64", "linux/amd64"))
					manifest_latest.append("%s:amd64" % (kernelVersion))
				isFirstStableAmd64 = False
			else:
				if "amd64-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "amd64", "linux/amd64"))

			if "amd64-%s" % (kernelVersion) not in deployed_tags:
				build_item_manifest_tags.append("amd64")

		if isStableX86:
			if isFirstStableX86:
				if "x86-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "latest", "x86", "linux/386"))
					manifest_latest.append("%s:x86" % (kernelVersion))
				isFirstStableX86 = False
			else:
				if "x86-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "x86", "linux/386"))

			if "x86-%s" % (kernelVersion) not in deployed_tags:
				build_item_manifest_tags.append("x86")

		if isStableArm32:
			if isFirstStableArm32:
				if "arm32v5-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm32v5", "linux/arm/v5"))
					manifest_latest.append("%s:arm32v5" % (kernelVersion))

				if "arm32v6-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm32v6", "linux/arm/v6"))
					manifest_latest.append("%s:arm32v6" % (kernelVersion))

				if "arm32v7-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm32v7", "linux/arm/v7"))
					manifest_latest.append("%s:arm32v7" % (kernelVersion))

				isFirstStableArm32 = False
			else:
				if "arm32v5-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm32v5", "linux/arm/v5"))

				if "arm32v6-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm32v6", "linux/arm/v6"))

				if "arm32v7-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm32v7", "linux/arm/v7"))

			if "arm32v5-%s" % (kernelVersion) not in deployed_tags:
				build_item_manifest_tags.append("arm32v5")

			if "arm32v6-%s" % (kernelVersion) not in deployed_tags:
				build_item_manifest_tags.append("arm32v6")

			if "arm32v7-%s" % (kernelVersion) not in deployed_tags:
				build_item_manifest_tags.append("arm32v7")

		if isStableArm64:
			if isFirstStableArm64:
				if "arm64v8-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm64v8", "linux/arm64/v8"))
					manifest_latest.append("%s:arm64v8" % (kernelVersion))
				isFirstStableArm64 = False
			else:
				if "arm64v8-%s" % (kernelVersion) not in deployed_tags:
					build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm64v8", "linux/arm64/v8"))

			if "arm64v8-%s" % (kernelVersion) not in deployed_tags:
				build_item_manifest_tags.append("arm64v8")

		if len(build_item_manifest_tags) > 0:
			manifest = "%s:%s" % (kernelVersion, ",".join(build_item_manifest_tags))
			manifest_items.append(manifest)


# https://docs.github.com/en/actions/learn-github-actions/workflow-commands-for-github-actions#setting-an-output-parameter
print("::set-output name=build_version::%s" % json.dumps(build_items))
print("::set-output name=manifest_version::%s" % json.dumps(manifest_items))
print("::set-output name=manifest_latest::%s" % json.dumps([",".join(manifest_latest)]))
