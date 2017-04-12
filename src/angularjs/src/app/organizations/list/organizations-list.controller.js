/**
 * @ngdoc controller
 * @name pfb.organizations.list.organizations-list.controller:OrganizationListController
 *
 * @description
 * Controller for Organization list page
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function OrganizationListController(Organization) {
        var ctl = this;
        ctl.organizations = [];
        ctl.orgTypes = Organization.orgTypes;

        initialize();

        function initialize() {
            ctl.orgs = Organization.query();
        }
    }

    angular
        .module('pfb.organizations.list')
        .controller('OrganizationListController', OrganizationListController);
})();
