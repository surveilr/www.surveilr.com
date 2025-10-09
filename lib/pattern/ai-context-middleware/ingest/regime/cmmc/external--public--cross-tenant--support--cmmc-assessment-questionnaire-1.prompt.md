---
id: cmmc-self-assessment-guide-q1
title: "CMMC Assessment Questionaire"
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
order: 20
---
### CMMC Self Assessment Questionnaire - Access Control (Limit information system access to authorized users and processes)

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
  "title": "Access Control (Limit information system access to authorized users and processes)",
  "status": "draft",
  "item": [
    {
      "type": "group",
      "linkId": "461149605484",
      "text": "AC.L1-3.1.1 - Access Control Policy & Account Management",
      "item": [
        {
          "linkId": "461149605484_helpText",
          "type": "display",
          "text": "Limit information system access to authorized users, processes acting on behalf of authorized users, or devices (including other information systems).",
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
      "linkId": "744146359806",
      "text": "Do you have an Access Control Policy?",
      "weight": 1.5,
      "repeats": false,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Yes",
            "score": 100
          }
        },
        {
          "valueCoding": {
            "display": "No - if no, would you like help creating one for your company?",
            "score": 0
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
      "linkId": "184584712182",
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
          "linkId": "669545773690",
          "text": "Does your organization have a documented access control policy that addresses:",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Purpose, scope, roles, and responsibilities"
              }
            },
            {
              "valueCoding": {
                "display": "Management commitment"
              }
            },
            {
              "valueCoding": {
                "display": "Coordination among organizational entities"
              }
            },
            {
              "valueCoding": {
                "display": "Compliance requirements"
              }
            }
          ]
        },
        {
          "linkId": "480722725067_helpText",
          "type": "display",
          "text": "Establish clear access control rules, including who can access what information, how access is granted, reviewed, and revoked",
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
      "linkId": "480722725067",
      "prefix": "1.",
      "text": "Access Control Policy Elements"
    },
    {
      "item": [
        {
          "type": "display",
          "linkId": "182548770364",
          "text": "How many accounts are currently in your systems? "
        },
        {
          "type": "integer",
          "linkId": "927965645729",
          "text": "Active user accounts:",
          "repeats": false
        },
        {
          "type": "integer",
          "linkId": "903940962912",
          "text": "Inactive/disabled user accounts:",
          "repeats": false
        },
        {
          "type": "integer",
          "linkId": "338820008158",
          "text": "Service accounts:",
          "repeats": false
        },
        {
          "type": "integer",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/maxValue",
              "valueInteger": 100
            }
          ],
          "linkId": "673437974050",
          "text": "Shared accounts:",
          "repeats": false
        },
        {
          "linkId": "217670863053_helpText",
          "type": "display",
          "text": "Maintain a detailed and up-to-date record of all user accounts, including their access levels and status",
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
      "linkId": "217670863053",
      "prefix": "2.",
      "text": "User Account Registry"
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
          "linkId": "368418823104",
          "text": "How is the principle of least privilege implemented?",
          "repeats": false,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Fully implemented across all systems"
              }
            },
            {
              "valueCoding": {
                "display": "Partially implemented"
              }
            },
            {
              "valueCoding": {
                "display": "Not implemented"
              }
            }
          ]
        },
        {
          "linkId": "159744780603_helpText",
          "type": "display",
          "text": "Grant users and systems only the minimum access necessary to perform their tasks",
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
      "linkId": "159744780603",
      "prefix": "3.",
      "text": "Principle of Least Privilege Implementation"
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
          "linkId": "341135397442",
          "text": "How are account lifecycle processes managed?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Automated identity management system"
              }
            },
            {
              "valueCoding": {
                "display": "Manual process with approval workflow"
              }
            },
            {
              "valueCoding": {
                "display": "Integration with HR systems"
              }
            },
            {
              "valueCoding": {
                "display": "Regular account reviews and recertification"
              }
            }
          ]
        },
        {
          "linkId": "589953648417_helpText",
          "type": "display",
          "text": "Establish and follow formal procedures to manage user accounts throughout their lifecycle",
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
      "linkId": "589953648417",
      "prefix": "4.",
      "text": "Account Management Processes"
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
          "linkId": "563546854643",
          "text": "How frequently are user accounts reviewed for validity and appropriate access?",
          "repeats": false,
          "answerOption": [
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
                "display": "Annually"
              }
            },
            {
              "valueCoding": {
                "display": "Other (specify):"
              }
            }
          ]
        },
        {
          "linkId": "789082578732_helpText",
          "type": "display",
          "text": "Regularly review user accounts to verify access is still appropriate and remove or adjust accounts as needed",
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
      "linkId": "789082578732",
      "text": "Account Review Frequency"
    },
    {
      "type": "group",
      "linkId": "700726342337",
      "text": "AC.L1-3.1.2 - Transaction & Function Control",
      "item": [
        {
          "linkId": "700726342337_helpText",
          "type": "display",
          "text": "Limit information system access to the types of transactions and functions that authorized users are permitted to execute.",
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
      "linkId": "316234331937",
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
          "linkId": "589002798804",
          "text": "How do you limit user access to specific transactions and functions?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Role-based access control (RBAC)"
              }
            },
            {
              "valueCoding": {
                "display": "Function-based permissions (create, read, update, delete)"
              }
            },
            {
              "valueCoding": {
                "display": "Application-level access controls"
              }
            },
            {
              "valueCoding": {
                "display": "Time-based access restrictions"
              }
            },
            {
              "valueCoding": {
                "display": "Location-based access restrictions"
              }
            }
          ]
        },
        {
          "linkId": "899089109837_helpText",
          "type": "display",
          "text": "Implement controls to monitor and regulate transactions, ensuring only authorized actions are performed within systems and applications",
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
      "linkId": "899089109837",
      "prefix": "1.",
      "text": "Transaction Control Implementation"
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
          "linkId": "525896610609",
          "text": "What types of functions are restricted based on user roles?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Administrative functions (user management, system configuration)"
              }
            },
            {
              "valueCoding": {
                "display": "Financial transactions and approvals"
              }
            },
            {
              "valueCoding": {
                "display": "Data export and bulk download functions"
              }
            },
            {
              "valueCoding": {
                "display": "Report generation and access"
              }
            },
            {
              "valueCoding": {
                "display": "System-level commands and utilities"
              }
            }
          ]
        },
        {
          "linkId": "561249826496_helpText",
          "type": "display",
          "text": "Limit system functions and capabilities based on user roles to ensure individuals can only perform actions necessary for their job responsibilities",
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
      "linkId": "561249826496",
      "prefix": "2.",
      "text": "Function Restrictions by Role"
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
          "linkId": "859148329958",
          "text": "How are high-risk transactions authorized?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Manager approval required"
              }
            },
            {
              "valueCoding": {
                "display": "Two-person authorization"
              }
            },
            {
              "valueCoding": {
                "display": "Automated business rules and limits"
              }
            },
            {
              "valueCoding": {
                "display": "No special authorization required"
              }
            }
          ]
        },
        {
          "linkId": "338456195634_helpText",
          "type": "display",
          "text": "Require formal approval before critical transactions are executed to prevent unauthorized or fraudulent activities.",
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
      "linkId": "338456195634",
      "prefix": "3.",
      "text": "Transaction Authorization Requirements"
    },
    {
      "type": "group",
      "linkId": "293091353060",
      "text": "AC.L1-3.1.20 - External Connections",
      "item": [
        {
          "linkId": "293091353060_helpText",
          "type": "display",
          "text": "Verify and control/limit connections to and use of external information systems.",
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
      "linkId": "358071855489",
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
          "linkId": "261758300502",
          "text": "What types of external systems does your organization connect to?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Cloud services (email, file storage, applications)"
              }
            },
            {
              "valueCoding": {
                "display": "Business partner networks"
              }
            },
            {
              "valueCoding": {
                "display": "Vendor/supplier systems"
              }
            },
            {
              "valueCoding": {
                "display": "Government systems and portals"
              }
            },
            {
              "valueCoding": {
                "display": "Personal devices (BYOD)"
              }
            },
            {
              "valueCoding": {
                "display": "Remote access system"
              }
            },
            {
              "valueCoding": {
                "display": "No external connections"
              }
            }
          ]
        },
        {
          "linkId": "118413869969_helpText",
          "type": "display",
          "text": "Manage and secure connections to external systems to protect your network from unauthorized access and data breaches.",
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
      "linkId": "118413869969",
      "prefix": "1.",
      "text": "External System Connections"
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
          "linkId": "495111707033",
          "text": "How do you verify external system connections?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Digital certificates and PKI"
              }
            },
            {
              "valueCoding": {
                "display": "VPN connections with authentication"
              }
            },
            {
              "valueCoding": {
                "display": "Firewall rules and IP restrictions"
              }
            },
            {
              "valueCoding": {
                "display": "Signed interconnection agreements"
              }
            },
            {
              "valueCoding": {
                "display": "Continuous monitoring and logging"
              }
            }
          ]
        },
        {
          "linkId": "397995568740_helpText",
          "type": "display",
          "text": "Use verification techniques to confirm the identity and security of external connections before allowing access to your systems",
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
      "linkId": "397995568740",
      "prefix": "2.",
      "text": "Connection Verification Methods"
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
          "linkId": "597499672942",
          "text": "What limitations are placed on external connections?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Time-based access restrictions"
              }
            },
            {
              "valueCoding": {
                "display": "Restrictions on data types that can be shared"
              }
            },
            {
              "valueCoding": {
                "display": "Limited to specific user groups"
              }
            },
            {
              "valueCoding": {
                "display": "Management approval required for each connection"
              }
            },
            {
              "valueCoding": {
                "display": "Comprehensive audit trails and logging"
              }
            }
          ]
        },
        {
          "linkId": "354025378477_helpText",
          "type": "display",
          "text": "Define and enforce restrictions on external connections to minimize exposure and reduce security risks.",
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
      "linkId": "354025378477",
      "text": "Connection Control Limitations"
    },
    {
      "type": "group",
      "linkId": "942841103790",
      "text": "AC.L1-3.1.22 - Control Public Information",
      "item": [
        {
          "linkId": "942841103790_helpText",
          "type": "display",
          "text": "Control information posted or processed on publicly accessible information systems.",
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
      "linkId": "260717222110",
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
          "linkId": "660159010455",
          "text": "What publicly accessible systems does your organization operate?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Company website"
              }
            },
            {
              "valueCoding": {
                "display": "Social media accounts"
              }
            },
            {
              "valueCoding": {
                "display": "Customer portals or self-service systems"
              }
            },
            {
              "valueCoding": {
                "display": "Corporate blog or news site"
              }
            },
            {
              "valueCoding": {
                "display": "Public forums or discussion boards"
              }
            },
            {
              "valueCoding": {
                "display": "No publicly accessible systems"
              }
            }
          ]
        },
        {
          "linkId": "501427838641_helpText",
          "type": "display",
          "text": "Secure and monitor systems that are accessible to the public to prevent unauthorized access and data leakage.",
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
      "linkId": "501427838641",
      "text": "Publicly Accessible Systems"
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
          "linkId": "229261839700",
          "text": "How do you ensure FCI is not posted on public systems?",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Pre-publication review and approval process"
              }
            },
            {
              "valueCoding": {
                "display": "Designated reviewers trained to identify FCI"
              }
            },
            {
              "valueCoding": {
                "display": "Automated content scanning for sensitive information"
              }
            },
            {
              "valueCoding": {
                "display": "Periodic audits of published content"
              }
            },
            {
              "valueCoding": {
                "display": "Procedures for rapid removal of inappropriate content"
              }
            }
          ]
        },
        {
          "linkId": "786703783052_helpText",
          "type": "display",
          "text": "Establish regular procedures to review and validate information before it is published or shared",
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
      "linkId": "786703783052",
      "prefix": "2.",
      "text": "Content Review Process"
    },
    {
      "item": [
        {
          "type": "display",
          "linkId": "624223914711",
          "text": "Who is authorized to post content to public systems?"
        },
        {
          "type": "integer",
          "linkId": "374839487767",
          "text": "Number of authorized personnel:",
          "repeats": false
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
          "linkId": "177243885107",
          "text": "Choose all that apply:",
          "repeats": true,
          "answerOption": [
            {
              "valueCoding": {
                "display": "Marketing department"
              }
            },
            {
              "valueCoding": {
                "display": "Communications/PR team"
              }
            },
            {
              "valueCoding": {
                "display": "Executive leadership"
              }
            },
            {
              "valueCoding": {
                "display": "IT administrators"
              }
            }
          ]
        },
        {
          "linkId": "815496752107_helpText",
          "type": "display",
          "text": "Designate and control who is allowed to publish or distribute organizational information",
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
      "linkId": "815496752107",
      "prefix": "3.",
      "text": "Authorized Publishing Personnel"
    }
  ]
}