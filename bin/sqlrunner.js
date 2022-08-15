#!/usr/bin/env node

"use strict";

const {
	FCancellationTokenSourceManual,
	FExceptionCancelled,
	FLogger,
	FSqlProviderFactory,
	Fsleep,
	FException,
	FExceptionConfiguration,
	FExecutionContextLogger,
	FExecutionContextCancellation,
	FExecutionContext,
} = require("@freemework/common");

const fs = require("fs");
const path = require("path");
const { promisify } = require("util");

const fsReadFileAsync = promisify(fs.readFile);
const fsReaddirAsync = promisify(fs.readdir);

const { version: packageVersion } = require("../package.json");

const appLogger = FLogger.Console;
const appCancellationTokenSource = new FCancellationTokenSourceManual();

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
	const logger = appLogger.getLogger("sqlrunner");
	logger.info(`SQL Runnner v${packageVersion}`);

	const executionContext = new FExecutionContextLogger(
		new FExecutionContextCancellation(
			FExecutionContext.None,
			appCancellationTokenSource.token
		),
		logger
	);

	const startDate = new Date();

	const sqlScriptsDirectory = process.env.DATA_DIRECTORY;
	if (sqlScriptsDirectory === undefined) {
		throw new FException("Undefined value for DATA_DIRECTORY environment variable. Expected path to directory with SQL scripts.");
	}

	const postgresUrlStr = process.env.DATABASE_URL;
	if (postgresUrlStr === undefined) {
		throw new FException("Undefined value for DATABASE_URL environment variable. Expected URL representation of connection string.");
	}

	let postgresUrl;
	try {
		postgresUrl = new URL(postgresUrlStr);
	} catch (e) {
		const ex = FException.wrapIfNeeded(e);
		throw new FException("Wrong value for DATABASE_URL environment variable. Expected URL.", ex);
	}

	logger.info("Establishing database connection...");
	let sqlProviderFactory;
	switch (postgresUrl.protocol) {
		case "postgres:":
		case "postgres+ssl:":
			const { FSqlProviderFactoryPostgres } = require("@freemework/sql.postgres");
			sqlProviderFactory = new FSqlProviderFactoryPostgres({
				url: postgresUrl,
				defaultSchema: `public`
			});
			break;
		default:
			throw new FException(`Unsupported schema(protocol) "${postgresUrl.protocol}" of the DATABASE_URL`);
	}
	await sqlProviderFactory.init(executionContext);
	try {
		logger.info(`Looking for the SQL scripts inside ${sqlScriptsDirectory} ...`);

		const sqlFiles = (await fsReaddirAsync(sqlScriptsDirectory, { withFileTypes: true }))
			.filter(w => w.isFile() && w.name.endsWith(".sql"))
			.map(sqlFile => sqlFile.name);

		logger.info(`Obtaining SQL connection(provider) ...`);
		await sqlProviderFactory.usingProviderWithTransaction(executionContext, async (sqlProvider) => {

			for (const sqlFileName of sqlFiles) {
				logger.info(`Processing SQL script: ${sqlFileName} ...`);
				const sqlFilePath = path.join(sqlScriptsDirectory, sqlFileName);
				const sqlFileContent = await fsReadFileAsync(sqlFilePath, "utf-8");

				await sqlProvider
					.statement(sqlFileContent)
					.execute(executionContext);
			}

		});

	} finally {
		logger.info("Closing database connection...");
		await sqlProviderFactory.dispose();
	}

	const endDate = new Date();
	const secondsDiff = (endDate.getTime() - startDate.getTime()) / 1000;
	logger.info(`Done in ${secondsDiff} seconds.`);
}

main().then(
	function () { process.exit(0); }
).catch(
	function (e) {
		const ex = FException.wrapIfNeeded(e);
		let exitCode;
		if (ex instanceof FExceptionCancelled) {
			appLogger.warn("Application cancelled by user");
			exitCode = 42;
		} else {
			console.log(ex);
			appLogger.fatal(`Application crashed. ${ex.name}: ${ex.message}`);
			exitCode = 127;
		}
		process.exit(exitCode);
	}
);
