/**
 * @ngdoc service
 * @name pfb.components.Pagination:Pagination
 *
 * @description
 * Handles parsing next/previous links for params to aid pagination
 */
(function() {
    'use strict';

    /* @ngInject */
    function Pagination() {

        var module = {
            getLinkParams: getLinkParams
        };

        return module;

        function getLinkParams(url) {
            if (!url) {
                return null;
            } else {
                var uri = URI(url);
                return uri.search(true);
            }
        }
    }

    angular.module('pfb.components')
        .factory('Pagination', Pagination);
})();
