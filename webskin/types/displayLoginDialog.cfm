<cfsetting enablecfoutputonly="true">

<cfoutput>
	<cfif len(application.fc.lib.social.getFacebookAppID()) OR len(application.fc.lib.social.getLinkedInAPIKey())>
		<h1>Social Sign In</h1>
			<div id="loginsocialbuttons">
			<cfif len(application.fc.lib.social.getFacebookAppID())>
				<p><a class="btn btn-block btn-social btn-social-facebook" onclick="$s.facebookLogin();" style="background-color: ##3b5998;"><i class="fa fa-fw fa-facebook-square"></i>&nbsp;Sign In with Facebook</a></p>
			</cfif>
			<cfif len(application.fc.lib.social.getLinkedInAPIKey())>
				<p><a class="btn btn-block btn-social btn-social-linkedin" onclick="$s.linkedinLogin();" style="background-color: ##0077b5;"><i class="fa fa-fw fa-linkedin-square"></i>&nbsp;Sign In with LinkedIn</a></p>
			</cfif>
		</div>
	</cfif>

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
		<cfif application.fapi.getConfig("social", "bSignupName")>
			<div class="form-group">
				<label class="access-hide" for="signupfirstname">First Name</label>
				<input class="form-control" id="signupfirstname" placeholder="" type="text">
			</div>
			<div class="form-group">
				<label class="access-hide" for="signuplastname">Last Name</label>
				<input class="form-control" id="signuplastname" placeholder="" type="text">
			</div>
		</cfif>
		<button class="btn" type="submit">Sign Up</button>
	</form>

	<form id="forgotpasswordform" onsubmit="return $s.farcryForgotPassword();">
		<h1>Forgot password?</h1>
		<p>Please provide your email address. A link to reset your password will be sent to you.</p>
		<div class="form-group">
			<label class="access-hide" for="forgotpasswordemail">Email</label>
			<input class="form-control" id="forgotpasswordemail" placeholder="Email" type="email">
		</div>
		<button class="btn" type="submit">Reset password</button>
	</form>
</cfoutput>

<cfsetting enablecfoutputonly="false">