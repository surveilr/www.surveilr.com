---
id: cmmc-self-assessment-guide-q3
title: "CMMC Assessment Questionaire Identification and Authentication"
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
order: 22
---
### CMMC Self Assessment Questionnaire - Identification and Authentication

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
  "title": "Identification & Authentication (Verify identities of users and processes)",
  "status": "draft",
  "description": "Verify identities of users and processes",
  "item": [
    {
      "type": "group",
      "linkId": "228228158249",
      "text": "IA.L1-3.5.1 - Identify users and authenticate identities",
      "item": [
        {
          "linkId": "228228158249_helpText",
          "type": "display",
          "text": "Identify information system users, processes acting on behalf of users, or devices.",
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
      "linkId": "362061549890",
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
      "linkId": "139461602895",
      "text": "User Identification Standards",
      "repeats": false,
      "answerOption": [
        {
          "valueCoding": {
            "display": "First name + last name (john.smith)"
          }
        },
        {
          "valueCoding": {
            "display": "First initial + last name (jsmith)"
          }
        },
        {
          "valueCoding": {
            "display": "Employee ID numbers (EMP001234)"
          }
        },
        {
          "valueCoding": {
            "display": "Department codes + names (IT-jsmith)"
          }
        }
      ]
    },
    {
      "item": [
        {
          "type": "integer",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Enter number"
            }
          ],
          "linkId": "179545641231",
          "text": "Number of service accounts:"
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
          "linkId": "753553198622",
          "text": "Check all that apply:",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Database services"
              }
            },
            {
              "valueCoding": {
                "display": "Web applications"
              }
            },
            {
              "valueCoding": {
                "display": "Backup processes"
              }
            },
            {
              "valueCoding": {
                "display": "Monitoring/logging services"
              }
            },
            {
              "valueCoding": {
                "display": "Security scanning tools"
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
          "linkId": "926744954268",
          "text": "Do you have a device inventory spreadsheet?",
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
          "linkId": "446911811643_helpText",
          "type": "display",
          "text": "Manage service accounts carefully by assigning minimal privileges and regularly reviewing their usage to prevent misuse.",
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
      "linkId": "446911811643",
      "text": "Service Account Management"
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
      "linkId": "359160217347",
      "text": "Device Identification",
      "repeats": true,
      "answerOption": [
        {
          "valueCoding": {
            "display": "MAC addresses"
          }
        },
        {
          "valueCoding": {
            "display": "IP addresses (static)"
          }
        },
        {
          "valueCoding": {
            "display": "Computer/device names"
          }
        },
        {
          "valueCoding": {
            "display": "Asset tag numbers"
          }
        },
        {
          "valueCoding": {
            "display": "Serial numbers"
          }
        },
        {
          "valueCoding": {
            "display": "Certificates/digital signatures"
          }
        }
      ]
    },
    {
      "item": [
        {
          "type": "integer",
          "linkId": "878410531769",
          "text": "Workstations/laptops:"
        },
        {
          "type": "integer",
          "linkId": "361034048943",
          "text": "Servers:"
        },
        {
          "type": "integer",
          "linkId": "424090205463",
          "text": "Mobile devices:"
        },
        {
          "type": "integer",
          "linkId": "764441913827",
          "text": "Network devices:"
        },
        {
          "linkId": "543189099428_helpText",
          "type": "display",
          "text": "Maintain an up-to-date list of all devices connected to the network to track and manage authorized hardware",
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
      "linkId": "543189099428",
      "text": "Device Inventory"
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
      "linkId": "297397401977",
      "text": "Identity Verification Process",
      "repeats": true,
      "answerOption": [
        {
          "valueCoding": {
            "display": "HR verification with employee records"
          }
        },
        {
          "valueCoding": {
            "display": "Manager approval with written authorization"
          }
        },
        {
          "valueCoding": {
            "display": "Background check completion"
          }
        },
        {
          "valueCoding": {
            "display": "Photo identification verification"
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
      "linkId": "210356958517",
      "text": "Supporting Documentation",
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
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Any additional notes, remediation plans, or implementation challenges..."
        }
      ],
      "linkId": "268793244463",
      "text": "Additional Notes"
    },
    {
      "type": "group",
      "linkId": "865372145224",
      "text": "IA.L1-3.5.2 - Authenticate users and processes",
      "item": [
        {
          "linkId": "865372145224_helpText",
          "type": "display",
          "text": "Authenticate (or verify) the identities of those users, processes, or devices, as a prerequisite to allowing access to organizational information systems.",
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
      "linkId": "676336695824",
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
                "code": "check-box",
                "display": "Check-box"
              }
            ]
          }
        }
      ],
      "linkId": "901079756471",
      "text": "User Authentication Methods",
      "repeats": true,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Username and password"
          }
        },
        {
          "valueCoding": {
            "display": "Multi-factor authentication (MFA)"
          }
        },
        {
          "valueCoding": {
            "display": "Smart cards/PIV cards"
          }
        },
        {
          "valueCoding": {
            "display": "Biometric authentication"
          }
        },
        {
          "valueCoding": {
            "display": "Digital certificates"
          }
        },
        {
          "valueCoding": {
            "display": "Single sign-on (SSO)"
          }
        }
      ]
    },
    {
      "item": [
        {
          "type": "integer",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "8"
            }
          ],
          "linkId": "444552965098",
          "text": "Minimum length (characters):"
        },
        {
          "type": "integer",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "90"
            }
          ],
          "linkId": "499668919305",
          "text": "Password expiration (days):"
        },
        {
          "type": "integer",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "5"
            }
          ],
          "linkId": "190124104069",
          "text": "Password history (passwords remembered):"
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
          "linkId": "404025003688",
          "text": "Click all that apply:",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Uppercase letters required"
              }
            },
            {
              "valueCoding": {
                "display": "Lowercase letters required"
              }
            },
            {
              "valueCoding": {
                "display": "Numbers required"
              }
            },
            {
              "valueCoding": {
                "display": "Special characters required"
              }
            }
          ]
        },
        {
          "linkId": "459655669415_helpText",
          "type": "display",
          "text": "Set and enforce strong password rules to ensure users and processes securely verify their identity before accessing systems.",
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
      "linkId": "459655669415",
      "text": "Password Requirements"
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
      "linkId": "928879235030",
      "text": "Multi-Factor Authentication",
      "repeats": false,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Yes, for all users and systems"
          }
        },
        {
          "valueCoding": {
            "display": "Yes, for privileged accounts only"
          }
        },
        {
          "valueCoding": {
            "display": "Yes, for remote access only"
          }
        },
        {
          "valueCoding": {
            "display": "Yes, for critical systems only"
          }
        },
        {
          "valueCoding": {
            "display": "No, not implemented"
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
      "linkId": "830887074055",
      "text": "Default Credential Management",
      "repeats": false,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Always changed before deployment"
          }
        },
        {
          "valueCoding": {
            "display": "Changed during initial configuration"
          }
        },
        {
          "valueCoding": {
            "display": "Users required to change on first login"
          }
        },
        {
          "valueCoding": {
            "display": "No formal process"
          }
        }
      ]
    },
    {
      "item": [
        {
          "type": "integer",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "3"
            }
          ],
          "linkId": "647413778355",
          "text": "Number of failed attempts before lockout:"
        },
        {
          "type": "integer",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "30"
            }
          ],
          "linkId": "552155632772",
          "text": "Account lockout duration (minutes):"
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
          "linkId": "947716241721",
          "text": "Click all that apply:",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Administrator notification sent"
              }
            },
            {
              "valueCoding": {
                "display": "Security team alerted"
              }
            },
            {
              "valueCoding": {
                "display": "Logged for review"
              }
            }
          ]
        },
        {
          "linkId": "341175611920_helpText",
          "type": "display",
          "text": "Implement procedures to detect, respond to, and limit the impact of failed authentication attempts to protect against unauthorized access.",
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
      "linkId": "341175611920",
      "text": "Authentication Failure Handling"
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
      "linkId": "230111377333",
      "text": "Supporting Documentation",
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
      "type": "text",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
          "valueString": "Any additional notes, remediation plans, or implementation challenges..."
        }
      ],
      "linkId": "939036015644",
      "text": "Additional Notes"
    }
  ]
}