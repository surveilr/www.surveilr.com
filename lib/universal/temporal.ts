export function timeSince(date: Date): string {
  const milliseconds = new Date().getTime() - date.getTime();
  const intervals = [
    { label: "years", seconds: 31536000 },
    { label: "months", seconds: 2592000 },
    { label: "days", seconds: 86400 },
    { label: "hours", seconds: 3600 },
    { label: "minutes", seconds: 60 },
    { label: "seconds", seconds: 1 },
    { label: "milliseconds", seconds: 1 / 1000 },
  ];

  for (const interval of intervals) {
    const count = Math.floor(milliseconds / (interval.seconds * 1000));
    if (count >= 1) {
      return `${count} ${interval.label}`;
    }
  }

  return `${milliseconds} milliseconds`;
}
