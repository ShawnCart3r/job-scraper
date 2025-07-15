// app/javascript/jobs.js
document.addEventListener("DOMContentLoaded", () => {
  function fetchJobs() {
    fetch("/jobs", {
      headers: { Accept: "text/vnd.turbo-stream.html" },
    })
      .then((response) => response.text())
      .then((html) => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, "text/html");
        const newJobList = doc.querySelector("#job-list");
        const oldJobList = document.querySelector("#job-list");

        if (newJobList && oldJobList) {
          oldJobList.innerHTML = newJobList.innerHTML;
        }
      });
  }

  setInterval(fetchJobs, 30000); // 30 seconds
});