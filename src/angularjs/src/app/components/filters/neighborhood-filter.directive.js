(function() {

    /**
     * @ngdoc controller
     * @name pfb.components.filters.NeighborhoodFilterController
     *
     * @description
     * Controller for the neighborhood filtering table header
     */
    /** @ngInject */
    function NeighborhoodFilterController() {
        var ctl = this;
        initialize();

        function initialize() {
            ctl.filters = {}
            ctl.nameFilter = '';
            ctl.stateFilter = '';
            ctl.countryFilter = '';
            ctl.onFilterChanged = onFilterChanged;
        }

        function onFilterChanged() {
            ctl.filters = {
                name: ctl.nameFilter,
                state: ctl.stateFilter,
                country: ctl.countryFilter
            };
        }
    }

    /**
     * @ngdoc directive
     * @scope
     * @name pfb.components.filters.NeighborhoodFilterDirective:pfbNeighborhoodFilter
     *
     * @description
     * Directive for the neighborhood table header
     * Filters by neighborhood name, state and country
     */
    function NeighborhoodFilterDirective() {
        var module = {
            restrict: 'A',
            templateUrl: 'app/components/filters/neighborhood-filter.html',
            controller: 'NeighborhoodFilterController',
            controllerAs: 'ctl',
            bindToController: true,
            scope: {
                filters: '='
            }
        };
        return module;
    }

    angular.module('pfb.components.filters')
        .controller('NeighborhoodFilterController', NeighborhoodFilterController)
        .directive('pfbNeighborhoodFilter', NeighborhoodFilterDirective);
})();
