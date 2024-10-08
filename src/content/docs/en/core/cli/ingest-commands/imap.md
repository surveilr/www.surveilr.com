---
title: IMAP Email Ingestion
description: Documentation for the resource surveillance CLI tool.
---


Surveilr provides the capability to ingest IMAP emails directly into the RSSD (Resource Surveillance State Database) through its `surveilr ingest imap` command. This tool automates the process of fetching emails from a specified folder and batch size, transforming them into structured JSON data, and inserting the data into the RSSD's `ur_ingest_session_imap_acct_folder_message` table.

This capability extends to all email providers supporting IMAP. Additionally, for Microsoft 365 users, Surveilr facilitates seamless connectivity by providing guidance on connecting to the Microsoft Graph API, ensuring comprehensive access to email data within the platform.


### Registering an App in Azure for OAuth2
To use the `surveilr ingest imap` command with Microsoft 365 authentication methods, you need to register an app in Azure and obtain the necessary credentials (client ID and client secret). Here's how to register an app in Azure:

1. **Sign in to the** [Azure Portal](https://portal.azure.com/#home).

2. Click **Applications** to create a new app.
 ![New registration](../../../../../../assets/images/content/docs/core/cli/ingest-commands/applications.avif) 

3. In the left navigation panel, select **App registrations**  
 ![App registrations](../../../../../../assets/images/content/docs/core/cli/ingest-commands/app-registrations.avif)

1. Provide a name for your app, such as "Surveilr App" 
 ![Surveilr App](../../../../../../assets/images/content/docs/core/cli/ingest-commands/surveilr-app.avif)

1. Choose the appropriate **Supported account types** for your app by clicking on Authentication and selecting "Accounts in any organizational directory." 
 ![Authentication](../../../../../../assets/images/content/docs/core/cli/ingest-commands/authentication.avif)

1. Set the **Redirect URI** as application's redirect URL (e.g., `https://your-redirect-uri.com/redirect`). 
 ![redirect URL](../../../../../../assets/images/content/docs/core/cli/ingest-commands/redirect-url.avif)


    **Note**: Redirect URL will be a proxy pass (https) connection to the `surveilr imap ingest` service.


7. Click **Register** to create the app.

8. Once registered, navigate to the app's **Certificates & secrets** section to create a new client secret.

9. Copy the **Application (client) ID** and the newly created **client secret** as you will need them for authentication.

10. Set the necessary permissions for the application.
 ![API_permission](../../../../../../assets/images/content/docs/core/cli/ingest-commands/api-permission.avif)



After registering the app, use the client ID and secret in the surveilr ingest imap command as explained above.


### Surveilr IMAP Ingest Command
The `surveilr ingest imap` command allows you to specify an IMAP email folder and batch size for ingestion. It connects to an IMAP email server using specified authentication methods (such as OAuth 2.0) and retrieves emails based on your criteria. The emails are then formatted as JSON data and stored in the `ur_ingest_session_imap_acct_folder_message` table in the RSSD.

#### Syntax
The basic syntax of the `surveilr ingest imap` command is:


```bash
$ surveilr ingest imap -f="<email-folder>" --batch-size="<batch-size>" <auth-provider> -m <auth-method> -i="<client-id>" -s="<client-secret>"
```
Here's a breakdown of each parameter:

- **`-f`**: Specifies the email folder to ingest from (e.g., "Inbox").
- **`--batch-size`**: Specifies the number of emails to ingest per batch (e.g., "20,000").
- **`<auth-provider>`**: Specifies the authentication provider (e.g., "microsoft-365").
- **`-m`**: Specifies the authentication method (e.g., "device-code").
- **`-i`**: Specifies the client ID for authentication (e.g., "abxxxx7bxxx-xxx-xxx-xxx63c").
- **`-s`**: Specifies the client secret for authentication (e.g., "mb8xxxxx-xxxxx-xxxx-ajs").


### Methods of Authentication
There are two primary methods of authentication for the surveilr ingest imap command when using the Microsoft 365 provider:

1. **Device Code Method**: This method utilizes device code authentication for token generation.

```bash
$ surveilr ingest imap -f="Inbox" --batch-size="20000" microsoft-365 -m device-code -i="abxxxx7bxxx-xxx-xxx-xxx63c" -s="mb8xxxxx-xxxxx-xxxx-ajs"
```
2. **Auth Code Method**: This method uses authorization code flow for token generation.

```bash
$ surveilr ingest imap -f="Inbox" --batch-size="20000" microsoft-365 -m  auth-code -i="abxxxx7bxxx-xxx-xxx-xxx63c" -s="mb8xxxxx-xxxxx-xxxx-ajs" -a "https://your-redirect-uri.com"

```

### Result
The output of the command is a JSON object representing the structured data of the ingested emails. This data is automatically inserted into the `ur_ingest_session_imap_acct_folder_message` table in the RSSD.

### Additional Usage Options
In addition to the folder and batch size, there are several other options that you can specify for the `surveilr ingest imap` command:

- **`-d`**: Specify the target SQLite database.
- **`-I`**: Specify SQL files for batch execution.
- **`-u`**: Specify the email address (username).
- **`-p`**: Specify the password (mainly an app password).
- **`-a`**: Specify the IMAP server address.
- **`--port`**: Specify the IMAP server port.
- **`-e`**: Choose whether to extract attachments.
- **`--progress`**: Choose whether to display progress animation.



### Conclusion
By utilizing Surveilr's `surveilr ingest imap` command, you can efficiently ingest IMAP emails into the RSSD for further analysis and processing. This allows for seamless integration of email data with other surveillance data in your system.

