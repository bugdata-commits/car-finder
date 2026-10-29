# Testing Google authentication locally

CarFinder now includes a `Continue with Google` button in the existing authentication modal. The button uses Supabase Auth and returns to the exact page that started the flow. It does not put the Google client secret in the website source.

## One-time provider setup

In Supabase, enable the Google provider and enter the Google OAuth Web Client ID and Client Secret. In Google Cloud, use a Web application OAuth client with these values:

### Authorized JavaScript origins

```text
http://localhost:4173
http://127.0.0.1:4173
```

### Authorized redirect URI

```text
https://eeodzwzxpquqwtvccqab.supabase.co/auth/v1/callback
```

In Supabase Authentication → URL Configuration, add both local URLs to Additional Redirect URLs:

```text
http://localhost:4173/**
http://127.0.0.1:4173/**
```

Keep the production Site URL and production redirect URL in place. The Google callback remains the Supabase callback; the local URL is the final destination after Supabase completes the provider login.

## Start the local site

From the repository root:

```bash
python3 -m http.server 4173 --bind 0.0.0.0
```

Open one of these in a browser on the same computer:

```text
http://localhost:4173/
http://127.0.0.1:4173/
```

Use the same hostname you added to the Supabase redirect allow-list.

## Test sequence

1. Open the local site in a private/incognito window.
2. Click **Sign in**.
3. Click **Continue with Google**.
4. Select the Google test account and approve the basic profile access.
5. Confirm that Google returns to the local CarFinder page.
6. Confirm that the header changes to the signed-in state and that **My Listings** is available.
7. Sign out and repeat once to confirm the session can be cleared.

The current implementation requests the normal Supabase Google identity flow only. It does not request Gmail, Drive, Calendar, or other sensitive Google API scopes.

## Troubleshooting

- `redirect_uri_mismatch`: the Google Cloud Authorized redirect URI is not exactly `https://eeodzwzxpquqwtvccqab.supabase.co/auth/v1/callback`.
- `invalid redirect URL`: the exact local origin/path is missing from Supabase URL Configuration, or the browser hostname does not match the allow-list entry.
- Google provider disabled: enable Google under Supabase Authentication → Providers and save the Client ID and Secret.
- App not available to test user: add the Google account under the Google OAuth app’s test users while the app is in Testing mode.
- Works once but not after changing ports: add the new port to both Google Authorized JavaScript origins and Supabase Additional Redirect URLs.

Never commit the Google Client Secret to GitHub or place it in `index.html`.
