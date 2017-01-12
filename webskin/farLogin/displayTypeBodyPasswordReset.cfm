<cfsetting enablecfoutputonly="true">

<cfoutput>
	<form id="passwordresetform" onsubmit="return $s.farcryPasswordReset();">
		<h1>Reset Password</h1>
		<div class="form-group">
			<label for="passwordresetpassword">New Password</label>
			<input id="passwordresetpassword" placeholder="New Password" type="password">
		</div>
		<div class="form-group">
			<label for="passwordresetconfirmpassword">Confirm Password</label>
			<input id="passwordresetconfirmpassword" placeholder="Confirm New Password" type="password">
		</div>
		<input type="hidden" id="passwordresetemail" value="#url.email#">
		<input type="hidden" id="passwordresetkey" value="#url.key#">
		<button type="submit">Reset Password</button>
	</form>
</cfoutput>

<cfsetting enablecfoutputonly="false">