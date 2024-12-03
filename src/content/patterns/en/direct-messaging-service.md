---
title: "Direct Secure Messaging Service"
description: "Trusted and protected health information exchange is backed by the Direct Standard®"
main:
  id: 5
  content: |
    The Direct Secure Messaging Service Pattern for surveilr ingests clinical data CCDA XML files and allows querying, summarizing episodes of care and exploration of those files.
  imgCard: "@/images/pattern/direct-message-pattern.avif"
  imgMain: "@/images/pattern/direct-message-pattern.png"
  imgAlt: "Direct Secure Messaging Service"
tabs:
  - id: "tabs-with-card-item-1"
    dataTab: "#tabs-with-card-1"
    title: "Overview"
  - id: "tabs-with-card-item-2"
    dataTab: "#tabs-with-card-2"
    title: "Capabilities"
  - id: "tabs-with-card-item-3"
    dataTab: "#tabs-with-card-3"
    title: "Screenshots"
longDescription:
  title: "Direct Secure Messaging Service"
  subTitle: |
    This pattern is designed to facilitate the secure exchange of clinical data using the phiMail service. It consists of four main modules, each serving a distinct purpose within the overall system. These modules work together to securely and efficiently send, receive, process, and analyze clinical messages.


    PhiMail is a secure messaging service that facilitates the exchange of protected health information (PHI) in compliance with healthcare regulations like HIPAA. It is designed to support healthcare providers, organizations, and other stakeholders in securely transmitting health-related data, ensuring both privacy and integrity.
  btnTitle: "Use the SQL"
  btnURL: "/lib/pattern/direct-messaging-service/package.sql"
descriptionList:
  - title: "Compliance with HIPAA"
    subTitle: "PhiMail ensures that all communications involving PHI meet the stringent requirements of the Health Insurance Portability and Accountability Act (HIPAA). This includes encryption of data in transit, secure storage, and proper handling of sensitive information."
  - title: "DIRECT Protocol Support"
    subTitle: "PhiMail is built on the DIRECT protocol, a standardized method for secure email communication in healthcare. This enables seamless and secure transmission of health information between different systems and organizations, such as hospitals, laboratories, and physician offices."
  - title: "Encryption and Security"
    subTitle: "PhiMail utilizes robust encryption mechanisms to protect data, ensuring that only authorized parties can access the information. This includes the use of SSL/TLS for secure connections and digital signatures to verify the authenticity of messages."
  - title: "Interoperability"
    subTitle: "PhiMail supports interoperability with various healthcare systems, enabling the exchange of data in different formats like CDA (Clinical Document Architecture). This allows for smooth integration with electronic health records (EHR) systems and other health information exchanges (HIEs)."
specificationsLeft:
  - title: "Message Tracking and Acknowledgments"
    subTitle: "phiMail provides detailed tracking of message delivery, including delivery status and read receipts. This is crucial in healthcare settings, where confirmation of receipt and action on health-related messages is often required."
  - title: "Scalability and Customization"
    subTitle: "phiMail can be tailored to the specific needs of healthcare organizations, whether they require a standalone messaging solution or integration with existing systems. It is scalable to accommodate the needs of small practices as well as large healthcare networks."
  - title: "Secure Attachments"
    subTitle: "phiMail supports the secure exchange of attachments, such as medical records, lab results, and other documents. These attachments are encrypted and can be managed securely within the platform."

specificationsRight:
  - title: "Clinical Communication"
    subTitle: "Facilitates the exchange of medical records, referrals, and other critical health information between providers, ensuring timely and secure communication."
  - title: "Laboratory Results"
    subTitle: "Enables labs to send results directly to providers, integrating seamlessly with EHR systems for quick access."
  - title: "Patient Communication"
    subTitle: "Allows healthcare providers to securely send and receive information directly with patients, such as test results, care instructions, or appointment reminders."

blueprints:
  first: "@/images/pattern/direct-message-ss-2.avif"
  second: "@/images/pattern/direct-message-ss-3.avif"
  third: "@/images/pattern/direct-message-ss-1.avif"
liveDemo:
  btnTitle: "Live Demo"
  btnURL: "https://eg.surveilr.com/lib/pattern/direct-messaging-service/"
---
