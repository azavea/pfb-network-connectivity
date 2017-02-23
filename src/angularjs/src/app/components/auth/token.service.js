/**
 * @ngdoc service
 * @name pfb.auth.token:TokenService
 *
 * @description
 * Handles requesting and regenerating tokens
 */
(function() {
    'use strict';

    /**
     * @ngInject
     */
    function TokenService ($q, $http) {

        var module = {
            createToken: createToken,
            getToken: getToken
        };

        return module;

        function createToken(userUuid) {
            var dfd = $q.defer();
            var url = '/api/users/' + userUuid + '/token/';
            $http.post(url)
                .success(function(data) {
                    dfd.resolve(data.token);
                })
                .error(function() {
                    dfd.reject('Unable to create token');
                });
            return dfd.promise;
        }

        function getToken(userUuid) {
            var dfd = $q.defer();
            var url = '/api/users/' + userUuid + '/token/';
            $http.get(url)
                .success(function(data) {
                    dfd.resolve(data.token);
                })
                .error(function() {
                    dfd.reject('Unable to retrieve token');
                });
            return dfd.promise;
        }

    }

    angular.module('pfb.components.auth')
        .factory('TokenService', TokenService);

})();
