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
            ctl.logout = AuthService.logout;
            ctl.userArea = AuthService.getUserOrgArea();
            ctl.userUuid = AuthService.getUserId();
            ctl.userName = AuthService.getUserName();

            if (!AuthService.getEmail()) {
                $state.go('login');
            }
        }
    }

    function pfbNavbar() {
        var directive = {
            restrict: 'E',
            templateUrl: 'app/components/navbar/navbar.html',
            controller: 'NavbarController',
            controllerAs: 'navbar',
            bindToController: true
        };

        return directive;
    }


    angular
        .module('pfb')
        .controller('NavbarController', NavbarController)
        .directive('pfbNavbar', pfbNavbar);

})();
