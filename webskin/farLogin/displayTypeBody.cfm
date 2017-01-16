<cfsetting enablecfoutputonly="true">
<!--- @@cachestatus: -1 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset stProfile = application.fapi.getCurrentUser()>

<cfif structIsEmpty(stProfile)>
	<skin:view stObject="#stObj#" webskin="displayLoginDialog">
<cfelse>
	<skin:view stObject="#stObj#" webskin="displayLoginProfile">
</cfif>

<cfsetting enablecfoutputonly="false">