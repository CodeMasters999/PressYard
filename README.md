# 🛠️ PressYard - Manage WordPress Local Environments Easily

[![Download PressYard](https://img.shields.io/badge/Download-PressYard-brightgreen)](https://github.com/CodeMasters999/PressYard)

---

PressYard helps you create isolated WordPress environments using Docker. It sets up each environment with its own clean local web address. You can copy, rename, and start these isolated setups easily on your Windows PC. This lets you develop and test WordPress sites, plugins, and themes without affecting other projects.

## 📋 What is PressYard?

PressYard is a simple tool for managing local WordPress sites. It uses Docker and Docker Compose to create separate containers for each environment. These containers run services like WordPress, PHP, MariaDB, and a reverse proxy (Traefik) to handle clean URLs.

You do not need deep technical skills. PressYard uses scripts that run on PowerShell in Windows. It simplifies creating, cloning, and running WordPress setups that behave like live sites on your computer.

---

## 💻 System Requirements

Before you use PressYard, make sure your system meets these requirements:

- Windows 10 or later (64-bit)
- Docker Desktop installed and running
- PowerShell 5.1 or later
- At least 4 GB of free RAM
- At least 10 GB of free disk space
- Internet connection for downloading Docker images

### Installing Docker Desktop on Windows

If you do not have Docker Desktop, download it from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop). Follow the official installation guide for Windows. Make sure to enable the WSL 2 backend during installation for best performance.

---

## 🚀 Getting Started with PressYard

### Step 1: Download PressYard

Click the green button below or visit the provided link to get the latest version of PressYard:

[![Download PressYard](https://img.shields.io/badge/Download-PressYard-brightgreen)](https://github.com/CodeMasters999/PressYard)

You will be taken to the PressYard GitHub page. From there, you can download the repository as a ZIP file. Select the "Code" button and then "Download ZIP."

### Step 2: Extract the Files

Once the ZIP file downloads, open it and extract all files to a folder on your computer. For example, you might create a folder named `PressYard` on your Desktop.

### Step 3: Prepare Your Environment

Open PowerShell as Administrator:

1. Click the Start menu.
2. Type `PowerShell`.
3. Right-click on Windows PowerShell.
4. Choose `Run as Administrator`.

Navigate to the folder where you extracted PressYard. In PowerShell, type:

```powershell
cd C:\Users\YourName\Desktop\PressYard
```

Replace the path with the location where you extracted the files.

### Step 4: Run the Setup Script

In the PowerShell window, run the main setup script by typing:

```powershell
.\setup.ps1
```

This script will check your system for Docker and prepare the configuration files you need. It may take a few minutes to complete.

---

## ⚙️ How to Use PressYard

### Creating a New WordPress Environment

To create a new WordPress site, use the following PowerShell command from your PressYard folder:

```powershell
.\create.ps1 -name MySite
```

Replace `MySite` with a name for your environment. PressYard will copy the base environment files, set up a Docker container for WordPress, PHP, and MariaDB, and start the services.

### Access the Site Locally

Once the setup completes, open your web browser and visit:

```
http://mysite.localhost
```

Replace `mysite` with your chosen environment name. This URL is clean and isolated on your computer. Each environment uses a unique address like this.

---

### Managing Environments

You can list all environments you have created by running:

```powershell
.\list.ps1
```

To stop an environment from running, use:

```powershell
.\stop.ps1 -name MySite
```

To start it again:

```powershell
.\start.ps1 -name MySite
```

### Renaming an Environment

If you want to rename an existing environment, use:

```powershell
.\rename.ps1 -oldName MySite -newName NewSite
```

This copies and adjusts all relevant files and settings. After renaming, use the new local URL shown when the environment starts.

---

## 🔧 Technical Details

- **Docker Containers Used:**
  - WordPress (latest stable version)
  - MariaDB (for database)
  - PHP 8.x (configured for WordPress)
  - Traefik (reverse proxy to manage URLs)

- **Local URLs Format:**  
  `http://[environment-name].localhost`

- **PowerShell Scripts:**
  - `setup.ps1` to initialize the project
  - `create.ps1` to make new environments
  - `start.ps1` and `stop.ps1` to control services
  - `rename.ps1` to change environment names
  - `list.ps1` to show all environments

- **Configuration Files:**
  - `docker-compose.yml` handles the services for each environment
  - `.env` files define environment variables and ports

---

## 🛠 Troubleshooting Tips

- **Docker Not Running?**  
  Make sure Docker Desktop is started and running on your Windows system.

- **Script Fails to Run?**  
  Check if PowerShell script execution is enabled. Run PowerShell as Administrator and enter:

  ```powershell
  Set-ExecutionPolicy RemoteSigned
  ```

- **Local URL Does Not Work?**  
  PressYard modifies your `hosts` file to add `.localhost` entries. Make sure you run PowerShell as Administrator to allow the script to edit it.

- **Images Not Downloading?**  
  Check your internet connection and Docker Desktop status.

---

## 📥 Download and Install PressYard

Return to the PressYard GitHub page for the latest files:

[![Download PressYard](https://img.shields.io/badge/Download-PressYard-brightgreen)](https://github.com/CodeMasters999/PressYard)

Follow the steps above to extract, set up, and start your WordPress environments.

---

## 📚 Additional Resources

- Official Docker Desktop for Windows: https://www.docker.com/products/docker-desktop  
- PowerShell Script Execution Policies: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy  
- WordPress Local Development Tips: https://developer.wordpress.org/apis/handbook/

---

## 🔎 About This Project

PressYard targets developers and designers who want to work on WordPress projects locally without interfering with their main system. It speeds up setup time for testing themes and plugins by providing clean, isolated environments with local URLs.

Topics related to PressYard include:

`dev-environment`, `developer-tools`, `docker`, `docker-compose`, `local-development`, `localhost`, `mariadb`, `php`, `powershell`, `self-hosted`, `traefik`, `wordpress`, `wordpress-development`, `wordpress-plugin`, `wordpress-theme`.