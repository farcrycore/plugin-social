<cfsetting enablecfoutputonly="true">
<!--- @@viewstack: data --->
<!--- @@mimetype: application/json --->

<cfparam name="form.email" default="">

<cfset stResult = structNew()>
<cfset stResult["bSuccess"] = true>

<cfset oUser = application.fapi.getContentType(typename="farUser")>


<!--- validate form --->
<cfif NOT len(form.email) OR NOT isValid("email", form.email)>
	<cfset stResult["error"] = "Please provide a valid email address">
	<cfset stResult["bSuccess"] = false>
</cfif>

<!--- find existing user --->
<cfif stResult["bSuccess"]>
	<cfset stExistingUser = oUser.getByUserID(userid=form.email)>

	<cfif structIsEmpty(stExistingUser)>
		<cfset stResult["error"] = "An account was not found for this email address">
		<cfset stResult["bSuccess"] = false>
	</cfif>
</cfif>


<cfif stResult["bSuccess"]>

	<!--- generate and set new password reset hash --->
	<cfset stProperties = structNew() />
	<cfset stProperties.objectid = stExistingUser.objectid />
	<cfset stProperties.forgotPasswordHash = application.fc.utils.generateRandomString() />
	<cfset application.fapi.setData(typename="farUser", stProperties="#stProperties#") />
	<!--- get user profile --->
	<cfset stProfile = application.fapi.getContentType(typename="dmProfile").getProfile(username=form.email, ud="CLIENTUD")>
	<!--- send email --->
	<cfset result = application.fc.lib.social.sendPasswordResetEmail(stProfile=stProfile, forgotPasswordHash=stProperties.forgotPasswordHash)>
	<cfif result eq false>
		<cfset stResult["error"] = "There was an error sending your password reset email. Please contact the site administrators.">
		<cfset stResult["bSuccess"] = false>
	</cfif>

</cfif>

<cfoutput>
#serializeJSON(stResult)#
</cfoutput>

<cfsetting enablecfoutputonly="false">