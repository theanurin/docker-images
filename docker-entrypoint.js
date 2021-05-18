#!/usr/bin/env node

"use strict";

// Mask all logging
process.env.LOG4JS_CONFIG = "/usr/local/bin/log4js.json";

const { ManualCancellationTokenSource } = require("@zxteam/cancellation");
const { InvalidOperationError } = require("@zxteam/errors");
const { launcher, registerShutdownHook } = require("@zxteam/launcher");

const Mustache = require("mustache");
const fs = require('fs');

function runtime(cancellationToken, configuration) {
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

	return new Promise(function (resolve, reject) {
		process.stdout.write(
			Mustache.render(templateContent, configuration),
			function (err) {
				if (err) { return reject(err); }
				return resolve();
			}
		);
	});
}

function createConfigurationProxy(finalConfig) {
	function keyWalker(rootObj, keys, sourceConfig, parentObject, parentKeyName) {
		const target = {};
		if (rootObj === null) {
			rootObj = target;
		}
		target["$root"] = rootObj;
		const dottedKeys = new Map();
		for (const key of keys) {
			const dotIndex = key.indexOf(".");
			if (dotIndex === -1) {
				const value = sourceConfig.get(key);
				target[key] = value;
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
			const inner = keyWalker(rootObj, subKeys, sourceConfig.getConfiguration(parentKey), target, parentKey);
			target[parentKey] = inner;
			target[`${parentKey}s`] = Object.keys(inner).filter(key => !key.endsWith("s") && key !== "$parent" && key !== "$root").map(key => {
				const innerObj = inner[key];
				const wrap = { ...innerObj };
				Object.defineProperty(wrap, "$parent", {
					get: function () {
						return innerObj["$parent"]["$parent"];
					}
				});
				return wrap;
			});

		}

		if (parentObject !== null) {
			target["$parent"] = parentObject;
		}

		return target;
	}

	const objectConfig = keyWalker(null, finalConfig.keys, finalConfig, null, null);

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
