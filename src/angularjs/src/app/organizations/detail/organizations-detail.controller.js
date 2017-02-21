/**
 * @ngdoc controller
 * @name repository.organizations.organizations-detail.controller:OrganizationDetailController
 *
 * @description
 * Handles creating/editing an organization; only available to admins in admin org
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function OrganizationDetailController($log, $stateParams, $state, toastr, AuthService,
                                          Organization, Area) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.editing = !!$stateParams.uuid;
            ctl.isAdminUser = AuthService.isAdminUser();
            ctl.isAdminOrg = AuthService.isAdminOrg();
            ctl.saveOrg = saveOrg;
            ctl.orgTypes = {
                ADMIN: 'Administrator Organization',
                AREA: 'Area Agency',
                SUBSCRIBER: 'Subscription'
            };
            ctl.org = {};
            loadData();
        }

        // Load data, load org after areas to prevent race condition in dropdown
        function loadData() {
            var areas = Area.query();
            areas.$promise.then(function() {
                ctl.areas = _.keyBy(areas, function(area) {
                    return area.abbreviation;
                });
                if ($stateParams.uuid) {
                    ctl.org = Organization.get($stateParams);
                }
            });
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
                    $state.go('organizations.list');
                }, function() {
                    toastr.error('Error creating organization.');
                });
            }
        }
    }

    angular
        .module('repository.organizations.detail')
        .controller('OrganizationDetailController', OrganizationDetailController);
})();
