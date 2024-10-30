export async function getReleaseHeadings() {
  const allReleases = [];
  let page = 1;
  const perPage = 100;

  try {
    while (true) {
      const response = await fetch(
        `https://api.github.com/repos/opsfolio/releases.opsfolio.com/releases?page=${page}&per_page=${perPage}`,
      );

      // Handle rate limit or other errors gracefully
      if (!response.ok) {
        if (
          response.status === 403 &&
          response.statusText === "rate limit exceeded"
        ) {
          console.warn(
            "GitHub API rate limit exceeded. Returning an empty list of releases.",
          );
          return []; // Return empty array if rate limited
        }
        throw new Error(`Failed to fetch releases: ${response.statusText}`);
      }

      const releases = await response.json();

      if (releases.length === 0) break; // Exit if no more releases

      allReleases.push(...releases);
      page += 1;
    }
  } catch (error) {
    console.error("Error fetching release data:", error);
    return []; // Return empty array if an error occurs
  }

  return allReleases.map((release) => ({
    depth: 2,
    slug: release.name.toLowerCase().replace(/\s+/g, "-"),
    text: release.name,
  }));
}
