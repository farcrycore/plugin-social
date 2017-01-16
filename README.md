# Social Sign In plugin for FarCry Core 7.x

This plugin will add support for social sign in services including Facebook and LinkedIn, along with support for ajax based signup and sign in for FarCry Core's built-in user directory.


## Installation

- extract the plugin to /farcry/plugins/social
- register the plugin in your farcryContructor.cfm
- configure the "Social Sign In" settings via the webtop or environment variables


## Social App Configuration

Social sign in requires that you create an "Application" with each third party provider that you wish to integrate.

### Facebook

Create a Facebook Application via:
https://developers.facebook.com/apps

On the *Settings > Basic* page of the application settings, configure the **App Domains** and **Site URL** to allow the application to be used from particular domains only.

The **App ID** value can be configured in the webtop as the Facebook API **App ID**.

### LinkedIn

Create a LinkedIn Application via:
https://www.linkedin.com/developer/apps

On the **Authentication** page of the application settings, configure the **Default Application Permissions** to allow:

- r_basicprofile
- r_emailaddress

(Note: both of these permission are **required** for this plugin to work correctly)

The **Client ID** value can be configured in the webtop as the LinkedIn **App API Key**.

On the *JavaScript* page of the application settings, configure the **Valid SDK Domains** to allow the application to be used from particular domains only.


## Sample Code / Implementation

Implementing the social sign in features into your FarCry application is done via a registered JS library called `fcsocial`, and embedding some HTML for the login buttons, login form, sign up form, and forgot password form.

### JavaScript configuration

First the library needs to be loaded in the &lt;head&gt; of your HTML output, usually in the `displayHeaderStandard` webskin;

    <!--- include fcsocial JS library --->
    <cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
    <skin:loadJS id="fcsocial" />

Then the fcsocial plugin can be initialised near the bottom of the HTML &lt;body&gt;, usually in the `displayFooterStandard` webskin;

    <script type="text/javascript">
    $s = fcsocial($j, {
        <cfif len(application.fc.lib.social.getFacebookAppID())>
            facebook_appid: "#application.fc.lib.social.getFacebookAppID()#",
            facebook_xfbml: #application.fc.lib.social.getParseXFBML()#,
        </cfif>
        <cfif len(application.fc.lib.social.getLinkedInAPIKey())>
            linkedin_api_key: "#application.fc.lib.social.getLinkedInAPIKey()#",
        </cfif>
        onSessionRequest: function(user) {
            // your callback code
        },
        maxage: #application.fc.lib.social.getMaxAge()#
    });
    </script>
    <cfif len(application.fc.lib.social.getLinkedInAPIKey())>
    <script type="text/javascript" src="//platform.linkedin.com/in.js">
        api_key: #application.fc.lib.social.getLinkedInAPIKey()#
        authorize: true
        scope: #application.fc.lib.social.getLinkedInPermissionScope()#
        onLoad: $s.onLinkedInLoad
    </script>
    </cfif>

