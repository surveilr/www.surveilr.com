---
id: cmmc-self-assessment-guide-q5
title: "CMMC Assessment Questionaire Physical Protection"
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
order: 24
---
### CMMC Assessment Questionnaire - Physical Protection
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
  "title": "Physical Protection (Limit physical access to information systems and facilities)",
  "status": "draft",
  "item": [
    {
      "item": [
        {
          "item": [
            {
              "type": "display",
              "linkId": "324592389560",
              "text": "How many individuals are authorized for physical access to FCI areas (fill in the total for each)?"
            },
            {
              "type": "integer",
              "linkId": "436045572485",
              "text": "Full-time employees:"
            },
            {
              "type": "integer",
              "linkId": "857782926958",
              "text": "Contractors:"
            },
            {
              "type": "integer",
              "linkId": "944400994758",
              "text": "Part-time employees:"
            },
            {
              "type": "integer",
              "linkId": "571574306369",
              "text": "Visitors (with escort):"
            },
            {
              "linkId": "296125947947_helpText",
              "type": "display",
              "text": "Maintain an updated list of individuals authorized to access secure physical areas to ensure proper access control.",
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
          "linkId": "296125947947",
          "text": "1. Authorized Personnel Inventory",
          "required": false,
          "repeats": false
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "702794466613",
              "text": "What areas require controlled physical access?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Server rooms/data centers"
                },
                {
                  "valueString": "Workstation areas processing FCI"
                },
                {
                  "valueString": "Executive offices"
                },
                {
                  "valueString": "Mail/shipping areas"
                },
                {
                  "valueString": "Network equipment rooms"
                },
                {
                  "valueString": "Storage areas for FCI media"
                },
                {
                  "valueString": "Conference rooms used for FCI discussions"
                }
              ]
            },
            {
              "linkId": "209389086115_helpText",
              "type": "display",
              "text": "Control and restrict access to sensitive physical locations to prevent unauthorized entry and protect assets.",
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
          "linkId": "209389086115",
          "text": "2. Physical Access Areas"
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "784352573703",
              "text": "Who authorizes physical access to controlled areas?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Facility manager"
                },
                {
                  "valueString": "Department supervisor"
                },
                {
                  "valueString": "IT security team"
                },
                {
                  "valueString": "Security manager"
                },
                {
                  "valueString": "HR department"
                }
              ]
            },
            {
              "linkId": "869992586185_helpText",
              "type": "display",
              "text": "Establish formal procedures to grant, review, and revoke physical access permissions for personnel.",
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
          "linkId": "869992586185",
          "text": "3. Authorization Process"
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "773851219827",
              "text": "What types of physical access credentials are issued?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Photo ID badges"
                },
                {
                  "valueString": "Physical keys"
                },
                {
                  "valueString": "Biometric scanners"
                },
                {
                  "valueString": "Proximity cards/key fobs"
                },
                {
                  "valueString": "PIN codes"
                },
                {
                  "valueString": "Visitor badges"
                }
              ]
            },
            {
              "linkId": "263666472314_helpText",
              "type": "display",
              "text": "Issue and manage secure access credentials to verify and control entry to restricted physical areas.",
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
          "linkId": "263666472314",
          "text": "4. Access Credentials"
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "208747627440",
              "text": "Are there time-based restrictions on physical access?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Yes, business hours only"
                },
                {
                  "valueString": "Yes, specific hours by role"
                },
                {
                  "valueString": "Yes, weekdays only"
                },
                {
                  "valueString": "No time restrictions"
                }
              ]
            },
            {
              "linkId": "409121643490_helpText",
              "type": "display",
              "text": "Limit physical access to authorized areas during specific times to reduce security risks outside business hours.",
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
          "linkId": "409121643490",
          "text": "5. Time-Based Access Restrictions",
          "repeats": false
        },
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
          "linkId": "660777712272",
          "text": "Implementation Status",
          "repeats": false,
          "answerOption": [
            {
              "valueString": "Fully Implemented"
            },
            {
              "valueString": "Partially Implemented"
            },
            {
              "valueString": "Not Implemented"
            }
          ]
        },
        {
          "linkId": "624769621183_helpText",
          "type": "display",
          "text": "Limit physical access to organizational information systems, equipment, and the respective operating environments to authorized individuals",
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
      "linkId": "624769621183",
      "text": "PE.L1-3.10.1 - Physical Access Authorization"
    },
    {
      "item": [
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "684131391577",
              "text": "Does your organization require all visitors to be escorted?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Yes, all visitors must be escorted at all times"
                },
                {
                  "valueString": "Yes, but only in restricted areas"
                },
                {
                  "valueString": "No formal escort requirement"
                }
              ]
            },
            {
              "linkId": "984680126159_helpText",
              "type": "display",
              "text": "Require authorized personnel to accompany visitors while they are in secure areas to ensure safety and security.",
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
          "linkId": "984680126159",
          "text": "1. Visitor Escort Policy",
          "repeats": false
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "400470675855",
              "text": "How are visitors identified and distinguished from employees?",
              "required": false,
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Distinctive visitor badges or lanyards"
                },
                {
                  "valueString": "Visitor sign-in log at reception"
                },
                {
                  "valueString": "Photo identification requirement"
                },
                {
                  "valueString": "Advance visitor approval and notification"
                },
                {
                  "valueString": "Temporary access cards or badges"
                }
              ]
            },
            {
              "linkId": "896661213301_helpText",
              "type": "display",
              "text": "Implement procedures to verify and record visitor identities before granting physical access to facilities.",
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
          "linkId": "896661213301",
          "text": "2. Visitor Identification",
          "repeats": false
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "829474009766",
              "text": "How is visitor activity monitored while on premises?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Continuous escort by authorized personnel"
                },
                {
                  "valueString": "Security camera surveillance"
                },
                {
                  "valueString": "Physical access restrictions to sensitive areas"
                },
                {
                  "valueString": "Time limits on visitor access"
                },
                {
                  "valueString": "Activity logs maintained by escorts"
                }
              ]
            },
            {
              "linkId": "588293653185_helpText",
              "type": "display",
              "text": "Track and record visitor movements within facilities to detect and prevent unauthorized activities.",
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
          "linkId": "588293653185",
          "text": "3. Visitor Activity Monitoring",
          "repeats": false
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "422650784362",
              "text": "Who is authorized to escort visitors?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Any employee"
                },
                {
                  "valueString": "Security staff only"
                },
                {
                  "valueString": "Trained escort personnel"
                },
                {
                  "valueString": "Designated personnel only"
                },
                {
                  "valueString": "Managers and supervisors only"
                }
              ]
            },
            {
              "linkId": "286167746672_helpText",
              "type": "display",
              "text": "Define who is permitted to escort visitors and ensure they understand their responsibilities for security and supervision.",
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
          "linkId": "286167746672",
          "text": "4. Escort Authorization",
          "repeats": false
        },
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
          "linkId": "231843690847",
          "text": "Implementation Status",
          "repeats": false,
          "answerOption": [
            {
              "valueString": "Fully Implemented"
            },
            {
              "valueString": "Partially Implemented"
            },
            {
              "valueString": "Not Implemented"
            }
          ]
        },
        {
          "linkId": "197390251867_helpText",
          "type": "display",
          "text": "Escort visitors and monitor visitor activity",
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
      "linkId": "197390251867",
      "text": "PE.L1-3.10.3 - Escort Visitors"
    },
    {
      "item": [
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "734633292283",
              "text": "How do you log physical access to your facilities?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Electronic badge readers with automatic logging"
                },
                {
                  "valueString": "Manual sign-in/sign-out sheets"
                },
                {
                  "valueString": "Security camera recordings"
                },
                {
                  "valueString": "Security guard logs and reports"
                },
                {
                  "valueString": "Physical key assignment and tracking logs"
                }
              ]
            },
            {
              "linkId": "492440543443_helpText",
              "type": "display",
              "text": "Implement methods to accurately record entry and exit activities in secure areas for audit and investigation purposes.",
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
          "linkId": "492440543443",
          "text": "1. Access Logging Methods"
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "174905707594",
              "text": "What information is captured in your physical access logs Information Captured in Logs?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Person's identity (name, employee ID, visitor ID)"
                },
                {
                  "valueString": "Date and time of access"
                },
                {
                  "valueString": "Entry and exit times"
                },
                {
                  "valueString": "Specific location or area accessed"
                },
                {
                  "valueString": "Purpose of visit or access"
                },
                {
                  "valueString": "Escort information (if applicable)"
                },
                {
                  "valueString": "Failed access attempts"
                }
              ]
            },
            {
              "linkId": "349759491673_helpText",
              "type": "display",
              "text": "Record key details such as date, time, personnel identity, and access points to ensure comprehensive tracking of physical access events.",
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
          "linkId": "349759491673",
          "text": "2. Information Captured in Logs"
        },
        {
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
                        "code": "drop-down",
                        "display": "Drop down"
                      }
                    ]
                  }
                }
              ],
              "linkId": "245305278102",
              "text": "How long are physical access logs retained?",
              "answerOption": [
                {
                  "valueString": "30 Days"
                },
                {
                  "valueString": "90 Days"
                },
                {
                  "valueString": "6 Months"
                },
                {
                  "valueString": "1 Year"
                },
                {
                  "valueString": "Longer than 1 year"
                }
              ]
            },
            {
              "type": "string",
              "linkId": "741567851452",
              "text": "How frequently are access logs reviewed?",
              "answerOption": [
                {
                  "valueString": "Daily"
                },
                {
                  "valueString": "Weekly"
                },
                {
                  "valueString": "Monthly"
                },
                {
                  "valueString": "Quaterly"
                },
                {
                  "valueString": "Only when incidents occur"
                },
                {
                  "valueString": "Never formally reviewed"
                }
              ]
            },
            {
              "type": "string",
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
              "linkId": "745836226925",
              "text": "Who reviews the physical access logs?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Security manager"
                },
                {
                  "valueString": "IT security team"
                },
                {
                  "valueString": "Facility manager"
                },
                {
                  "valueString": "HR department"
                }
              ]
            },
            {
              "linkId": "831615420801_helpText",
              "type": "display",
              "text": "Maintain and regularly review access logs to detect anomalies and support security investigations.",
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
          "linkId": "831615420801",
          "text": "3. Log Retention and Review "
        },
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
          "linkId": "320438032270",
          "text": "Implementation Status",
          "repeats": false,
          "answerOption": [
            {
              "valueString": "Fully Implemented"
            },
            {
              "valueString": "Partially Implemented"
            },
            {
              "valueString": "Not Implemented"
            }
          ]
        }
      ],
      "type": "group",
      "linkId": "430398414481",
      "text": "PE.L1-3.10.4 - Physical Access Logs"
    },
    {
      "item": [
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "903629274308",
              "text": "What types of physical access devices does your organization use?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Physical keys"
                },
                {
                  "valueString": "Proximity cards or fobs"
                },
                {
                  "valueString": "Keypad entry systems"
                },
                {
                  "valueString": "Electronic key cards or badges"
                },
                {
                  "valueString": "Biometric scanners (fingerprint, retina, etc.) Smart cards with embedded chips"
                },
                {
                  "valueString": "Mobile phone apps for access control"
                },
                {
                  "valueString": "Smart cards with embedded chips"
                }
              ]
            },
            {
              "linkId": "621187042559_helpText",
              "type": "display",
              "text": "Keep an up-to-date inventory of all devices used to control physical access, such as card readers and locks, to ensure proper management and security.",
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
          "linkId": "621187042559",
          "text": "1. Physical Access Device Inventory "
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "173451266066",
              "text": "How are physical access devices controlled and managed?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Formal inventory tracking system"
                },
                {
                  "valueString": "Device assignment records maintained"
                },
                {
                  "valueString": "Device return procedures for departing employees"
                },
                {
                  "valueString": "Regular audits of device assignment"
                },
                {
                  "valueString": "Procedures for lost or stolen devices"
                },
                {
                  "valueString": "Ability to quickly revoke device access"
                }
              ]
            },
            {
              "linkId": "250263340197_helpText",
              "type": "display",
              "text": "Implement procedures to configure, monitor, and maintain physical access devices to prevent unauthorized use or tampering.",
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
          "linkId": "250263340197",
          "text": "2. Device Control and Management "
        },
        {
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
                        "code": "check-box",
                        "display": "Check-box"
                      }
                    ]
                  }
                }
              ],
              "linkId": "911514884520",
              "text": "What security measures protect physical access devices?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Secure storage for unassigned devices"
                },
                {
                  "valueString": "Encrypted data on electronic devices"
                },
                {
                  "valueString": "Device expiration dates and automatic deactivation"
                },
                {
                  "valueString": "Protection against unauthorized duplication"
                },
                {
                  "valueString": "Tamper-resistant design"
                }
              ]
            },
            {
              "linkId": "703507215918_helpText",
              "type": "display",
              "text": "Apply security controls to protect physical access devices from damage, tampering, or unauthorized modification.",
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
          "linkId": "703507215918",
          "text": "3. Device Security Measures "
        },
        {
          "item": [
            {
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
                            "code": "check-box",
                            "display": "Check-box"
                          }
                        ]
                      }
                    }
                  ],
                  "linkId": "944580322601",
                  "text": "Check all that apply:",
                  "repeats": true,
                  "answerOption": [
                    {
                      "valueString": "Regular testing of device functionality"
                    },
                    {
                      "valueString": "Battery monitoring and replacement"
                    },
                    {
                      "valueString": "Regular software/firmware updates"
                    },
                    {
                      "valueString": "Calibration of biometric devices"
                    },
                    {
                      "valueString": "Backup systems for device failures"
                    }
                  ]
                }
              ],
              "type": "string",
              "linkId": "466342459779",
              "text": "How frequently are electronic access systems updated?",
              "answerOption": [
                {
                  "valueString": "Real-time update"
                },
                {
                  "valueString": "Daily"
                },
                {
                  "valueString": "Weekly"
                },
                {
                  "valueString": "Monthly"
                },
                {
                  "valueString": "As Needed Basis"
                }
              ]
            },
            {
              "linkId": "130535369896_helpText",
              "type": "display",
              "text": "Regularly perform maintenance and apply updates to physical access devices to ensure their reliability and security.",
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
          "linkId": "130535369896",
          "text": "4. Device Maintenance and Updates"
        },
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
          "linkId": "294892506040",
          "text": "Implementation Status",
          "repeats": false,
          "answerOption": [
            {
              "valueString": "Fully Implemented"
            },
            {
              "valueString": "Partially Implemented"
            },
            {
              "valueString": "Not Implemented"
            }
          ]
        }
      ],
      "type": "group",
      "linkId": "806534035552",
      "text": "PE.L1-3.10.5 - Manage Physical Access Devices"
    }
  ]
}

```