---
title: Frequently Asked Questions (FAQs)
description: Answers to all Frequently asked questions by our users.
tableOfContents: false
---


<details class="details" open>

<summary class="faq">
<h6>Why should I use Surveilr?</h6>
</summary>

<p>Surveilr is the better option for gathering compliance proof through machine
attestation, which is why you should use it. Code, test results, emails,
issues/tickets, and wikis are examples of machine attestation artifacts that
Surveilr's agent can use to conclusively demonstrate adherence to security,
privacy, safety, and regulatory compliance policies—as opposed to human
attestation, which depends on trust and manual processes. Through the use of
this method, people can verify information more quickly and accurately by
avoiding the need to complete forms, respond to emails, or take up time in
meetings. Compared to conventional human-based approaches, Surveilr's machine
attestation technology offers a dependable and automated means of verifying
policy compliance, hence improving security and regulatory adherence.</p>

</details>

<details class="details">

<summary class="faq"><h6>How do I install Surveilr?</h6></summary>

<p>We have provided a detailed guide on how to install `surveilr` on your machine
(Linux, Windows, and MacOS ), find it <a href="/surveilr/how-to/installation-guide">here</a>.</p>

</details>

<details class="details">

<summary class="faq"><h6>What are the minimum system requirements to run Surveilr?</h6></summary>

<p>While surveilr can run on low-performing systems, we recommend at least a dual-core processor, 2GB of RAM, and 8GB of available disk space for optimal performance.</p>

</details>

<details class="details">

<summary class="faq"><h6>How do I use Surveilr?</h6></summary>

<p>We have provided a comprehensive guide on how surveilr can be used to gather
machine-attested compliance evidences from different Work Product Artifacts
(WPAs) across a wide variety of disciplines. Here's an example of how
<a href="/surveilr/disciplines/software-engineer">software engineers</a> make use of
surveilr.</p>

</details>

<details class="details">

<summary class="faq"><h6>Will my data such as emails be tracked by Opsfolio?</h6></summary>

<p>No, Opsfolio does not track personal information, including emails, at any point
in time. All data processed by Surveilr is stored in a Resource Surveillance
State Database <a href="/surveilr/reference/concepts/resource-surveillance#rssd">(RSSD)</a>
that is stored locally on the client's machine, and not connected to any of our
cloud databases.</p>

</details>

<details class="details">

<summary class="faq"><h6>If my data is tracked by the company, how can I trust that my data is safe?</h6></summary>

<p>We do not track your data, so you can be rest assured your data is safe.</p>

</details>

<details class="details">

<summary class="faq"><h6>I have generated the RSSD files, now what's the next step from this?</h6></summary>

<p>The next step is to navigate to the <a href="/surveilr/disciplines/software-engineer">disciplines and WPAs</a> page, choose your discipline, and see various ways you can extract machine-attested compliance evidences from the RSSD using SQL, depending on the <a href="/surveilr/reference/concepts/work-product-artifacts">Work Product Artifact (WPA)</a>. Here's an example of how
<a href="/surveilr/disciplines/software-engineer">software engineers</a> extract compliance evidences from the <a href="/surveilr/reference/concepts/resource-surveillance">RSSD</a> file.</p>

</details>

<details class="details">

<summary class="faq"><h6>While using the IMAP ingestion how can I exclude confidential email from getting ingested in the RSSDs?</h6></summary>

<p>Specific emails boxes are authorized via credentials that you supply. Usually, operational emails are sent to individual purpose-specific mailboxes (not personal) so if you can segregate by mailbox then no confidential emails will ever be ingested. If you have a mailbox which might have mixed content, we have filters that allow you to only pick up emails using regular expressions and search expressions to match specific content only.</p>

</details>


<details class="details">

<summary class="faq"><h6>How does the tool perform under high data loads?</h6></summary>

<p>It performs very well with full horizontal and vertical scaling capabilities. Many workloads are performed offline with very low CPU, memory, and I/O impacts.</p>

</details>

<details class="details">

<summary class="faq"><h6>How will we be using these RSSD files for auditing or compliance check?</h6></summary>

<p>How the RSSD files will be used for auditing and compliance check is dependent on various disciplines and the their policies. To get started,  navigate to the <a href="/surveilr/disciplines/software-engineer">disciplines and WPAs</a> page, choose your discipline, and see various ways you can extract machine-attested compliance evidences from the RSSD using SQL, depending on the <a href="/surveilr/reference/concepts/work-product-artifacts">Work Product Artifact (WPA)</a>. Here's an example of how
<a href="/surveilr/disciplines/software-engineer">software engineers</a> extract compliance evidences from the <a href="/surveilr/reference/concepts/resource-surveillance">RSSD</a> file.</p>

</details>

<details class="details">

<summary class="faq"><h6>Will we be using this RSSD file in Opsfolio Suite for auditing or in some other way?</h6></summary>

<p>Yes, RSSDs are used for auditing in Opsfolio Suite but because they are simple SQLite databases they can also be used for anything else your company would like.</p>

</details>

