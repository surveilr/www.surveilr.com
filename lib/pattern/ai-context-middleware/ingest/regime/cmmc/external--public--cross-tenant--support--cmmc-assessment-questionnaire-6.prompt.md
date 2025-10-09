---
id: cmmc-self-assessment-guide-q6
title: "CMMC Assessment Questionaire Policy Framework Assessment"
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
order: 25
---
### CMMC Assessment Questionnaire - Policy Framework Assessment
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
  "title": "Policy Framework Assessment (Policy Implementation - All CMMC Level 1 Practices)",
  "status": "draft",
  "item": [
    {
      "type": "group",
      "linkId": "364455629781",
      "text": "Policy Framework Assessment",
      "item": [
        {
          "linkId": "364455629781_helpText",
          "type": "display",
          "text": "Comprehensive assessment of your organization's policy management framework covering all CMMC Level 1 practices.",
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
                ],
                "text": "Check-box"
              }
            }
          ],
          "repeats": true,
          "linkId": "527949557496",
          "text": "Who is responsible for developing and approving CMMC-related policies?",
          "answerOption": [
            {
              "valueCoding": {
                "display": "Chief Information Officer"
              }
            },
            {
              "valueCoding": {
                "display": "Chief Information Security Officer"
              }
            },
            {
              "valueCoding": {
                "display": "Chief Executive Officer"
              }
            },
            {
              "valueCoding": {
                "display": "Legal/Compliance Department"
              }
            },
            {
              "valueCoding": {
                "display": "IT Security Team"
              }
            }
          ]
        },
        {
          "linkId": "590810573907_helpText",
          "type": "display",
          "text": "Establish a formal process to create, review, and approve policies to ensure they align with organizational goals and compliance requirements.",
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
      "linkId": "590810573907",
      "prefix": "1.",
      "text": "Policy Development and Approval"
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
                ],
                "text": "Check-box"
              }
            }
          ],
          "repeats": true,
          "linkId": "992068463537",
          "text": "How frequently are CMMC-related policies reviewed and updated?",
          "answerOption": [
            {
              "valueCoding": {
                "display": "Quarterly"
              }
            },
            {
              "valueCoding": {
                "display": "Bi-annually"
              }
            },
            {
              "valueCoding": {
                "display": "Annually"
              }
            },
            {
              "valueCoding": {
                "display": "When regulations change"
              }
            },
            {
              "valueCoding": {
                "display": "No formal schedule"
              }
            }
          ]
        },
        {
          "linkId": "441079114846_helpText",
          "type": "display",
          "text": "Implement regular procedures to review and update policies to keep them current and effective.",
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
      "linkId": "441079114846",
      "prefix": "2.",
      "text": "Policy Review and Update Procedures"
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
                ],
                "text": "Check-box"
              }
            }
          ],
          "repeats": true,
          "linkId": "472951321809",
          "text": "What training is provided to employees on CMMC-related policies?",
          "answerOption": [
            {
              "valueCoding": {
                "display": "Initial security awareness training"
              }
            },
            {
              "valueCoding": {
                "display": "Role-specific policy training"
              }
            },
            {
              "valueCoding": {
                "display": "Annual refresher training"
              }
            },
            {
              "valueCoding": {
                "display": "just-in-time training for policy changes"
              }
            },
            {
              "valueCoding": {
                "display": "No formal training program"
              }
            }
          ]
        },
        {
          "linkId": "401642968533_helpText",
          "type": "display",
          "text": "Provide ongoing training to employees to ensure understanding and compliance with organizational policies.",
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
      "linkId": "401642968533",
      "prefix": "3.",
      "text": "Employee Training on Policies"
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
                ],
                "text": "Check-box"
              }
            }
          ],
          "repeats": true,
          "linkId": "758349008850",
          "text": "How is compliance with CMMC-related policies monitored?",
          "answerOption": [
            {
              "valueCoding": {
                "display": "Regular internal audits"
              }
            },
            {
              "valueCoding": {
                "display": "Automated compliance monitoring"
              }
            },
            {
              "valueCoding": {
                "display": "Self-assessment questionnaires"
              }
            },
            {
              "valueCoding": {
                "display": "Manager reviews and attestations"
              }
            },
            {
              "valueCoding": {
                "display": "Third-party assessments"
              }
            }
          ]
        },
        {
          "linkId": "237023742748_helpText",
          "type": "display",
          "text": "Regularly monitor and assess adherence to policies to identify gaps and enforce compliance.",
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
      "linkId": "237023742748",
      "prefix": "4.",
      "text": "Policy Compliance Monitoring"
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
          "linkId": "255836550808",
          "text": "How are exceptions to CMMC-related policies managed?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Formal exception request process"
              }
            },
            {
              "valueCoding": {
                "display": "Risk assessment for exceptions"
              }
            },
            {
              "valueCoding": {
                "display": "Compensating controls for exceptions"
              }
            },
            {
              "valueCoding": {
                "display": "Regular review of approved exceptions"
              }
            },
            {
              "valueCoding": {
                "display": "No formal exception process"
              }
            }
          ]
        },
        {
          "linkId": "260429244098_helpText",
          "type": "display",
          "text": "Establish a process to document, review, and approve exceptions to policies while managing associated risks.",
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
      "linkId": "260429244098",
      "prefix": "5.",
      "text": "Policy Exception Management"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Any additional information about your policy framework."
        }
      ],
      "linkId": "795388091631",
      "text": "Additional Notes"
    }
  ]
}

```