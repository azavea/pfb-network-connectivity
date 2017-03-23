(function() {

    /**
     * @ngdoc controller
     * @name pfb.components.filters.AnalysisJobFilterController
     *
     * @description
     * Controller for the analysis job filtering table header
     */
    /** @ngInject */
    function AnalysisJobFilterController($scope, Neighborhood, AuthService, AnalysisJobStatuses) {
        var ctl = this;
        initialize();

        function initialize() {
            loadOptions(ctl.param);
            $scope.$watch(function(){return ctl.statusFilter;}, filterStatus);
            $scope.$watch(function(){return ctl.neighborhoodFilter;}, filterNeighborhood);
            $scope.$watch(function(){return ctl.analysisJobFilter;}, filterBoundary);
        }

        function loadOptions() {
            Neighborhood.all().$promise.then(function(data) {
                ctl.neighborhoods = data.results;
            });

            ctl.statusFilter = null;
            ctl.neighborhoodFilter = null;
            ctl.statuses = AnalysisJobStatuses.statuses;
        }

        function filterNeighborhood(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                neighborhood: newFilter,
                status: AnalysisJobStatuses.filterMap[ctl.statusFilter]
            };
        }

        function filterStatus(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                neighborhood: ctl.neighborhoodFilter,
                status: AnalysisJobStatuses.filterMap[newFilter]
            };
        }

        function filterBoundary(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }
            ctl.filters = {
                neighborhood: ctl.neighborhoodFilter,
                status: AnalysisJobStatuses.filterMap[ctl.statusFilter]
            };
        }
    }

    /**
     * @ngdoc directive
     * @scope
     * @name pfb.components.filters.AnalysisJobFilterDirective:pfbAnalysisJobFilter
     *
     * @description
     * Directive for the analysis filtering table header
     * Filters by neighborhood and status with client-side auto-complete
     */
    function AnalysisJobFilterDirective() {
        var module = {
            restrict: 'A',
            templateUrl: 'app/components/filters/analysis-job-filter.html',
            controller: 'AnalysisJobFilterController',
            controllerAs: 'ctl',
            bindToController: true,
            scope: {
                filters: '='
            }
        };
        return module;
    }

    angular.module('pfb.components.filters')
        .controller('AnalysisJobFilterController', AnalysisJobFilterController)
        .directive('pfbAnalysisJobFilter', AnalysisJobFilterDirective);
})();
