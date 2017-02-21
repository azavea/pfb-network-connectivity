/**
 * @ngdoc controller
 * @name repository.organizations.list.organizations-list.controller:OrganizationListController
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
        ctl.orgTypes = {
            SUBSCRIBER: 'Subscriber',
            AREA: 'Area',
            ADMIN: 'Admin'
        };

        initialize();

        function initialize() {
            ctl.orgs = Organization.query();
        }
    }

    angular
        .module('repository.organizations.list')
        .controller('OrganizationListController', OrganizationListController);
})();
