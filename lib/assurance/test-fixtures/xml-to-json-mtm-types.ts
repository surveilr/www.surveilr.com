// To parse this data:
//
//   import { Convert, XML } from "./file";
//
//   const xML = Convert.toXML(json);
//
// These functions will throw an error if the JSON doesn't
// match the expected interface, even if the JSON is valid.

export interface XML {
  ThreatModel: ThreatModel;
}

export interface ThreatModel {
  DrawingSurfaceList: DrawingSurfaceList;
  MetaInformation: MetaInformation;
  Notes: string;
  ThreatGenerationEnabled: boolean;
  Validations: string;
  Version: number;
  Profile: Profile;
}

export interface DrawingSurfaceList {
  DrawingSurfaceModel: DrawingSurfaceModel;
}

export interface DrawingSurfaceModel {
  GenericTypeId: string;
  Guid: string;
  Properties: DrawingSurfaceModelProperties;
  TypeId: string;
  Borders: Borders;
  Header: string;
  Lines: Lines;
  Zoom: number;
}

export interface Borders {
  KeyValueOfguidanyType: BordersKeyValueOfguidanyType[];
}

export interface BordersKeyValueOfguidanyType {
  Key: string;
  Value: PurpleValue;
}

export interface PurpleValue {
  GenericTypeId: string;
  Guid: string;
  Properties: PurpleProperties;
  TypeId: string;
  Height: number;
  Left: number;
  StrokeDashArray: string;
  StrokeThickness: number;
  Top: number;
  Width: number;
}

export interface PurpleProperties {
  anyType: PurpleAnyType[];
}

export interface PurpleAnyType {
  DisplayName: string;
  Name: string;
  Value: boolean | FluffyValue | number | string;
  SelectedIndex?: number;
}

export interface FluffyValue {
  string: string[];
}

export interface Lines {
  KeyValueOfguidanyType: LinesKeyValueOfguidanyType[];
}

export interface LinesKeyValueOfguidanyType {
  Key: string;
  Value: TentacledValue;
}

export interface TentacledValue {
  GenericTypeId: string;
  Guid: string;
  Properties: FluffyProperties;
  TypeId: string;
  HandleX: number;
  HandleY: number;
  PortSource: string;
  PortTarget: string;
  SourceGuid: string;
  SourceX: number;
  SourceY: number;
  TargetGuid: string;
  TargetX: number;
  TargetY: number;
}

export interface FluffyProperties {
  anyType: FluffyAnyType[];
}

export interface FluffyAnyType {
  DisplayName: string;
  Name: string;
  Value: boolean | StickyValue | ValueEnum | number;
  SelectedIndex?: number;
}

export interface StickyValue {
  string: string[] | string;
}

export enum ValueEnum {
  Empty = "",
  GenericDataFlow = "Generic Data\n                  Flow",
  HTTPS = "HTTPS",
}

export interface DrawingSurfaceModelProperties {
  anyType: TentacledAnyType[];
}

export interface TentacledAnyType {
  DisplayName: string;
  Name: string;
  Value: string;
}

export interface MetaInformation {
  Assumptions: string;
  Contributors: string;
  ExternalDependencies: string;
  HighLevelSystemDescription: string;
  Owner: string;
  Reviewer: string;
  ThreatModelName: string;
}

export interface Profile {
  PromptedKb: string;
}

// Converts JSON strings to/from your types
// and asserts the results of JSON.parse at runtime
export class Convert {
  public static toXML(json: string): XML {
    return cast(JSON.parse(json), r("XML"));
  }

  public static xMLToJson(value: XML): string {
    return JSON.stringify(uncast(value, r("XML")), null, 2);
  }
}

function invalidValue(typ: any, val: any, key: any, parent: any = ""): never {
  const prettyTyp = prettyTypeName(typ);
  const parentText = parent ? ` on ${parent}` : "";
  const keyText = key ? ` for key "${key}"` : "";
  throw Error(
    `Invalid value${keyText}${parentText}. Expected ${prettyTyp} but got ${
      JSON.stringify(val)
    }`,
  );
}

function prettyTypeName(typ: any): string {
  if (Array.isArray(typ)) {
    if (typ.length === 2 && typ[0] === undefined) {
      return `an optional ${prettyTypeName(typ[1])}`;
    } else {
      return `one of [${
        typ.map((a) => {
          return prettyTypeName(a);
        }).join(", ")
      }]`;
    }
  } else if (typeof typ === "object" && typ.literal !== undefined) {
    return typ.literal;
  } else {
    return typeof typ;
  }
}

function jsonToJSProps(typ: any): any {
  if (typ.jsonToJS === undefined) {
    const map: any = {};
    typ.props.forEach((p: any) => map[p.json] = { key: p.js, typ: p.typ });
    typ.jsonToJS = map;
  }
  return typ.jsonToJS;
}

function jsToJSONProps(typ: any): any {
  if (typ.jsToJSON === undefined) {
    const map: any = {};
    typ.props.forEach((p: any) => map[p.js] = { key: p.json, typ: p.typ });
    typ.jsToJSON = map;
  }
  return typ.jsToJSON;
}

