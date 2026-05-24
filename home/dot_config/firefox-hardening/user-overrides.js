// Enable userChrome.css / userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

user_pref("browser.startup.page", 3); // restore previous session
user_pref("browser.search.suggest.enabled", true);

user_pref("privacy.clearOnShutdown.history", false);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false)

user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);

user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);
user_pref("sidebar.main.tools", "");
user_pref("sidebar.visibility", "always-show");

/* END: internal custom pref to test for syntax errors ***/
user_pref("_user.js.parrot", "Ahoy!");
