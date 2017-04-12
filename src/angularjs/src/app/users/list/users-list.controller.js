/**
 * @ngdoc controller
 * @name pfb.users.list.users-list.controller:UserDetailController
 *
 * @description
 * Controller for user detail page. This pulls double-duty for creating and editing
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function UserListController($state, $stateParams, $scope, Pagination, User) {
        var ctl = this;

        var defaultParams = {
            limit: null,
            offset: null
        };
        var nextParams = {};
        var prevParams = {};

        initialize();

        function initialize() {
            ctl.hasNext = false;
            ctl.getNext = getNext;

            ctl.hasPrev = false;
            ctl.getPrev = getPrev;

            ctl.users = [];

            ctl.roleOptions = {
                VIEWER: 'Viewer',
                ADMIN: 'Administrator',
                EDITOR: 'Editor',
                UPLOADER: 'Uploader'
            };
            getUsers();
            ctl.filters = {};
            $scope.$watch(function(){return ctl.filters;}, filterUsers);
        }

        function filterUsers(filters) {
            var params = _.merge({}, defaultParams, filters);
            if (filters.organization) {
                params.organization = filters.organization;
            }
            if (filters.role) {
                params.role = filters.role;
            }
            getUsers(params);
            return true;
        }

        function getUsers(params) {
            params = params || $stateParams;
            User.query(params).$promise.then(function(data) {
                ctl.users = _.map(data.results, function(obj) {
                    return new User(obj);
                });

                if (data.next) {
                    ctl.hasNext = true;
                    nextParams = Pagination.getLinkParams(data.next);
                } else {
                    ctl.hasNext = false;
                    nextParams = {};
                }

                if (data.previous) {
                    ctl.hasPrev = true;
                    prevParams = Pagination.getLinkParams(data.previous);
                } else {
                    ctl.hasPrev = false;
                    prevParams = {};
                }
            });
        }

        function getNext() {
            var params = _.merge({}, defaultParams, nextParams);
            $state.go('users.list', params, {
                notify: false
            });
            getUsers(params);
        }

        function getPrev() {
            var params = _.merge({}, defaultParams, prevParams);
            $state.go('users.list', params, {
                notify: false
            });
            getUsers(params);
        }
    }

    angular
        .module('pfb.users.list')
        .controller('UserListController', UserListController);
})();
