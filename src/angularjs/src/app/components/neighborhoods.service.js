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
                    limit: 'all'
                }
            },
            'geojson': {
                method: 'GET',
                isArray: false,
                url: '/api/neighborhoods_geojson/'
            }
        });
    }

    angular.module('pfb.components')
        .factory('Neighborhood', Neighborhood);
})();
