import { cwd } from "process";
import { execSync } from "child_process";

// This endpoint generates `/pattern/[name]/package.sql` by running the SQL
// generator at Astro build time. This means the SQL executables should be
// available in the Astro build environment or the files generated will contain
// errors

export async function GET({ params, props }) {
  try {
    const output = execSync(props.exec, { encoding: "utf-8" });
    return new Response(output, {
      status: 200,
      headers: {
        "Content-Type": "text/plain",
      },
    });
  } catch (err) {
    return new Response(
      `Error generate SQL for ${params.name} from \`${props.exec}\` in ${cwd()}: ${err.message}`,
      {
        status: 200,
        headers: {
          "Content-Type": "text/plain",
        },
      },
    );
  }
}

// TODO: instead of "hardcoding the `exec` in this file, use Astro ContentCollections to store
// the `exec` value in src/content/patterns/<lang>/[name].md frontmatter.

export async function getStaticPaths() {
  return [{
    params: {
      name: "std",
    },
    props: {
      // assume current directory is the project root (Astro default)
      exec: `deno run -A ./lib/std/package.sql.ts`,
    }
  }, {
    params: {
      name: "fhir-explorer",
    },
    props: {
      // assume current directory is the project root (Astro default)
      exec: `deno run -A ./lib/pattern/fhir-explorer/package.sql.ts`,
    }
  }, {
    params: {
      name: "osquery",
    },
    props: {
      // assume current directory is the project root (Astro default)
      exec: `deno run -A ./lib/pattern/osquery/package.sql.ts`,
    }
  }];
}
