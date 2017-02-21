/**
 * @ngdoc service
 * @name pfb.components.organization:Organization
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

    angular.module('pfb')
        .factory('Organization', Organization);
})();
