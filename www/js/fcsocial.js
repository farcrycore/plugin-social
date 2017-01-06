fcsocial = function($, options){

	//
	// INIT
	//

	options.maxage = options.maxage || 14400;
	options.facebook_appid = options.facebook_appid || "";
	options.facebook_xfbml = options.facebook_xfbml || true;
	options.linkedin_api_key = options.linkedin_api_key || "";

	// onSessionRequest(user) callback fires on page load when the user has an existing session
	// e.g. this could be used each time a page is rendered to update personalised user content
	// such as a profile menu, log CRM analytics, etc
	options.onSessionRequest = options.onSessionRequest || function(user) {
		// default callback for session requests is empty
	};

	// onLogin(user) callback fires after the user has just logged in successfully
	options.onLogin = options.onLogin || function(user) {
		// default callback reloads page after login
		window.location.reload(true);
	};

	// onLogout() callback fires after the user has just logged out
	options.onLogout = options.onLogout || function() {
		// default callback reloads page after logout
		window.location.reload(true);
	};


	if (options.facebook_appid.length) {
		window.fbAsyncInit = function() {
			FB.init({
				appId      : options.facebook_appid,
				cookie     : true,  // enable cookies to allow the server to access 
				                    // the session
				xfbml      : options.facebook_xfbml,  // parse social plugins on this page
				version    : 'v2.8' // use graph api version 2.8
			});

			FB.getLoginStatus(function(response) {
				statusChangeCallback(response);
			});

		};

		// Load the SDK asynchronously
		(function(d, s, id) {
			var js, fjs = d.getElementsByTagName(s)[0];
			if (d.getElementById(id)) return;
			js = d.createElement(s); js.id = id;
			js.src = "//connect.facebook.net/en_US/sdk.js";
			fjs.parentNode.insertBefore(js, fjs);
		}(document, 'script', 'facebook-jssdk'));

	}


	//
	// HELPERS
	//

	function getCurrentUser() {
		var user = {
			success: false
		};
		var val = document.cookie.replace(/(?:(?:^|.*;\s*)FCSOCIAL\s*\=\s*([^;]*).*$)|^.*$/, "$1");
		if (val != null && val != "") {
			dval = base64DecodeUnicode(val);
			user = JSON.parse(dval);
			user.success = true;
		}
		return user;
	}

	function setCurrentUser(user) {
		// set user cookie
		document.cookie = "FCSOCIAL=" + base64EncodeUnicode(JSON.stringify(user)) + ";max-age=" + options.maxage;
	}


	function login(user) {
		setCurrentUser(user);
		// onLogin callback
		options.onLogin(user);
	}

	function logout() {
		document.cookie = "FCSOCIAL=;expires=0";
		$.ajax({
			url: "/login/displayAjaxSocialLogout",
			method: "POST",
			success: function(r) {
				// onLogout callback
				options.onLogout();
			}
		});
	}


	function base64EncodeUnicode(str) {
		return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function(match, p1) {
			return String.fromCharCode('0x' + p1);
		}));
	}
	function base64DecodeUnicode(str) {
		return decodeURIComponent(Array.prototype.map.call(atob(str), function(c) {
			return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
		}).join(''));
	}


	//
	// LINKEDIN
	//

	this.onLinkedInLoad = function() {
		if (options.linkedin_api_key.length) {
			IN.Event.on(IN, "auth", getProfileData);
		}
	}

	this.linkedinLogin = function() {
		IN.User.authorize(function(){
			getProfileData();
		});
	};

	this.linkedinLogout = function() {
		IN.User.logout(function(){
			logout();
		});
	}


	// Handle the successful return from the API call
	function onSuccess(data) {

		// validate linkedin login
		$.ajax({
			url: "/login/displayAjaxSocialLogin",
			method: "POST",
			data: {
				"signin": "linkedin",
				"id": data.id,
				"firstname": data.firstName,
				"lastname": data.lastName,
				"email": data.emailAddress,
				"oauth_token": IN.ENV.auth.oauth_token
			},
			success: function(r) {

				if (r.bSuccess == true) {
					var user = {
						"signin": "linkedin",
						"id": data.id,
						"firstname": data.firstName,
						"lastname": data.lastName,
						"email": data.emailAddress
					};

					// login
					login(user);

				}
				else {
					console.log("ERROR LOGGING IN");
				}

			}
		});

	}

	// Handle an error response from the API call
	function onError(error) {
		console.log(error);
	}

	// Use the API call wrapper to request the member's basic profile data
	function getProfileData() {
		// check for existing login
		var user = getCurrentUser();
		if (user.success == false) {
			IN.API.Raw("/people/~:(id,first-name,last-name,email-address)").result(onSuccess).error(onError);
		}
		else {
			// onSessionRequest callback
			options.onSessionRequest(user);
		}
	}


	//
	// FACEBOOK
	//

	this.facebookLogin = function() {
		FB.login(function(response) {
			FB.getLoginStatus(function(response) {
				statusChangeCallback(response);
			});
		});
	}

	this.facebookLogout = function() {
		FB.logout(function(response) {
			logout();
		});
	}

	// This is called with the results from from FB.getLoginStatus().
	function statusChangeCallback(response) {
		// The response object is returned with a status field that lets the
		// app know the current login status of the person.
		// Full docs on the response object can be found in the documentation
		// for FB.getLoginStatus().
		if (response.status === 'connected') {
			// Logged into your app and Facebook.

			// check for existing login
			var user = getCurrentUser();
			
			if (user.success == false) {

				FB.api('/me', {fields: 'name,first_name,last_name,email'}, function(data) {

					// validate facebook login
					$.ajax({
						url: "/login/displayAjaxSocialLogin",
						method: "POST",
						data: {
							"signin": "facebook",
							"id": data.id,
							"firstname": data.first_name,
							"lastname": data.last_name,
							"email": data.email,
							"accessToken": response.authResponse.accessToken
						},
						success: function(r){

							if (r.bSuccess == true) {
								var user = {
									"signin": "facebook",
									"id": data.id,
									"firstname": data.first_name,
									"lastname": data.last_name,
									"email": data.email,
								}

								// login
								login(user);

							}
							else {
								console.log("ERROR LOGGING IN");
							}

						}
					});

				});

			}
			else {

				// onSessionRequest callback
				if (options.onSessionRequest != null) {
					options.onSessionRequest(user);
				}

			}

		} else if (response.status === 'not_authorized') {
			// The person is logged into Facebook, but not your app.
		} else {
			// The person is not logged into Facebook, so we're not sure if
			// they are logged into this app or not.
		}
	}


	return this;
};
