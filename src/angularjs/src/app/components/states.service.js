/**
 * @ngdoc service
 * @name repository.components.stats:Area
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

    angular.module('repository.components')
        .factory('Area', Area);
})();
