/**
 * @ngdoc controller
 * @name pfb.login.user-login.controller:LoginController
 *
 * @description
 * Controller handling logging a user in
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function LoginController($log, $state, toastr, AuthService) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.login = login;
            if (AuthService.getEmail()) {
                $state.go('admin.analysis-jobs.list');
            }
        }

        function login() {
            AuthService.user = AuthService.login(
                {'email': ctl.email, 'password': ctl.password}
            ).then(function() {
                $state.go('admin.analysis-jobs.list');
            }).catch(function() {
                toastr.error('Unable to login with credentials', 'Error');
            });
        }
    }

    angular
        .module('pfb.login')
        .controller('LoginController', LoginController);

})();
