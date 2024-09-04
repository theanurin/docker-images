#!/usr/bin/env node

"use strict";

const { DUMMY_CANCELLATION_TOKEN } = require("@zxteam/cancellation");
const { chainConfiguration, envConfiguration, fileConfiguration } = require("@zxteam/configuration");
const { InvalidOperationError } = require("@zxteam/errors");
const { logger: rootLogger } = require("@zxteam/logger");
const { MigrationSources } = require("@zxteam/sql");

const Mustache = require("mustache");

const fs = require("fs");
const path = require("path");
const appLogger = rootLogger.getLogger("build");

async function main() {
	appLogger.info(`Database Migration Builder`);

	const appOpts = parseArgs();

	const startDate = new Date();

	const mainLogger = rootLogger.getLogger("main");

	const configFile = path.normalize(path.join(process.cwd(), "database.config"));
	const configuration = createConfiguration(
		fs.existsSync(configFile) ? configFile : null,
		appOpts.envConfigurationFile,
		appOpts.extraConfigFiles,
		mainLogger.getLogger("config-loader")
	);
	const configurationProxy = configuration !== null ? createConfigurationProxy(configuration) : Object.freeze({});

	mainLogger.info("Loading migration scripts...");
	const loadOpts = {};
	if (appOpts.versionFrom !== null) { loadOpts.versionFrom = appOpts.versionFrom; }
	if (appOpts.versionTo !== null) { loadOpts.versionTo = appOpts.versionTo; }
	const migrationSources = await MigrationSources.loadFromFilesystem(
		DUMMY_CANCELLATION_TOKEN,
		path.normalize(path.join(process.cwd(), appOpts.sourceDir)),
		loadOpts
	);

	const destinationDirectory = path.normalize(path.join(process.cwd(), appOpts.buildDir));
	if (fs.existsSync(destinationDirectory)) {
		mainLogger.info(`Cleaning target directory ${destinationDirectory}...`);
		deleteDirectoryRecursiveSync(destinationDirectory, false);
	} else {
		mainLogger.info(`Creating target directory ${destinationDirectory}...`);
		fs.mkdirSync(destinationDirectory, { recursive: true, mode: 0o777 });
	}

	mainLogger.info("Building Mustache templates...");

	const transformedSources = migrationSources.map(
		(content, opts) => {
			mainLogger.info(`[${opts.versionName}] ${opts.itemName}`);

			const renderContext = {
				direction: opts.direction, // install/rollback
				version: opts.versionName,
				file: opts.itemName,
				...configurationProxy,
			};

			if (appOpts.buildConfiguration !== null) {
				const capitalizeBuildConfiguration = capitalize(appOpts.buildConfiguration);
				const envFlagName = `is${capitalizeBuildConfiguration}`;
				renderContext[envFlagName] = true;
			}

			return Mustache.render(content, renderContext);
		}
	);

	mainLogger.info(`Saving compiled scripts  to ${destinationDirectory}...`);
	await transformedSources.saveToFilesystem(
		DUMMY_CANCELLATION_TOKEN,
		destinationDirectory
	);

	const endDate = new Date();
	const secondsDiff = (endDate.getTime() - startDate.getTime()) / 1000;
	mainLogger.info(`Done in ${secondsDiff} seconds.`);
}

main().then(
	function () { process.exit(0); }
).catch(
	function (reason) {
		appLogger.fatal("Crash application", reason);
		process.exit(1);
	}
);

function deleteDirectoryRecursiveSync(directory, isRemoveItself = true) {
	if (fs.existsSync(directory)) {
		fs.readdirSync(directory).forEach((file, index) => {
			const curPath = path.join(directory, file);
			if (fs.lstatSync(curPath).isDirectory()) {
				// recurse
				deleteDirectoryRecursiveSync(curPath);
			} else {
				// delete file
				fs.unlinkSync(curPath);
			}
		});
		if (isRemoveItself === true) {
			fs.rmdirSync(directory);
		}
	}
}

