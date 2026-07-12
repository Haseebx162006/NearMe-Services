# ProGuard/R8 rules for NearMe Flutter App
# Suppress warnings from Stripe SDK regarding missing Push Provisioning classes

-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Wildcard to catch any other optional Push Provisioning classes from Stripe
-dontwarn com.stripe.android.pushProvisioning.**