function transform(
  val: any,
  typ: any,
  getProps: any,
  key: any = "",
  parent: any = "",
): any {
  function transformPrimitive(typ: string, val: any): any {
    if (typeof typ === typeof val) return val;
    return invalidValue(typ, val, key, parent);
  }

  function transformUnion(typs: any[], val: any): any {
    // val must validate against one typ in typs
    const l = typs.length;
    for (let i = 0; i < l; i++) {
      const typ = typs[i];
      try {
        return transform(val, typ, getProps);
      } catch (_) {}
    }
    return invalidValue(typs, val, key, parent);
  }

  function transformEnum(cases: string[], val: any): any {
    if (cases.indexOf(val) !== -1) return val;
    return invalidValue(
      cases.map((a) => {
        return l(a);
      }),
      val,
      key,
      parent,
    );
  }

  function transformArray(typ: any, val: any): any {
    // val must be an array with no invalid elements
    if (!Array.isArray(val)) return invalidValue(l("array"), val, key, parent);
    return val.map((el) => transform(el, typ, getProps));
  }

  function transformDate(val: any): any {
    if (val === null) {
      return null;
    }
    const d = new Date(val);
    if (isNaN(d.valueOf())) {
      return invalidValue(l("Date"), val, key, parent);
    }
    return d;
  }

  function transformObject(
    props: { [k: string]: any },
    additional: any,
    val: any,
  ): any {
    if (val === null || typeof val !== "object" || Array.isArray(val)) {
      return invalidValue(l(ref || "object"), val, key, parent);
    }
    const result: any = {};
    Object.getOwnPropertyNames(props).forEach((key) => {
      const prop = props[key];
      const v = Object.prototype.hasOwnProperty.call(val, key)
        ? val[key]
        : undefined;
      result[prop.key] = transform(v, prop.typ, getProps, key, ref);
    });
    Object.getOwnPropertyNames(val).forEach((key) => {
      if (!Object.prototype.hasOwnProperty.call(props, key)) {
        result[key] = transform(val[key], additional, getProps, key, ref);
      }
    });
    return result;
  }

  if (typ === "any") return val;
  if (typ === null) {
    if (val === null) return val;
    return invalidValue(typ, val, key, parent);
  }
  if (typ === false) return invalidValue(typ, val, key, parent);
  let ref: any = undefined;
  while (typeof typ === "object" && typ.ref !== undefined) {
    ref = typ.ref;
    typ = typeMap[typ.ref];
  }
  if (Array.isArray(typ)) return transformEnum(typ, val);
  if (typeof typ === "object") {
    return typ.hasOwnProperty("unionMembers")
      ? transformUnion(typ.unionMembers, val)
      : typ.hasOwnProperty("arrayItems")
      ? transformArray(typ.arrayItems, val)
      : typ.hasOwnProperty("props")
      ? transformObject(getProps(typ), typ.additional, val)
      : invalidValue(typ, val, key, parent);
  }
  // Numbers can be parsed by Date but shouldn't be.
  if (typ === Date && typeof val !== "number") return transformDate(val);
  return transformPrimitive(typ, val);
}

function cast<T>(val: any, typ: any): T {
  return transform(val, typ, jsonToJSProps);
}

function uncast<T>(val: T, typ: any): any {
  return transform(val, typ, jsToJSONProps);
}

function l(typ: any) {
  return { literal: typ };
}

function a(typ: any) {
  return { arrayItems: typ };
}

function u(...typs: any[]) {
  return { unionMembers: typs };
}

function o(props: any[], additional: any) {
  return { props, additional };
}

function m(additional: any) {
  return { props: [], additional };
}

function r(name: string) {
  return { ref: name };
}

