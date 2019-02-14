/**
 * @ngdoc service
 * @name pfb.components.stats:Country
 * @description
 * Resource for countries
 */
(function() {
    'use strict';

    /* @ngInject */
    function Country($resource) {
        return $resource('/api/countries/', {}, {
            cache: true,
            query: {
                method: 'GET',
                isArray: true
            }
        });
    }

    angular.module('pfb.components')
        .factory('Country', Country);
})();
