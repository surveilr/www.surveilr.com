---
title:  Rclone
description: File management platform
---

This documentation provides comprehensive instructions for installing and
configuring Rclone, a powerful command-line program for syncing files and
directories to various cloud storage providers.

#### Prerequisites

Before you begin, make sure you have the following:

- A working internet connection.
- Appropriate permissions to install software on your system.

### Installation Steps

##### Install rclone

Rclone is single executable (rclone, or rclone.exe on Windows) that you can
simply download and install from the
[official website](https://rclone.org/downloads/)

Alternatively, you can use the Eget binary installer:

- ##### Eget binary installer

```bash
curl https://zyedidia.github.io/eget.sh | sh
sudo mv eget /usr/local/bin/
```

- ##### Install rclone

```bash
eget --download-only --asset linux-amd64.deb  rclone/rclone
sudo dpkg -i rclone*linux-amd64.deb
```

##### Run rclone config

Run the following command to configure Rclone:

```bash
rclone config
```

---

## Rclone Setup with SFTP

This guide provides step-by-step instructions for configuring Rclone with SFTP.

#### Prerequisites

Before you start, ensure you have the following:

- A working internet connection.
- Create an ssh key for passwordless login

#### Configure Rclone

##### If you're not using key based password less login , pass in the credentials:

```bash
rclone config create sftp sftp <host> user <username>  pass <password> port <port>
```

##### If you have a public key, follow the command below:

```bash
rclone config create sftp sftp <host> user <username> port <port> key_file <path-to-the-key-file>
```

##### Once configured, you can copy files using:

```bash
rclone copy <file-name> <rclone-remote-name>:<remote-path-to-copy>
```

---

## Configure AWS S3 as storage provider

This guide provides step-by-step instructions for configuring Rclone with AWS
S3.

#### Prerequisites

Before you start, ensure you have the following:

- A working internet connection.
- AWS Access Key ID and Secret Access Key.
- AWS bucket with respective policy

##### Step 1: Create a AWS bucket and add respective policy

- login to aws account and Navigate to S3
- Click the "Create bucket" button.
- Enter a unique and meaningful name for your bucket.
- Choose a region for your bucket.
- Configure other settings as needed and click "Create bucket."

##### Navigate to S3:

- In the S3 dashboard, click on the bucket you just created.
- Click on the "Permissions" tab.
- Block public access disable this
- Scroll down to the "Bucket policy" section and click "Edit."
- Add a bucket policy specifying the permissions. Here's an example policy

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::652710155969:user/username"
            },
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::bucketname/*",
                "arn:aws:s3:::bucketname"
            ]
        }
    ]
}
```

##### Step 2: Configure Rclone

Run the following command in your terminal to configure Rclone:

```
rclone config create resource-surveillance s3 provider AWS access_key_id <key_id> secret_access_key <access_key> region <region> acl bucket-owner-full-control
```

Change the values with your values

#### Start Using Rclone

```
You're now ready to use Rclone for managing files on AWS S3!
```

##### You can now use Rclone for various operations. For example, to copy local files to your S3 bucket:

```
rclone copy <file-name> <rclone-remote-name>:<bucket_name>
```

---

## Configure OneDrive as storage provider

This guide provides step-by-step instructions for configuring Rclone with
Microsoft OneDrive

### Creating Client ID for OneDrive Business

This guide provides step-by-step instructions on how to create a Client ID for
OneDrive Business to integrate with your application.

#### Prerequisites

Before you begin, make sure you have the following:

- Microsoft 365 Business account with administrative privileges.
- Access to the Azure portal (https://portal.azure.com/).

##### 1. Log in to the Azure Portal

Visit [Azure Portal](https://portal.azure.com/) and log in with your Microsoft
365 Business account.

##### 2. Navigate to Azure Active Directory

In the left navigation pane, select "Azure Active Directory."

##### 3. App Registrations

Navigate to "App registrations" under the "Manage" section.

##### 4. New Registration

Click on "New registration" to create a new application registration.

##### 5. Configure the Application

- **Name:** Provide a name for your application.
- **Supported account types:** Accounts in this organizational directory only
  (Single tenant)
- **Redirect URI:** Enter the redirect URI for your
  application.(`http://localhost:53682/`)
- **Certificates & secrets:** Under manage select Certificates & secrets, click
  New client secret. Enter a description (can be anything) and set Expires to 24
  months. Copy and keep that secret Value for later use (you won't be able to
  see this value afterwards).
- **Search and select the following permissions:** Files.Read, Files.ReadWrite,
  Files.Read.All, Files.ReadWrite.All, offline_access, User.Read and
  Sites.Read.All (if custom access scopes are configured, select the permissions
  accordingly). Once selected click Add permissions at the bottom.

- Find YOUR_TENANT_ID of your organization.

In the rclone config, set auth_url to
https://login.microsoftonline.com/YOUR_TENANT_ID/oauth2/v2.0/authorize

In the rclone config, set token_url to
https://login.microsoftonline.com/YOUR_TENANT_ID/oauth2/v2.0/token

#### Configure Rclone

Run the following command in your terminal to configure Rclone:

```
rclone config
```

This will guide you through an interactive setup process:

```
e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> n
name> <name for rclone>
Type of storage to configure.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
[snip]
XX / Microsoft OneDrive
   \ "onedrive"
[snip]
Storage> onedrive
Microsoft App Client Id
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_id>
Microsoft App Client Secret
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_secret>
Edit advanced config? (y/n)
y) Yes
n) No
y/n> n
Remote config
Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.
y) Yes
n) No
y/n> y
If your browser doesn't open automatically go to the following link: http://127.0.0.1:53682/auth
Log in and authorize rclone for access
Waiting for code...
Got code
Choose a number from below, or type in an existing value
 1 / OneDrive Personal or Business
   \ "onedrive"
Your choice> 1
Found 1 drives, please select the one you want to use:
0: OneDrive (business) id=b!Eqwertyuiopasdfghjklzxcvbnm-xxxxxxxxxxxxxxxxxxxx
Chose drive to use:> 0
Found drive 'root' of type 'business', URL: https://org-my.sharepoint.com/personal/you/Documents
Is that okay?
y) Yes
n) No
y/n> y
--------------------
[one-drive]
type = onedrive
token = {"access_token":"youraccesstoken","token_type":"Bearer","refresh_token":"yourrefreshtoken","expiry":"2018-08-26T22:39:52.486512262+08:00"}
drive_id = b!Eqwertyuiopasdfghjklzxcvbnm-xxxxxxxxxxxxxxxxxxxx
drive_type = business
--------------------
y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y
```

#### Start Using rclone

You're now ready to use rclone for managing files on Microsoft OneDrive

###### Copy your RSSD SQLite .db file to OneDrive Aggregrated RSSD remote drive.

```bash
rclone copy /path/to/file/resource-surveillance-$(hostname).sqlite.db one-drive:opsfolio-arssd
```
