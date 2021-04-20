#!/usr/bin/env python3
#
#
# Welcome to ADM.TOOLS client. See details https://api.adm.tools/
#
# This script provides LEGO API implementation. See https://go-acme.github.io/lego/dns/exec/
#
# This script will be called in following ways:
#   ./update-dns.py present "_acme-challenge.test.yourdomain.test." "MsijOYZxqyjGnFGwhjrhfg-Xgbl5r68WPda0J9EgqqI"
#   ./update-dns.py cleanup "_acme-challenge.test.yourdomain.test." "MsijOYZxqyjGnFGwhjrhfg-Xgbl5r68WPda0J9EgqqI"
#   ./update-dns.py timeout  (WARINING this not implemented https://github.com/go-acme/lego/blob/403070dd9be7579bb97e9a9b3b63ca0500fe3e7f/providers/dns/exec/exec.go, use EXEC_POLLING_INTERVAL and EXEC_PROPAGATION_TIMEOUT instead)
#
# Environment variables:
#    - ADM_TOOLS_ROOT_DOMAINS    - comma separated domain list
#    - ADM_TOOLS_API_TOKEN_FILE  - path to token file
#    - ADM_TOOLS_API_URL         - override API url
#
# To debug the script
#
#  $ docker run -it --rm --volume $PWD/tools.adm.py:/opt/tools.adm.py --volume /path/to/tools-adm-api.token:/run/secrets/update_dns_api_token zxteamorg/traefik-with-python:latest /bin/sh
#  EXEC_MODE=none ADM_TOOLS_ROOT_DOMAINS=yourdomain.test ADM_TOOLS_API_TOKEN_FILE=/run/secrets/update_dns_api_token /opt/tools.adm.py "present" "_acme-challenge.test.yourdomain.test." "MsijOYZxqyjGnFGwhjrhfg-Xgbl5r68WPda0J9EgqqI"
#


import os
import sys
import logging
import json
import requests
import time

# == For trace ==
#import http.client as http_client
#http_client.HTTPConnection.debuglevel = 1
#logging.basicConfig()
#logging.getLogger().setLevel(logging.DEBUG)
#requests_log = logging.getLogger("requests.packages.urllib3")
#requests_log.setLevel(logging.DEBUG)
#requests_log.propagate = True


if "EXEC_MODE" in os.environ and os.environ["EXEC_MODE"] == "RAW":
	print("RAW mode is not supported by the app", sys.argv[0], file=sys.stderr)
	sys.exit(1)

if "ADM_TOOLS_API_URL" not in os.environ:
	os.environ["ADM_TOOLS_API_URL"] = "https://adm.tools"

if "ADM_TOOLS_ROOT_DOMAINS" not in os.environ or "ADM_TOOLS_API_URL" not in os.environ or "ADM_TOOLS_API_TOKEN_FILE" not in os.environ:
	print("You need to define following variables to use the app: ADM_TOOLS_ROOT_DOMAINS, ADM_TOOLS_API_URL and ADM_TOOLS_API_TOKEN_FILE", sys.argv[0], file=sys.stderr)
	sys.exit(1)

rootDomains = os.environ["ADM_TOOLS_ROOT_DOMAINS"].split(",")
dnsApiUrl = os.environ["ADM_TOOLS_API_URL"]
dnsApiTokenFile = os.environ["ADM_TOOLS_API_TOKEN_FILE"]

try:
	with open(dnsApiTokenFile, "r") as f:
		dnsApiToken = f.read()
except Exception as e:
	print("Cannot load token file '" + dnsApiTokenFile + "'.", "Inner error:", e, file=sys.stderr)
	sys.exit(1)

for rootDomainIndex in range(len(rootDomains)):
	rootDomain = rootDomains[rootDomainIndex]
	if rootDomain.endswith("."):
		rootDomain = rootDomain[:-1]
		rootDomains[rootDomainIndex] = rootDomain
	del rootDomain

