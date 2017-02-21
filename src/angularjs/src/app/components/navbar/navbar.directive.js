/**
 * @ngdoc directive
 * @name repository.navbar.directive:repositoryNavbar
 * @restrict 'E'
 *
 * @description
 * Top level navigation bar for repository application
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

    function repositoryNavbar() {
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
        .module('repository')
        .controller('NavbarController', NavbarController)
        .directive('repositoryNavbar', repositoryNavbar);

})();
