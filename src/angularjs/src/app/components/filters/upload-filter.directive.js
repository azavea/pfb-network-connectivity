(function() {

    /**
     * @ngdoc controller
     * @name pfb.components.filters.UploadFilterController
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
            $scope.$watch(function(){return ctl.neighborhoodFilter;}, filterNeighborhood);
            $scope.$watch(function(){return ctl.boundaryFilter;}, filterBoundary);
        }

        function loadOptions() {
            $http.get('/api/neighborhoods/').success(function(data) {
                ctl.neighborhoods = data;
            });
            ctl.statuses = BoundaryUploadStatuses.statuses;
        }

        function filterNeighborhood(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                neighborhood: newFilter,
                status: BoundaryUploadStatuses.filterMap[ctl.statusFilter]
            };
        }

        function filterStatus(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                neighborhood: ctl.neighborhoodFilter,
                status: BoundaryUploadStatuses.filterMap[newFilter]
            };
        }

        function filterBoundary(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                neighborhood: ctl.neighborhoodFilter,
                status: BoundaryUploadStatuses.filterMap[ctl.statusFilter]
            };
        }
    }

    /**
     * @ngdoc directive
     * @scope
     * @name pfb.components.filters.UploadFilterDirective:pfbUploadFilter
     *
     * @description
     * Directive for the Boundary upload filtering table header
     * Filters by neighborhood and status with client-side auto-complete
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

    angular.module('pfb.components.filters')
        .controller('UploadFilterController', UploadFilterController)
        .directive('pfbUploadFilter', UploadFilterDirective);
})();
