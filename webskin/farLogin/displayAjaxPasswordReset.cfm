<cfsetting enablecfoutputonly="true">
<!--- @@viewstack: data --->
<!--- @@mimetype: application/json --->

<cfparam name="form.key" default="">
<cfparam name="form.email" default="">
<cfparam name="form.password" default="">
<cfparam name="form.confirmpassword" default="">

<cfset stResult = structNew()>
<cfset stResult["bSuccess"] = true>

<cfset oUser = application.fapi.getContentType(typename="farUser")>


<!--- validate form --->
<cfif NOT len(form.email) OR NOT isValid("email", form.email)>
	<cfset stResult["error"] = "Please provide a valid email address">
	<cfset stResult["bSuccess"] = false>
<cfelseif NOT len(form.password)>
	<cfset stResult["error"] = "Please provide a password">
	<cfset stResult["bSuccess"] = false>
<cfelseif NOT len(form.confirmpassword)>
	<cfset stResult["error"] = "Please provide a confirmation password">
	<cfset stResult["bSuccess"] = false>
<cfelseif form.password neq form.confirmpassword>
	<cfset stResult["error"] = "Please provide a password and matching confirmation password">
	<cfset stResult["bSuccess"] = false>
</cfif>

<!--- find user by email and validate key --->
<cfif stResult["bSuccess"]>
	<cfset stExistingUser = oUser.getByUserID(userid=form.email)>

	<cfif structIsEmpty(stExistingUser)>
		<cfset stResult["error"] = "An account was not found for this email address.">
		<cfset stResult["bSuccess"] = false>
	<cfelseif NOT structKeyExists(stExistingUser, "forgotPasswordHash") OR NOT len(stExistingUser.forgotPasswordHash)>
		<cfset stResult["error"] = "There was an error resetting the password for this account. Please check your password reset link and try again.">
		<cfset stResult["bSuccess"] = false>
		<cflog file="social" text="password reset forgot hash missing from user profile -- email=#form.email#">
	<cfelseif stExistingUser.forgotPasswordHash neq form.key>
		<cfset stResult["error"] = "There was an error resetting the password for this account.">
		<cfset stResult["bSuccess"] = false>
		<cflog file="social" text="password reset forgot hashes not matching -- forgotPasswordHash=#stExistingUser.forgotPasswordHash# form.key=#form.key#">
	</cfif>

</cfif>

<cfif stResult["bSuccess"]>

	<!--- reset password and clear password reset hash --->
	<cfset stProperties = structNew() />
	<cfset stProperties.objectid = stExistingUser.objectid />
	<cfset stProperties.password = form.password />
	<cfset stProperties.forgotPasswordHash = "" />
	<cfset application.fapi.setData(typename="farUser", stProperties="#stProperties#") />

</cfif>

<cfoutput>
#serializeJSON(stResult)#
</cfoutput>

<cfsetting enablecfoutputonly="false">