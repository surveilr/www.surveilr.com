import React, { useEffect, useState } from "react";
import { marked } from "marked";

// Define a type for a GitHub release object
interface Release {
  id: number;
  name: string;
  body: string;
  html_url: string;
}

const ReleasesList: React.FC = () => {
  const [allReleases, setAllReleases] = useState<Release[]>([]);
  const [rateLimitExceeded, setRateLimitExceeded] = useState(false);

  const fetchReleases = async () => {
    const perPage = 100;
    let page = 1;
    let releases: Release[] = [];

    try {
      while (true) {
        const response = await fetch(
          `https://api.github.com/repos/opsfolio/releases.opsfolio.com/releases?page=${page}&per_page=${perPage}`,
        );

        if (!response.ok) {
          if (
            response.status === 403 &&
            response.statusText === "rate limit exceeded"
          ) {
            setRateLimitExceeded(true);
            console.warn("GitHub API rate limit exceeded.");
            break;
          }
          throw new Error(`Failed to fetch releases: ${response.statusText}`);
        }

        const data: Release[] = await response.json();
        if (data.length === 0) break;

        releases = [...releases, ...data];
        page += 1;
      }
    } catch (error) {
      console.error("Error fetching release data:", error);
      setRateLimitExceeded(true);
    }

    setAllReleases(releases);
  };

  useEffect(() => {
    fetchReleases();
  }, []);

  return (
    <>
      {rateLimitExceeded ? (
        <p className="mt-4 font-semibold text-red-600">
          GitHub API rate limit exceeded. Please try again later.
        </p>
      ) : (
        <ul>
          {allReleases.map((release) => (
            <li key={release.id}>
              <h2 id={release.name.toLowerCase().replace(/\s+/g, "-")}>
                {release.name}
              </h2>
              <div
                dangerouslySetInnerHTML={{ __html: marked(release.body) }}
              ></div>
              <a
                href={release.html_url}
                target="_blank"
                rel="noopener noreferrer"
              >
                View Release
              </a>
            </li>
          ))}
        </ul>
      )}
    </>
  );
};

export default ReleasesList;
