---
id: cmmc-self-assessment-guide-q7
title: "CMMC Assessment Questionaire System and Communication Protection"
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
order: 26
---
### CMMC Assessment Questionnaire - System and Communication Protection
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
  "title": "System & Communications Protection (Monitor, control, and protect organizational communications)",
  "status": "draft",
  "item": [
    {
      "item": [
        {
          "type": "display",
          "linkId": "998940326541",
          "text": "Requirements: Implement network monitoring and boundary protection including firewalls, intrusion detection, and communication controls."
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
          "linkId": "954433842901",
          "text": "Implementation Status ",
          "required": true,
          "repeats": false,
          "answerOption": [
            {
              "valueString": "Fully Implemented - All boundary protection controls are in place and operational"
            },
            {
              "valueString": "Partially Implemented - Some boundary protection controls exist but gaps remain"
            },
            {
              "valueString": "Not Implemented - No boundary protection controls currently in place"
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
                    "code": "radio-button",
                    "display": "Radio Button"
                  }
                ]
              }
            }
          ],
          "linkId": "979372224491",
          "text": "Do you have a network diagram showing system boundaries, key components, and data flows?",
          "repeats": false,
          "answerOption": [
            {
              "valueString": "Yes"
            },
            {
              "valueString": "No"
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
                  "valueString": "Include hardware models, firmware versions and their primary functions.  e.g., Cisco ASA 5515-X v9.12.3 - Primary perimeter firewall, Palo Alto PA-220 v10.1.2 - Branch office firewall."
                }
              ],
              "linkId": "591770672887",
              "text": "External Boundary Components",
              "item": [
                {
                  "linkId": "591770672887_helpText",
                  "type": "display",
                  "text": "List the components that make up your external system boundaries (e.g., firewalls, routers, gateways); Include hardware models, firmware versions, and their primary functions",
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
              "type": "text",
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
                  "valueString": "Include components that separate development, test and production environments or create internal segmentation. eg., Internal VLAN switches, host-based firewalls,  Network ACLs."
                }
              ],
              "linkId": "930792706809",
              "text": "Key Internal Boundary Components",
              "item": [
                {
                  "linkId": "930792706809_helpText",
                  "type": "display",
                  "text": "List any key internal boundaries that separate parts of your network; Include components that separate development, test, and production environments or create internal segmentation",
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
              "linkId": "861774438513_helpText",
              "type": "display",
              "text": "Clearly define the limits of your information systems to identify what needs protection and control.",
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
          "linkId": "861774438513",
          "text": "1. System Boundary Definition",
          "repeats": false
        },
        {
          "item": [
            {
              "type": "text",
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
                  "valueString": "e.g., Cisco ASA 5500, Palo Alto PA-220"
                }
              ],
              "linkId": "843201435494",
              "text": "Firewall Manufacturer/Model",
              "repeats": false,
              "item": [
                {
                  "linkId": "843201435494_helpText",
                  "type": "display",
                  "text": "e.g., Cisco ASA 5500, Palo Alto PA-220",
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
              "type": "text",
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
                  "valueString": "e.g., v9.12.3"
                }
              ],
              "linkId": "706452201694",
              "text": "Firewall Software/Firmware Version",
              "repeats": false,
              "item": [
                {
                  "linkId": "706452201694_helpText",
                  "type": "display",
                  "text": "e.g., v9.12.3",
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
              "linkId": "949755108024",
              "text": "Default deny policy is implemented (traffic is denied by default unless explicitly permitted)",
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
                  "valueString": "e.g., HTTPS (TCP/443), SSH (TCP/22), DNS (UDP/53)"
                }
              ],
              "linkId": "963088071424",
              "text": "Explicitly Allowed Services/Protocols",
              "repeats": false,
              "item": [
                {
                  "linkId": "963088071424_helpText",
                  "type": "display",
                  "text": "e.g., HTTPS (TCP/443), SSH (TCP/22), DNS (UDP/53)",
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
              "type": "text",
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
                  "valueString": "e.g., Telnet (TCP/23), FTP (TCP/21), HTTP (TCP/80)"
                }
              ],
              "linkId": "122305830447",
              "text": "Explicitly Denied Services/Protocols",
              "repeats": false,
              "item": [
                {
                  "linkId": "122305830447_helpText",
                  "type": "display",
                  "text": "e.g., Telnet (TCP/23), FTP (TCP/21), HTTP (TCP/80)",
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
              "linkId": "835757897200_helpText",
              "type": "display",
              "text": "Set up and manage firewalls to control and monitor incoming and outgoing network traffic based on security rules.",
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
          "linkId": "835757897200",
          "text": "2. Firewall Configuration"
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
              "linkId": "847131102373",
              "text": "How do you monitor communications at system boundaries?",
              "repeats": true,
              "answerOption": [
                {
                  "valueCoding": {
                    "display": "Firewall logs and analysis"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Intrusion detection/prevention systems"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Network monitoring tools"
                  }
                },
                {
                  "valueCoding": {
                    "display": "SIEM system integration"
                  }
                },
                {
                  "valueCoding": {
                    "display": "Manual log review"
                  }
                }
              ]
            },
            {
              "linkId": "434121826556_helpText",
              "type": "display",
              "text": "Establish continuous monitoring to detect and respond to security events within systems and communications.",
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
          "linkId": "434121826556",
          "text": "3. Monitoring Implementation"
        },
        {
          "item": [
            {
              "type": "display",
              "linkId": "375737094397",
              "text": "Note: Ensure these documents are readily available with your other compliance documentation for review"
            },
            {
              "linkId": "794317413983_helpText",
              "type": "display",
              "text": "List your supporting documentation and ensure these documents are available with your other compliance documentation",
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
          "type": "text",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "eg., Network Security Policy, v2.1, Firewall configuration documentation, Security monitoring procedures. "
            }
          ],
          "linkId": "794317413983",
          "text": "Supporting Documentation"
        },
        {
          "type": "text",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Any additional information, challenges or implementation notes"
            }
          ],
          "linkId": "782731881405",
          "text": "Additional Notes"
        },
        {
          "linkId": "617514452468_helpText",
          "type": "display",
          "text": "Monitor, control, and protect organizational communications (i.e., information transmitted or received by organizational information systems) at the external boundaries and key internal boundaries of the information systems.",
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
      "linkId": "617514452468",
      "text": "SC.L1-3.13.1 - Monitor and control system communications"
    },
    {
      "item": [
        {
          "type": "display",
          "linkId": "556770566326",
          "text": "Requirements: Create DMZ or separated network segments for public-facing systems to isolate them from internal networks."
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
          "linkId": "274150359667",
          "text": "Implementation Status ",
          "required": true,
          "repeats": false,
          "answerOption": [
            {
              "valueString": "Fully Implemented - DMZ/subnetworks properly isolate public systems"
            },
            {
              "valueString": "Partially Implemented - Some separation exists but not comprehensive"
            },
            {
              "valueString": "Not Implemented - No network separation for public systems"
            }
          ]
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
              "linkId": "956471776047",
              "text": "What publicly accessible system components does your organization operate?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Web servers"
                },
                {
                  "valueString": "Email servers (public-facing)"
                },
                {
                  "valueString": "DNS servers"
                },
                {
                  "valueString": "FTP servers"
                },
                {
                  "valueString": "VPN gateways"
                },
                {
                  "valueString": "Remote access servers"
                },
                {
                  "valueString": "API gateways"
                },
                {
                  "valueString": "No publicly accessible components"
                }
              ]
            },
            {
              "linkId": "194546217130_helpText",
              "type": "display",
              "text": "Identify and manage system components like web servers, email servers, and public applications that are accessible to external users",
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
          "linkId": "194546217130",
          "text": "1. Publicly Accessible System Components"
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
              "linkId": "517448335213",
              "text": "How are publicly accessible systems separated from internal networks?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Demilitarized Zone (DMZ) implementation"
                },
                {
                  "valueString": "Virtual LAN (VLAN) segmentation"
                },
                {
                  "valueString": "Physical network separation"
                },
                {
                  "valueString": "Firewall rules and access control lists"
                },
                {
                  "valueString": "Cloud-based isolation and separation"
                },
                {
                  "valueString": "Proxy servers and reverse proxies"
                }
              ]
            },
            {
              "linkId": "560463506575_helpText",
              "type": "display",
              "text": "Implement measures to separate and segment networks to limit unauthorized access and contain potential security breaches.",
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
          "linkId": "560463506575",
          "text": "2. Network Separation Implementation"
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
              "linkId": "634425708590",
              "text": "What controls prevent unauthorized access from public networks to internal networks?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Default deny policies (all traffic blocked unless explicitly allowed)"
                },
                {
                  "valueString": "Stateful firewall inspection"
                },
                {
                  "valueString": "Application-level proxy filtering"
                },
                {
                  "valueString": "Intrusion detection and prevention systems"
                },
                {
                  "valueString": "Continuous network monitoring and logging"
                },
                {
                  "valueString": "Strong authentication for any allowed connections"
                }
              ]
            },
            {
              "linkId": "126262667735_helpText",
              "type": "display",
              "text": "Control and restrict communication between networks to prevent unauthorized access and data transfer.",
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
          "linkId": "126262667735",
          "text": "3. Access Control Between Networks"
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
              "linkId": "536378863536",
              "text": "How do you monitor activity in your public-facing network segments?",
              "repeats": true,
              "answerOption": [
                {
                  "valueString": "Security Information and Event Management (SIEM) system"
                },
                {
                  "valueString": "Network monitoring tools and dashboards"
                },
                {
                  "valueString": "Automated log analysis and alerting"
                },
                {
                  "valueString": "Regular vulnerability scanning"
                },
                {
                  "valueString": "Periodic penetration testing"
                },
                {
                  "valueString": "Manual log review and analysis"
                }
              ]
            },
            {
              "linkId": "414442892901_helpText",
              "type": "display",
              "text": "Continuously monitor demilitarized zones (DMZ) and public networks to detect and respond to potential security threats.",
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
          "linkId": "414442892901",
          "text": "4. DMZ/Public Network Monitoring"
        },
        {
          "item": [
            {
              "type": "display",
              "linkId": "561948412525",
              "text": "Note: Ensure these documents are readily available with your other compliance documentation for review"
            },
            {
              "linkId": "980001173858_helpText",
              "type": "display",
              "text": "List your supporting documentation and ensure these documents are available with your other compliance documentation",
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
          "type": "text",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "eg., Network Security Policy, v2.1, Firewall configuration documentation, Security monitoring procedures. "
            }
          ],
          "linkId": "980001173858",
          "text": "Supporting Documentation"
        },
        {
          "type": "text",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/entryFormat",
              "valueString": "Any additional information, challenges or implementation notes"
            }
          ],
          "linkId": "597392284230",
          "text": "Additional Notes"
        },
        {
          "linkId": "587208645662_helpText",
          "type": "display",
          "text": "Implement subnetworks for publicly accessible system components that are physically or logically separated from internal organizational networks.",
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
      "linkId": "587208645662",
      "text": "SC.L1-3.13.5 - Implement subnetworks for publicly accessible components"
    }
  ]
}

```