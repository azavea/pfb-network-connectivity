/**
 * @ngdoc service
 * @name pfb.components.stats:Neighborhood
 *
 * @description
 * Resource for neighborhoods
 */
(function() {
    'use strict';

    /* @ngInject */
    function Neighborhood($resource) {
        return $resource('/api/neighborhoods/:uuid/', {uuid: '@uuid'}, {
            'query': {
                method: 'GET',
                isArray: false
            },
            'all': {
                method: 'GET',
                isArray: false,
                params: {
                    limit: 10000
                }
            }
        });
    }

    angular.module('pfb.components')
        .factory('Neighborhood', Neighborhood);
})();
