/**
 * @ngdoc service
 * @name pfb.auth.PasswordResetService:PasswordResetService
 *
 * @description
 * Handles requesting and processing password resets
 */
(function() {
    'use strict';

    /**
     * @ngInject
     */
    function PasswordResetService ($q, $http) {

        var module = {
            requestPasswordReset: requestPasswordReset,
            resetPassword: resetPassword
        };

        return module;

        function requestPasswordReset(email) {
            var dfd = $q.defer();
            var url = '/api/request-password-reset/';
            $http.post(url, {email: email})
                .success(function(data) {
                    dfd.resolve(data);
                });
            return dfd.promise;
        }

        function resetPassword(password, token) {
            var dfd = $q.defer();
            var url = '/api/reset-password/';
            $http.post(url, {password: password, token: token})
                .success(function(data) {
                    dfd.resolve(data);
                })
                .error(function() {
                    dfd.reject('Unable to reset password');
                });
            return dfd.promise;
        }

    }

    angular.module('pfb.components.auth')
        .factory('PasswordResetService', PasswordResetService);

})();
