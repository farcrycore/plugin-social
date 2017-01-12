<cfcomponent output="false">

	<!--- configuration helper methods --->

	<cffunction name="getMaxAge" returntype="string" output="false">
		<cfreturn application.fapi.getConfig("social", "maxage", 14400)>
	</cffunction>

	<cffunction name="getFacebookAppID" returntype="string" output="false">
		<cfreturn application.fapi.getConfig("social", "facebookAppID", "")>
	</cffunction>

	<cffunction name="getParseXFBML" returntype="string" output="false">
		<cfset var parse = "true">
		<cfif application.fapi.getConfig("social", "bParseXFBML", true) eq false>
			<cfset parse = "false">
		</cfif>
		<cfreturn parse>
	</cffunction>

	<cffunction name="getLinkedInAPIKey" returntype="string" output="false">
		<cfreturn application.fapi.getConfig("social", "linkedinAPIKey", "")>
	</cffunction>

	<cffunction name="getLinkedInPermissionScope" returntype="string" output="false">
		<cfreturn application.fapi.getConfig("social", "linkedinPermissionScope", "r_basicprofile r_emailaddress")>
	</cffunction>

	<!--- init --->

	<cffunction name="initRequest" output="false">
		<!--- request.fclogin can be used for basic webskin caching --->
		<cfparam name="request.fclogin" default="0">

		<cfif structKeyExists(cookie, "fclogin")>
			<!--- ensure the cookie.fclogin value is valid --->
			<cfif cookie.fclogin eq "0" OR cookie.fclogin eq "1">
				<cfset request.fclogin = cookie.fclogin>
			<cfelse>
				<cfset request.fclogin = 0>
				<cfset structDelete(cookie, "FCLOGIN")>
			</cfif>
		</cfif>
	</cffunction>

	<!--- login/logout --->

	<cffunction name="login" output="false">
		<cfargument name="username" type="string" required="true">

		<!--- farcry login --->
		<cfset application.security.login(arguments.username, "CLIENTUD")>

		<!--- set cookie --->
		<cfset maxage = application.fc.lib.social.getMaxAge()>
		<cfset expires = dateConvert("local2utc", dateAdd("s", maxage, now()))>
		<cfcookie name="FCLOGIN" value="1" httponly="true" expires="#dateFormat(expires, "yyyy-mm-dd")#T#timeFormat(expires, "HH:mm:ss")#.000Z">

	</cffunction>

	<cffunction name="logout" output="false">

		<!--- farcry logout --->
		<cfset application.security.logout()>
		<!--- reset request.fclogin --->
		<cfset request.fclogin = 0>
		<!--- remove cookies --->
		<cfset structDelete(cookie, "FCLOGIN")>
		<cfset structDelete(cookie, "FCSOCIAL")>

	</cffunction>

	<!--- email --->

	<cffunction name="sendPasswordResetEmail" output="false" returntype="boolean">
		<cfargument name="stProfile" type="struct" required="true">
		<cfargument name="forgotPasswordHash" type="string" required="true">

		<cfset var bResult = true>
		<cfset var html = "">

		<!--- get password reset link --->
		<cfset var link = application.fapi.getLink(type="farLogin", view="displayPagePasswordReset", urlParameters="email=#stProfile.emailAddress#&key=#arguments.forgotPasswordHash#", includeDomain=true)>

		<!--- get email HTML --->
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<skin:view r_html="html" bIgnoreSecurity="true" typename="dmProfile" stObject="#arguments.stProfile#" webskin="emailPasswordReset" link="#link#" />


		<!--- send email --->
		<cfmail from="#getEmailFromAddress()#" to="#stProfile.emailAddress#" subject="#getEmailPasswordResetSubject()#" type="html">
			<cfoutput>#html#</cfoutput>
		</cfmail>

		<cflog file="social" text="sent password reset email -- from=#getEmailFromAddress()# to=#stProfile.emailAddress# subject=#getEmailPasswordResetSubject()#">

		<cfreturn bResult>
	</cffunction>

	<cffunction name="getEmailFromAddress" output="false" returntype="string">
		<cfreturn application.fapi.getConfig("general","adminemail")>
	</cffunction>

	<cffunction name="getEmailPasswordResetSubject" output="false" returntype="string">
		<cfreturn "Password Reset for your account">
	</cffunction>


</cfcomponent>