The `fcsocial()` constructor method accepts a jQuery object (this can be Core's `$j` or your own `$` jQuery object) and an object which contains the social configuration options and callback functions, and returns `$s` which can be used globally throughout your app to call public functions of the JS library such as a login or logout action.

The **options** include;

- **maxage** - the number of seconds before the social sign in cookies expire (default: `14400`)
- **facebook_appid** - the Facebook API App ID
- **facebook_xfbml** - a boolean flag which will instruct the Facebook JS SDK to parse XFBML found in the HTML of the page (default: `true`)
- **linkedin_api_key** - the LinkedIn App API Key

*Each of the above options can be configured in FarCry via the webtop, and read via the supporting methods provided in the `application.fc.lib.social` lib, as per the sample code above.*

Additional UI related **options** include;

- **login_location** - a custom login location to redirect to (default: empty string, page will reload)
- **logout_location** - a custom logout location to redirect to (default: empty string, page will reload)
- **farcry_loginemail** - ID of the login form email field (default: "#loginemail")
- **farcry_loginpassword**- ID of the login form password field (default: "#loginpassword")
- **farcry_loginerror** - selector of the element which any login error message will be inserted before (default: "#loginform .form-group:first")
- **farcry_signupemail** - ID of the signup form email field (default: "#signupemail")
- **farcry_signuppassword** - ID of the signup form password field (default: "#signuppassword")
- **farcry_signupconfirmpassword** - ID of the signup form confirm password field (default: "#signupconfirmpassword")
- **farcry_forgotpasswordemail** - ID of the forgot password form email field (default: "#forgotpasswordemail")
- **farcry_forgotpassworderror** - selector of the element which any forgot password error message will be inserted before (default: "#forgotpasswordform .form-group:first")
- **farcry_forgotpasswordsubmit** - ID of the forgot password submit button (default: "#forgotpasswordform .btn")
- **farcry_passwordresetemail** - ID of the password reset form email field (default: "#passwordresetemail")
- **farcry_passwordresetkey** - ID of the password reset key hidden field (default: "#passwordresetkey")
- **farcry_passwordresetpassword** - ID of the password reset form password field (default: "#passwordresetpassword")
- **farcry_passwordresetconfirmpassword** - ID of the password reset form confirm password field (default: "#passwordresetconfirmpassword")
- **farcry_passwordreseterror** - selector of the element which any password reset error message will be inserted before (default: "#passwordresetform .form-group:first")
- **farcry_signuperror** - selector of the element which any signup error message will be inserted before (default: "#signupform .form-group:first")
- **farcry_errorclass** - the class names which will be applied to an error message element (default: "alert alert-error")

*Each of the above options are DOM selectors that are used by the library to find specified input elements, insert error message elements, or apply classes to elements. They can but customised as needed to suit your login/signup UI.*


The **callbacks** include;

- **onAnonymousRequest()** - fires on page load when the user does not have a session e.g. this could be used each time a page is rendered to log CRM analytics, etc
- **onSessionRequest(user)** - fires on page load when the user has an existing session e.g. this could be used each time a page is rendered to update personalised user content such as a profile menu, log CRM analytics, etc. The `user` object is provided to the callback containing the available user data.
- **onLogin(user)** - fires after the user has just logged in successfully. If this callback is not provided the default behaviour is to reload the page after login.
- **onLogout()** - fires after the user has just logged out. If this callback is not provided the default behaviour is to reload the page after logout.

The returned object `$s` **public functions** include;

- **$s.logout()** - initiate a logout of the current user session
- **$s.facebookLogin()** - initiate a Facebook login (e.g. from a button onclick event)
- **$s.facebookLogout()** - initiate a Facebook logout
- **$s.linkedinLogin()** - initiate a LinkedIn login (e.g. from a button onclick event)
- **$s.linkedinLogout()** - initiate a LinkedIn logout
- **$s.onLinkedInLoad()** - required by the LinkedIn `in.js` SDK
- **$s.farcryLogin()** - initiate a FarCry login using the login form on the page (e.g. from a "submit" event on the form element)
- **$s.farcrySignUp()** - initiate a FarCry signup using the sign up form on the page (e.g. from a "submit" event on the form element)
- **$s.farcryForgotPassword()** - initiate a forgot password email using the forgot password form on the page (e.g. from a "submit" event on the form element)
- **$s.farcryPasswordReset()** - initiate a password reset using the password reset form on the page (e.g. from a "submit" event on the form element)

The second &lt;script&gt; element initialises the LinkedIn in.js using `key: value` options;

- **api_key** - the LinkedIn App API Key
- **authorize** - a flag to check for an existing user authentication token (note: this plugin **requires** the value: `true`)
- **scope** - the LinkedIn App Permission Scope (note: the minimum **required** permissions are: `r_basicprofile r_emailaddress`)
- **onLoad** - the callback to run when the request has been authorized on page load


### HTML for the UI

The social login buttons and the login/signup via email forms can be placed in your webskin of choice. These forms below are examples which work with the default configuration options in the `fcsocial` JS library.

#### Login buttons/form

    <h1>Social Sign In</h1>
    <a class="btn" onclick="$s.facebookLogin();" style="background-color: #3b5998;"><i class="fa fa-fw fa-facebook-square"></i>&nbsp;Sign In with Facebook</a>
    <a class="btn" onclick="$s.linkedinLogin();" style="background-color: #0077b5;"><i class="fa fa-fw fa-linkedin-square"></i>&nbsp;Sign In with LinkedIn</a>

    <form id="loginform" onsubmit="return $s.farcryLogin();">
        <h1>Sign In via email</h1>
        <div class="form-group">
            <label class="access-hide" for="loginemail">Email</label>
            <input class="form-control" id="loginemail" placeholder="Email" type="email">
        </div>
        <div class="form-group">
            <label class="access-hide" for="loginpassword">Password</label>
            <input class="form-control" id="loginpassword" placeholder="Password" type="password">
        </div>
        <button class="btn" type="submit">Sign In</button>
    </form>


#### Sign up form

    <form id="signupform" onsubmit="return $s.farcrySignUp();">
        <h1>Sign up</h1>
        <div class="form-group">
            <label class="access-hide" for="signupemail">Email</label>
            <input class="form-control" id="signupemail" placeholder="Email" type="email">
        </div>
        <div class="form-group">
            <label class="access-hide" for="signuppassword">Password</label>
            <input class="form-control" id="signuppassword" placeholder="Password" type="password">
        </div>
        <div class="form-group">
            <label class="access-hide" for="signupconfirmpassword">Confirm Password</label>
            <input class="form-control" id="signupconfirmpassword" placeholder="Confirm Password" type="password">
        </div>
        <button class="btn" type="submit">Sign Up</button>
    </form>

#### Forgot password form

    <form id="forgotpasswordform" onsubmit="return $s.farcryForgotPassword();">
        <h1>Forgot password?</h1>
        <div class="form-group">
            <label class="access-hide" for="forgotpasswordemail">Email</label>
            <input class="form-control" id="forgotpasswordemail" placeholder="Email" type="email">
        </div>
        <button class="btn" type="submit">Reset password</button>
    </form>

#### Password reset form

This example HTML is provided by the plugin in the `farLogin/displayTypeBodyPasswordReset.cfm` webskin. You can override it in your project to customise it.

    <form id="passwordresetform" onsubmit="return $s.farcryPasswordReset();">
        <h1>Reset Password</h1>
        <div class="form-group">
            <label for="passwordresetpassword">New Password</label>
            <input id="passwordresetpassword" placeholder="New Password" type="password">
        </div>
        <div class="form-group">
            <label for="passwordresetconfirmpassword">Confirm Password</label>
            <input id="passwordresetconfirmpassword" placeholder="Confirm New Password" type="password">
        </div>
        <input type="hidden" id="passwordresetemail" value="#url.email#">
        <input type="hidden" id="passwordresetkey" value="#url.key#">
        <button type="submit">Reset Password</button>
    </form>


#### Customisations

The example HTML can customised as needed to match the IDs and selector options used when initialising `fcsocial()`, and the callbacks such as `$s.facebookLogin()` could be bound using JavaScript event listeners rather than using inline `onclick` or `onsubmit` attributes.

For the "submit" handlers on forms, remember to `return false` to avoid a page reload before the async requests have had time to return a response (the `$s.farcryLogin` and `$s.farcrySignUp` callbacks return false by default, hence why the example HTML above uses `onsubmit="return $s.farcryLogin();"`, etc).


### Forgot Password email template

If a user who has signed up via email needs to request a password reset an email is sent using the template defined in the `dmProfile/emailPasswordReset.cfm"` webskin. You can override it in your project to customise it.