const typeMap: any = {
  "XML": o([
    { json: "ThreatModel", js: "ThreatModel", typ: r("ThreatModel") },
  ], false),
  "ThreatModel": o([
    {
      json: "DrawingSurfaceList",
      js: "DrawingSurfaceList",
      typ: r("DrawingSurfaceList"),
    },
    {
      json: "MetaInformation",
      js: "MetaInformation",
      typ: r("MetaInformation"),
    },
    { json: "Notes", js: "Notes", typ: "" },
    {
      json: "ThreatGenerationEnabled",
      js: "ThreatGenerationEnabled",
      typ: true,
    },
    { json: "Validations", js: "Validations", typ: "" },
    { json: "Version", js: "Version", typ: 3.14 },
    { json: "Profile", js: "Profile", typ: r("Profile") },
  ], false),
  "DrawingSurfaceList": o([
    {
      json: "DrawingSurfaceModel",
      js: "DrawingSurfaceModel",
      typ: r("DrawingSurfaceModel"),
    },
  ], false),
  "DrawingSurfaceModel": o([
    { json: "GenericTypeId", js: "GenericTypeId", typ: "" },
    { json: "Guid", js: "Guid", typ: "" },
    {
      json: "Properties",
      js: "Properties",
      typ: r("DrawingSurfaceModelProperties"),
    },
    { json: "TypeId", js: "TypeId", typ: "" },
    { json: "Borders", js: "Borders", typ: r("Borders") },
    { json: "Header", js: "Header", typ: "" },
    { json: "Lines", js: "Lines", typ: r("Lines") },
    { json: "Zoom", js: "Zoom", typ: 0 },
  ], false),
  "Borders": o([
    {
      json: "KeyValueOfguidanyType",
      js: "KeyValueOfguidanyType",
      typ: a(r("BordersKeyValueOfguidanyType")),
    },
  ], false),
  "BordersKeyValueOfguidanyType": o([
    { json: "Key", js: "Key", typ: "" },
    { json: "Value", js: "Value", typ: r("PurpleValue") },
  ], false),
  "PurpleValue": o([
    { json: "GenericTypeId", js: "GenericTypeId", typ: "" },
    { json: "Guid", js: "Guid", typ: "" },
    { json: "Properties", js: "Properties", typ: r("PurpleProperties") },
    { json: "TypeId", js: "TypeId", typ: "" },
    { json: "Height", js: "Height", typ: 0 },
    { json: "Left", js: "Left", typ: 0 },
    { json: "StrokeDashArray", js: "StrokeDashArray", typ: "" },
    { json: "StrokeThickness", js: "StrokeThickness", typ: 0 },
    { json: "Top", js: "Top", typ: 0 },
    { json: "Width", js: "Width", typ: 0 },
  ], false),
  "PurpleProperties": o([
    { json: "anyType", js: "anyType", typ: a(r("PurpleAnyType")) },
  ], false),
  "PurpleAnyType": o([
    { json: "DisplayName", js: "DisplayName", typ: "" },
    { json: "Name", js: "Name", typ: "" },
    { json: "Value", js: "Value", typ: u(true, r("FluffyValue"), 0, "") },
    { json: "SelectedIndex", js: "SelectedIndex", typ: u(undefined, 0) },
  ], false),
  "FluffyValue": o([
    { json: "string", js: "string", typ: a("") },
  ], false),
  "Lines": o([
    {
      json: "KeyValueOfguidanyType",
      js: "KeyValueOfguidanyType",
      typ: a(r("LinesKeyValueOfguidanyType")),
    },
  ], false),
  "LinesKeyValueOfguidanyType": o([
    { json: "Key", js: "Key", typ: "" },
    { json: "Value", js: "Value", typ: r("TentacledValue") },
  ], false),
  "TentacledValue": o([
    { json: "GenericTypeId", js: "GenericTypeId", typ: "" },
    { json: "Guid", js: "Guid", typ: "" },
    { json: "Properties", js: "Properties", typ: r("FluffyProperties") },
    { json: "TypeId", js: "TypeId", typ: "" },
    { json: "HandleX", js: "HandleX", typ: 0 },
    { json: "HandleY", js: "HandleY", typ: 0 },
    { json: "PortSource", js: "PortSource", typ: "" },
    { json: "PortTarget", js: "PortTarget", typ: "" },
    { json: "SourceGuid", js: "SourceGuid", typ: "" },
    { json: "SourceX", js: "SourceX", typ: 0 },
    { json: "SourceY", js: "SourceY", typ: 0 },
    { json: "TargetGuid", js: "TargetGuid", typ: "" },
    { json: "TargetX", js: "TargetX", typ: 0 },
    { json: "TargetY", js: "TargetY", typ: 0 },
  ], false),
  "FluffyProperties": o([
    { json: "anyType", js: "anyType", typ: a(r("FluffyAnyType")) },
  ], false),
  "FluffyAnyType": o([
    { json: "DisplayName", js: "DisplayName", typ: "" },
    { json: "Name", js: "Name", typ: "" },
    {
      json: "Value",
      js: "Value",
      typ: u(true, r("StickyValue"), r("ValueEnum"), 0),
    },
    { json: "SelectedIndex", js: "SelectedIndex", typ: u(undefined, 0) },
  ], false),
  "StickyValue": o([
    { json: "string", js: "string", typ: u(a(""), "") },
  ], false),
  "DrawingSurfaceModelProperties": o([
    { json: "anyType", js: "anyType", typ: a(r("TentacledAnyType")) },
  ], false),
  "TentacledAnyType": o([
    { json: "DisplayName", js: "DisplayName", typ: "" },
    { json: "Name", js: "Name", typ: "" },
    { json: "Value", js: "Value", typ: "" },
  ], false),
  "MetaInformation": o([
    { json: "Assumptions", js: "Assumptions", typ: "" },
    { json: "Contributors", js: "Contributors", typ: "" },
    { json: "ExternalDependencies", js: "ExternalDependencies", typ: "" },
    {
      json: "HighLevelSystemDescription",
      js: "HighLevelSystemDescription",
      typ: "",
    },
    { json: "Owner", js: "Owner", typ: "" },
    { json: "Reviewer", js: "Reviewer", typ: "" },
    { json: "ThreatModelName", js: "ThreatModelName", typ: "" },
  ], false),
  "Profile": o([
    { json: "PromptedKb", js: "PromptedKb", typ: "" },
  ], false),
  "ValueEnum": [
    "",
    "Generic Data\n                  Flow",
    "HTTPS",
  ],
};
