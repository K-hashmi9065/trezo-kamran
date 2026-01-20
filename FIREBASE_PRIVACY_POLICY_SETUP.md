# Firebase Setup Guide for Privacy Policy

## Firebase Structure

Based on your Firebase screenshot, here's how to structure your Privacy Policy data:

### Collection: `support_menu`

### Document: `privacy_policy`

```
support_menu (collection)
  └── privacy_policy (document)
      ├── title: "Privacy Policy"
      ├── order: 3
      ├── effective_date: "04 September, 2024"
      └── content (subcollection)
          ├── section_1 (document)
          │   ├── title: "1. Introduction"
          │   ├── body: "Welcome to Trezo. We value your privacy..."
          │   └── order: 1
          │
          ├── section_2 (document)
          │   ├── title: "2. Information We Collect"
          │   ├── body: "• Personal Information: When you create an account..."
          │   └── order: 2
          │
          ├── section_3 (document)
          │   ├── title: "3. How We Use Your Information"
          │   ├── body: "• To Provide Services: We use your data..."
          │   └── order: 3
          │
          └── ... (more sections)
```

## Detailed Structure

### Main Document: `privacy_policy`

**Required Fields:**

- `effective_date` (string): The date when the policy became effective
  - Example: `"04 September, 2024"`
- `title` (string): Display name for the menu
  - Example: `"Privacy Policy"`
- `order` (number): Order in support menu
  - Example: `3`

### Subcollection: `content`

Each document in the `content` subcollection represents one section of the privacy policy.

**Document ID Examples:**

- `section_1`
- `section_2`
- `section_3`
- etc.

**Required Fields for Each Section:**

- `title` (string): Section heading
  - Example: `"1. Introduction"`
  - Example: `"2. Information We Collect"`
- `body` (string): Section content (supports multiple paragraphs and bullet points)
  - Use `\n` for line breaks
  - Use `•` for bullet points
- `order` (number): Display order (sections will be sorted by this)
  - Example: `1`, `2`, `3`, etc.

## Example Privacy Policy Sections

### Section 1: Introduction

```json
{
  "title": "1. Introduction",
  "body": "Welcome to Trezo. We value your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and protect your data.",
  "order": 1
}
```

### Section 2: Information We Collect

```json
{
  "title": "2. Information We Collect",
  "body": "• Personal Information: When you create an account, we collect your name, email address, and password.\n\n• Usage Data: We collect information about how you use the app, including savings goals, transaction history, and interaction with features.\n\n• Device Information: We collect data about the device you use to access Trezo, including device type, operating system, and IP address.",
  "order": 2
}
```

### Section 3: How We Use Your Information

```json
{
  "title": "3. How We Use Your Information",
  "body": "• To Provide Services: We use your data to create and manage your savings goals, track progress, and provide app features.\n\n• To Improve the App: We analyze usage data to enhance user experience and add new features.\n\n• To Communicate: We may send you notifications about your goals, updates, and important information.",
  "order": 3
}
```

### Section 4: Data Security

```json
{
  "title": "4. Data Security",
  "body": "We implement industry-standard security measures to protect your personal information:\n\n• All data is encrypted in transit and at rest\n• We use Firebase Authentication for secure login\n• Regular security audits and updates\n• Access controls and monitoring",
  "order": 4
}
```

### Section 5: Your Rights

```json
{
  "title": "5. Your Rights",
  "body": "You have the right to:\n\n• Access your personal data\n• Request correction of inaccurate data\n• Request deletion of your account and data\n• Opt-out of communications\n• Export your data\n\nTo exercise these rights, please contact us through the app's support section.",
  "order": 5
}
```

### Section 6: Contact Us

```json
{
  "title": "6. Contact Us",
  "body": "If you have any questions about this Privacy Policy or how we handle your data, please contact us:\n\nEmail: privacy@trezo.com\nWebsite: www.trezo.com/privacy\n\nWe will respond to your inquiries within 48 hours.",
  "order": 6
}
```

## How to Add Sections in Firebase Console

1. **Navigate to Firestore Database**
2. **Find or create** the `support_menu` collection
3. **Find or create** the `privacy_policy` document
4. **Add the effective_date field:**
   - Field name: `effective_date`
   - Type: string
   - Value: `"04 September, 2024"` (or your date)
5. **Create the `content` subcollection:**
   - Click on the `privacy_policy` document
   - Click "Start collection"
   - Collection ID: `content`
6. **Add sections:**
   - Click "Add document"
   - Document ID: `section_1` (or auto-generate)
   - Add fields:
     - `title` (string): Section heading
     - `body` (string): Section content
     - `order` (number): Sort order
7. **Repeat** for each section

## Formatting Tips for Body Content

### Line Breaks

Use `\n` for single line breaks or `\n\n` for paragraph breaks:

```
"First paragraph.\n\nSecond paragraph."
```

### Bullet Points

Use `•` followed by a space:

```
"• First point\n• Second point\n• Third point"
```

### Combined Example

```
"Here's an introduction.\n\n• First bullet point\n• Second bullet point\n\nAnd a conclusion."
```

## Testing

After setting up your Firebase data:

1. Run your app
2. Navigate to Help & Support
3. Tap on "Privacy Policy"
4. You should see:
   - Title: "Privacy Policy"
   - Effective Date at the top
   - All sections in order
   - Properly formatted content

## Complete Example Setup

```
support_menu
  └── privacy_policy
      ├── title: "Privacy Policy"
      ├── order: 3
      ├── effective_date: "04 September, 2024"
      └── content
          ├── section_1
          │   ├── title: "1. Introduction"
          │   ├── body: "Welcome to Trezo..."
          │   └── order: 1
          ├── section_2
          │   ├── title: "2. Information We Collect"
          │   ├── body: "• Personal Information..."
          │   └── order: 2
          ├── section_3
          │   ├── title: "3. How We Use Your Information"
          │   ├── body: "• To Provide Services..."
          │   └── order: 3
          ├── section_4
          │   ├── title: "4. Data Security"
          │   ├── body: "We implement industry-standard..."
          │   └── order: 4
          ├── section_5
          │   ├── title: "5. Your Rights"
          │   ├── body: "You have the right to..."
          │   └── order: 5
          └── section_6
              ├── title: "6. Contact Us"
              ├── body: "If you have any questions..."
              └── order: 6
```

## Troubleshooting

### Privacy Policy not loading?

- Check that `support_menu/privacy_policy` document exists
- Verify the `effective_date` field is present
- Check that `content` subcollection has sections
- Verify Firebase rules allow reading the data

### Sections in wrong order?

- Check that each section has an `order` field (number type)
- Lower numbers appear first
- Make sure orders are unique

### Text not formatting correctly?

- Use `\n` for line breaks in the body field
- Use `\n\n` for paragraph breaks
- Use `•` character for bullet points
