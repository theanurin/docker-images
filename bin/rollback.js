#!/usr/bin/env node

"use strict";

const { ManualCancellationTokenSource, sleep } = require("@zxteam/cancellation");
const { chainConfiguration, envConfiguration, secretsDirectoryConfiguration } = require("@zxteam/configuration");
const { CancelledError, ConfigurationError } = require("@zxteam/errors");
const { logger: rootLogger } = require("@zxteam/logger");
const { MigrationSources } = require("@zxteam/sql");
const { PostgresProviderFactory, PostgresMigrationManager } = require("@zxteam/sql-postgres");

const fs = require("fs");

const { version: packageVersion } = require("../package.json");

const appLogger = rootLogger.getLogger("rollback");
const appCancellationTokenSource = new ManualCancellationTokenSource();

let destroyRequestCount = 0
const shutdownSignals = Object.freeze(["SIGTERM", "SIGINT"]);

async function gracefulShutdown(signal) {
	if (destroyRequestCount++ === 0) {
		appCancellationTokenSource.cancel();

		if (appLogger.isInfoEnabled) {
			appLogger.info(`Interrupt signal received: ${signal}`);
		}
	} else {
		if (appLogger.isInfoEnabled) {
			appLogger.info(`Interrupt signal (${destroyRequestCount}) received: ${signal}`);
		}
	}
}
shutdownSignals.forEach((signal) => process.on(signal, () => gracefulShutdown(signal)));

async function main() {
	const mainLogger = appLogger.getLogger("main");
	appLogger.info(`Database Migration Rollback ${packageVersion}`);

	const startDate = new Date();

	const config = await readConfiguration();

	mainLogger.info("Establishing database connection...");
	const sqlProviderFactory = new PostgresProviderFactory({
		url: config.postgresUrl,
		defaultSchema: `public`,
		log: mainLogger.getLogger("factory")
	});
	await sqlProviderFactory.init(appCancellationTokenSource.token);
	try {
		mainLogger.info(`Loading migration scripts from ${config.migrationSourcesDirectory}...`);
		const migrationSources = await MigrationSources.loadFromFilesystem(
			appCancellationTokenSource.token,
			config.migrationSourcesDirectory
		);

		const manager = new PostgresMigrationManager({
			migrationSources, sqlProviderFactory,
			log: mainLogger.getLogger("migration")
		});

		mainLogger.info("Obtaining current database version...");
		const currentDatabaseVersion = await manager.getCurrentVersion(appCancellationTokenSource.token);
		mainLogger.info(`Current database version is '${currentDatabaseVersion}'.`);

		if (config.targetVersion !== null) {
			mainLogger.info(`Target version '${config.targetVersion}' to rollback.`);
		} else {
			mainLogger.info("Target version is not defined. Using full rollback.");
		}

		if (!process.argv.includes("--no-sleep")) {
			// Sleep a little bit (may be user will want to avoid rollback)
			mainLogger.info("Sleep a little bit before rollback scripts (you are able to cancel the process yet)...");
			await sleep(appCancellationTokenSource.token, 8000);
		}

		if (config.targetVersion !== null) {
			mainLogger.info(`Rollback migration scripts to target version '${config.targetVersion}'...`);
			await manager.rollback(appCancellationTokenSource.token, config.targetVersion);
		} else {
			mainLogger.info(`Rollback ALL migration scripts...`);
			await manager.rollback(appCancellationTokenSource.token);
		}
	} finally {
		mainLogger.info("Closing database connection...");
		await sqlProviderFactory.dispose();
	}

	const endDate = new Date();
	const secondsDiff = (endDate.getTime() - startDate.getTime()) / 1000;
	mainLogger.info(`Done in ${secondsDiff} seconds.`);
}

async function readConfiguration() {
	const configParts = [];

	configParts.push(envConfiguration());

	if (fs.existsSync("/etc/sqlmigrationrunner-postgres/migration/secrets")) {
		configParts.push(await secretsDirectoryConfiguration("/etc/sqlmigrationrunner-postgres/migration/secrets"));
	}
	if (fs.existsSync("/run/secrets")) {
		configParts.push(await secretsDirectoryConfiguration("/run/secrets"));
	}

	const config = chainConfiguration(...configParts);

	const postgresUrl = config.getURL("postgres.url");
	const migrationSourcesDirectory = config.getString("migration.directory");
	const targetVersion = config.hasNonEmpty("migration.rollbackTargetVersion") ? config.getString("migration.rollbackTargetVersion") : null;

	return Object.freeze({
		postgresUrl, targetVersion, migrationSourcesDirectory
	});
}

main().then(
	function () { process.exit(0); }
).catch(
	function (reason) {
		let exitCode;
		if (reason instanceof ConfigurationError) {
			appLogger.fatal(`Wrong configuration. Cannot continue. ${reason.message}`);
			exitCode = 1;
		} else if (reason instanceof CancelledError) {
			appLogger.warn("Application cancelled by user");
			exitCode = 42;
		} else {
			appLogger.fatal("Application crashed", reason);
			exitCode = 127;
		}
	}
);
