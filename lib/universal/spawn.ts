export type FlexibleText =
  | string
  | { readonly fileSystemPath: string | string[] }
  | Iterable<string>
  | ArrayLike<string>
  | Generator<string>;

export type FlexibleTextSupplierSync =
  | FlexibleText
  | (() => FlexibleText);

/**
 * Accept a flexible source of text such as a string, a file system path, an
 * array of strings or a TypeScript Generator and convert them to a string
 * array.
 * @param supplier flexible source of text
 * @returns a resolved string array of text
 */
export const flexibleTextListSync = (
  supplier: FlexibleTextSupplierSync,
  options?: {
    readTextFileSync?: (...fsPath: string[]) => string[];
  },
): string[] => {
  const readTextFileSync = options?.readTextFileSync ??
    ((...fsPath) => fsPath.map((fsp) => Deno.readTextFileSync(fsp)));

  return typeof supplier === "function"
    ? flexibleTextListSync(supplier())
    : typeof supplier === "string"
    ? [supplier]
    : (typeof supplier === "object" && "fileSystemPath" in supplier
      ? Array.isArray(supplier.fileSystemPath)
        ? readTextFileSync(...supplier.fileSystemPath)
        : readTextFileSync(supplier.fileSystemPath)
      : Array.from(supplier));
};

export const textFromSupplierSync = (
  supplier: Uint8Array | FlexibleTextSupplierSync,
) => {
  if (supplier instanceof Uint8Array) {
    return new TextDecoder().decode(supplier);
  } else {
    return flexibleTextListSync(supplier).join("\n");
  }
};

/**
 * Executes a command with optional environment variables and input data.
 * @param command - The command to execute, specified as an array where the first element is the command and the rest are arguments.
 * @param env - Optional environment variables to set for the command.
 * @param stdInSupplier - Optional string input to pass to the command via stdin.
 * @returns A promise that returns the spawned results
 */
export async function spawnedResult(
  command: string[],
  env?: Record<string, string>,
  stdInSupplier?: Uint8Array | FlexibleTextSupplierSync,
) {
  const cmd = new Deno.Command(command[0], {
    args: command.slice(1),
    env,
    stdin: stdInSupplier ? "piped" : undefined,
    stdout: "piped",
    stderr: "piped",
  });
  const childProcess = cmd.spawn();

  if (stdInSupplier) {
    const stdInPipe = childProcess.stdin.getWriter();
    if (stdInSupplier instanceof Uint8Array) {
      stdInPipe.write(stdInSupplier);
    } else {
      const te = new TextEncoder();
      for (const SQL of flexibleTextListSync(stdInSupplier)) {
        stdInPipe.write(te.encode(SQL));
      }
    }
    stdInPipe.close();
  }

  const { success, code, stdout: stdoutRaw, stderr: stderrRaw } =
    await childProcess
      .output();

  return {
    childProcess,
    command,
    code,
    success,
    stdoutRaw,
    stderrRaw,
    stdout: () => new TextDecoder().decode(stdoutRaw),
    stderr: () => new TextDecoder().decode(stderrRaw),
  };
}
