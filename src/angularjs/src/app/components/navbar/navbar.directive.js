/**
 * @ngdoc directive
 * @name pfb.navbar.directive:pfbNavbar
 * @restrict 'E'
 *
 * @description
 * Top level navigation bar for pfb application
 */

(function() {
    'use strict';

    /** @ngInject */
    function NavbarController(AuthService, $state) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.isAdminOrg = AuthService.isAdminOrg();
            ctl.isAdminUser = AuthService.isAdminUser();
            ctl.isAdminOrOrgAdminUser = AuthService.isAdminUser() || AuthService.isOrgAdminUser();
            ctl.logout = AuthService.logout;
            ctl.userUuid = AuthService.getUserId();
            ctl.userName = AuthService.getUserName();

            ctl.admin = $state.includes('admin');
            ctl.hideName = $state.is('home');
        }
    }

    function pfbNavbar() {
        var directive = {
            restrict: 'E',
            templateUrl: 'app/components/navbar/navbar.html',
            controller: 'NavbarController',
            controllerAs: 'navbar',
            bindToController: true,
            scope: {
                admin: '@',
                hideName: '@'
            }
        };

        return directive;
    }


    angular
        .module('pfb')
        .controller('NavbarController', NavbarController)
        .directive('pfbNavbar', pfbNavbar);

})();
