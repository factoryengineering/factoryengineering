# Azure Static Web Apps Deployment Setup

This guide walks through setting up GitHub Actions to build and deploy the Factory Engineering Astro documentation site to Azure Static Web Apps with the custom domain `factoryengineering.dev`.

## Prerequisites

- GitHub repository: `michaellperry/factoryengineering`
- Custom domain: `factoryengineering.dev` (hosted at DNSimple)
- Azure account with appropriate permissions

## Step 1: Create Azure Static Web App

1. **Go to Azure Portal** (portal.azure.com) and sign in

2. **Create a new Static Web App:**
   - Click "Create a resource" → Search for "Static Web App"
   - Click "Create"

3. **Configure the basics:**
   - **Subscription**: Choose your subscription
   - **Resource Group**: Create new or use existing
   - **Name**: `factoryengineering` (or your preferred name)
   - **Plan type**: Choose Free (perfect for getting started) or Standard (if you need custom domains and enterprise features)
   - **Region**: Choose closest to your users
   - **Deployment source**: Select "GitHub"

4. **GitHub Integration:**
   - Click "Sign in with GitHub"
   - Authorize Azure
   - **Organization**: `michaellperry`
   - **Repository**: `factoryengineering`
   - **Branch**: `main`

5. **Build Details:**
   - **Build Presets**: Select "Custom"
   - **App location**: `/` (root)
   - **Api location**: Leave empty (no API)
   - **Output location**: `dist`

6. **Review + Create** → Wait for deployment (takes ~2 minutes)

## Step 2: GitHub Actions Workflow (Auto-Generated)

Azure will automatically create a GitHub Actions workflow file in your repository at `.github/workflows/azure-static-web-apps-<random-id>.yml`. This workflow will:
- Trigger on push to `main` and on pull requests
- Build your Astro site
- Deploy to Azure

The workflow will look something like this:

```yaml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - main

jobs:
  build_and_deploy_job:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_<ID> }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"
          api_location: ""
          output_location: "dist"

  close_pull_request_job:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_<ID> }}
          action: "close"
```

## Step 3: Configure Custom Domain (factoryengineering.dev)

Once your Azure Static Web App is deployed:

### In Azure Portal

1. Go to your Static Web App resource
2. Click "Custom domains" in the left menu
3. Click "+ Add" → Select "Custom domain on other DNS"
4. Enter your domain: `factoryengineering.dev`
5. Azure will show you a TXT record to verify ownership

### In DNSimple

1. Log into your DNSimple account
2. Select the `factoryengineering.dev` domain
3. Go to DNS records
4. Add the TXT record Azure provided (for verification)
5. Add a CNAME record:
   - **Name**: `@` (or leave blank for apex domain)
   - **Type**: `ALIAS` or `CNAME`
   - **Value**: The Azure-provided hostname (e.g., `<generated-name>.azurestaticapps.net`)

   *Note: For apex domains (no www), DNSimple supports ALIAS records. If using www, use CNAME.*

### Complete the Setup

1. Back in Azure Portal, click "Validate" to verify the TXT record
2. Once validated, Azure will automatically provision an SSL certificate (takes 5-10 minutes)

### Optional - Add www subdomain

- In Azure, add `www.factoryengineering.dev` as another custom domain
- In DNSimple, add another CNAME for `www` → Azure hostname

## Step 4: Test the Deployment

After everything is set up:

1. **Push a commit to trigger the GitHub Action:**
   ```bash
   git commit --allow-empty -m "Trigger deployment"
   git push
   ```

2. **Watch the GitHub Actions run at:**
   ```
   https://github.com/michaellperry/factoryengineering/actions
   ```

3. **Once complete, visit:**
   - Azure temporary URL: `https://<generated-name>.azurestaticapps.net`
   - Your custom domain: `https://factoryengineering.dev`

## Optional Enhancements

### Add Staging Environment

Azure Static Web Apps automatically creates preview environments for pull requests, giving you a unique URL to preview changes before merging.

### Add Build Caching

Optimize the GitHub Actions workflow by caching node_modules:

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v3
  with:
    node-version: '18'
    cache: 'npm'
```

### Configure Build Environment Variables

If your site needs environment variables during build:

1. In Azure Portal, go to your Static Web App
2. Click "Configuration" in the left menu
3. Add environment variables under "Application settings"

## Project Configuration

### Build Configuration

- **Package Manager**: npm
- **Build Command**: `npm run build` (runs `astro build`)
- **Output Directory**: `dist`
- **Node Version**: 18.x or higher

### Framework Details

This site uses:
- **Astro** (v5.16.4) - Static site generator
- **Starlight** - Documentation theme
- **Tailwind CSS** (v4) - Styling
- **TypeScript** - Type safety

## Troubleshooting

### Build Fails

- Check the GitHub Actions logs for specific errors
- Ensure all dependencies are in `package.json`
- Verify the output location is set to `dist`

### Custom Domain Not Working

- Verify DNS records are properly configured
- Allow 5-10 minutes for SSL certificate provisioning
- Check DNS propagation using tools like `dig` or online DNS checkers

### Site Loads But Assets Missing

- Ensure the `output_location` in the workflow matches your build output directory
- Check if there are any relative path issues in your code

## Resources

- [Azure Static Web Apps Documentation](https://docs.microsoft.com/azure/static-web-apps/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Astro Documentation](https://docs.astro.build/)
- [DNSimple DNS Documentation](https://support.dnsimple.com/)
