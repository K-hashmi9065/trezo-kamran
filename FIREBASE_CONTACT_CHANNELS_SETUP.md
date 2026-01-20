# Firebase Setup Guide for Contact Support Channels

## Current Implementation

The app now fetches contact channels from Firebase in the following order:

1. First tries: `support_menu/contact_support/channels` (subcollection)
2. If empty, tries: `customer_support` (collection) ✅ **This matches your current Firebase structure**

## Your Firebase Structure (Based on Screenshot)

You have a `customer_support` collection with the following structure:

### Collection: `customer_support`

Each document in this collection represents one channel. Here's how to set them up:

#### Document: `customer_support` (or any channel name)

```
{
  "icon": "",  // Icon identifier (see supported icons below)
  "link": "+1234567890",  // The URL, phone number, or email
  "name": "Customer Support",  // Display name
  "order": 1  // Optional: Order for sorting (lower numbers appear first)
}
```

#### Document: `facebook`

```
{
  "icon": "facebook",
  "link": "https://facebook.com/yourpage",
  "name": "Facebook",
  "order": 4
}
```

#### Document: `instagram`

```
{
  "icon": "instagram",
  "link": "https://instagram.com/yourprofile",
  "name": "Instagram",
  "order": 6
}
```

#### Document: `twitter`

```
{
  "icon": "twitter",
  "link": "https://twitter.com/yourhandle",
  "name": "X (formerly Twitter)",
  "order": 5
}
```

#### Document: `website`

```
{
  "icon": "website",
  "link": "https://yourwebsite.com",
  "name": "Website",
  "order": 2
}
```

#### Document: `whatsapp`

```
{
  "icon": "whatsapp",
  "link": "https://wa.me/1234567890",
  "name": "WhatsApp",
  "order": 3
}
```

## Supported Icon Values

Set the `icon` field to one of these values:

- `"whatsapp"` → Green message icon 💬
- `"email"` → Blue email icon 📧
- `"customer_support"` → Blue email icon 📧
- `"phone"` → Blue phone icon 📞
- `"facebook"` → Blue Facebook icon
- `"instagram"` → Pink camera icon 📷
- `"twitter"` or `"x"` → Light blue @ icon
- `"website"` → Blue globe icon 🌐
- Any other value or empty → Grey link icon 🔗

## Link Formats

### WhatsApp

```
"link": "https://wa.me/1234567890"
```

Replace `1234567890` with your WhatsApp number (with country code, no + or spaces)

### Email

```
"link": "mailto:support@yourdomain.com"
```

### Phone

```
"link": "tel:+1234567890"
```

### Website/Social Media

```
"link": "https://yourwebsite.com"
"link": "https://facebook.com/yourpage"
"link": "https://instagram.com/yourprofile"
"link": "https://twitter.com/yourhandle"
```

## How to Add Channels in Firebase Console

1. Open Firebase Console
2. Go to Firestore Database
3. Find or create the `customer_support` collection
4. Click "Add document"
5. Set the Document ID (e.g., `whatsapp`, `facebook`, `email`)
6. Add these fields:
   - `icon` (string): Icon identifier
   - `link` (string): The URL/phone/email
   - `name` (string): Display name
   - `order` (number): Sort order (optional)
7. Click "Save"

## Example: Complete Firebase Setup

```
customer_support (collection)
│
├── customer_support
│   ├── icon: "email"
│   ├── link: "mailto:support@yourapp.com"
│   ├── name: "Customer Support"
│   └── order: 1
│
├── website
│   ├── icon: "website"
│   ├── link: "https://yourapp.com"
│   ├── name: "Website"
│   └── order: 2
│
├── whatsapp
│   ├── icon: "whatsapp"
│   ├── link: "https://wa.me/1234567890"
│   ├── name: "WhatsApp"
│   └── order: 3
│
├── facebook
│   ├── icon: "facebook"
│   ├── link: "https://facebook.com/yourpage"
│   ├── name: "Facebook"
│   └── order: 4
│
├── twitter
│   ├── icon: "x"
│   ├── link: "https://twitter.com/yourhandle"
│   ├── name: "X (formerly Twitter)"
│   └── order: 5
│
└── instagram
    ├── icon: "instagram"
    ├── link: "https://instagram.com/yourprofile"
    ├── name: "Instagram"
    └── order: 6
```

## Testing

After setting up your Firebase data:

1. Run your app
2. Navigate to Help & Support
3. Tap on "Contact Support"
4. You should see all channels listed with their icons and names
5. Tap any channel to open the link

## Troubleshooting

### Channels not showing up?

- Check Firebase Console → Firestore → `customer_support` collection
- Verify all documents have `name` and `link` fields
- Check Firebase rules allow reading the collection
- Look at app logs for error messages

### Icons not showing correctly?

- Check the `icon` field value matches one of the supported icons
- Make sure the value is lowercase
- If empty or unsupported, a default grey link icon will show

### Channels in wrong order?

- Add/update the `order` field (number type)
- Lower numbers appear first
- If no order field, channels appear in random order
