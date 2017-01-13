<cfsetting enablecfoutputonly="true">
<!--- @@viewstack: any --->
<!--- @@fualias: passwordreset --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset url.bodyview = "displayTypeBodyPasswordReset">
<cfset stObj.label = "Password reset">
<cfset request.stObj = stObj>

<cfparam name="url.email" default="">
<cfparam name="url.key" default="">

<!--- validate email --->
<cfif NOT len(url.email) OR NOT isValid("email", url.email)>
	<cfset url.bodyview = "displayTypeBodyPasswordResetError">
</cfif>

<!--- find user by email and validate key --->
<cfset oUser = application.fapi.getContentType(typename="farUser")>
<cfset stExistingUser = oUser.getByUserID(userid=url.email)>
<cfif structIsEmpty(stExistingUser)>
	<cfset url.bodyview = "displayTypeBodyPasswordResetError">
	<cflog file="social" text="user account not found -- email=#url.email# key=#url.key#">
<cfelseif NOT structKeyExists(stExistingUser, "forgotPasswordHash") OR NOT len(stExistingUser.forgotPasswordHash)>
	<cfset url.bodyview = "displayTypeBodyPasswordResetError">
	<cflog file="social" text="user account forgot password hash not found -- email=#url.email# key=#url.key#">
<cfelseif NOT len(url.key) OR stExistingUser.forgotPasswordHash neq url.key>
	<cfset url.bodyview = "displayTypeBodyPasswordResetError">
	<cflog file="social" text="user account password hash does not match -- email=#url.email# key=#url.key#">
</cfif>

<!--- render the page --->
<skin:view typename="farLogin" stObject="#stObj#" webskin="displayPageStandard">

<cfsetting enablecfoutputonly="false">