/**
 * @ngdoc service
 * @name pfb.components.stats:Area
 *
 * @description
 * Resource for areas
 */
(function() {
    'use strict';

    /* @ngInject */
    function Area($resource) {
        return $resource('/api/areas/');
    }

    angular.module('pfb.components')
        .factory('Area', Area);
})();
