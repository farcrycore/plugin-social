<cfsetting enablecfoutputonly="true">
<!--- @@viewstack: data --->
<!--- @@mimetype: application/json --->

<cfparam name="form.signin" default="">
<cfparam name="form.id" default="">
<cfparam name="form.email" default="">
<cfparam name="form.firstname" default="">
<cfparam name="form.lastname" default="">
<cfparam name="form.password" default="">

<cfset stResult = structNew()>
<cfset stResult["bSuccess"] = false>

<cfset stSocial = structNew()>

<cfset oUser = application.fapi.getContentType(typename="farUser")>


<!--- validate signin api --->
<cfif NOT listFindNoCase("facebook,linkedin,farcry", form.signin)>
	<cfset stResult["error"] = "Invalid Sign In API">
<!--- validate id (except when farcry login is used) --->
<cfelseif NOT len(form.id) AND form.signin neq "farcry">
	<cfset stResult["error"] = "User ID is missing">
<!--- validate email --->
<cfelseif NOT len(form.email) OR NOT isValid("email", form.email)>
	<cfset stResult["error"] = "Email address is missing or invalid">
<!--- validate password (only when farcry login is used) --->
<cfelseif NOT len(form.password) AND form.signin eq "farcry">
	<cfset stResult["error"] = "Password is missing">
	<cfset stResult["signin"] = "farcry">
</cfif>


<!--- facebook login --->
<cfif form.signin eq "facebook">
	<cfparam name="form.accessToken" default="">

	<cfset stResponse = structNew()>
	<cftry>
		<!--- get user via facebook api --->
		<cfhttp method="GET" url="https://graph.facebook.com/v2.8/me?fields=id,email,first_name,last_name&access_token=#form.accessToken#" result="stResponse" timeout="10">
		</cfhttp>
		<cfcatch>
			<cfset stResult["error"] = "Facebook API Error">
		</cfcatch>
	</cftry>

	<cfif structKeyExists(stResponse, "status_code") AND stResponse.status_code eq "200" AND isJSON(stResponse.filecontent)>
		<cfset stUser = deserializeJSON(stResponse.filecontent)>

		<!--- validate response --->
		<cfif structKeyExists(stUser, "id") AND stUser.id eq form.id AND structKeyExists(stUser, "email") AND stUser.email eq form.email>
			<cfset stSocial.facebookID = stUser.id>
			<cfset stSocial.emailAddress = stUser.email>
			<cfset stSocial.firstname = stUser.first_name>
			<cfset stSocial.lastname = stUser.last_name>

			<cfset form.email = stUser.email>
			<cfset stResult["bSuccess"] = true>
		</cfif>
	</cfif>

	<cfif NOT stResult["bSuccess"]>
		<!--- login error --->
		<cfset stResult["error"] = "Facebook API Error - Invalid Repsonse">
	</cfif>
</cfif>

<!--- linkedin login --->
<cfif form.signin eq "linkedin">
	<cfparam name="form.oauth_token" default="">

	<cfset stResponse = structNew()>
	<cftry>
		<!--- get user email via linkedin api --->
		<cfhttp url="https://api.linkedin.com/v1/people/#form.id#/email-address?format=json" method="GET" result="stResponse" timeout="10">
			<cfhttpparam type="header" name="oauth_token" value="#form.oauth_token#">
		</cfhttp>

		<cfcatch>
			<cfset stResult["error"] = "Linkedin API Error">
		</cfcatch>
	</cftry>

	<cfif structKeyExists(stResponse, "status_code") AND stResponse.status_code eq "200" AND isJSON(stResponse.filecontent)>
		<cfset emailAddress = deserializeJSON(stResponse.filecontent)>

		<!--- validate response --->
		<cfif isSimpleValue(emailAddress) AND emailAddress eq form.email>
			<cfset stSocial.linkedinID = form.id>
			<cfset stSocial.emailAddress = emailAddress>
			<cfset stSocial.firstname = form.firstname>
			<cfset stSocial.lastname = form.lastname>

			<cfset form.email = emailAddress>
			<cfset stResult["bSuccess"] = true>
		</cfif>
	</cfif>

	<cfif NOT stResult["bSuccess"]>
		<!--- login error --->
		<cfset stResult["error"] = "Linkedin API Error - Invalid Response">
	</cfif>	
</cfif>


<!--- farcry login --->
<cfif form.signin eq "farcry">
	<cfset stUser = oUser.getByUserID(userid=form.email)>

	<cfif NOT isValid("email", form.email)>
		<cfset stResult["error"] = "Please provide a valid email address">
	<cfelseif structIsEmpty(stUser)>
		<cfset stResult["error"] = "An account was not found for this email address">
	<cfelse>
		<!--- check password --->
		<cfset qUser = application.fapi.getContentObjects(typename="farUser", lProperties="objectid,userid,password,userstatus,failedLogins", userid_eq=form.email)>
		<cfloop query="qUser">
			<cfif application.security.cryptlib.passwordMatchesHash(password=form.password,hashedPassword=qUser.password)>
				<!--- password matches --->
				<cfset stResult["bSuccess"] = true>
			</cfif>
		</cfloop>

		<cfif NOT stResult["bSuccess"]>
			<cfset stResult["error"] = "Login failed. Invalid email address or password.">
		</cfif>
	</cfif>
</cfif>


<cfif stResult["bSuccess"]>

	<!--- find user --->
	<cfset stUser = oUser.getByUserID(userid=form.email)>

	<cfset oProfile = application.fapi.getContentType(typename="dmProfile")>
	<cfset stProfile = structNew()>

	<cfif NOT structIsEmpty(stUser)>
		<cfset stProfile = oProfile.getProfile(form.email, "CLIENTUD")>
	</cfif>


	<cfif NOT structKeyExists(stProfile, "bInDB") OR NOT stProfile.bInDB>
		<!--- create the user record --->
		<cfset stUser = {
			typename: "farUser",
			userid: form.email,
			userstatus: "active"
		}>
		<cfset oUser.createData(stProperties=stUser, user="registration")>

		<!--- set up the profile --->
		<cfset stProfile = {
			username: form.email,
			bActive: 1,
			userdirectory: "CLIENTUD"
		}>
		<!--- merge the social fields into the profile --->
		<cfset structAppend(stProfile, stSocial)>

		<!--- create the profile --->
		<cfset stProfile = oProfile.createProfile(stProperties=stProfile)>

	<cfelse>
		<!--- update the profile with latest data by merging the social fields into the profile --->
		<cfset structAppend(stProfile, stSocial)>
		<cfset oProfile.setData(stProperties=stProfile)>
	</cfif>

	<!--- do social login --->
	<cfset application.fc.lib.social.login(stProfile.username)>

<cfelse>
	<cfset application.fc.lib.social.logout()>
</cfif>

<cfoutput>
#serializeJSON(stResult)#
</cfoutput>

<cfsetting enablecfoutputonly="false">