/**
 * @ngdoc service
 * @name repository.components.organization:Organization
 *
 * @description
 * Resource for Organization
 */
(function() {
    'use strict';

    /* @ngInject */
    function Organization($resource) {

        return $resource('/api/organizations/:uuid/', {uuid: '@uuid'}, {
            'update': {
                method: 'PUT'
            },
            'list': {
                method: 'GET',
                url: '/api/organizations/',
                isArray: true
            }
        });
    }

    angular.module('repository')
        .factory('Organization', Organization);
})();
