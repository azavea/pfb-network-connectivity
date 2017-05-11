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
    function PlaceListController($log, $state, $stateParams, $scope,
                                 Pagination, AuthService, Neighborhood, AnalysisJob) {
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
            ctl.searchText = '';

            ctl.comparePlaces = new Array(3);
            ctl.addPlaceToCompare = addPlaceToCompare;
            ctl.removeComparePlace = removeComparePlace;
            ctl.filterNeighborhoods = filterNeighborhoods;
            ctl.goComparePlaces = goComparePlaces;
            // convenience property to track number of selected places; must be updated on add/remove
            ctl.comparePlacesCount = 0;

            ctl.sortBy = sortingOptions[0]; // default to alphabetical order
            ctl.sortingOptions = sortingOptions;

            ctl.getPlaces = getPlaces;

            getPlaces();
        }

        /**
         * Add a place to the list of up to three places to view on compare page.
         *
         * @param {Neighborhood} place Neighborhood to list of places to compare
         * @param {boolean} updateUrl If true, will update URL without refreshing the page
                                      to include the place UUID in the route
         */
        function addPlaceToCompare(place, updateUrl) {
            if (place.comparing) {
                $log.warn('aready have place selected to compare');
                return;
            }

            // put place in first empty comparison slot of the three available
            var firstEmpty = _.findIndex(ctl.comparePlaces, function(place) { return !place; });
            if (firstEmpty > -1) {
                place.comparing = true;
                ctl.comparePlaces[firstEmpty] = place;
                ctl.comparePlacesCount++;
                // update URL to include place to compare, to retain state in case of page refresh
                if (updateUrl) {
                    updateComparisonsInUrl();
                }
            } else {
                $log.warn('already have three places to compare');

            }
        }

        // Convenience method to transition to places comparison page.
        function goComparePlaces() {
            $state.go('places.compare', $stateParams);
        }

        /**
         * Fired when an option selected from comparison drop-down.
         * Remove a selected place from comparison list.
         *
         * @param {String} uuid Neighborhood ID to remove from set of places to compare
         */
        function removeComparePlace(uuid) {
            if (!uuid) {
                return; // on page load, this watch fires will no value
            }

            var removeOffset = _.findIndex(ctl.comparePlaces, function(place) {
                return place && place.uuid === uuid;
            });

            if (removeOffset > -1) {
                // unset flag on Neighborhood marking selection for comparison
                ctl.comparePlaces[removeOffset].comparing = false;
                // remove Neighborhood from array of places selected for comparison
                ctl.comparePlaces[removeOffset] = null;
                ctl.comparePlacesCount--;
                updateComparisonsInUrl();
            } else {
                $log.warn('no place with UUID ' + uuid + ' found to remove from comparison');
            }
        }

        // helper to update URL after places added or removed for comparison, without reloading
        function updateComparisonsInUrl() {
            _.each(ctl.comparePlaces, function(place, index) {
                $stateParams['place' + (index + 1)] = place ? place.uuid : '';
            });
            $state.go('places.list', $stateParams, {notify: false});
        }

        function filterNeighborhoods() {
            getPlaces();
        }

        function getPlaces(params) {
            params = params || _.merge({}, $stateParams, defaultParams);
            params.ordering = ctl.sortBy.value;
            if (ctl.searchText) {
                params.search = ctl.searchText;
            }

            ctl.comparePlacesCount = 0;
            ctl.comparePlaces = new Array(3);

            // Read out pre-set places to compare from the URL. Keep this state in the URL
            // so user can navigate between places list and comparison without losing selections.
            var uuidsToCompare = [$stateParams.place1, $stateParams.place2, $stateParams.place3];

            AnalysisJob.query(params).$promise.then(function(data) {

                ctl.places = _.map(data.results, function(obj) {
                    var neighborhood = new Neighborhood(obj.neighborhood);
                    // get properties from the neighborhood's last run job
                    neighborhood.modifiedAt = obj.modifiedAt;
                    neighborhood.overall_score = obj.overall_score;

                    // add convenience flag to indicate if place selected for comparison
                    if (_.includes(uuidsToCompare, neighborhood.uuid)) {
                        addPlaceToCompare(neighborhood, false);
                    } else {
                        neighborhood.comparing = false;
                    }

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
