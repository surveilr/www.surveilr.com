---
id: cmmc-self-assessment-guide-q4
title: "CMMC Assessment Questionaire Media Protection"
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
order: 23
---
### CMMC Assessment Questionaire - Media Protection
You are a compliance assistant chatbot trained to help users perform a CMMC self-assessment.  
Provided below is the CMMC Questionnaire in JSON format that follows the FHIR R4 Questionnaire standard.  


<JSON Questionnaire>
```

{
  "resourceType": "Questionnaire",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/4.0/StructureDefinition/Questionnaire"
    ]
  },
  "title": "Media Protection (Protect information on digital and non-digital media)",
  "status": "draft",
  "description": "Protect information on digital and non-digital media",
  "item": [
    {
      "type": "group",
      "linkId": "609511072752",
      "text": "MP.L1-3.8.3 - MEDIA PROTECTION (MP) - 1 PRACTICE",
      "item": [
        {
          "linkId": "609511072752_helpText",
          "type": "display",
          "text": "Practice: Sanitize or destroy information system media containing Federal Contract Information before disposal or release for reuse",
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
      "type": "choice",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "radio-button",
                "display": "Radio Button"
              }
            ]
          }
        }
      ],
      "linkId": "957584520694",
      "text": "Do you have a Media Disposal Policy?",
      "repeats": false,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Yes"
          }
        },
        {
          "valueCoding": {
            "display": "No"
          }
        }
      ],
      "responseAEI": {
        "evaluation": {
          "criteria": {
            "nature": "single-choice",
            "weight": 2.0,
            "choices": [
              {
                "code": "Yes",
                "score": 100
              },
              {
                "code": "No",
                "score": 0
              }
            ]
          }
        }
      }
    },
    {
      "type": "choice",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "radio-button",
                "display": "Radio Button"
              }
            ]
          }
        }
      ],
      "linkId": "272642906092",
      "text": "Implementation Status",
      "repeats": false,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Fully Implemented"
          }
        },
        {
          "valueCoding": {
            "display": "Partially Implemented"
          }
        },
        {
          "valueCoding": {
            "display": "Not Implemented"
          }
        }
      ],
      "responseAEI": {
        "evaluation": {
          "criteria": {
            "nature": "single-choice",
            "weight": 2.0,
            "choices": [
              {
                "code": "Fully Implemented",
                "score": 100
              },
              {
                "code": "Partially Implemented",
                "score": 50
              },
              {
                "code": "Not Implemented",
                "score": 0
              }
            ]
          }
        }
      }
    },
    {
      "item": [
        {
          "type": "choice",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "check-box",
                    "display": "Check-box"
                  }
                ]
              }
            }
          ],
          "linkId": "698818405059",
          "text": "Confirm that your media disposal policy includes the following elements (click all that apply):",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Types of media covered by policy (Policy defines all types of media that may contain FCI (hard drives, SSDs, USB drives, etc.))"
              }
            },
            {
              "valueCoding": {
                "display": "Identification methods for FCI-containing media (Procedures for identifying media that contains or may contain FCI)"
              }
            },
            {
              "valueCoding": {
                "display": "Sanitization methods by media type (Specific sanitization methods appropriate for each media type)"
              }
            },
            {
              "valueCoding": {
                "display": "Destruction methods by media type (Specific destruction methods appropriate for each media type)"
              }
            },
            {
              "valueCoding": {
                "display": "Verification requirements (Procedures to verify sanitization or destruction was successful)"
              }
            },
            {
              "valueCoding": {
                "display": "Documentation requirements (Required records of sanitization and destruction activities)"
              }
            },
            {
              "valueCoding": {
                "display": "Roles and responsibilities (Designation of who is responsible for each aspect of media disposal)"
              }
            },
            {
              "valueCoding": {
                "display": "Compliance with relevant standards (References to NIST SP 800-88 or other applicable standards)"
              }
            }
          ],
          "responseAEI": {
            "evaluation": {
              "criteria": {
                "nature": "multi-choice",
                "weight": 1.0,
                "choices": [
                  {
                    "code": "Types of media covered by policy (Policy defines all types of media that may contain FCI (hard drives, SSDs, USB drives, etc.))",
                    "score": 12.5,
                    "weight": 0.12
                  },
                  {
                    "code": "Identification methods for FCI-containing media (Procedures for identifying media that contains or may contain FCI)",
                    "score": 12.5,
                    "weight": 0.12
                  },
                  {
                    "code": "Sanitization methods by media type (Specific sanitization methods appropriate for each media type)",
                    "score": 12.5,
                    "weight": 0.12
                  },
                  {
                    "code": "Destruction methods by media type (Specific destruction methods appropriate for each media type)",
                    "score": 12.5,
                    "weight": 0.12
                  },
                  {
                    "code": "Verification requirements (Procedures to verify sanitization or destruction was successful)",
                    "score": 12.5,
                    "weight": 0.12
                  },
                  {
                    "code": "Documentation requirements (Required records of sanitization and destruction activities)",
                    "score": 12.5,
                    "weight": 0.12
                  },
                  {
                    "code": "Roles and responsibilities (Designation of who is responsible for each aspect of media disposal)",
                    "score": 12.5,
                    "weight": 0.12
                  },
                  {
                    "code": "Compliance with relevant standards (References to NIST SP 800-88 or other applicable standards)",
                    "score": 12.5,
                    "weight": 0.12
                  }
                ],
                "aggregation": "sum",
                "maxScore": 100
              }
            }
          }
        },
        {
          "linkId": "393852162334_helpText",
          "type": "display",
          "text": "Define and document policies for handling, storing, and disposing of media to prevent unauthorized access and data loss.",
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
      ],
      "type": "group",
      "linkId": "393852162334",
      "prefix": "1.",
      "text": "Policy Elements"
    }
  ]
}

```