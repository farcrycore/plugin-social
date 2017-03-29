fcsocial = function($, options){

	//
	// INIT
	//

	options.maxage = options.maxage || 14400;
	options.facebook_appid = options.facebook_appid || "";
	options.facebook_xfbml = options.facebook_xfbml || true;
	options.linkedin_api_key = options.linkedin_api_key || "";

	options.login_location = options.login_location || "";
	options.logout_location = options.logout_location || "";
	options.login_socialbuttons = options.login_socialbuttons || "#loginsocialbuttons";

	options.farcry_loginemail = options.farcry_loginemail || "#loginemail";
	options.farcry_loginpassword = options.farcry_loginpassword || "#loginpassword";
	options.farcry_loginerror = options.farcry_loginerror || "#loginform .form-group:first";
	options.farcry_signupemail = options.farcry_signupemail || "#signupemail";
	options.farcry_signuppassword = options.farcry_signuppassword || "#signuppassword";
	options.farcry_signupconfirmpassword = options.farcry_signupconfirmpassword || "#signupconfirmpassword";
	options.farcry_signupfirstname = options.farcry_signupfirstname || "#signupfirstname";
	options.farcry_signuplastname = options.farcry_signuplastname || "#signuplastname";
	options.farcry_signuperror = options.farcry_signuperror || "#signupform .form-group:first";
	options.farcry_forgotpasswordemail = options.farcry_forgotpasswordemail || "#forgotpasswordemail";
	options.farcry_forgotpassworderror = options.farcry_forgotpassworderror || "#forgotpasswordform .form-group:first";
	options.farcry_forgotpasswordsubmit = options.farcry_forgotpasswordsubmit || "#forgotpasswordform .btn";
	options.farcry_passwordresetemail = options.farcry_passwordresetemail || "#passwordresetemail";
	options.farcry_passwordresetkey = options.farcry_passwordresetkey || "#passwordresetkey";
	options.farcry_passwordresetpassword = options.farcry_passwordresetpassword || "#passwordresetpassword";
	options.farcry_passwordresetconfirmpassword = options.farcry_passwordresetconfirmpassword || "#passwordresetconfirmpassword";
	options.farcry_passwordreseterror = options.farcry_passwordreseterror || "#passwordresetform .form-group:first";

	options.farcry_successclass = options.farcry_successclass || "alert alert-success";
	options.farcry_errorclass = options.farcry_errorclass || "alert alert-danger";


	// onAnonymousRequest() callback fires on page load when the user does not have a session
	// e.g. this could be used each time a page is rendered to log CRM analytics, etc
	options.onAnonymousRequest = options.onAnonymousRequest || function() {
		// default callback for anonymous requests is empty
	};

	// onSessionRequest(user) callback fires on page load when the user has an existing session
	// e.g. this could be used each time a page is rendered to update personalised user content
	// such as a profile menu, log CRM analytics, etc
	options.onSessionRequest = options.onSessionRequest || function(user) {
		// default callback for session requests is empty
	};

	// onLogin(user) callback fires after the user has just logged in successfully
	options.onLogin = options.onLogin || function(user) {
		if (options.login_location == "") {
			window.location.reload(true);
		}
		else {
			window.location.href = options.login_location;
		}
	};

	// onLogout() callback fires after the user has just logged out
	options.onLogout = options.onLogout || function() {
		if (options.logout_location == "") {
			window.location.reload(true);
		}
		else {
			window.location.href = options.logout_location;
		}
	};



	// farcryLogin() callback fires when the login form is submitted
	options.farcryLogin = options.farcryLogin || function(email, password) {

		email = email || $(options.farcry_loginemail).val();
		password = password || $(options.farcry_loginpassword).val();

		$.ajax({
			url: "/farLogin/displayAjaxSocialLogin",
			method: "POST",
			data: {
				"signin": "farcry",
				"email": email,
				"password": password
			},
			success: function(r) {

				if (r.bSuccess == true) {
					var user = {
						"signin": "farcry",
						"email": $(options.farcry_loginemail).val()
					};

					// login
					login(user);

				}
				else {
					showError(options.farcry_loginerror, r.error);
				}

			},
			error: function() {
				showError(options.farcry_loginerror, "There was an error logging in. Please try again or contact the site administrators.");
			}
		});

	};
	this.farcryLogin = function() {
		options.farcryLogin();
		return false;
	};

	// farcrySignUp() callback fires when the sign up form is submitted
	options.farcrySignUp = options.farcrySignUp || function() {

		$.ajax({
			url: "/farLogin/displayAjaxSignUp",
			method: "POST",
			data: {
				"signin": "farcry",
				"email": $(options.farcry_signupemail).val(),
				"password": $(options.farcry_signuppassword).val(),
				"confirmpassword": $(options.farcry_signupconfirmpassword).val(),
				"firstname": $(options.farcry_signupfirstname).val(),
				"lastname": $(options.farcry_signuplastname).val()
			},
			success: function(r) {

				if (r.bSuccess == true) {
					var user = {
						"signin": "farcry",
						"email": $(options.farcry_signupemail).val()
					};

					// login
					login(user);

				}
				else {
					showError(options.farcry_signuperror, r.error);
				}

			},
			error: function() {
				showError(options.farcry_signuperror, "There was an error signing up. Please try again or contact the site administrators.");
			}

		});

	};
	this.farcrySignUp = function() {
		options.farcrySignUp();
		return false;
	};

	// farcryForgotPassword() callback fires when the forgot password form is submitted
	options.farcryForgotPassword = options.farcryForgotPassword || function() {

		$.ajax({
			url: "/farLogin/displayAjaxForgotPassword",
			method: "POST",
			data: {
				"signin": "farcry",
				"email": $(options.farcry_forgotpasswordemail).val(),
			},
			success: function(r) {
				if (r.bSuccess == true) {
					// show success message
					showSuccess(options.farcry_forgotpassworderror, "An email has been sent to you containing a link to reset your password.");
				}
				else {
					showError(options.farcry_forgotpassworderror, r.error);
				}

			},
			error: function() {
				showError(options.farcry_forgotpassworderror, "There was an error sending your password reset email. Please contact the site administrators.");
			}
		});

	};
	this.farcryForgotPassword = function() {
		options.farcryForgotPassword();
		return false;
	};

	// farcryPasswordReset() callback fires when the forgot password form is submitted
	options.farcryPasswordReset = options.farcryPasswordReset || function() {

		var email = $(options.farcry_passwordresetemail).val();
		var password = $(options.farcry_passwordresetpassword).val();

		$.ajax({
			url: "/farLogin/displayAjaxPasswordReset",
			method: "POST",
			data: {
				"signin": "farcry",
				"email": email,
				"key": $(options.farcry_passwordresetkey).val(),
				"password": password,
				"confirmpassword": $(options.farcry_passwordresetconfirmpassword).val()
			},
			success: function(r) {

				if (r.bSuccess == true) {
					var user = {
						"signin": "farcry",
						"email": email
					};

					// login and redirect to home page
					if (options.login_location == "") {
						options.login_location = "/";
					}
					options.farcryLogin(email, password);

				}
				else {
					showError(options.farcry_passwordreseterror, r.error);
				}

			},
			error: function() {
				showError(options.farcry_passwordreseterror, "There was an error resetting your password. Please try again or contact the site administrators.");
			}
		});

	};
	this.farcryPasswordReset = function() {
		options.farcryPasswordReset();
		return false;
	};


	// check for a user session and fire the onSessionRequest callback
	var currentuser = getCurrentUser();
	if (currentuser.success == true) {
		options.onSessionRequest(currentuser);
	}
	else {
		options.onAnonymousRequest();
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
		var user = getCurrentUser();
		if (user && user.signin) {
			if (user.signin == "facebook") facebookLogout();
			else if (user.signin == "linkedin") linkedinLogout();
			else if (user.signin == "farcry") removeSession();
		}
		else {
 			removeSession();
		}
	}
	this.logout = logout;


	function removeSession() {
		document.cookie = "FCSOCIAL=;expires=0";
		$.ajax({
			url: "/farLogin/displayAjaxSocialLogout",
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
		try {
			IN.User.logout(function(){
				removeSession();
			});
		}
		catch (err) {
			removeSession();
		}
	}


	// Handle the successful return from the API call
	function onSuccess(data) {

		// validate linkedin login
		$.ajax({
			url: "/farLogin/displayAjaxSocialLogin",
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
					showError(options.login_socialbuttons, "There was an error logging in. Please try again or contact the site administrators.");
				}

			},
			error: function() {
				showError(options.login_socialbuttons, "There was an error logging in. Please try again or contact the site administrators.");
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
	}


	//
	// FACEBOOK
	//

	this.facebookLogin = function() {
		FB.login(function(response) {
			FB.getLoginStatus(function(response) {
				statusChangeCallback(response);
			});
		}, {
			scope: "email",
			auth_type: "rerequest"
		});
	}

	this.facebookLogout = function() {
		try {
			FB.logout(function(response) {
				removeSession();
			});
		}
		catch (err) {
			removeSession();
		}
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
						url: "/farLogin/displayAjaxSocialLogin",
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
								showError(options.login_socialbuttons, "There was an error logging in. Please try again or contact the site administrators.");
							}

						},
						error: function() {
							showError(options.login_socialbuttons, "There was an error logging in. Please try again or contact the site administrators.");
						}
					});

				});

			}

		} else if (response.status === 'not_authorized') {
			// The person is logged into Facebook, but not your app.
		} else {
			// The person is not logged into Facebook, so we're not sure if
			// they are logged into this app or not.
		}
	}


	function showSuccess(selector, message) {
		hideError();
		$("<div class='" + options.farcry_successclass + " fcsocial-error'>" + message + "</div>").insertBefore(selector);
	}

	function showError(selector, message) {
		hideError();
		$("<div class='" + options.farcry_errorclass + " fcsocial-error'>" + message + "</div>").insertBefore(selector);
	}

	function hideError() {
		$(".fcsocial-error").remove();
	}


	return this;
};
