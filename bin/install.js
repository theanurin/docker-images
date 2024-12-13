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
	FException,
} = require("@freemework/common");
const { FConfigurationEnv, FConfigurationDirectory } = require("@freemework/hosting");
const { FSqlMigrationSources } = require("@freemework/sql.misc.migration");
const { FSqlConnectionFactoryPostgres, FSqlMigrationManagerPostgres } = require("@freemework/sql.postgres");

const fs = require("fs");

const { version: packageVersion } = require("../package.json");

const { MaskService } = require("../lib/mask-service.js");

FLogger.setLoggerFactory((loggerName) => FLoggerConsole.create(loggerName, {
	level: process.env["LOG_LEVEL"] !== undefined
		? FLoggerLevel.parse(process.env["LOG_LEVEL"].toUpperCase())
		: FLoggerLevel.INFO,
	format: "text",
}));
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
	appLogger.info(appExecutionContext, `Database Migration Install/Up v${packageVersion}`);

	const isLaxMode = (function () {
		for (const arg of process.argv) {
			if (arg.startsWith("--mode=")) {
				if (arg === "--mode=lax") { return true; }
				if (arg !== "--mode=strict") {
					throw new CommandLineException(`Unsupported mode '${arg}'`);
				}
			}
		}
		return false;
	})();

	const startDate = new Date();

	const config = await readConfiguration();

	const maskedPostgresUrl = MaskService.default.maskUri(config.postgresUrl);
	appLogger.info(appExecutionContext, () => `Establishing database connection... ${maskedPostgresUrl.toString()}`);
	const sqlConnectionFactory = new FSqlConnectionFactoryPostgres({
		url: config.postgresUrl,
		defaultSchema: `public`,
		log: appLogger
	});
	await sqlConnectionFactory.init(appExecutionContext);
	try {
		appLogger.info(appExecutionContext, `Loading migration scripts from ${config.migrationSourcesDirectory} ...`);
		const migrationSources = await FSqlMigrationSources.loadFromFilesystem(
			appExecutionContext,
			config.migrationSourcesDirectory
		);

		const manager = new FSqlMigrationManagerPostgres({
			sqlConnectionFactory,
			log: appLogger
		});

		appLogger.info(appExecutionContext, "Obtaining current database version ...");
		const currentDatabaseVersion = await manager.getCurrentVersion(appExecutionContext);
		appLogger.info(appExecutionContext, `Current database version is '${currentDatabaseVersion}'.`);

		if (config.targetVersion !== null) {
			appLogger.info(appExecutionContext, `Target version '${config.targetVersion}' to install.`);
		} else {
			appLogger.info(appExecutionContext, "Target version is not defined. Using latest version to install.");
		}

		if (!process.argv.includes("--no-sleep")) {
			// Sleep a little bit (may be user will want to avoid installation)
			appLogger.info(appExecutionContext, "Sleep a little bit before install scripts (you are able to cancel the process yet) ...");
			await FSleep(appExecutionContext, 8000);
		}

		if (isLaxMode) {
			appLogger.info(appExecutionContext, "LAX mode. Obtaining installed versions...");
			let laxRollbackTargetVersion = null;
			const installedVersions = [...await manager.listVersions(appExecutionContext)];
			if (installedVersions.length > 0) {
				const migrationVersions = [...migrationSources.versionNames];
				installedVersions.sort();
				migrationVersions.sort();

				let isNeedRollback = false;

				for (let installedVersionIndex = 0; installedVersionIndex < installedVersions.length; ++installedVersionIndex) {
					if (migrationVersions.length <= installedVersionIndex) { break; }
					const installedVersion = installedVersions[installedVersionIndex];
					const migrationVersion = migrationVersions[installedVersionIndex];
					if (installedVersion !== migrationVersion) {
						isNeedRollback = true;
						break;
					}
					laxRollbackTargetVersion = installedVersion;
				}
				if (migrationVersions.length < installedVersions.length) {
					isNeedRollback = true;
				}

				if (isNeedRollback) {
					if (laxRollbackTargetVersion === null) {
						appLogger.info(appExecutionContext, () => `Rollback ALL migration scripts ...`);
						await manager.rollback(appExecutionContext); // Full rollback
					} else {
						appLogger.info(appExecutionContext, () => `Rollback migration scripts to LAX version '${laxRollbackTargetVersion}' ...`);
						await manager.rollback(appExecutionContext, laxRollbackTargetVersion); // Rollback to LAX version
					}
				} else {
					appLogger.info(appExecutionContext, "LAX mode. No need to rollback anything due to no changes in installed versions history.");
				}
			} else {
				appLogger.info(appExecutionContext, "LAX mode. No any installed versions");
			}
		}

		if (config.targetVersion !== null) {
			appLogger.info(appExecutionContext, () => `Installing migration scripts to target version '${config.targetVersion}' ...`);
			await manager.install(appExecutionContext, migrationSources, config.targetVersion);
		} else {
			appLogger.info(appExecutionContext, () => `Installing migration scripts to latest version ...`);
			await manager.install(appExecutionContext, migrationSources);
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
		} else if (reason instanceof CommandLineException) {
			appLogger.fatal(FExecutionContext.Default, reason.message);
			exitCode = 2;
		} else if (reason instanceof FCancellationException) {
			appLogger.warn(FExecutionContext.Default, "Application cancelled by user");
			exitCode = 42;
		} else {
			appLogger.fatal(FExecutionContext.Default, () => `Application crashed: ${reason}`);
			exitCode = 127;
		}

		FSleep(FExecutionContext.Default, 250).then(function () {
			process.exit(exitCode);
		});
	}
);

class CommandLineException extends FException { }
