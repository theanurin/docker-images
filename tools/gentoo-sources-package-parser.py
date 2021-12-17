#!/usr/bin/env python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import json
import requests

def format_build_item(kernel_version, stability, latestly, docker_tag, docker_platform):
	'''
	Format build item: <kernel_version>:<stable|testing>:<latest|non-latest>:<docker_tag>:<docker_platform>
	'''
	return ":".join([kernel_version, stability, latestly, docker_tag, docker_platform])


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

		isTestingAmd64 = "kk-keyword-testing" in htmlTableBodyColumnAmd64["class"]
		isTestinX86 = "kk-keyword-testing" in htmlTableBodyColumnX86["class"]
		isTestingArm32 = "kk-keyword-testing" in htmlTableBodyColumnArm32["class"]
		isTestingArm64 = "kk-keyword-testing" in htmlTableBodyColumnArm64["class"]

		build_item_manifest_tags = []
		# Use stable ONLY
		if not isTestingAmd64:
			if isFirstStableAmd64:
				build_items.append(format_build_item(kernelVersion, "stable", "latest", "amd64", "linux/amd64"))
				manifest_latest.append("%s:amd64" % (kernelVersion))
				isFirstStableAmd64 = False
			else:
				build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "amd64", "linux/amd64"))
			build_item_manifest_tags.append("amd64")

		if not isTestinX86:
			if isFirstStableX86:
				build_items.append(format_build_item(kernelVersion, "stable", "latest", "x86", "linux/386"))
				manifest_latest.append("%s:x86" % (kernelVersion))
				isFirstStableX86 = False
			else:
				build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "x86", "linux/386"))
			build_item_manifest_tags.append("x86")

		if not isTestingArm32:
			if isFirstStableArm32:
				build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm32_v5", "linux/arm/v5"))
				build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm32_v6", "linux/arm/v6"))
				build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm32_v7", "linux/arm/v7"))
				manifest_latest.append("%s:arm32_v5" % (kernelVersion))
				manifest_latest.append("%s:arm32_v6" % (kernelVersion))
				manifest_latest.append("%s:arm32_v7" % (kernelVersion))
				isFirstStableArm32 = False
			else:
				build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm32_v5", "linux/arm/v5"))
				build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm32_v6", "linux/arm/v6"))
				build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm32_v7", "linux/arm/v7"))
			build_item_manifest_tags.append("arm32_v5")
			build_item_manifest_tags.append("arm32_v6")
			build_item_manifest_tags.append("arm32_v7")

		if not isTestingArm64:
			if isFirstStableArm64:
				build_items.append(format_build_item(kernelVersion, "stable", "latest", "arm64_v8", "linux/arm64/v8"))
				manifest_latest.append("%s:arm64_v8" % (kernelVersion))
				isFirstStableArm64 = False
			else:
				build_items.append(format_build_item(kernelVersion, "stable", "non-latest", "arm64_v8", "linux/arm64/v8"))
			build_item_manifest_tags.append("arm64_v8")
		
		if len(build_item_manifest_tags) > 0:
			manifest = "%s:%s" % (kernelVersion, ",".join(build_item_manifest_tags))
			manifest_items.append(manifest)


# https://docs.github.com/en/actions/learn-github-actions/workflow-commands-for-github-actions#setting-an-output-parameter
print("::set-output name=build_version::%s" % json.dumps(build_items))
print("::set-output name=manifest_version::%s" % json.dumps(manifest_items))
print("::set-output name=manifest_latest::%s" % json.dumps([",".join(manifest_latest)]))
