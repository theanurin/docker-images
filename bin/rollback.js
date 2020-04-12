#!/usr/bin/env node

"use strict";

const {
	FCancellationException,
	FConfigurationException,
	FLogger,
	FLoggerConsole,
	FCancellationTokenSourceManual,
	FLoggerLevel,
	FSleep,
	FConfigurationChain,
	FExecutionContext,
	FCancellationExecutionContext,
} = require("@freemework/common");
const { FConfigurationEnv, FConfigurationDirectory } = require("@freemework/hosting");
const { FSqlConnectionFactoryPostgres, FSqlMigrationManagerPostgres } = require("@freemework/sql.postgres");

const fs = require("fs");

const { version: packageVersion } = require("../package.json");


FLogger.setLoggerFactory((loggerName) => FLoggerConsole.create(loggerName, { level: FLoggerLevel.INFO, format: "text" }));
const appLogger = FLogger.create("install");

const appCancellationTokenSource = new FCancellationTokenSourceManual();
const appExecutionContext = new FCancellationExecutionContext(FExecutionContext.Default, appCancellationTokenSource.token);

let destroyRequestCount = 0
const shutdownSignals = Object.freeze(["SIGTERM", "SIGINT"]);

async function gracefulShutdown(signal) {
	if (destroyRequestCount++ === 0) {
		appCancellationTokenSource.cancel();

		if (appLogger.isInfoEnabled) {
			appLogger.info(appExecutionContext, () => `Interrupt signal received: ${signal}`);
		}
	} else {
		if (appLogger.isInfoEnabled) {
			appLogger.info(appExecutionContext, () => `Interrupt signal (${destroyRequestCount}) received: ${signal}`);
		}
	}
}
shutdownSignals.forEach((signal) => process.on(signal, () => gracefulShutdown(signal)));

async function main() {
	appLogger.info(appExecutionContext, `Database Migration Rollback v${packageVersion}`);

	const startDate = new Date();

	const config = await readConfiguration();

	appLogger.info(appExecutionContext, () => `Establishing database connection... ${config.postgresUrl.toString()}`);
	const sqlConnectionFactory = new FSqlConnectionFactoryPostgres({
		url: config.postgresUrl,
		defaultSchema: `public`,
		log: appLogger
	});
	await sqlConnectionFactory.init(appExecutionContext);
	try {
		const manager = new FSqlMigrationManagerPostgres({
			sqlConnectionFactory,
			log: appLogger
		});

		appLogger.info(appExecutionContext, "Obtaining current database version ...");
		const currentDatabaseVersion = await manager.getCurrentVersion(appExecutionContext);
		appLogger.info(appExecutionContext, `Current database version is '${currentDatabaseVersion}'.`);

		if (config.targetVersion !== null) {
			appLogger.info(appExecutionContext, `Target version '${config.targetVersion}' to rollback.`);
		} else {
			appLogger.info(appExecutionContext, "Target version is not defined. Using full rollback.");
		}

		if (!process.argv.includes("--no-sleep")) {
			// Sleep a little bit (may be user will want to avoid rollback)
			appLogger.info(appExecutionContext, "Sleep a little bit before rollback scripts (you are able to cancel the process yet) ...");
			await FSleep(appExecutionContext, 8000);
		}

		if (config.targetVersion !== null) {
			appLogger.info(appExecutionContext, () => `Rollback migration scripts to target version '${config.targetVersion}' ...`);
			await manager.rollback(appExecutionContext, config.targetVersion);
		} else {
			appLogger.info(appExecutionContext, () => `Rollback ALL migration scripts ...`);
			await manager.rollback(appExecutionContext);
		}
	} finally {
		appLogger.info(appExecutionContext, "Closing database connection ...");
		await sqlConnectionFactory.dispose();
	}

	const endDate = new Date();
	const secondsDiff = (endDate.getTime() - startDate.getTime()) / 1000;
	appLogger.info(appExecutionContext, () => `Done in ${secondsDiff} seconds.`);
}

async function readConfiguration() {
	const configParts = [];

	configParts.push(new FConfigurationEnv());

	if (fs.existsSync("/etc/sqlmigration/secrets")) {
		configParts.push(await FConfigurationDirectory.read("/etc/sqlmigration/secrets"));
	}
	if (fs.existsSync("/run/secrets")) {
		configParts.push(await FConfigurationDirectory.read("/run/secrets"));
	}

	const config = new FConfigurationChain(...configParts);

	const postgresUrl = config.get("postgres.url").asUrl;
	const migrationSourcesDirectory = config.get("migration.directory").asString;
	const targetVersion = config.has("migration.targetVersion") ? config.get("migration.targetVersion").asString : null;

	return Object.freeze({
		postgresUrl, targetVersion, migrationSourcesDirectory
	});
}

main().then(
	function () { process.exit(0); }
).catch(
	function (reason) {
		let exitCode;
		if (reason instanceof FConfigurationException) {
			appLogger.fatal(FExecutionContext.Default, () => `Wrong configuration. Cannot continue. ${reason.message}`);
			exitCode = 1;
		} else if (reason instanceof FCancellationException) {
			appLogger.warn(FExecutionContext.Default, "Application cancelled by user");
			exitCode = 42;
		} else {
			appLogger.fatal(FExecutionContext.Default, () => `Application crashed: ${reason}`);
			exitCode = 127;
		}

		const timeout = setTimeout(guardForMissingLoggerCallback, 5000);
		const finalExitCode = exitCode;
		function guardForMissingLoggerCallback() {
			// This guard resolve promise, if log4js does not call shutdown callback
			process.exit(finalExitCode);
		}
		// require('log4js').shutdown(function (log4jsErr) {
		// 	if (log4jsErr) {
		// 		console.error("Failure log4js.shutdown:", log4jsErr);
		// 	}
		// 	clearTimeout(timeout);
		// 	process.exit(finalExitCode);
		// });
		FSleep(appExecutionContext, 250).then(function () {
			clearTimeout(timeout);
			process.exit(finalExitCode);
		});
	}
);
