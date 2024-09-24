import { exec, execSync } from 'child_process';
import { readdirSync, statSync } from 'fs';
import { join, resolve } from 'path';

const BASE_DIR = './lib'; // Base directory to search for files

// Define the directories we want to match using regular expressions
const PROXY_FILES = [
    new RegExp('lib/assurance'),
    new RegExp('lib/pattern'),
    new RegExp('lib/service'),
    new RegExp('lib/std'),
];

// Utility function to recursively get all file paths from the base directory and match with regex
function walkDirectory(dir, regexList) {
    let results = [];
    const list = readdirSync(dir);

    list.forEach(file => {
        const filePath = join(dir, file);
        const stat = statSync(filePath);

        if (stat && stat.isDirectory()) {
            // Recursively walk directories
            results = results.concat(walkDirectory(filePath, regexList));
        } else {
            // Relative file path to BASE_DIR
            const relativePath = filePath.replace(`${BASE_DIR}/`, '');

            // Check if the file matches any of the provided regular expressions
            if (regexList.some(regex => regex.test(relativePath))) {
                results.push(relativePath);
            }
        }
    });

    return results;
}

export async function getStaticPaths() {
    // Get all file paths that match the regex in PROXY_FILES
    const files = walkDirectory(BASE_DIR, PROXY_FILES);

    // Map files to params and props for Astro routing
    const endpoints = files.flatMap(file => {
        const resolvedPath = resolve(BASE_DIR, file);
        const endpoints = [{
            params: {
                slug: `/${file}`, // Generate slug without `.ts` if it's `.sql.ts`
            },
            props: {
                exec: `cat ${resolvedPath}`, // Set the exec command dynamically
            }
        }];

        // Check if the file ends with `.sql.ts` and add another endpoint which is the Deno execution result of the sql.ts file
        if (file.endsWith('.sql.ts')) {
            endpoints.push({
                params: {
                    slug: `/${file.replace(/.ts$/, '')}`, // Generate slug without `.ts` if it's `.sql.ts`
                },
                props: {
                    exec: `deno run -A ${resolvedPath}`, // Set the exec command dynamically
                },
            })
        }

        return endpoints;
    });

    return endpoints;
}

export async function GET({ params, props }) {
    try {
        // Execute the given command to get STDOUT
        const filePath = params.slug;
        const output = execSync(props.exec, { encoding: 'utf-8' });

        return new Response(output, {
            status: 200,
            headers: {
                'Content-Type': 'text/plain',
            },
        });
    } catch (err) {
        return new Response(`Error reading file ${filePath}: ${err.message}`, {
            status: 500,
            headers: {
                'Content-Type': 'text/plain',
            },
        });
    }
}
