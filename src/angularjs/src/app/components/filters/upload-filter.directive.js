(function() {

    /**
     * @ngdoc controller
     * @name repository.components.filters.UploadFilterController
     *
     * @description
     * Controller for the Boundary upload filtering table header
     */
    /** @ngInject */
    function UploadFilterController($scope, $http, AuthService, BoundaryUploadStatuses) {
        var ctl = this;
        initialize();

        function initialize() {
            loadOptions(ctl.param);
            $scope.$watch(function(){return ctl.statusFilter;}, filterStatus);
            $scope.$watch(function(){return ctl.areaFilter;}, filterArea);
            $scope.$watch(function(){return ctl.boundaryFilter;}, filterBoundary);
        }

        function loadOptions() {
            $http.get('/api/areas/').success(function(data) {
                ctl.areas = data;
            });
            ctl.statuses = BoundaryUploadStatuses.statuses;
        }

        function filterArea(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                area: newFilter,
                status: BoundaryUploadStatuses.filterMap[ctl.statusFilter]
            };
        }

        function filterStatus(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                area: ctl.areaFilter,
                status: BoundaryUploadStatuses.filterMap[newFilter]
            };
        }

        function filterBoundary(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                area: ctl.areaFilter,
                status: BoundaryUploadStatuses.filterMap[ctl.statusFilter]
            };
        }
    }

    /**
     * @ngdoc directive
     * @scope
     * @name repository.components.filters.UploadFilterDirective:repositoryUploadFilter
     *
     * @description
     * Directive for the Boundary upload filtering table header
     * Filters by area and status with client-side auto-complete
     */
    function UploadFilterDirective() {
        var module = {
            restrict: 'A',
            templateUrl: 'app/components/filters/upload-filter.html',
            controller: 'UploadFilterController',
            controllerAs: 'ctl',
            bindToController: true,
            scope: {
                filters: '='
            }
        };
        return module;
    }

    angular.module('repository.components.filters')
        .controller('UploadFilterController', UploadFilterController)
        .directive('repositoryUploadFilter', UploadFilterDirective);
})();
