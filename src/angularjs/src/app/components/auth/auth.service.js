/**
 * @ngdoc service
 * @name pfb.auth.service:AuthService
 *
 * @description
 * Handles logging user in, logging out, accessing information on authenticated user
 */
(function() {
    'use strict';

    /**
     * @ngInject
     */
    function AuthService ($q, $http, $cookies, $state, User) {

        var userIdCookie = 'AuthService.userId';
        var emailCookie = 'AuthService.email';
        var userNameCookie = 'Authservice.userName';
        var userRoleCookie = 'AuthService.role';
        var userIsAdminOrg = 'AuthService.isAdminOrg';
        var userOrgArea = 'AuthService.userOrgArea';

        var module = {
            login: login,
            logout: logout,
            resetPassword: resetPassword,
            requestPasswordReset: requestPasswordReset,
            getUserId: getUserId,
            getEmail: getEmail,
            isAdminUser: isAdminUser,
            isAdminOrg: isAdminOrg,
            getUserOrgArea: getUserOrgArea,
            canViewAreaSite: canViewAreaSite,
            getUserName: getUserName
        };

        return module;

        function login(auth) {
            var dfd = $q.defer();
            $http.post('/api/login/', auth)
                .success(function(data) {
                    var user = new User(data);
                    $cookies.putObject(emailCookie, user.email);
                    $cookies.putObject(userIdCookie, user.uuid);
                    $cookies.putObject(userRoleCookie, user.role);
                    $cookies.putObject(userIsAdminOrg, user.isAdminOrganization);
                    $cookies.putObject(userOrgArea, user.area);
                    var userName = user.firstName;
                    if (!userName.length) {
                        userName = user.email;
                    }
                    $cookies.putObject(userNameCookie, userName);
                    dfd.resolve(user);
                })
                .error(function() {
                    dfd.reject('Unable to login');
                });

            return dfd.promise;
        }

        function logout() {
            var dfd = $q.defer();
            $http.post('/api/logout/')
                .success(function() {
                    $cookies.putObject(emailCookie, null);
                    $cookies.putObject(userIdCookie, null);
                    $cookies.putObject(userRoleCookie, null);
                    $cookies.putObject(userIsAdminOrg, null);
                    $cookies.putObject(userOrgArea, null);
                    dfd.resolve();
                    $state.go('login');
                })
                .error(function() {
                    dfd.reject('Unable to logout');
                });

            return dfd.promise;
        }

        function requestPasswordReset(user) {
            return $http.post('/api/request-password-reset/', {
                email: user
            });
        }

        function resetPassword(token, newPassword) {
            return $http.post('/api/reset-password/', {
                token: token,
                password: newPassword
            });
        }

        function getUserId() {
            return $cookies.getObject(userIdCookie);
        }

        function getEmail() {
            return $cookies.getObject(emailCookie);
        }

        function getUserName() {
            return $cookies.getObject(userNameCookie);
        }
        function canViewAreaSite() {
            return ($cookies.getObject(userRoleCookie) !== 'SUBSCRIBER' &&
                    $cookies.getObject(userRoleCookie) !== 'UPLOADER');
        }

        function isAdminUser() {
            return $cookies.getObject(userRoleCookie) === 'ADMIN';
        }

        function isAdminOrg() {
            return $cookies.getObject(userIsAdminOrg);
        }

        function getUserOrgArea() {
            return $cookies.getObject(userOrgArea);
        }
    }

    angular.module('pfb.components.auth').factory('AuthService', AuthService);

})();