function createConfiguration(configFile, envConfigurationFile, extraConfigFiles, logger) {
	const configs = [];

	logger.info(`Loading configuration environment variables...`);
	configs.push(envConfiguration());

	if (extraConfigFiles !== null) {
		for (const extraConfigFile of extraConfigFiles) {
			logger.info(`Loading configuration from file ${extraConfigFile}...`);
			configs.push(fileConfiguration(extraConfigFile));
		}
	}

	if (envConfigurationFile !== null) {
		logger.info(`Loading configuration from file ${envConfigurationFile}...`);
		configs.push(fileConfiguration(envConfigurationFile));
	}

	if (configFile !== null) {
		logger.info(`Loading configuration from file ${configFile}...`);
		configs.push(fileConfiguration(configFile));
	}

	const finalConfig = chainConfiguration(...configs);

	return finalConfig;
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
			const inner = keyWalker(rootObj, subKeys, sourceConfig.getConfiguration(parentKey), target, parentKey);
			target[parentKey] = inner;
			target[`${parentKey}s`] = Object.keys(inner).filter(key => !key.endsWith("s") && key !== "$parent" && key !== "$root").map(key => {
				const innerObj = inner[key];
				if (typeof innerObj === "string" || typeof innerObj === "number" || typeof innerObj === "boolean") {
					return innerObj;
				}
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

	const objectConfig = keyWalker(
		null,
		finalConfig.keys.filter(k => k.startsWith("database")), // ignore any configuration keys except database*
		finalConfig,
		null,
		null
	);

	function makeProxyAdapter(ns, obj) {
		return new Proxy(obj, {
			get(_, property) {
				if (typeof property === "string") {
					if (property in obj) {
						const value = obj[property];
						if (typeof value === "string" || typeof value === "number" || typeof value === "boolean") {
							return value;
						} else {
							return makeProxyAdapter([...ns, property], value);
						}
					}
					const fullProperty = [...ns, property].join(".");
					throw new InvalidOperationError(`Non-existing property request '${fullProperty}'.`);
				}
			}
		});
	}

	const proxyConfig = makeProxyAdapter([], objectConfig);

	return proxyConfig;
}

function parseArgs() {
	let buildConfiguration = null;
	let envConfigurationFile = null;
	let versionFrom = null;
	let versionTo = null;
	let sourceDir = "updates";
	let buildDir = ".dist";
	let extraConfigFiles = [];

	if (process.env["VERSION_FROM"]) {
		versionFrom = process.env["VERSION_FROM"];
	}

	if (process.env["VERSION_TO"]) {
		versionTo = process.env["VERSION_TO"];
	}

	if (process.env["BUILD_CONFIGURATION"]) {
		buildConfiguration = process.env["BUILD_CONFIGURATION"];
		envConfigurationFile = path.normalize(path.join(process.cwd(), `database-${buildConfiguration}.config`));
	}

	if (process.env["SOURCE_PATH"]) {
		sourceDir = process.env["SOURCE_PATH"];
	}

	if (process.env["BUILD_PATH"]) {
		buildDir = process.env["BUILD_PATH"];
	}

	if (process.env["EXTRA_CONFIGS"]) {
		const extraConfigsValue = process.env["EXTRA_CONFIGS"];
		extraConfigFiles = extraConfigsValue.split(",");
	}


	return Object.freeze({
		buildConfiguration,
		envConfigurationFile,
		versionFrom,
		versionTo,
		sourceDir,
		buildDir,
		extraConfigFiles
	});
}

/**
 * https://stackoverflow.com/questions/2332811/capitalize-words-in-string
 * Capitalizes first letters of words in string.
 * @param {string} str String to be modified
 * @param {boolean=false} lower Whether all other letters should be lowercased
 * @return {string}
 * @usage
 *   capitalize('fix this string');     // -> 'Fix This String'
 *   capitalize('javaSCrIPT');          // -> 'JavaSCrIPT'
 *   capitalize('javaSCrIPT', true);    // -> 'Javascript'
 */
const capitalize = (str, lower = false) =>
	(lower ? str.toLowerCase() : str).replace(/(?:^|\s|["'([{])+\S/g, match => match.toUpperCase());
;