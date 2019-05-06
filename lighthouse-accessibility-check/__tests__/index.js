const {
  getValues,
  populateCheckContent,
  checkReport,
  checkFileContent
} = require("../lib");

const data = {
  categories: {
    pwa: {
      score: 0.3
    },
    speed: {
      score: 0.5
    }
  }
};

test("getValues can parse pwa and speed score", () => {
  const result = getValues(data.categories);
  expect(result).toEqual("PWA 30, SPEED 50");
});

test("getValues returns empty when no data was passed", () => {
  const result = getValues();
  expect(result).toEqual("");
});

test("populateCheckContent returns object for check file", () => {
  const report = checkReport;
  const desc = "my description";
  const result = populateCheckContent(desc);
  expect(result.description).toEqual("Lighthouse returned the following scores: " + desc);
  expect(result.component).toEqual("Missing component");
});

test("checkFileContent returns valid content for the check file", () => {
  const result = checkFileContent(data.categories);
  expect(JSON.parse(result).description).toEqual("Lighthouse returned the following scores: PWA 30, SPEED 50");
});
