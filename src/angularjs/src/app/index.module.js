(function() {
    'use strict';

    angular
        .module('repository', [
            'angular-loading-bar', 'repository.login', 'repository.boundaryUploads', 'repository.help',
            'repository.passwordReset', 'repository.users', 'repository.organizations',
            'ngAnimate', 'ngCookies', 'ngSanitize', 'ngMessages', 'ngAria',
            'ngResource', 'ui.router', 'toastr', 'ui.bootstrap', 'repository.components']);

})();
