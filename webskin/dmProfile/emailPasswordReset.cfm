<cfsetting enablecfoutputonly="true">
<!--- @@description: Password Reset Email Template --->

<cfparam name="stParam.link" type="string">

<cfoutput>
<html>
<body>
	<p>Hello,</p>
	<p>You have recently requested a password reset for your account.</p>
	<p><a href="#stParam.link#">Please click here to reset your password</a>.</p>
	<p>If the link does not work please copy the following URL below into your web browser:</p>
	<p>#stParam.link#</p>
	<p>Thanks.</p>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">