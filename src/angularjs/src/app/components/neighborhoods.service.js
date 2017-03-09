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
        return $resource('/api/neighborhoods/');
    }

    angular.module('pfb.components')
        .factory('Neighborhood', Neighborhood);
})();
