/**
 * @ngdoc directive
 * @name pfb.footer.directive:pfbFooter
 * @restrict 'E'
 *
 * @description
 * Top level navigation bar for pfb application
 */

(function() {
    'use strict';

    /** @ngInject */
    function FooterController(AuthService) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.logout = AuthService.logout;
            // if user ID cookie is set, assume user is logged in
            ctl.loggedIn = !!AuthService.getUserId();
        }
    }

    function pfbFooter() {
        var directive = {
            restrict: 'E',
            templateUrl: 'app/components/footer/footer.html',
            controller: 'FooterController',
            controllerAs: 'footer',
            bindToController: true
        };

        return directive;
    }


    angular
        .module('pfb')
        .controller('FooterController', FooterController)
        .directive('pfbFooter', pfbFooter);

})();
