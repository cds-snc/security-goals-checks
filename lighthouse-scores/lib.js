const path = require("path");
const fs = require("fs");
const lighthouse = require("lighthouse");
const chromeLauncher = require("chrome-launcher");
const BrowserFetcher = require("puppeteer/lib/BrowserFetcher");
const uuidv4 = require('uuid/v4');

/* IMPORTANT ensure the correct node modules path here */
const browserFetcher = new BrowserFetcher(
  path.join(__dirname, "node_modules/puppeteer/")
);

const packageJson = require("puppeteer/package.json");
const revision = packageJson.puppeteer.chromium_revision;
const revisionInfo = browserFetcher.revisionInfo(revision);

let opts = {
  lighthouseFlags: {
    output: "json",
    disableDeviceEmulation: false,
    port: "",
    output: "json",
    saveAssets: false
  },
  chromeFlags: ["--headless", "--no-sandbox", "--disable-gpu"]
};

const writeCheckFile = (path = "", content = "") => {

  const id = uuidv4();
  fs.writeFile(`${path}${id}.json`, content, function(err) {
    if (err) {
      return console.log(err);
    }

    console.log("The file was saved!");
  });
};

const getValues = (data = {}) => {
  let report = [];
  Object.keys(data).forEach(function(key) {
    let score = data[key].score;
    score = Math.round(score * 100);
    report.push(`${key.toUpperCase()} ${score}`);
  });

  return report.join(", ");
};

const checkReport = {
  origin: "",
  satisfies: [],
  component: "Source code",
  references: "",
  timestamp: new Date().toISOString(),
  passed: true,
  description: "",
  release: ""
};

const populateCheckContent = description => {
  const ORIGIN = process.env.ORIGIN ? process.env.ORIGIN : "Missing origin";

  const SATISFIES = process.env.SATISFIES
    ? process.env.SATISFIES.split(",")
    : "";

  const COMPONENT = process.env.COMPONENT
    ? process.env.COMPONENT
    : "Missing component";

  const URL = process.env.URL ? process.env.URL : "Missing Url";

  const RELEASE = process.env.RELEASE ? process.env.RELEASE : null;

  return {
    ...checkReport,
    ...{
      description: `Lighthouse returned the following scores: ${description}`,
      origin: ORIGIN,
      satisfies: SATISFIES,
      component: COMPONENT,
      references: URL,
      release: RELEASE
    }
  };
};

const checkFileContent = data => {
  return JSON.stringify(populateCheckContent(getValues(data)));
};

const scanURL = async (url = process.env.URL) => {
  console.log(`Launching chromeLauncher... ${url}`);
  console.log(`chromePath: ${revisionInfo.executablePath}`);

  const chrome = await chromeLauncher.launch({
    chromeFlags: opts.chromeFlags,
    chromePath: revisionInfo.executablePath
  });

  opts.lighthouseFlags.port = chrome.port;

  console.log(`Launching lighthouse on port:${chrome.port}`);

  const res = await lighthouse(url, opts.lighthouseFlags);
  await chrome.kill();

  if (res && res.report) {
    return JSON.parse(res.report);
  } else {
    throw new Error("failed to pull lighthouse report");
  }
};

module.exports.getValues = getValues;
module.exports.populateCheckContent = populateCheckContent;
module.exports.checkFileContent = checkFileContent;
module.exports.checkReport = checkReport;
module.exports.scanURL = scanURL;
module.exports.writeCheckFile = writeCheckFile;
