#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run --allow-env

import { XMLParser } from "npm:fast-xml-parser";
import {
  InputData,
  jsonInputForTargetLanguage,
  quicktype,
} from "npm:quicktype-core";

async function quicktypeJSON(
  targetLanguage: string,
  typeName: string,
  jsonString: string,
) {
  const jsonInput = jsonInputForTargetLanguage(targetLanguage);

  // We could add multiple samples for the same desired
  // type, or many sources for other types. Here we're
  // just making one type from one piece of sample JSON.
  await jsonInput.addSource({
    name: typeName,
    samples: [jsonString],
  });

  const inputData = new InputData();
  inputData.addInput(jsonInput);

  return await quicktype({
    inputData,
    lang: targetLanguage,
  });
}

const xmlFile = Deno.readTextFileSync("./xml-to-json-mtm.xml");
const xmlParser = new XMLParser({
  ignoreDeclaration: true,
  preserveOrder: false,
  ignoreAttributes: true,
  attributeNamePrefix: "@",
  removeNSPrefix: true,
});

const xmlJSON = JSON.stringify(await xmlParser.parse(xmlFile), undefined, "  ");

const { lines: xmlJsonParser } = await quicktypeJSON(
  "typescript",
  "XML",
  xmlJSON,
);

console.log(xmlJSON);
Deno.writeTextFileSync(
  "./xml-to-json-mtm-types.ts",
  xmlJsonParser.join("\n"),
);
