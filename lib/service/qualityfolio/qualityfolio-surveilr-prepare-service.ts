#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-net
/**
 * Qualityfolio Surveilr Preparation Script
 * ========================================
 *
 * This script prepares the Qualityfolio data by executing the surveilr ingest command
 * with proper error handling, path validation, and environment integration.
 *
 * Features:
 * - Validates the environment and prerequisites
 * - Manages database backups and cleanup
 * - Executes surveilr ingest and shell commands
 * - Handles configuration through command-line arguments and environment variables
 *
 * Usage:
 * ------
 * Run the script with Deno:
 * 
 * deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-net qualityfolio-surveilr-prepare-service.ts [options]
 *
 * Options:
 * - rssdPath: Path to the SQLite database (default: "src/content/db/qualityfolio/resource-surveillance.sqlite.db")
 * - ingestDir: Directory containing Qualityfolio data to ingest (default: "./qualityfolio")
 * - enable: Set to "true" to enable preparation (can also be set via ENABLE_QUALITYFOLIO_PREPARE environment variable)
 *
 * Environment Variables:
 * - PUBLIC_QUALITYFOLIO_DB: Alternative way to specify the database path
 * - ENABLE_QUALITYFOLIO_PREPARE: Set to "true" to enable preparation
 *
 * Example:
 * --------
 * ENABLE_QUALITYFOLIO_PREPARE=true deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-net qualityfolio-surveilr-prepare-service.ts rssdPath=/path/to/db.sqlite ingestDir=/path/to/qualityfolio/data
 *
 * Note: Ensure that the 'surveilr' command is available in your system's PATH.
 */
import "https://deno.land/x/dotenv@v3.2.2/load.ts";
import { ensureDir } from "https://deno.land/std@0.224.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

/**
 * Interface for command execution result
 */
interface CommandResult {
    success: boolean;
    stdout: string;
    stderr: string;
    code: number;
}

/**
 * CommandExecutor class handles executing shell commands using modern Deno APIs.
 */
class CommandExecutor {
    /**
     * Executes a shell command and returns detailed result information.
     * @param command - Command to be executed along with its arguments.
     * @returns Promise<CommandResult> - Detailed execution result
     */
    static async executeCommand(command: string[]): Promise<CommandResult> {
        console.log(`[QUALITYFOLIO] Executing command: ${command.join(" ")}`);

        try {
            const process = new Deno.Command(command[0], {
                args: command.slice(1),
                stdout: "piped",
                stderr: "piped",
            });

            const { code, stdout, stderr } = await process.output();
            const stdoutText = new TextDecoder().decode(stdout);
            const stderrText = new TextDecoder().decode(stderr);

            if (code === 0) {
                console.log(`[QUALITYFOLIO] Command executed successfully.`);
                if (stdoutText.trim()) {
                    console.log(`[QUALITYFOLIO] Output: ${stdoutText.trim()}`);
                }
                return { success: true, stdout: stdoutText, stderr: stderrText, code };
            } else {
                console.error(`[QUALITYFOLIO] Command failed with exit code: ${code}`);
                if (stderrText.trim()) {
                    console.error(`[QUALITYFOLIO] Error output: ${stderrText.trim()}`);
                }
                return { success: false, stdout: stdoutText, stderr: stderrText, code };
            }
        } catch (error) {
            const errorMessage = error instanceof Error
                ? error.message
                : String(error);
            console.error(
                `[QUALITYFOLIO] Failed to execute command: ${errorMessage}`,
            );
            return {
                success: false,
                stdout: "",
                stderr: errorMessage,
                code: -1,
            };
        }
    }

    /**
     * Checks if a command/binary exists in the system PATH.
     * @param command - The command to check
     * @returns Promise<boolean> - True if command exists
     */
    static async commandExists(command: string): Promise<boolean> {
        try {
            const result = await this.executeCommand(["which", command]);
            return result.success;
        } catch {
            return false;
        }
    }
}

/**
 * FileHandler class for directory validation operations.
 */