def apiPost(path, payload):
	time.sleep(1)

	headers = {'Content-type': 'application/x-www-form-urlencoded', 'User-Agent': 'curl/7.54.0', 'Authorization': 'Bearer ' + dnsApiToken }

	apiUrl = dnsApiUrl + path

	response = requests.post(apiUrl, data=payload, headers=headers)
	if response.status_code >= 400:
		raise Exception(response.status_code, response.reason, response.text[:300]);

	respData = json.loads(response.text)
	if respData["result"] != True:
		raise Exception(response.text)

	return respData["response"]

def readDomainId(domainName):
	response = apiPost('/action/dns/list/', { 'domains_search_request': domainName })
	if 'list' not in response:
		raise Exception("Response has not 'list' field.", response)

	domainList = response['list']

	if domainName not in domainList:
		raise Exception("Domain is not presented in domain list.", domainName)
		
	domainInfo = domainList[domainName]

	if 'domain_id' not in domainInfo:
		raise Exception("Domain record has not 'domain_id' field.", domainInfo)

	domainId = domainInfo['domain_id']

	return domainId


def cleanup(dns_key, dns_value):
	rootDomain = None

	for testRootDomain in rootDomains:
		if dns_key.endswith(testRootDomain + ".") and len(dns_key) >= len(testRootDomain) + 2: # dot after root domain + dot after acme challenge
			rootDomain = testRootDomain
			break

	if rootDomain == None:
		raise Exception("Cannot resolve root domain from challange key", dns_key)

	domainId = readDomainId(rootDomain)

	domainRecordsResponse = apiPost('/action/dns/records_list/', {'domain_id': domainId });
	if 'list' not in domainRecordsResponse:
		raise Exception("Response has not 'list' field.", domainRecordsResponse)

	domainRecords = domainRecordsResponse['list']
	domainTxtRecords = list(filter(lambda x: x['type'] == 'TXT', domainRecords))

	acmeChallenge = dns_key[:-len(rootDomain) - 2]

	for domainTxtRecord in domainTxtRecords:
		if 'id' not in domainTxtRecord:
			raise Exception("Domain TXT Record has not 'id' field.", domainTxtRecord)

		domainTxtRecordId = domainTxtRecord['id']
		apiPost('/action/dns/record_delete/', {'subdomain_id': domainTxtRecordId}); 


def present(dns_key, dns_value):
	cleanup(dns_key, dns_value)

	rootDomain = None

	for testRootDomain in rootDomains:
		if dns_key.endswith(testRootDomain + ".") and len(dns_key) >= len(testRootDomain) + 2: # dot after root domain + dot after acme challenge
			rootDomain = testRootDomain
			break

	if rootDomain == None:
		raise Exception("Cannot resolve root domain from challange key", dns_key)

	domainId = readDomainId(rootDomain)

	acmeChallenge = dns_key[:-len(rootDomain) - 2]

	apiPost('/action/dns/records_add/', {'domain_id': domainId, 'type': 'TXT', 'record': acmeChallenge, 'data': dns_value }); 

	

def timeout():
	# WARINING this not implemented https://github.com/go-acme/lego/blob/403070dd9be7579bb97e9a9b3b63ca0500fe3e7f/providers/dns/exec/exec.go
	# use EXEC_POLLING_INTERVAL and EXEC_PROPAGATION_TIMEOUT instead
	print(json.dumps({"timeout": 600, "interval": 30}), flush=True, end='')

def ensureArgvLen(expectedLen):
	if len(sys.argv) < expectedLen:
		raise Exception("Wrong execution contract. Required args were not passed.")

def main():
	try:
		ensureArgvLen(2)
		command = sys.argv[1]
		if command == "present":
			ensureArgvLen(4)
			dns_key = sys.argv[2]
			dns_value = sys.argv[3]
			present(dns_key, dns_value)
		elif command == "cleanup":
			ensureArgvLen(4)
			dns_key = sys.argv[2]
			dns_value = sys.argv[3]
			cleanup(dns_key, dns_value)
		elif command == "timeout":
			timeout()

		sys.exit(0)
	except Exception as err:
		print("Failed", err, file=sys.stderr)

		print("API Login: '" + dnsApiLogin + "'", file=sys.stderr)
		print("API Token: '" + dnsApiToken + "'", file=sys.stderr)

		sys.exit(1)


if __name__ == "__main__":
	main()
