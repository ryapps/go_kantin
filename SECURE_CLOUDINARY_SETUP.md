# Secure Cloudinary Setup Guide

## Important Security Notice

Currently, your application is sending the API key from the client side, which is a security risk. For production applications, you should use unsigned uploads with upload presets.

## Recommended Setup: Unsigned Upload Preset

### Step 1: Create an Upload Preset in Cloudinary

1. Log in to your Cloudinary dashboard
2. Navigate to **Settings** → **Upload** 
3. Scroll down to **Upload presets**
4. Click **Add upload preset**
5. Fill in the form:
   - **Name**: Choose a unique name (e.g., `kantin_app_upload`)
   - **Mode**: Select **Unsigned**
   - **Folder**: Optionally specify a folder name to organize uploads
   - **Incoming transformations**: Add any transformations you want applied to all uploaded images (optional)
6. Click **Save upload preset**

### Step 2: Update Your Configuration

Update the `lib/core/config/cloudinary_config.dart` file:

```dart
static const String uploadPreset = 'YOUR_UPLOAD_PRESET_NAME'; // Replace with your actual preset name
```

### Step 3: Update Your Cloudinary Service

The service is already configured to use the upload preset when available.

## Alternative: Server-Side Upload (Most Secure)

For maximum security, consider implementing image upload through your own server endpoint that then forwards to Cloudinary. This keeps all credentials on your server.

## Current Configuration Security Issues

⚠️ **Warning**: Your current configuration exposes your API key in the client code. This is acceptable for development but should be changed before production.

The current setup:
- Uses `ml_default` upload preset (which may not exist or be properly configured)
- Falls back to signed upload with API key exposure

## Testing the Setup

After configuring the upload preset:

1. Run your Flutter app
2. Try uploading an image
3. Check the debug console for any error messages
4. Verify the image appears in your Cloudinary Media Library

## Troubleshooting Common Issues

- **"Bad Request" error**: Usually caused by incorrect upload preset name or missing required fields
- **401 Unauthorized**: May indicate invalid API key or cloud name
- **File too large**: Cloudinary free tier has 10MB limit per file
- **Unsupported format**: Ensure the file is in a supported format (JPEG, PNG, GIF, etc.)

## Best Practices

1. Always use unsigned upload presets for client-side uploads
2. Implement proper error handling and user feedback
3. Validate file types and sizes before upload
4. Consider compressing images before upload to reduce bandwidth
5. Store only the public ID and derive URLs dynamically when possible