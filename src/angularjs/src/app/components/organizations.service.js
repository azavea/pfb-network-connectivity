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
        var module = $resource('/api/organizations/:uuid/', {uuid: '@uuid'}, {
            'update': {
                method: 'PUT'
            },
            'list': {
                method: 'GET',
                url: '/api/organizations/',
                isArray: true
            }
        });

        module.orgTypes = {
            ADMIN: 'Administrator Organization',
            LOCAL: 'Local Agency',
            SUBSCRIBER: 'Subscription'
        };

        return module;
    }

    angular.module('pfb')
        .factory('Organization', Organization);
})();
