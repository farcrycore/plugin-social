<cfsetting enablecfoutputonly="true">
<!--- @@viewstack: data --->
<!--- @@mimetype: application/json --->

<!--- social logout --->
<cfset application.fc.lib.social.logout()>

<!--- reload page after logging out --->
<cfoutput>
{
	"bSuccess": true
}
</cfoutput>

<cfsetting enablecfoutputonly="false">