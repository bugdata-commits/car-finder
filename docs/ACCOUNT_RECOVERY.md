# CarFinder account recovery

CarFinder supports three recovery paths in the authentication modal:

1. **Email reset link** uses `supabase.auth.resetPasswordForEmail()` and opens the new-password form after the user follows the secure recovery link.
2. **Email one-time code** uses `signInWithOtp({ email })` and `verifyOtp({ email, token, type: "email" })`. The Supabase email template must include `{{ .Token }}` if the project should send a numeric code rather than a magic link.
3. **Phone one-time code** uses `signInWithOtp({ phone })` and `verifyOtp({ phone, token, type: "sms" })`.

## Required Supabase configuration

- Email recovery must have the production and local app URLs in Authentication → URL Configuration.
- Phone OTP requires Phone authentication to be enabled and an SMS provider such as Twilio, Twilio Verify, MessageBird, Vonage, or TextLocal.
- Use international phone numbers such as `+263771234567`.
- Configure rate limits and CAPTCHA before enabling public phone OTP to control SMS abuse and cost.
- Add test phone numbers with fixed codes in Supabase when testing without sending real SMS.

The website never receives or stores a user's password or OTP. The Google and phone provider secrets stay in Supabase configuration, not in `index.html`.
