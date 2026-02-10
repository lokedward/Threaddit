# AI Stylist Setup Guide

## Prerequisites
1. Google Cloud account with billing enabled
2. Imagen API access (may require allowlist approval)

## Setup Steps

### 1. Enable Imagen API
```bash
# First, set your project ID
gcloud config set project YOUR_PROJECT_ID

# Enable the AI Platform API
gcloud services enable aiplatform.googleapis.com
```

### 2. Create API Key (OAuth recommended for production)
For testing, you can use an API key:
1. Go to: https://console.cloud.google.com/apis/credentials
2. Click "Create Credentials" → "API Key"
3. Copy the generated key

**For production**: Use OAuth 2.0 service account instead of API keys.

### 3. Configure the App
1. Open `Config.swift`
2. Replace `YOUR_GOOGLE_API_KEY_HERE` with your API key
3. Replace `YOUR_PROJECT_ID` in the endpoint URL with your GCP project ID

Example:
```swift
struct AppConfig {
    static let googleAPIKey = "AIzaSyCa2Sg9..."
    static let imagenEndpoint = "https://us-central1-aiplatform.googleapis.com/v1/projects/my-project-123/locations/us-central1/publishers/google/models/imagen-3.0-generate-001:predict"
}
```

### 4. Test the Integration
1. Build and run the app
2. Navigate to the AI Stylist tab (hanger icon)
3. Select 2-3 clothing items from your closet
4. Tap "GENERATE LOOK"
5. Wait 10-20 seconds for the AI-generated model photo

## API Costs
- Imagen 3 pricing: ~$0.04-0.08 per image generated
- Budget recommendation: Set a daily spending limit in GCP Console
- Consider caching generated images to reduce costs

## Troubleshooting

**"Invalid API endpoint configuration"**
- Check that `imagenEndpoint` has correct project ID

**"AI service error: 403"**
- Verify API key is correct
- Ensure Imagen API is enabled for your project
- Check if you need to request access to Imagen

**"AI service error: 429"**
- You've hit rate limits
- Wait a few minutes or increase quota in GCP Console

**Generation takes too long**
- Normal: 10-20 seconds is expected
- If >30 seconds, check network connection
- Consider adding timeout handling

## Security Notes
- `Config.swift` is gitignored to prevent leaking API keys
- Never commit API keys to version control
- For production, implement server-side API calls with user authentication
