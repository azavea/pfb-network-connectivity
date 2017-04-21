/**
 * @ngdoc controller
 * @name pfb.organizations.organizations-detail.controller:OrganizationDetailController
 *
 * @description
 * Handles creating/editing an organization; only available to admins in admin org
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function OrganizationDetailController($log, $stateParams, $state, toastr, AuthService,
                                          Organization) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.editing = !!$stateParams.uuid;
            ctl.isAdminUser = AuthService.isAdminUser();
            ctl.isAdminOrg = AuthService.isAdminOrg();
            ctl.saveOrg = saveOrg;
            ctl.orgTypes = Organization.orgTypes;
            ctl.org = {};
            loadData();
        }

        function loadData() {
            if ($stateParams.uuid) {
                ctl.org = Organization.get($stateParams);
            }
        }

        function saveOrg() {
            toastr.info('Saving organization');
            if (ctl.org.uuid) {
                ctl.org.$update().then(function(org) {
                    ctl.org = org;
                    toastr.success('Changes saved.');
                });
            } else {
                Organization.save(ctl.org).$promise.then(function(org) {
                    ctl.org = org;
                    toastr.success('Organization created.');
                    $state.go('admin.organizations.list');
                }, function() {
                    toastr.error('Error creating organization.');
                });
            }
        }
    }

    angular
        .module('pfb.organizations.detail')
        .controller('OrganizationDetailController', OrganizationDetailController);
})();
