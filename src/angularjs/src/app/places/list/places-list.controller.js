/**
 * @ngdoc controller
 * @name pfb.place.list.controller:PlaceListController
 *
 * @description
 * Controller for listing analysis jobs
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function PlaceListController($log, $state, $stateParams, $scope, Pagination, AuthService,
                                 Neighborhood, AnalysisJob) {
        var ctl = this;

        var sortingOptions = [
            {value: 'neighborhood__state_abbrev,neighborhood__label', label: 'Alphabetical'},
            {value: '-overall_score', label: 'Highest Rated'},
            {value: 'overall_score', label: 'Lowest Rated'},
            {value: '-modified_at', label: 'Last Updated'}
        ];

        var defaultParams = {
            limit: null,
            offset: null,
            latest: 'True',
            status: 'COMPLETE'
        };
        var nextParams = {};
        var prevParams = {};

        initialize();

        function initialize() {
            ctl.isAdminUser = AuthService.isAdminUser();

            ctl.hasNext = false;
            ctl.getNext = getNext;

            ctl.hasPrev = false;
            ctl.getPrev = getPrev;
            ctl.places = [];

            ctl.neighborhoodFilter = null;
            ctl.placeToRemoveFromComparison = null;

            ctl.comparePlaces = [];
            ctl.addPlaceToCompare = addPlaceToCompare;

            ctl.sortBy = sortingOptions[0]; // default to alphabetical order
            ctl.sortingOptions = sortingOptions;

            ctl.getPlaces = getPlaces;

            getPlaces();
            loadOptions();
            $scope.$watch(function(){return ctl.neighborhoodFilter;}, filterNeighborhood);
            $scope.$watch(function(){return ctl.placeToRemoveFromComparison;}, selectedComparePlace);
        }

        function addPlaceToCompare(place) {
            if (place.comparing) {
                $log.warn('aready have place selected to compare');
                return;
            }

            if (ctl.comparePlaces.length < 3) {
                place.comparing = true;
                ctl.comparePlaces.push(place);
            } else {
                $log.warn('already have three places to compare');

            }
        }

        /**
         * Fired when an option selected from comparison drop-down.
         * Either remove a selected place from comparison list, or if special last option selected,
         * go to comparison page with selections.
         */
        function selectedComparePlace(uuid) {
            if (!uuid) {
                return; // on page load, this watch fires will no value
            }

            // use special flag for bottom list item, which is to go to the compare page
            if (uuid === 'compare') {
                var newParams = _.extend({}, $stateParams);
                _.map(ctl.comparePlaces, function(place, offset) {
                    newParams['place' + (offset + 1)] = place.uuid;
                });
                $state.go('places.compare', newParams);
            } else {
                _.remove(ctl.comparePlaces, function(place) {
                    if (place.uuid === uuid) {
                        // unset convenience flag indicating this is a place to compare
                        place.comparing = false;
                        return true;
                    }
                    return false;
                });

                // be sure to clear current selection once removing it as an option
                // sometimes angular does this on its own, but it doesn't seem to be consistent
                ctl.placeToRemoveFromComparison = null;
            }
        }

        function filterNeighborhood(newFilter, oldFilter) {
            if (newFilter === oldFilter) {
                return;
            }

            getPlaces();
        }

        function loadOptions() {
            // fetch all neighborhoods, to populate the search bar
            Neighborhood.all().$promise.then(function(data) {
                ctl.allNeighborhoods = data.results;
            });
        }

        function getPlaces(params) {
            params = params || _.merge({}, $stateParams, defaultParams);
            params.ordering = ctl.sortBy.value;
            if (ctl.neighborhoodFilter) {
                params.neighborhood = ctl.neighborhoodFilter.uuid;
            }

            AnalysisJob.query(params).$promise.then(function(data) {

                ctl.places = _.map(data.results, function(obj) {
                    var neighborhood = new Neighborhood(obj.neighborhood);
                    // get properties from the neighborhood's last run job
                    neighborhood.modifiedAt = obj.modifiedAt;
                    neighborhood.overall_score = obj.overall_score;
                    // add convenience flag to indicate if place selected for comparison
                    neighborhood.comparing = false;
                    return neighborhood;
                });

                if (data.next) {
                    ctl.hasNext = true;
                    nextParams = Pagination.getLinkParams(data.next);
                } else {
                    ctl.hasNext = false;
                    nextParams = {};
                }

                if (data.previous) {
                    ctl.hasPrev = true;
                    prevParams = Pagination.getLinkParams(data.previous);
                } else {
                    ctl.hasPrev = false;
                    prevParams = {};
                }

            });
        }

        function getNext() {
            var params = _.merge({}, defaultParams, nextParams);
            $state.go('places.list', params, {notify: false});
            getPlaces(params);
        }

        function getPrev() {
            var params = _.merge({}, defaultParams, prevParams);
            $state.go('places.list', params, {notify: false});
            getPlaces(params);
        }

    }

    angular
        .module('pfb.places.list')
        .controller('PlaceListController', PlaceListController);
})();