class FileHandler {
    /**
     * Validates that a directory exists and is accessible.
     * @param dirPath - Path to validate
     * @returns Promise<boolean> - True if valid
     */
    static async validateDirectory(dirPath: string): Promise<boolean> {
        try {
            const stat = await Deno.stat(dirPath);
            return stat.isDirectory;
        } catch {
            return false;
        }
    }
}

/**
 * DatabaseManager class for handling database backup and cleanup operations.
 */
class DatabaseManager {
    private dbPath: string;

    constructor(dbPath: string) {
        this.dbPath = dbPath;
    }

    /**
     * Checks if the database file exists.
     * @returns Promise<boolean> - True if database file exists
     */
    async databaseExists(): Promise<boolean> {
        try {
            const stat = await Deno.stat(this.dbPath);
            return stat.isFile;
        } catch {
            return false;
        }
    }

    /**
     * Creates a backup of the existing database, keeping only the last backup.
     * @returns Promise<string> - Path to the backup file
     */
    async createBackup(): Promise<string> {
        const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
        const dbDir = path.dirname(this.dbPath);
        const dbName = path.basename(this.dbPath, ".db");
        const backupDir = path.join(dbDir, "backup");
        const backupPath = path.join(backupDir, `${dbName}-${timestamp}.db`);

        try {
            // Check if backup directory exists, create if needed
            await this.ensureBackupDirectory(backupDir);

            // Remove previous backup files to keep only the last one
            await this.cleanupOldBackups(backupDir, dbName);

            // Copy database file to backup location
            await Deno.copyFile(this.dbPath, backupPath);
            console.log(`[QUALITYFOLIO] Database backed up to: ${backupPath}`);

            return backupPath;
        } catch (error) {
            const errorMessage = error instanceof Error
                ? error.message
                : String(error);
            throw new Error(`Failed to create database backup: ${errorMessage}`);
        }
    }

    /**
     * Ensures the backup directory exists, creates it if needed.
     * @param backupDir - Path to the backup directory
     */
    private async ensureBackupDirectory(backupDir: string): Promise<void> {
        try {
            await Deno.stat(backupDir);
            console.log(`[QUALITYFOLIO] Backup directory exists: ${backupDir}`);
        } catch {
            console.log(`[QUALITYFOLIO] Backup directory not found: ${backupDir}`);
            console.log(`[QUALITYFOLIO] Creating backup directory: ${backupDir}`);
            await ensureDir(backupDir);
            console.log(
                `[QUALITYFOLIO] Successfully created backup directory: ${backupDir}`,
            );
        }
    }

    /**
     * Removes old backup files, keeping only the most recent one.
     * @param backupDir - Directory containing backup files
     * @param dbName - Base name of the database
     */
    private async cleanupOldBackups(
        backupDir: string,
        dbName: string,
    ): Promise<void> {
        try {
            // Check if backup directory exists
            try {
                await Deno.stat(backupDir);
            } catch {
                // Directory doesn't exist, nothing to clean up
                return;
            }

            // Read all files in backup directory
            const backupFiles: { name: string; path: string; mtime: Date }[] = [];

            for await (const entry of Deno.readDir(backupDir)) {
                if (
                    entry.isFile && entry.name.startsWith(dbName) &&
                    entry.name.endsWith(".db")
                ) {
                    const filePath = path.join(backupDir, entry.name);
                    const stat = await Deno.stat(filePath);
                    backupFiles.push({
                        name: entry.name,
                        path: filePath,
                        mtime: stat.mtime || new Date(0),
                    });
                }
            }

            // Sort by modification time (newest first) and remove all but keep space for the new one
            backupFiles.sort((a, b) => b.mtime.getTime() - a.mtime.getTime());

            // Remove all existing backup files (we'll create a new one)
            for (const file of backupFiles) {
                await Deno.remove(file.path);
                console.log(`[QUALITYFOLIO] Removed old backup: ${file.name}`);
            }
        } catch (error) {
            // Log warning but don't fail the backup process
            console.warn(
                `[QUALITYFOLIO] Warning: Could not cleanup old backups: ${error instanceof Error ? error.message : error
                }`,
            );
        }
    }

