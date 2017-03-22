/**
 * @ngdoc service
 * @name pfb.components.stats:State
 * @description
 * Resource for states
 */
(function() {
    'use strict';

    /* @ngInject */
    function State($resource) {
        return $resource('/api/states/', {}, {
            'query': {
                method: 'GET',
                isArray: true
            }
        });
    }

    angular.module('pfb.components')
        .factory('State', State);
})();
