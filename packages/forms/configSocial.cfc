<cfcomponent displayname="Social Sign In" extends="farcry.core.packages.forms.forms" output="false"
	key="social" hint="Configuration for Social Sign In">

	<cfproperty name="maxage" type="integer" required="true" default="14400"
		ftSeq="1" ftFieldset="Session" ftLabel="Cookie Max-Age"
		ftType="integer"
		ftHint="The number of seconds for the social sign in cookies">

	<cfproperty name="bSignupName" type="boolean" required="false" default="false"
		ftSeq="5" ftFieldset="Email Signup" ftLabel="Ask For Name" />

	<cfproperty name="facebookAppID" type="string"
		ftSeq="11" ftFieldset="Facebook API" ftLabel="App ID"
		ftHint="The Application ID of the Facebook App to sign in to">

	<cfproperty name="bParseXFBML" type="boolean" default="true"
		ftSeq="12" ftFieldset="Facebook API" ftLabel="Parse XFBML"
		ftHint="Check this box to enable parsing of XFBML on the page (default: true)">

	<cfproperty name="linkedinAPIKey" type="string"
		ftSeq="21" ftFieldset="LinkedIn API" ftLabel="App API Key"
		ftHint="The Application API Key of the LinkedIn App to sign in to">

	<cfproperty name="linkedinPermissionScope" type="string" default="r_basicprofile r_emailaddress" ftDefault="r_basicprofile r_emailaddress"
		ftSeq="22" ftFieldset="LinkedIn API" ftLabel="Permission Scope"
		ftHint="The Permission Scope matching the configured 'Default Application Permissions' of the LinkedIn App<br>(Note: the mimimum required permissions are <code>r_basicprofile r_emailaddress</code>)">

</cfcomponent>
