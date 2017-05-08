/**
 * @ngdoc controller
 * @name pfb.users.users-detail.controller:UserDetailController
 *
 * @description
 * Controller for user detail page. This pulls double-duty for creating and editing
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function UserDetailController($state, $stateParams, toastr,
                                  User, Organization, AuthService, TokenService) {
        var ctl = this;

        function initialize() {
            ctl.organizations = {};
            ctl.user = {};
            ctl.isAdminUser = AuthService.isAdminUser();
            ctl.isOrgAdminUser = AuthService.isOrgAdminUser();
            ctl.isAdminOrg = AuthService.isAdminOrg();
            ctl.saveUser = saveUser;
            ctl.setUserActive = setUserActive;
            ctl.loggedInEmail = AuthService.getEmail();

            ctl.editing = !!$stateParams.uuid;

            ctl.roleOptions = {
                VIEWER: 'Viewer',
                ADMIN: 'Administrator',
                ORGADMIN: 'Organization Administrator',
                EDITOR: 'Editor',
                UPLOADER: 'Uploader'
            };

            ctl.createToken = createToken;
            loadData();
        }

        initialize();

        function loadData() {
            var orgs = Organization.query();

            orgs.$promise.then(function(orgs) {
                ctl.organizations = _.keyBy(orgs, function(org) {
                    return org.label;
                });
            });

            if (ctl.editing) {
                orgs.$promise.then(function() {
                    ctl.user = User.get($stateParams);
                    TokenService.getToken($stateParams.uuid).then(function(token) {
                        ctl.token = token;
                    });
                });
            }
        }

        function createToken() {
            var r = confirm('Refreshing an API token will invalidate the current one.\n' +
                            'This action is not reversible.\n'+
                            'Are you sure you want to do this?');
            if(r) {
                TokenService.createToken(ctl.user.uuid).then(function(token) {
                    ctl.token = token;
                    toastr.info('Token refreshed.');
                });
            }
        }

        function saveUser() {
            if (ctl.user.uuid) {
                ctl.user.$update().then(function(user) {
                    ctl.user = user;
                    toastr.info('Changes saved.');
                }, function(error) {
                    if (error.data && error.data.detail) {
                        toastr.error(error.data.detail, {timeOut: 5000});
                    }
                });
            } else {
                User.save(ctl.user).$promise.then(function() {
                    $state.go('admin.users.list');
                }, function(error) {
                    for (var key in error.data) {
                        if (error.data.hasOwnProperty(key)) {
                            for (var msg in error.data[key]) {
                                toastr.error(error.data[key][msg], {timeOut: 5000});
                            }
                        }
                    }
                });
            }
        }

        function setUserActive(active) {
            if (ctl.user.uuid) {
                ctl.user.isActive = active;
                ctl.user.$update().then(function(user) {
                    ctl.user = user;
                    if (ctl.user.isActive) {
                        toastr.info('User activated');
                    }
                    else {
                        toastr.info('User deactivated');
                    }
                });
            }
        }
    }

    angular
        .module('pfb.users.detail')
        .controller('UserDetailController', UserDetailController);
})();
