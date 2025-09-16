# How to Set Up Virtual Desktop Infrastructure (VDI) with Azure to reduce Compliance Surface Area for CMMC

## Introduction: Why VDI with Azure Virtual Desktop Matters for CMMC

For defense contractors preparing for CMMC Level 1, one of the most powerful levers you can pull is [shrinking your Compliance Surface Area (CSA)](https://www.opsfolio.com/blog/reduce-csa-gfe-descoping/). Every laptop and remote user that touches Controlled Unclassified Information (CUI) adds scope and cost to your audit.

Setting up a Virtual Desktop Infrastructure with Azure Virtual Desktop (AVD) offers a way out: centralize all FCI/CUI processing in a secure, FedRAMP-authorized cloud enclave. Endpoints then act only as “dumb terminals” streaming a secure session, not storing sensitive data locally.

The DoD’s CMMC Scoping Guide makes this explicit:

> “An endpoint hosting a VDI client configured to not allow any processing, storage, or transmission of CUI beyond the Keyboard/Video/Mouse sent to the VDI client is considered an Out-of-Scope Asset”
> [CMMC Level 2 Scoping Guide](https://dodcio.defense.gov/Portals/0/Documents/CMMC/ScopingGuideL2.pdf)

By using AVD, you can place all CUI within a hardened environment and document endpoints as out-of-scope, simplifying compliance dramatically.

## Prerequisites

Before setting up AVD, make sure you have the needed [prerequisites identified by Microsoft](https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites?tabs=portal).

These include:

* Identity provider: Microsoft Entra ID is required; Active Directory (AD DS or Azure AD DS) is recommended for enforcing fine-grained CMMC controls  
* Windows OS licenses for session host access  
* Network connectivity to both domain controllers and AVD


## Step 1: Define Your CUI Environment

Before deploying Azure Virtual Desktop, you need to know exactly what you’re protecting and where it lives. The very first thing an assessor will do is ask:

*“Where does your organization create, process, transmit, or store Controlled Unclassified Information (CUI)?”*

If your answer is a vague “well, some files are on laptops, some on a file server, some in email,” then all of those systems fall under the assessment boundary. That means hundreds of devices, dozens of workflows, and a massive compliance burden.

The value of Azure Virtual Desktop (AVD) is that it gives you a way to draw a sharp boundary line. By routing all CUI handling into the virtual desktop enclave, you can document that only AVD session hosts are in-scope. Endpoints, personal laptops, and mobile devices can be treated as out-of-scope assets, provided they don’t retain or process CUI.

This step is as much about business process mapping as it is about IT. You need to:

* Identify where CUI enters your organization (contracts, RFQs, engineering data).
* Trace how employees access and use that data in day-to-day work.
* Decide which workflows should be migrated into the AVD enclave.

Once you’ve mapped those flows, you update your System Security Plan (SSP) to state clearly:

* *“All CUI is processed exclusively within Azure Virtual Desktop session hosts.”*
* *“Endpoints only host the AVD client and do not store or transmit CUI.”*

By doing this upfront, you shift the compliance conversation. Instead of proving controls across your entire IT footprint, you show auditors a narrowed boundary around the AVD enclave with everything else excluded.


## Step 2: Create an Azure Virtual Desktop Host Pool

Once you’ve mapped your CUI flows and drawn the boundary, the next step is to stand up the enclave itself. You’ve decided that all CUI will live inside Azure Virtual Desktop (AVD). Now you need to build the environment that will actually enforce that decision.

First, establish the foundational building block of the enclave: the AVD host pool that will house session hosts, applications, and user access.

A host pool is a collection of one or more identical virtual machines (VMs) in Azure that serve as the desktops or apps your users connect to.

Only after this base environment is deployed can you layer in compliance controls like FSLogix, Conditional Access, and clipboard/drive restrictions.

**How-To:**

1. In Azure Portal → Azure Virtual Desktop → Create a Host Pool. 

   * Microsoft docs: [Deploy Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop).

2. Then complete the information on the basics tab.

> Note on Region Selection: All U.S. commercial Azure regions are approved at FedRAMP High Impact level ([Microsoft Azure Blog](https://azure.microsoft.com/en-us/blog/all-us-azure-regions-now-approved-for-fedramp-high-impact-level/#:~:text=All%20US%20Azure%20regions%20now,impact%20level%20%7C%20Microsoft%20Azure%20Blog)). For contractors with stricter requirements (e.g., export control, IL4/IL5), Azure Government regions provide additional assurance and are often the recommended choice for CMMC enclaves.


3. On the Virtual Machines tab, configure your session hosts. 

For CMMC, the key is to deploy Windows 10/11 Enterprise multi-session images (preferably hardened) and choose Trusted Launch or Confidential VMs so that secure boot, vTPM, and disk encryption are enabled. Make sure to disable public inbound ports and join the hosts to Azure AD so MFA and Conditional Access can be enforced.

4. Create a workspace on the workspace tab.

At this stage, most contractors register the default desktop application group to a workspace to get users connected quickly. For production, however, you’ll likely want to define custom application groups to align with the principle of least privilege, publishing only the apps or desktops specific user roles require.


## Step 3: Enable FSLogix Profiles to Prevent Local CUI Persistence

By default, Windows stores user profiles locally, which may present a compliance risk. **FSLogix profile containers** redirect user data into the cloud, ensuring nothing persists on endpoints.

Microsoft describes FSLogix as a profile management tool; in compliance contexts, it is often used to demonstrate that data isn’t stored locally. By redirecting user profiles into a central, encrypted container, you prevent CUI from persisting on session hosts or endpoints. This not only simplifies scope (endpoints stay out-of-scope), it also maps to NIST 800-171 requirements for controlling and protecting CUI at rest and in transit.


**Reference:**

* [Store FSLogix profile containers on Azure Files and Active Directory Domain Services or Microsoft Entra Domain Services](https://learn.microsoft.com/en-us/fslogix/how-to-configure-profile-container-azure-files-active-directory?tabs=adds).


**Compliance Implication:** This ensures endpoints remain “dumb terminals” with no CUI at rest outside the enclave.


## Step 4: Configure Security Baselines in AVD

Before giving users access to your new enclave, you need to harden it. This is where you translate compliance principles into technical guardrails: preventing data leakage, enforcing strong authentication, and ensuring auditors see that CUI is locked inside the AVD boundary. In practice, that means combining Group Policy settings on the session hosts with Azure AD Conditional Access and built-in AVD defaults.

### How GPOs Apply in Azure Virtual Desktop

A Group Policy Object (GPO) is a set of configuration rules in Windows that you can apply across servers or desktops. In an AVD environment, GPOs control what users can and can’t do inside their virtual session, for example, blocking them from redirecting local drives, printers, or clipboards. Because session hosts must be domain-joined to Active Directory (AD DS or Azure AD DS), GPOs can be applied consistently across all VMs in the enclave.

The GPOs apply directly to the AVD session hosts, regardless of which host pool, workspace, or application group users connect through. This ensures controls like disabling drive redirection, blocking USB devices, and enforcing idle timeouts are consistently applied to every session host in the enclave. For compliance, keeping these policies centralized in a single “AVD Security Baseline” GPO makes it easier to manage and present evidence during an audit.


**Configuring Security Setings via GPO**

 * Open the Group Policy Management console in AD. Right-click Group Policy Objects → New → enter policy name → right click the policy and Edit → Computer Configuration → Policies → Administrative Templates → Windows Components → Remote Desktop Services → Remote Desktop Session Host → Device and Resource Redirection → enable "Do not allow drive redirection". 

* Back out to Device and Resource Redirection → enable "Do not allow Clipboard redirection".

* Back out to Device and Resource Redirection → enable "Do not allow supported Plug and Play device redirection"

* Back out to Remote Desktop Session Host → Printer Redirection → enable "Do not allow client printer redirection"

* Back out to Remote Desktop Session Host → Azure Virtual Desktop → enable "Enable screen capture protection"

* Computer Configuration → Windows Settings → Security Settings → Local Policies → Security Options → Interactive logon: Machine inactivity limit = 900 seconds (15 minutes)

**Access & Connectivity Controls**

* **Enforce MFA with Azure AD Conditional Access.**

  * Docs: [Conditional Access in Azure AD](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview).

* **Encrypt traffic in transit (TLS 1.2+).** Enabled by default in AVD sessions.



## Step 5: Lock Down Endpoints

Even though one of the main advantages of AVD is that endpoints can be considered out-of-scope, you still have to prove to auditors that they are not handling CUI in practice. An unmanaged laptop that can cache files, redirect drives, or bypass controls would bring those devices back into scope.

The goal here isn’t to make endpoints fully compliant, but rather to show they’re gated and restricted so CUI never lands on them. You do this at the access layer with Conditional Access and device compliance policies:

* **Use Microsoft Intune (Endpoint Manager):** Apply baseline compliance checks: require full disk encryption, antivirus/EDR, and current patches. These prove devices are healthy before they can connect.
* **Conditional Access:** Create policies that only allow AVD access from compliant devices. If a user tries from a personal laptop or unmanaged workstation, the connection is blocked.
* **Verification:** Run a test from an unmanaged device and capture a screenshot showing the access denied message. That evidence shows your access boundary is real, not theoretical.


## Step 6: Test and Validate

Once your enclave is configured, you need to prove it actually enforces the controls you’ve set. Auditors will expect evidence that redirection is blocked, Conditional Access policies work, and monitoring is in place. This step is about validating your setup from the user’s perspective and capturing artifacts like screenshots, logs, or denial messages that you can later include in your SSP or present during an assessment.

**Testing Steps:**

1. Log in to AVD from a compliant endpoint.
2. Attempt to copy/paste text → confirm blocked.
3. Try saving a file locally → confirm denied.
4. Attempt login from unmanaged laptop → confirm access blocked by Conditional Access.
5. Review Azure Monitor logs for failed access attempts.


## Step 7: Documentation and Ongoing Compliance

Standing up a secure AVD enclave is only half the battle. For CMMC, you must also prove it and keep it running. That means two things:

* **Document in your SSP:** Capture the boundary (AVD enclave in-scope, endpoints out-of-scope), map your configurations to NIST 800-171 controls, and include evidence like screenshots and policy exports. This gives auditors a clear picture of how your enclave is secured.
* **Monitor and Maintain:** Compliance isn’t one-time. Patch session hosts regularly, review Conditional Access and GPO settings quarterly, and keep your SSP updated as changes occur. Periodically validate that controls (like blocked redirection and idle timeouts) are still working as intended.

Together, these practices show auditors that your controls aren’t just set once—they’re documented, reviewed, and actively managed over time.

## Conclusion

Azure Virtual Desktop provides contractors with a clear compliance boundary: all CUI lives in a FedRAMP-authorized enclave, while endpoints remain out-of-scope.

By centralizing CUI into a FedRAMP High enclave with Azure, you simplify audits, reduce long-term risk, and give your team a defensible compliance posture as requirements evolve.

👉 Unsure whether AVD is the right fit? Our [CMMC Readiness Service](https://opsfolio.com/regime/cmmc/cmmc-readiness) helps map CSA reduction strategies, configure Azure environments correctly, and prepare audit-ready documentation.
