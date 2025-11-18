# Secure Authentication with a Push Notification in Your iOS Device

This repository shows you how to build a Swift iOS app using Okta's mobile SDK for direct authentication.

Please read [Secure Authentication with a Push Notification in Your iOS Device][blog] to see how it was created.

**Prerequisites:**

- Xcode
- An IDE such as [Visual Studio Code](https://code.visualstudio.com/)
> [Okta](https://developer.okta.com/) has Authentication and User Management APIs that reduce development time with instant-on, scalable user infrastructure. Okta's intuitive API and expert support make it easy for developers to authenticate, manage and secure users and roles in any application.

* [Getting Started](#getting-started)
* [Links](#links)
* [Help](#help)
* [License](#license)

## Getting Started
~
To run this example, use the following commands:

```bash
git clone https://github.com/oktadev/okta-ios-swift-directauth-example.git
cd okta-ios-swift-directauth-example
```

### Create an OIDC Application in Okta

Before you begin, you'll need an [Okta Integrator Free Plan account](https://developer.okta.com/login). Once you have an account, sign in. Next, in the Admin Console:

1. Go to **Applications** > **Applications**
2. Click **Create App Integration**
3. Select **OIDC - OpenID Connect** as the sign-in method
4. Select **Native Application** as the application type, then click **Next**
5. Enter an app integration name
6. Configure the redirect URIs:
    * Redirect URI: `com.okta.{yourOktaDomain}:/callback`
    * Post Logout Redirect URI: `com.okta.{yourOktaDomain}:/` (where `{yourOktaDomain}.okta.com` is your Okta domain name). 
7. Select **Advanced**:
    * Select the **OOB** and **MFA OOB** grant types
8. In the **Controlled access** section, select the appropriate access level
9. Click **Save**
 
**NOTE**: When using a custom authorization server, you need to set up authorization policies. Complete these additional steps:

1. In the Admin Console, go to **Security** > **API** > **Authorization Servers**
2. Select your custom authorization server (`default`)
3. On the **Access Policies** tab, ensure you have at least one policy:
    * If no policies exist, click **Add New Access Policy**
    * Give it a name like "Default Policy"
    * Set **Assign** to "All clients"
    * Click **Create Policy**
4. For your policy, ensure you have at least one rule:
    * Click **Add Rule** if no rules exist
    * Give it a name like "Default Rule"
    * Set **Grant type is** to "Authorization Code"
    * Select **Advanced** and enable "MFA OOB"
    * Set **User is** to "Any user assigned the app"
    * Set **Scopes requested** to "Any scopes"
    * Select **Create Rule**

For more details, see the [Custom Authorization Server](https://developer.okta.com/docs/concepts/auth-servers/#custom-authorization-server) documentation.

### Enable Push Notification for Okta Verify

By default, push factor isn't enabled in the Okta Integrator Free Plan org. To enable it:

1. In the Admin Console, go to **Security** > **Authenticators**
2. Find **Okta Verify** and select **Actions** > **Edit**
3. In the Okta Verify modal, find **Verification options** and select **Push notification (Android and iOS only)**
4. Select **Save**

After creating the app, you can find the configuration details on the app's **General** tab:

  * **Client ID**: Found in the **Client Credentials** section
  * **Issuer**: Found in the **Issuer URI** field for the authorization server that appears by selecting **Security** > **API** from the navigation pane.

```
Issuer:    https://dev-133337.okta.com/oauth2/default
Client ID: 0oab8eb55Kb9jdMIr5d6
```

NOTE: You can also use the Okta CLI Client or Okta PowerShell Module to automate this process. See this guide for more information about setting up your app.

## Links

This example uses the following open source libraries from Okta:

* [Okta with Mobile SDK](https://github.com/okta/okta-mobile-swift)

## Help

Please post any questions as comments on the [blog post][blog], or visit our [Okta Developer Forums](https://devforum.okta.com/).

## License

Apache 2.0, see [LICENSE](LICENSE).

[blog]: https://developer.okta.com/blog/2025/11/18/okta-ios-directauth
