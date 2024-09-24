import { execSync } from 'child_process';
import { readdirSync, statSync, constants as fsConsts } from 'fs';
import { join } from 'path';

/**
 * NOTE: this becomes a rather "dangerous" module if it is executed in Hybrid
 * or SSR mode but should be safe in static mode.
 * 
 * This Astro endpoints asset enables dynamic routing and content serving for 
 * files in the `lib` directory of this repo. It walks through the `lib` 
 * directory, identifies files based on proxy configurations, and sets up
 * routes to either display file contents or execute files (e.g., using 
 * Deno or direct execution for .sql.xyz files like .sql.ts).
 * 
 * The walkDirectory function recursively scans the specified directory
 * (in this case, lib) and identifies files that match certain conditions
 * defined by the proxy configurations, returning metadata about these
 * files. 
 * 
 * The getStaticPaths function then uses walkDirectory to gather the matching
 * file paths and generates static paths (routes) for Astro, either to serve
 * the raw content of the file or execute it (e.g., using cat or deno run) and
 * serve the STDOUT of the executed file. 
 * 
 * When a user requests one of these paths via the Astro site URL, the GET
 * function is triggered, executing the appropriate command based on the file
 * type and returning the output as the HTTP response. 
 * 
 * Together, these functions enable dynamic routing, content serving, and file
 * execution based on the structure and contents of the lib directory.
 */

/**
 * Recursively walks through a directory and returns all file paths that match certain proxy configurations.
 *
 * This function is used to traverse a specified directory (`basePath`) and apply proxy configurations (`proxyConf`) 
 * that determine which files should be included based on a custom `acceptFn`. It returns an array of matching file 
 * paths and their associated metadata, including the resolved (absolute) path, relative path, file statistics, and 
 * the proxy configuration.
 *
 * @param {string} basePath - The base directory to search in.
 * @param {string} activePath - The current directory being searched.
 * @param {Array<{ 
*   acceptFn: (relativePath: string, stat: Object) => boolean,  // Function to accept/reject files based on relative path and file stats
*   endpointFn: (relativePath: string, resolvedPath: string) => Array<Object>  // Function to generate endpoint configuration for matched files
* }>} proxyConf - An array of proxy configurations, each with an `acceptFn` to match files and `endpointFn` to generate endpoints.
* @returns {Array<{ 
*   relativePath: string,          // The relative path of the file from the basePath
*   resolvedPath: string,          // The absolute path of the file
*   acceptFn: (relativePath: string, stat: Object) => boolean,  // Function to accept/reject files based on relative path and file stats
*   endpointFn: (relativePath: string, resolvedPath: string) => Array<Object>  // Function to generate endpoint configuration for matched files
*   stat: Object                   // The file stats object returned by `fs.statSync`
* }>} - An array of objects representing files that match the proxy configurations.
*/
function walkDirectory(basePath, activePath, proxyConf) {
    let results = [];
    readdirSync(activePath).forEach(file => {
        const resolvedPath = join(activePath, file);
        const stat = statSync(resolvedPath);

        if (stat && stat.isDirectory()) {
            // Recursively walk directories
            results = results.concat(walkDirectory(basePath, resolvedPath, proxyConf));
        } else {
            for (const pc of proxyConf) {
                if (pc.acceptFn(activePath, stat)) {
                    results.push({ relativePath: resolvedPath.replace(`${basePath}/`, ''), resolvedPath, ...pc, stat });
                    break;
                }
            }
        }
    });
    return results;
}

/**
 * Generates static paths for all files that match the proxy configurations in the `lib` directory.
 * 
 * This function uses the `walkDirectory` function to collect all files from the `lib` directory and apply proxy 
 * configurations to each file. For each accepted file, it uses the appropriate `endpointFn` to create routes 
 * and define how to handle the contents of the file. Some routes are for directly reading files, while others 
 * execute files (e.g., using Deno) when the file ends with `.sql.ts`.
 *
 * @returns {Promise<Array<Object>>} - A promise that resolves to an array of endpoint objects for Astro's static paths.
 */
export async function getStaticPaths() {
    const basePath = 'lib';
    const typicalEndpointsFn = (relativePath, resolvedPath, stat) => {
        const endpoints = [{
            params: { slug: `/${relativePath}` },
            props: {
                exec: `cat ${resolvedPath}`, // we just want the contents of the file
                resolvedPath,
                relativePath
            }
        }];

        // Check if the slug ends with `.sql.*` and add another endpoint which is the generic or Deno execution result of the sql.ts file
        if (/\.sql\..*$/.test(relativePath)) {
            const slug = `/${relativePath.replace(/\.sql\..*$/, '.sql')}`;
            // if the file is executable, capture the output as SQL
            if(stat.mode & fsConsts.S_IXUSR) {
                endpoints.push({
                    params: { slug },
                    props: {
                        exec: resolvedPath, // Execute the file and accept the STDOUT as SQL
                        resolvedPath,
                        relativePath
                    },
                })
            } else if (relativePath.endsWith('.ts')) {
                // if the file is not executable but is a `.sql.ts` file, use Deno to execute it
                // and capture the output as SQL
                endpoints.push({
                    params: { slug },
                    props: {
                        exec: `deno run -A ${resolvedPath}`, // Set the exec command dynamically
                        resolvedPath,
                        relativePath
                    },
                });
            }
        }

        return endpoints;
    };

    const acceptedPaths = walkDirectory(basePath, basePath, [
        { acceptFn: (path) => path.startsWith('lib/assurance'), endpointFn: typicalEndpointsFn },
        { acceptFn: (path) => path.startsWith('lib/pattern') && path.indexOf('pattern/fhir-explorer/ingest') == -1, endpointFn: typicalEndpointsFn },
        { acceptFn: (path) => path.startsWith('lib/service'), endpointFn: typicalEndpointsFn },
        { acceptFn: (path) => path.startsWith('lib/std'), endpointFn: typicalEndpointsFn },
    ]);

    // Map files to params and props for Astro routing
    return acceptedPaths.flatMap(path => path.endpointFn(path.relativePath, path.resolvedPath, path.stat));
}

/**
 * Handles GET requests for specific file paths by executing a command to retrieve file contents or output.
 * 
 * This function executes a specified command (either to read or run a file) based on the `exec` prop. If 
 * the file is to be read (via `cat`) or executed (via `deno run` or as an executable), it captures the 
 * command output and returns it in the HTTP response.
 * 
 * @param {Object} params - The parameters of the request, including the `slug` (URL path of the file).
 * @param {Object} props - The properties of the request, including the execution command (`exec`).
 * @returns {Promise<Response>} - A promise that resolves to a response containing the file output or an error message.
 */
export async function GET({ params, props }) {
    try {
        // Execute the given command to get STDOUT
        const output = execSync(props.exec, { encoding: 'utf-8' });

        return new Response(output, {
            status: 200,
            headers: {
                'Content-Type': 'text/plain',
            },
        });
    } catch (err) {
        return new Response(`Error executing ${params.slug}: ${err.message}`, {
            status: 500,
            headers: {
                'Content-Type': 'text/plain',
            },
        });
    }
}
