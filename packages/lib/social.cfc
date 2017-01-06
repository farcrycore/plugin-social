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

</cfcomponent>