    /**
     * Removes the existing database file.
     */
    async removeDatabase(): Promise<void> {
        try {
            await Deno.remove(this.dbPath);
            console.log(`[QUALITYFOLIO] Removed existing database: ${this.dbPath}`);
        } catch (error) {
            const errorMessage = error instanceof Error
                ? error.message
                : String(error);
            throw new Error(`Failed to remove database file: ${errorMessage}`);
        }
    }

    /**
     * Performs complete database preparation: backup and cleanup.
     */
    async prepareDatabase(): Promise<void> {
        console.log("[QUALITYFOLIO] Preparing database...");

        const dbExists = await this.databaseExists();
        if (dbExists) {
            console.log(`[QUALITYFOLIO] Existing database found: ${this.dbPath}`);

            // Create backup
            await this.createBackup();

            // Remove existing database
            await this.removeDatabase();
        } else {
            console.log(
                `[QUALITYFOLIO] No existing database found at: ${this.dbPath}`,
            );
        }

        // Ensure parent directory exists for new database
        const dbDir = path.dirname(this.dbPath);
        await ensureDir(dbDir);
        console.log(`[QUALITYFOLIO] Ensured database directory exists: ${dbDir}`);

        console.log("[QUALITYFOLIO] Database preparation completed.");
    }
}

/**
 * Main Application Class for Qualityfolio Surveilr preparation.
 */
class QualityfolioSurveilrApp {
    private ingestDir: string;
    private dbPath: string;
    private ingestCommand: string[];
    private databaseManager: DatabaseManager;

    constructor(
        ingestDir: string,
        dbPath: string,
        ingestCommand: string[],
    ) {
        this.ingestDir = ingestDir;
        this.dbPath = dbPath;
        this.ingestCommand = ingestCommand;
        this.databaseManager = new DatabaseManager(dbPath);
    }

    /**
     * Validates the environment and prerequisites.
     */
    private async validateEnvironment(): Promise<void> {
        console.log("[QUALITYFOLIO] Validating environment...");

        // Check if surveilr command exists
        const surveilrExists = await CommandExecutor.commandExists("surveilr");
        if (!surveilrExists) {
            throw new Error(
                "surveilr command not found. Please install surveilr: https://www.surveilr.com/docs/core/installation/",
            );
        }

        // Check if ingest directory exists, create if needed
        await this.ensureIngestDirectory();

        console.log(
            "[QUALITYFOLIO] Environment validation completed successfully.",
        );
    }

    /**
     * Ensures the qualityfolio ingest directory exists, creates it if needed.
     */
    private async ensureIngestDirectory(): Promise<void> {
        const ingestDirValid = await FileHandler.validateDirectory(this.ingestDir);
        if (!ingestDirValid) {
            console.log(
                `[QUALITYFOLIO] Qualityfolio folder not found: ${this.ingestDir}`,
            );
            console.log(
                `[QUALITYFOLIO] Creating qualityfolio directory: ${this.ingestDir}`,
            );

            try {
                await ensureDir(this.ingestDir);
                console.log(
                    `[QUALITYFOLIO] Successfully created qualityfolio directory: ${this.ingestDir}`,
                );
            } catch (error) {
                const errorMessage = error instanceof Error
                    ? error.message
                    : String(error);
                throw new Error(
                    `Failed to create qualityfolio directory ${this.ingestDir}: ${errorMessage}`,
                );
            }
        } else {
            console.log(
                `[QUALITYFOLIO] Qualityfolio directory exists: ${this.ingestDir}`,
            );
        }
    }

