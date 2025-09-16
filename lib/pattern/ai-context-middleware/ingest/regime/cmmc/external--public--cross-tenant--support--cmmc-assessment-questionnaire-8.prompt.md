---
id: cmmc-self-assessment-guide-q8
title: "CMMC Assessment Questionaire System & Information Integrity "
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
order: 27
---
### CMMC Assessment Questionnaire - System & Information Integrity
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
  "title": "System & Information Integrity (Identify, report, and correct information system flaws)",
  "status": "draft",
  "item": [
    {
      "type": "group",
      "linkId": "350961856234",
      "text": "SI.L1-3.14.1 - Flaw Remediation",
      "item": [
        {
          "linkId": "350961856234_helpText",
          "type": "display",
          "text": "Identify, report, and correct information and information system flaws in a timely manner",
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
                ]
              }
            }
          ],
          "linkId": "758011605310",
          "text": "How does your organization identify system flaws and vulnerabilities?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Automated vulnerability scanning"
              }
            },
            {
              "valueCoding": {
                "display": "Vendor security notifications and bulletins"
              }
            },
            {
              "valueCoding": {
                "display": "Penetration testing"
              }
            },
            {
              "valueCoding": {
                "display": "Regular security assessments"
              }
            },
            {
              "valueCoding": {
                "display": "Threat intelligence feeds"
              }
            },
            {
              "valueCoding": {
                "display": "Incident response and forensics"
              }
            }
          ]
        }
      ],
      "type": "group",
      "linkId": "544004255685",
      "prefix": "1.",
      "text": "Flaw Identification Process"
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
          "linkId": "854540559647",
          "text": "How are identified flaws reported and tracked?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Formal tracking system or database"
              }
            },
            {
              "valueCoding": {
                "display": "Automatic management notification"
              }
            },
            {
              "valueCoding": {
                "display": "Risk assessment and prioritization"
              }
            },
            {
              "valueCoding": {
                "display": "Communication to affected stakeholders"
              }
            },
            {
              "valueCoding": {
                "display": "Detailed documentation of findings"
              }
            }
          ]
        },
        {
          "linkId": "603452357063_helpText",
          "type": "display",
          "text": "Establish processes to identify, report, and track system flaws and vulnerabilities until they are resolved.",
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
      "linkId": "603452357063",
      "prefix": "2.",
      "text": "Flaw Reporting and Tracking"
    },
    {
      "item": [
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
                        "code": "radio-button",
                        "display": "Radio Button"
                      }
                    ]
                  }
                }
              ],
              "linkId": "885354230428",
              "text": "Critical Severity Flaws:",
              "repeats": false,
              "answerOption": [
                {
                  "valueCoding": {
                    "display": "Immediate (within hours)"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Within 24 hours"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Within 72 hours"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Within 1 week"
                  }
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
              "linkId": "149460684671",
              "text": "High Severity Flaws:",
              "repeats": false,
              "answerOption": [
                {
                  "valueCoding": {
                    "display": "Within 1 week"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Within 2 weeks"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Within 1 month"
                  }
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
              "linkId": "119144494365",
              "text": "Medium/Low Severity Flaws:",
              "repeats": false,
              "answerOption": [
                {
                  "valueCoding": {
                    "display": "Within 1 month"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Within 1 quarter"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Next scheduled maintenance window"
                  }
                }
              ]
            }
          ],
          "type": "group",
          "linkId": "802989461197",
          "text": "What are your target timeframes for correcting identified flaws?"
        },
        {
          "linkId": "702845194175_helpText",
          "type": "display",
          "text": "Define and follow timelines to promptly address and fix identified system vulnerabilities to reduce security risks.",
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
      "linkId": "702845194175",
      "prefix": "3.",
      "text": "Flaw Correction Timeline"
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
                    "code": "radio-button",
                    "display": "Radio Button"
                  }
                ]
              }
            }
          ],
          "linkId": "896010001522",
          "text": "How are security patches and updates managed?",
          "repeats": false,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Testing in non-production environment before deployment"
              }
            },
            {
              "valueCoding": {
                "display": "Formal change control process"
              }
            },
            {
              "valueCoding": {
                "display": "Rollback procedures in case of issues"
              }
            },
            {
              "valueCoding": {
                "display": "Automated patch deployment capabilities"
              }
            },
            {
              "valueCoding": {
                "display": "Emergency patching procedures for critical flaws"
              }
            },
            {
              "valueCoding": {
                "display": "Documentation of all patches applied"
              }
            }
          ]
        },
        {
          "linkId": "535096646220_helpText",
          "type": "display",
          "text": "Implement procedures to regularly apply updates and patches to systems to protect against known vulnerabilities.",
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
      "linkId": "535096646220",
      "prefix": "4.",
      "text": "Patch Management Process"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Any additional context, challenges, or implementation details..."
        }
      ],
      "linkId": "731360730463",
      "text": "Additional Notes or Comments"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "List or describe the supporting documentation you have available (policies, procedures, scan reports, etc.)..."
        }
      ],
      "linkId": "231346071278",
      "text": "Supporting Documentation",
      "item": [
        {
          "linkId": "231346071278_helpText",
          "type": "display",
          "text": "Note: Have documentation available that demonstrates your flaw remediation processes, vulnerability scanning procedures, and patch management policies.",
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
                    "code": "radio-button",
                    "display": "Radio Button"
                  }
                ]
              }
            }
          ],
          "linkId": "892692932760",
          "text": "Do you have a malicious code protection policy document?",
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
          "item": [
            {
              "type": "string",
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
              "linkId": "942706169228",
              "text": "Do you need assistance?",
              "repeats": false,
              "answerOption": [
                {
                  "valueString": "Yes"
                },
                {
                  "valueString": "No"
                }
              ]
            }
          ]
        },
        {
          "linkId": "340771388729_helpText",
          "type": "display",
          "text": "Provide protection from malicious code at appropriate locations within organizational information systems",
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
      "linkId": "340771388729",
      "text": "SI.L1-3.14.2 - Malicious Code Protection"
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
          "linkId": "457010911238",
          "text": "Select all locations where malicious code protection is implemented:",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Email Gateway"
              }
            },
            {
              "valueCoding": {
                "display": "Web Proxy/Gateway"
              }
            },
            {
              "valueCoding": {
                "display": "Perimeter Firewall"
              }
            },
            {
              "valueCoding": {
                "display": "VPN Gateway"
              }
            },
            {
              "valueCoding": {
                "display": "Endpoints (Workstations, Laptops)"
              }
            },
            {
              "valueCoding": {
                "display": "Servers"
              }
            },
            {
              "valueCoding": {
                "display": "Mobile Devices"
              }
            }
          ]
        },
        {
          "linkId": "120577885697_helpText",
          "type": "display",
          "text": "Identify and secure critical points in systems and networks where integrity controls must be applied to prevent unauthorized changes.",
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
      "linkId": "120577885697",
      "prefix": "1.",
      "text": "Protection Locations"
    },
    {
      "item": [
        {
          "type": "string",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Enter primary anti-malware solution"
            }
          ],
          "linkId": "149423997720",
          "text": "Primary Anti-Malware Product/Solution: e.g., Microsoft Defender, McAfee, Symantec"
        },
        {
          "type": "string",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Enter version or release identifier"
            }
          ],
          "linkId": "343942743605",
          "text": "Anti-Malware Version/Release: Version number or release identifier"
        },
        {
          "type": "text",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Describe your anti-malware implementation scope..."
            }
          ],
          "linkId": "581419297519",
          "text": "Implementation Scope: Describe the scope of your anti-malware implementation (e.g., all company endpoints, specific servers)"
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
          "linkId": "394557514652",
          "text": "Real-Time Protection Enabled:",
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
          "linkId": "137330973781",
          "text": "Centrally Managed:",
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
          ]
        },
        {
          "linkId": "123297792461_helpText",
          "type": "display",
          "text": "Deploy and maintain tools and processes to detect, prevent, and respond to malware infections in your systems.",
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
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Enter primary anti-malware solution"
        }
      ],
      "linkId": "123297792461",
      "prefix": "2.",
      "text": "Implementation Details"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Any additional context, challenges, or implementation details..."
        }
      ],
      "linkId": "750023247979",
      "text": "Additional Notes or Comments"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "List or describe the supporting documentation you have available(policies, configuration guides, deployment records, etc.)..."
        }
      ],
      "linkId": "278751204941",
      "text": "Supporting Documentation",
      "item": [
        {
          "linkId": "278751204941_helpText",
          "type": "display",
          "text": "Note: Have documentation available that demonstrates your malicious code protection policies, anti-malware configurations, and deployment procedures.",
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
      "type": "group",
      "linkId": "363972470334",
      "text": "SI.L1-3.14.4 - Update Malicious Code Protection",
      "item": [
        {
          "linkId": "363972470334_helpText",
          "type": "display",
          "text": "Update malicious code protection mechanisms when new releases are available",
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
                    "code": "radio-button",
                    "display": "Radio Button"
                  }
                ]
              }
            }
          ],
          "linkId": "830996907328",
          "text": "How frequently are malicious code protection mechanisms updated?",
          "repeats": false,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Real-time updates (as available)"
              }
            },
            {
              "valueCoding": {
                "display": "Hourly"
              }
            },
            {
              "valueCoding": {
                "display": "Daily"
              }
            },
            {
              "valueCoding": {
                "display": "Weekly"
              }
            },
            {
              "valueCoding": {
                "display": "Manual updates only"
              }
            }
          ]
        },
        {
          "linkId": "370529733824_helpText",
          "type": "display",
          "text": "Regularly update malware protection tools and definitions to ensure defense against the latest threats.",
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
      "linkId": "370529733824",
      "prefix": "1.",
      "text": "Update Frequency"
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
          "linkId": "733457774453",
          "text": "How are malicious code protection updates managed?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Automatic updates enabled"
              }
            },
            {
              "valueCoding": {
                "display": "Centralized update management system"
              }
            },
            {
              "valueCoding": {
                "display": "Verification of successful updates"
              }
            },
            {
              "valueCoding": {
                "display": "Rollback capability for problematic updates"
              }
            },
            {
              "valueCoding": {
                "display": "Testing of updates before deployment"
              }
            },
            {
              "valueCoding": {
                "display": "Notification of update status and failures"
              }
            }
          ]
        },
        {
          "linkId": "400782620614_helpText",
          "type": "display",
          "text": "Establish procedures to manage and verify timely updates to malicious code protection systems.",
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
      "linkId": "400782620614",
      "prefix": "2.",
      "text": "Update Management Process"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Any additional context challenges, or implementation details..."
        }
      ],
      "linkId": "660268414578",
      "text": "Additional Notes or Comments"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "List o describe the supporting documentation you have available (update procedures, verification logs, rollback plans, etc.)..."
        }
      ],
      "linkId": "717091491475",
      "text": "Supporting Documentation",
      "item": [
        {
          "linkId": "717091491475_helpText",
          "type": "display",
          "text": "Note: Have documentation available that demonstrates your update management procedures, verification processes, and rollback capabilities.",
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
      "type": "group",
      "linkId": "237888898879",
      "text": "SI.L1-3.14.5 - System & File Scanning",
      "item": [
        {
          "linkId": "237888898879_helpText",
          "type": "display",
          "text": "Perform periodic scans of the information system and real-time scans of files from external sources",
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
      "linkId": "470606272303",
      "text": "Do you have a system scanning policy documentation, file scanning policy, and scanning procedure documentation?",
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
                    "code": "radio-button",
                    "display": "Radio Button"
                  }
                ]
              }
            }
          ],
          "linkId": "189466095401",
          "text": "Does your organization have antivirus/anti-malware software installed on all systems?",
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
            },
            {
              "valueCoding": {
                "display": "Partially (some systems only)"
              }
            }
          ]
        },
        {
          "type": "string",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Enter your current antivirus/anti-malware solution"
            }
          ],
          "linkId": "694425083943",
          "text": "What antivirus/anti-malware solution is currently deployed? e.g., Microsoft Defender, Norton, McAfee, etc."
        },
        {
          "linkId": "359679551926_helpText",
          "type": "display",
          "text": "Deploy anti-malware solutions to regularly scan systems and files for malicious software and remove threats promptly.",
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
      "linkId": "359679551926",
      "prefix": "1.",
      "text": "Anti-Malware Implementation"
    },
    {
      "item": [
        {
          "type": "choice",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "-- Select Frequency --"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "drop-down",
                    "display": "Drop down"
                  }
                ]
              }
            }
          ],
          "linkId": "508929065591",
          "text": "How frequently are full system scans conducted?",
          "repeats": false,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Daily"
              }
            },
            {
              "valueCoding": {
                "display": "Weekily"
              }
            },
            {
              "valueCoding": {
                "display": "Bi-weekly"
              }
            },
            {
              "valueCoding": {
                "display": "Monthly"
              }
            },
            {
              "valueCoding": {
                "display": "Quarterly"
              }
            },
            {
              "valueCoding": {
                "display": "Custom Schedule"
              }
            }
          ]
        },
        {
          "type": "choice",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "-- Select Scan Depth --"
            }
          ],
          "linkId": "889472415570",
          "text": "What level of thoroughness is used for periodic scans?",
          "repeats": false,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Quick Scan (critical files only)"
              }
            },
            {
              "valueCoding": {
                "display": "Standard Scan (system files and common user directories)"
              }
            },
            {
              "valueCoding": {
                "display": "Full Scan (entire file system)"
              }
            },
            {
              "valueCoding": {
                "display": "Custom Scan (specific directories)"
              }
            }
          ]
        },
        {
          "linkId": "558460360931_helpText",
          "type": "display",
          "text": "Schedule regular scans of systems and files to detect and address malware or security issues consistently.",
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
      "linkId": "558460360931",
      "prefix": "2.",
      "text": "Periodic Scanning Implementation"
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
                    "code": "radio-button",
                    "display": "Radio Button"
                  }
                ]
              }
            }
          ],
          "linkId": "740865411316",
          "text": "Are files from external sources scanned in real-time?",
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
            },
            {
              "valueCoding": {
                "display": "Partially (some sources only)"
              }
            }
          ]
        },
        {
          "linkId": "527252274149_helpText",
          "type": "display",
          "text": "Use real-time scanning to detect threats immediately and monitor file integrity to prevent unauthorized changes.",
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
      "linkId": "527252274149",
      "prefix": "3.",
      "text": "Real-time Scanning & File Integrity"
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
                "code": "check-box",
                "display": "Check-box"
              }
            ]
          }
        }
      ],
      "linkId": "146442608630",
      "text": "Which external sources are scanned?",
      "repeats": true,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Internet Downloads"
          }
        },
        {
          "valueCoding": {
            "display": "Email Attachments"
          }
        },
        {
          "valueCoding": {
            "display": "Removable Media"
          }
        },
        {
          "valueCoding": {
            "display": "Cloud Storage"
          }
        },
        {
          "valueCoding": {
            "display": "Network Shares"
          }
        },
        {
          "valueCoding": {
            "display": "Other External Sources"
          }
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
      "linkId": "842602142275",
      "text": "Do you employ file integrity monitoring for critical system files?",
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
        },
        {
          "valueCoding": {
            "display": "Planned"
          }
        }
      ]
    },
    {
      "item": [
        {
          "type": "text",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Describe your process for reviewing and documenting scan results..."
            }
          ],
          "linkId": "707425868010",
          "text": "How are scan results reviewed and documented? Describe your process for reviewing and documenting scan results..."
        },
        {
          "type": "choice",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "-- Select Response Timeframe --"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "drop-down",
                    "display": "Drop down"
                  }
                ]
              }
            }
          ],
          "linkId": "986030389075",
          "text": "What is your response timeframe when malware or vulnerabilities are detected?",
          "repeats": false,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Immediate (within hours)"
              }
            },
            {
              "valueCoding": {
                "display": "Within 24 hours"
              }
            },
            {
              "valueCoding": {
                "display": "Within 48 hours"
              }
            },
            {
              "valueCoding": {
                "display": "Within a week"
              }
            },
            {
              "valueCoding": {
                "display": "Other (specify in notes)"
              }
            }
          ]
        },
        {
          "type": "text",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Describe your process for remediating issues detected during scanning.."
            }
          ],
          "linkId": "164191875680",
          "text": "Describe your remediation process for identified issues: Describe your process for remediating issues detected during scanning..."
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
          "linkId": "967054991522",
          "text": "Has scanning effectiveness been tested?",
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
          ]
        },
        {
          "linkId": "123247885877_helpText",
          "type": "display",
          "text": "Establish procedures to review scan results, respond to detected threats, and test scanning tools for effectiveness.",
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
      "linkId": "123247885877",
      "prefix": "4.",
      "text": "Results Handling & Testing"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Any additional context, challenges, or implementation details"
        }
      ],
      "linkId": "892462719670",
      "text": "Has scanning effectiveness been tested?"
    },
    {
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "List or describe the supporting documentation you have available(scanning policies , procedures , scan logs , remediation records, etc.)..."
        }
      ],
      "linkId": "901609884580",
      "text": "Supporting Documentation",
      "item": [
        {
          "linkId": "901609884580_helpText",
          "type": "display",
          "text": "Note: Have documentation available that demonstrates your scanning policies, procedures, scan results, and remediation processes.",
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
    }
  ]
}

```