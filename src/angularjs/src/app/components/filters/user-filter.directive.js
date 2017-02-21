(function() {
    /**
     * @ngdoc controller
     * @name repository.components.filters.UserFilterController
     *
     * @description
     * Controller for the User filtering table header
    */
    /** @ngInject */
    function UserFilterController($scope, Organization, UserRoles) {
        var ctl = this;
        initialize();
        function initialize() {
            loadOptions(ctl.param);
            $scope.$watch(function(){return ctl.organizationFilter;}, filterOrgs);
            $scope.$watch(function(){return ctl.roleFilter;}, filterRoles);
        }

        function loadOptions() {
            Organization.list().$promise.then(function(organizations) {
                ctl.organizations = organizations;
            });

            ctl.role = null;
            ctl.roles = UserRoles.roles;
        }

        function filterRoles(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                role: UserRoles.roleFilters[newFilter],
                organization: ctl.organizationFilter
            };

        }

        function filterOrgs(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                role: UserRoles.roleFilters[ctl.roleFilter],
                organization: newFilter
            };
        }
    }

    /**
     * @ngdoc directive
     * @scope
     * @name repository.components.filters.UserFilterDirective:repositoryUserFilter
     *
     * @description
     * Directive for the User filtering table header
     * Filters by role and organization
     *
     */
    function UserFilterDirective() {
        var module = {
            restrict: 'A',
            templateUrl: 'app/components/filters/user-filter.html',
            controller: 'UserFilterController',
            controllerAs: 'ctl',
            bindToController: true,
            scope: {
                filters: '='
            }
        };
        return module;
    }

    angular.module('repository.components.filters')
        .controller('UserFilterController', UserFilterController)
        .directive('repositoryUserFilter', UserFilterDirective);
})();
