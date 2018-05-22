(function() {

    /**
     * @ngdoc controller
     * @name pfb.components.filters.AnalysisJobFilterController
     *
     * @description
     * Controller for the analysis job filtering table header
     */
    /** @ngInject */
    function AnalysisJobFilterController($scope, AnalysisJobStatuses) {
        var ctl = this;
        initialize();

        function initialize() {
            ctl.batchId = '';
            ctl.statusFilter = '';
            ctl.statuses = AnalysisJobStatuses.statuses;
            ctl.onTextFilterChanged = onTextFilterChanged;
            ctl.onStatusFilterChanged = onStatusFilterChanged;
        }

        function onTextFilterChanged() {
            ctl.filters = {
                neighborhood: ctl.searchText,
                status: AnalysisJobStatuses.filterMap[ctl.statusFilter],
                batch: ctl.batchId
            };
        }

        function onStatusFilterChanged($item) {
            var status = AnalysisJobStatuses.filterMap[$item || ctl.statusFilter];
            ctl.filters = {
                neighborhood: ctl.searchText,
                status: status || '',
                batch: ctl.batchId
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
