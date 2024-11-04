import { assertEquals } from "jsr:@std/assert@1";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";

async function isPortOpen(port: number): Promise<boolean> {
  try {
    const response = await fetch(`http://localhost:${port}`);
    return response.ok;
  } catch {
    return false;
  }
}

Deno.test("web-ui server availability", async (t) => {
  const port = 7777;
  const surveilrProcess = $`surveilr web-ui -p ${port}`.spawn();

  try {
    await new Promise((resolve) => setTimeout(resolve, 3000));

    await t.step("check server is running", async () => {
      const portOpen = await isPortOpen(port);
      assertEquals(
        portOpen,
        true,
        `❌ Error: surveilr server is not running on port ${port}.`,
      );
    });
  } finally {
    surveilrProcess.kill();
    await surveilrProcess;
  }
});

Deno.test("web-ui server using just surveilr", async (t) => {
  const port = 9000;
  const surveilrProcess = $`surveilr`.spawn();

  try {
    await new Promise((resolve) => setTimeout(resolve, 3000));

    await t.step("check server is running", async () => {
      const portOpen = await isPortOpen(port);
      assertEquals(
        portOpen,
        true,
        `❌ Error: surveilr server is not running on port ${port}.`,
      );
    });
  } finally {
    surveilrProcess.kill();
    await surveilrProcess;
  }
});
