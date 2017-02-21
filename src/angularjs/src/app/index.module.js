(function() {
    'use strict';

    angular
        .module('pfb', [
            'angular-loading-bar', 'pfb.login', 'pfb.boundaryUploads', 'pfb.help',
            'pfb.passwordReset', 'pfb.users', 'pfb.organizations',
            'ngAnimate', 'ngCookies', 'ngSanitize', 'ngMessages', 'ngAria',
            'ngResource', 'ui.router', 'toastr', 'ui.bootstrap', 'pfb.components']);

})();
