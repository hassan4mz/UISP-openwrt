# GitHub Actions Secrets Setup Guide

## Required Secrets for Release Builds

To enable automated signed APK and AAB builds when you create a version tag (e.g., `v1.0.0`), you need to configure the following secrets in your GitHub repository:

### How to Add Secrets

1. Go to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret** for each secret below

### Required Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `ANDROID_KEYSTORE_BASE64` | Your Android keystore file encoded in Base64 | `UEsDBBQAAAA...` |
| `ANDROID_KEYSTORE_PASSWORD` | Password for the keystore | `MySecurePassword123!` |
| `ANDROID_KEY_PASSWORD` | Password for the key alias | `MyKeyPassword456!` |
| `ANDROID_KEY_ALIAS` | Alias name for your key | `upload` |

---

## How to Generate a Keystore

### Option 1: Using Keytool (Command Line)

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You will be prompted to:
- Enter keystore password
- Enter your first and last name (organizational unit, organization, etc.)
- Enter key password (can be same as keystore password)

### Option 2: Using Android Studio

1. Open Android Studio
2. Go to **Build** → **Generate Signed Bundle / APK**
3. Select **APK** or **Android App Bundle**
4. Click **Create new...** under "Key store path"
5. Fill in the required information
6. Save the `.jks` file in a secure location

---

## How to Encode Keystore to Base64

### On Linux/macOS:

```bash
base64 upload-keystore.jks > keystore_base64.txt
```

Then copy the contents of `keystore_base64.txt` and paste it as the value for `ANDROID_KEYSTORE_BASE64` secret.

### On Windows (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File -Encoding ASCII keystore_base64.txt
```

### Alternative (Online Tool):

⚠️ **Security Warning**: Only use trusted offline tools. Never upload your keystore to online converters as it compromises your signing key security.

---

## Workflow Triggers

The GitHub Action workflow will automatically build and publish when:

### Debug APK (for testing)
- Push to `main` or `master` branch
- Pull requests to `main` or `master`
- Manual trigger via **Actions** tab → **Build Android APK** → **Run workflow**

### Release APK + AAB (for production)
- Creating a Git tag with format `v*` (e.g., `v1.0.0`, `v2.1.3`)

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This will:
1. Build signed release APK
2. Build signed App Bundle (AAB) for Google Play
3. Create a GitHub Release with both files attached
4. Generate release notes from commit messages

---

## Downloading Artifacts

### For Debug Builds (Push/PR)
1. Go to the **Actions** tab
2. Select the workflow run
3. Under **Artifacts**, click on `app-debug-apk`
4. The APK will download as a ZIP file

### For Release Builds (Tags)
1. Go to the **Releases** section of your repository
2. Find the latest release (e.g., v1.0.0)
3. Download `app-release.apk` or `app-release.aab` from the assets

---

## Security Best Practices

1. **Never commit your keystore** to the repository
2. **Keep your passwords secure** - use strong, unique passwords
3. **Backup your keystore** in multiple secure locations (losing it means you can't update your app)
4. **Use environment-specific secrets** if you have different keystores for staging/production
5. **Rotate secrets periodically** if there's any suspicion of compromise

---

## Troubleshooting

### Build fails with "keystore not found"
- Ensure all 4 secrets are correctly configured
- Check that the Base64 encoding is complete (no line breaks or truncation)

### Build fails with "password incorrect"
- Verify passwords match what you set when creating the keystore
- Check for extra spaces or special characters in secrets

### Release not created automatically
- Ensure the tag follows the `v*` pattern (e.g., `v1.0.0`)
- Check that `GITHUB_TOKEN` has write permissions (default in most repos)

### Artifact expires
- Debug artifacts expire after 30 days
- Release artifacts expire after 90 days
- Download important builds promptly or configure longer retention

---

## Manual Workflow Trigger

You can manually trigger the build without pushing code:

1. Go to **Actions** tab
2. Select **Build Android APK** workflow
3. Click **Run workflow** button
4. Choose branch and click **Run workflow**
5. Wait for completion and download from Artifacts
