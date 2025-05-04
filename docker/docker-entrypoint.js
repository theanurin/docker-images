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

const Mustache = require("mustache");
const fs = require('fs');

// Setup logging
// FLogger.setLoggerFactory((loggerName) => FLoggerConsole.create(loggerName, {
// 	level: FLoggerLevel.DEBUG,
// 	format: "text",
// 	output: "stderr",
// }));
FLogger.setLoggerFactory(FLoggerDummy.create);

function main(executionContext, configuration) {

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

	return new Promise(function (resolve, reject) {
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

flauncher(parseConfiguration, bootstrap);