    /**
     * Runs the application workflow.
     */
    async run(): Promise<void> {
        try {
            console.log(
                "[QUALITYFOLIO] Starting qualityfolio surveilr preparation...",
            );

            // Step 1: Validate environment (includes folder check)
            await this.validateEnvironment();

            // Step 2: Prepare database (backup and cleanup)
            await this.databaseManager.prepareDatabase();

            // Step 3: Execute the ingest command
            console.log("[QUALITYFOLIO] Executing surveilr ingest command...");
            const ingestResult = await CommandExecutor.executeCommand(
                this.ingestCommand,
            );

            if (!ingestResult.success) {
                throw new Error(
                    `Surveilr ingest command failed with exit code ${ingestResult.code}: ${ingestResult.stderr}`,
                );
            }

            // Step 4: Execute the surveilr shell command for package.sql
            console.log(
                "[QUALITYFOLIO] Executing surveilr shell command for package.sql...",
            );
            console.log(
                "[QUALITYFOLIO] Loading qualityfolio package from: https://surveilr.com/lib/service/qualityfolio/package.sql",
            );
            const shellCommand = [
                "surveilr",
                "shell",
                "-d",
                this.dbPath,
                "https://surveilr.com/lib/service/qualityfolio/package.sql",
            ];

            const shellResult = await CommandExecutor.executeCommand(shellCommand);

            if (!shellResult.success) {
                throw new Error(
                    `Surveilr shell command failed with exit code ${shellResult.code}: ${shellResult.stderr}`,
                );
            }

            console.log(
                "[QUALITYFOLIO] Successfully loaded qualityfolio package.sql",
            );

            console.log(
                "[QUALITYFOLIO] Qualityfolio surveilr preparation completed successfully!",
            );
        } catch (error: unknown) {
            const errorMessage = error instanceof Error
                ? error.message
                : String(error);
            console.error(`[QUALITYFOLIO] Error: ${errorMessage}`);
            Deno.exit(1);
        }
    }
}

/**
 * Configuration interface for the application
 */
interface QualityfolioConfig {
    rssdPath: string;
    ingestDir: string;
    enablePrepare: boolean;
}

/**
 * Parses command line arguments into a configuration object.
 */
function parseArguments(): QualityfolioConfig {
    const args = Object.fromEntries(
        Deno.args.map((arg) => {
            const [key, value] = arg.split("=");
            return [key, value];
        }),
    );

    // Get database path from qualityfolio-specific environment or arguments
    const envDbPath = Deno.env.get("PUBLIC_QUALITYFOLIO_DB");

    const rssdPath = args.rssdPath ||
        envDbPath ||
        "src/content/db/qualityfolio/resource-surveillance.sqlite.db";

    // Set ingest directory - this should point to the actual qualityfolio data directory
    const ingestDir = args.ingestDir || "./qualityfolio";

    // Check if preparation is enabled
    const enablePrepare =
        Deno.env.get("ENABLE_QUALITYFOLIO_PREPARE") === "true" ||
        args.enable === "true";

    return {
        rssdPath,
        ingestDir,
        enablePrepare,
    };
}

/**
 * Main execution block
 */
if (import.meta.main) {
    try {
        console.log(
            "[QUALITYFOLIO] Starting qualityfolio-surveilr-prepare script...",
        );

        const config = parseArguments();

        console.log("[QUALITYFOLIO] Configuration:");
        console.log(`  - Database path: ${config.rssdPath}`);
        console.log(`  - Ingest directory: ${config.ingestDir}`);
        console.log(`  - Preparation enabled: ${config.enablePrepare}`);

        if (!config.enablePrepare) {
            console.log(
                "[QUALITYFOLIO] Preparation is disabled. Set ENABLE_QUALITYFOLIO_PREPARE=true to enable.",
            );
            Deno.exit(0);
        }

        // Construct the surveilr ingest command
        const ingestCommand = [
            "surveilr",
            "ingest",
            "files",
            "-d",
            config.rssdPath,
            "-r",
            config.ingestDir,
        ];

        // Create and run the application
        const app = new QualityfolioSurveilrApp(
            config.ingestDir,
            config.rssdPath,
            ingestCommand,
        );

        await app.run();
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        console.error(`[QUALITYFOLIO] Fatal error: ${errorMessage}`);
        Deno.exit(1);
    }
}
