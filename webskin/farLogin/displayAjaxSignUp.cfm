<cfsetting enablecfoutputonly="true">
<!--- @@viewstack: data --->
<!--- @@mimetype: application/json --->

<cfparam name="form.email" default="">
<cfparam name="form.firstname" default="">
<cfparam name="form.lastname" default="">
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

<!--- find existing user --->
<cfif stResult["bSuccess"]>
	<cfset stExistingUser = oUser.getByUserID(userid=form.email)>

	<cfif NOT structIsEmpty(stExistingUser)>
		<cfset stResult["error"] = "An account already exists for this email address. Try signing in?">
		<cfset stResult["bSuccess"] = false>
	</cfif>
</cfif>


<cfif stResult["bSuccess"]>

	<cfset oProfile = application.fapi.getContentType(typename="dmProfile")>
	<cfset stProfile = structNew()>

	<!--- create the user record --->
	<cfset stUser = {
		typename: "farUser",
		userid: form.email,
		password: form.password,
		userstatus: "active"
	}>
	<cfset oUser.createData(stProperties=stUser, user="registration")>

	<!--- set up the profile --->
	<cfset stProfile = {
		username: form.email,
		emailAddress: form.email,
		bActive: 1,
		userdirectory: "CLIENTUD"
	}>

	<!--- create the profile --->
	<cfset stProfile = oProfile.createProfile(stProperties=stProfile)>

	<!--- do social login --->
	<cfset application.fc.lib.social.login(stProfile.username)>

<cfelse>
	<cfset application.fc.lib.social.logout()>
</cfif>

<cfoutput>
#serializeJSON(stResult)#
</cfoutput>

<cfsetting enablecfoutputonly="false">