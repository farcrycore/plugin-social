<cfsetting enablecfoutputonly="true">
<!--- @@cachestatus: -1 --->

<cfset stProfile = application.fapi.getCurrentUser()>

<cfoutput>
	<!--- user logged in --->
	<cfset name = "#stProfile.firstname# #stProfile.lastname#">
	<cfif NOT len(trim(name))>
		<cfset name = stProfile.emailAddress>
	</cfif>
	<div>
		<p>Hello #name#, you are logged in!</p>
		<p><button class="btn" onclick="$s.logout()">Logout</button></p>
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">