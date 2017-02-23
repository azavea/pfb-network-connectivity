/**
 * @ngdoc controller
 * @name pfb.help.controller:HelpController
 *
 * @description
 * Controller for Help page
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function HelpController($log, $location, $anchorScroll) {
        var ctl = this;

        initialize();

        function getHost (protocol, port) {
            var host = $location.host();
            if (ctl.protocol === 'https' && port !== 443) {
                host = host + ':' + port;
            } else if (ctl.protocol === 'http' && port !== 80) {
                host = host + ':' + port;
            }
            return host;
        }

        function initialize() {
            var port = $location.port();
            ctl.protocol = $location.protocol();
            ctl.host = getHost(ctl.protocol, port);
        }

        /**
         * @ngdoc function
         * @name pfb.help.controller:HelpController#scrollTo
         * @methodOf pfb.help.controller:HelpController
         *
         * @description
         * Scrolls to internal header based on ID for help page
         */
        ctl.scrollTo = function(id) {
            $location.hash(id);
            $anchorScroll();
        };
    }

    angular
        .module('pfb.help')
        .controller('HelpController', HelpController);
})();
