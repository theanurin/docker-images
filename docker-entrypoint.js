#!/usr/bin/env node

"use strict";

// Mask all logging
process.env.LOG4JS_CONFIG = "/usr/local/bin/log4js.json";

const { ManualCancellationTokenSource } = require("@zxteam/cancellation");
const { InvalidOperationError } = require("@zxteam/errors");
const { launcher, registerShutdownHook } = require("@zxteam/launcher");

const Mustache = require("mustache");
const fs = require('fs');

async function runtime(cancellationToken, configuration) {
	let templateContent;

	try {
		templateContent = fs.readFileSync(process.stdin.fd, "utf-8");
	} catch (e) {
		if (e instanceof Error && e.code === "EAGAIN") {
			console.error("ERROR! No STDIN data. Cannot continue.");
			process.exit(-1);
		}
		throw e;
	}
	console.log(Mustache.render(templateContent, configuration));
}

function createConfigurationProxy(finalConfig) {
	function keyWalker(keys, sourceConfig, parent) {
		const target = {};
		const dottedKeys = new Map();
		for (const key of keys) {
			const dotIndex = key.indexOf(".");
			if (dotIndex === -1) {
				target[key] = sourceConfig.get(key);
			} else {
				const parentKey = key.substring(0, dotIndex);
				const subKey = key.substring(dotIndex + 1);
				if (dottedKeys.has(parentKey)) {
					dottedKeys.get(parentKey).push(subKey);
				} else {
					dottedKeys.set(parentKey, [subKey]);
				}
			}
		}
		for (const [parentKey, subKeys] of dottedKeys.entries()) {
			const inner = keyWalker(subKeys, sourceConfig.getConfiguration(parentKey), parentKey);
			target[parentKey] = inner;
			target[`${parentKey}s`] = Object.keys(inner).filter(key => !key.endsWith("s")).map(key => inner[key]);

		}
		return target;
	}

	const objectConfig = keyWalker(finalConfig.keys, finalConfig);

	function makeProxyAdapter(ns, obj) {
		return new Proxy(obj, {
			get(_, propery) {
				if (typeof propery === "string") {
					if (propery in obj) {
						const value = obj[propery];
						if (typeof value === "string" || typeof value === "number" || typeof value === "boolean") {
							return value;
						} else {
							return makeProxyAdapter([...ns, propery], value);
						}
					}
					const fullProperty = [...ns, propery].join(".");
					throw new InvalidOperationError(`Non-existing property request '${fullProperty}'.`);
				}
			}
		});
	}

	const proxyConfig = makeProxyAdapter([], objectConfig);

	return proxyConfig;
}

function runtimeFactory(cancellationToken, configuration) {
	const cts = new ManualCancellationTokenSource();
	const runtimePromise = runtime(cts.token, configuration);
	runtimePromise.then(
		function () {
			process.exit(0);
		}
	).catch(
		function (reason) {
			console.error("Crash application", reason);
			process.exit(1);
		}
	);

	const runtimeInstance = Object.freeze({
		async destroy() { cts.cancel(); }
	});

	return Promise.resolve(runtimeInstance);
}

registerShutdownHook(async function () {
	await new Promise(function (resolve) {
		function guardForMissingLoggerCallback() {
			// This guard resolve promise, if log4js does not call shutdown callback
			resolve();
		}
		const timeout = setTimeout(guardForMissingLoggerCallback, 5000);
		require('log4js').shutdown(function (log4jsErr) {
			if (log4jsErr) {
				console.error("Failure log4js.shutdown:", log4jsErr);
			}
			clearTimeout(timeout);
			resolve();
		});
	});
});

launcher(createConfigurationProxy, runtimeFactory);
