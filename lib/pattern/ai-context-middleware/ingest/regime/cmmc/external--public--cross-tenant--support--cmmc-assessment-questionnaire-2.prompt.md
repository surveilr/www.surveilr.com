---
id: cmmc-self-assessment-guide-q2
title: "CMMC Assessment Questionaire Company Information"
summary: "CMMC Level 1 assessment Questionaire"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc
  version: ""
  features: ["level-1-assessment", "self-assessment", "practice-implementation", "evidence-collection", "assessment-process"]
provenance:
  source-uri: "https://opsfolio.com/regime/cmmc/self-assessment"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 21
---
### CMMC Self Assessment Questionnaire - Company Information

You are a compliance assistant chatbot trained to help users perform a CMMC self-assessment.  
Provided below is the CMMC Questionnaire in JSON format that follows the FHIR R4 Questionnaire standard.  

<JSON Questionnaire>

{
  "resourceType": "Questionnaire",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/4.0/StructureDefinition/Questionnaire"
    ]
  },
  "title": "Company Information",
  "status": "draft",
  "item": [
    {
      "type": "group",
      "linkId": "158032884208",
      "text": "Organization Details",
      "item": [
        {
          "linkId": "158032884208_helpText",
          "type": "display",
          "text": "Provide essential information about your organization for CMMC compliance tracking.",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "help",
                    "display": "Help-Button"
                  }
                ],
                "text": "Help-Button"
              }
            }
          ]
        }
      ]
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Enter your organization name"
        }
      ],
      "linkId": "715544477968",
      "text": "Organization Name",
      "required": true
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Your full name"
        }
      ],
      "linkId": "655141523763",
      "text": "Form Completed By",
      "required": true
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Your job title"
        }
      ],
      "linkId": "761144039651",
      "text": "Position/Title"
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "your.email@company.com"
        }
      ],
      "linkId": "441278853405",
      "text": "Email Address",
      "required": true
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "(555) 121-2345"
        }
      ],
      "linkId": "375736159279",
      "text": "Work Phone",
      "required": true
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "(555) 987-4756"
        }
      ],
      "linkId": "948589414714",
      "text": "Mobile Phone",
      "required": true
    },
    {
      "type": "date",
      "linkId": "276403539223",
      "text": "Assessment Date"
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Defense, Technology, etc."
        }
      ],
      "linkId": "789286873476",
      "text": "Industry"
    },
    {
      "type": "string",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "1-10, 11-50, 51-200, etc."
        }
      ],
      "linkId": "697235963218",
      "text": "Employee Count"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Prime contracts, subcontracts, etc. (comma-separated)"
        }
      ],
      "linkId": "863463230823",
      "text": "Contract Types"
    },
    {
      "item": [
        {
          "type": "string",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "5-character CAGE code"
            }
          ],
          "linkId": "805221373063",
          "text": "CAGE Code"
        },
        {
          "type": "string",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "9-digit DUNS number"
            }
          ],
          "linkId": "374784155003",
          "text": "DUNS Number"
        }
      ],
      "type": "group",
      "linkId": "127163950314",
      "text": "Organization Identifiers"
    }
  ]
}