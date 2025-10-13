#!/usr/bin/env node

"use strict";

const {
	FCancellationExecutionContext,
	FCancellationTokenSourceManual,
	FLogger,
	FLoggerConsole,
	FLoggerDummy,
	FLoggerLevel,
} = require("@freemework/common");
const { flauncher } = require("@freemework/hosting");

const { Liquid } = require("liquidjs");
const Mustache = require("mustache");
const fs = require('fs');

// Setup logging
// FLogger.setLoggerFactory((loggerName) => FLoggerConsole.create(loggerName, {
// 	level: FLoggerLevel.DEBUG,
// 	format: "text",
// 	output: "stderr",
// }));
FLogger.setLoggerFactory(FLoggerDummy.create);

let engine = "mustache";

async function main(executionContext, configuration) {

	const dynamicTemplateDataView = configuration.toDynamicView();

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

	if (engine === "liquid") {
		const liquid = new Liquid();
		const content = await liquid.parseAndRender(templateContent, dynamicTemplateDataView);
		return await new Promise(function (resolve, reject) {
			process.stdout.write(
				content,
				function (err) {
					if (err) { return reject(err); }
					return resolve();
				}
			);
		});
	} else {
		return await new Promise(function (resolve, reject) {
			let content;
			try {
				content = Mustache.render(templateContent, dynamicTemplateDataView, null, { escape: function (text) { return text; } });
			} catch (e) {
				return reject(e);
			}

			process.stdout.write(
				content,
				function (err) {
					if (err) { return reject(err); }
					return resolve();
				}
			);
		});
	}
}

function parseConfiguration(configuration) {
	return configuration;
}

function bootstrap(executionContext, configuration) {
	const cts = new FCancellationTokenSourceManual();
	executionContext = new FCancellationExecutionContext(executionContext, cts.token, true);

	const runtimePromise = main(executionContext, configuration);
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

if (process.argv.length > 2) {
	const args = [...process.argv];
	for (let index = 0; index < args.length; ++index) {
		const arg = args[index];
		if (arg === "--engine" && args.length > index + 1) {
			const newArgs = args.slice(0, index);
			newArgs.push(...args.slice(index + 2));
			engine = args[index + 1];
			process.argv = newArgs;
			break;
		}
	}
}

flauncher(parseConfiguration, bootstrap);
