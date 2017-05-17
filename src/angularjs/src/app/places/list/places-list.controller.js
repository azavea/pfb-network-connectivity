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
            {value: 'neighborhood__state_abbrev,neighborhood__label', label: 'Alphabetical by State'},
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
        var mapStyleKeys = {
            DEFAULT: 'default',
            COMPARE: 'compare'
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
            ctl.mapPlaces = {};

            ctl.comparePlaces = [];
            ctl.maxPlaceCompare = 3;
            ctl.addPlaceToCompare = addPlaceToCompare;
            ctl.removeComparePlace = removeComparePlace;
            ctl.filterNeighborhoods = filterNeighborhoods;
            ctl.goComparePlaces = goComparePlaces;
            ctl.isInPlaceCompare = isInPlaceCompare;
            ctl.isPlaceCompareFull = isPlaceCompareFull;

            ctl.sortBy = sortingOptions[0]; // default to alphabetical order
            ctl.sortingOptions = sortingOptions;

            ctl.getPlaces = getPlaces;

            getPlaces();
        }

        /**
         * Add a place to the list of up to three places to view on compare page.
         *
         * @param {Neighborhood} place Neighborhood to list of places to compare
         */
        function addPlaceToCompare(place) {
            if (isInPlaceCompare(place.uuid)) {
                $log.warn('aready have place selected to compare');
            } else if (isPlaceCompareFull()) {
                $log.warn('already have three places to compare');
            } else {
                ctl.comparePlaces.push(place);
                updateComparisonsInUrl();
                setMapPlaces(ctl.places);
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

            var removeOffset = getPlaceCompareIndex(uuid);
            if (removeOffset > -1) {
                // remove Neighborhood from array of places selected for comparison
                ctl.comparePlaces.splice(removeOffset, 1);
                updateComparisonsInUrl();
                setMapPlaces(ctl.places);
            } else {
                $log.warn('no place with UUID ' + uuid + ' found to remove from comparison');
            }
        }

        function getPlaceCompareIndex(uuid) {
            return _.findIndex(ctl.comparePlaces, function (p) {
                return p && p.uuid === uuid;
            });
        }

        function isInPlaceCompare(uuid) {
            return getPlaceCompareIndex(uuid) !== -1;
        }

        function isPlaceCompareFull() {
            return ctl.comparePlaces.length >= ctl.maxPlaceCompare;
        }

        // helper to update URL after places added or removed for comparison, without reloading
        function updateComparisonsInUrl() {
            for (var i = 0; i < ctl.maxPlaceCompare; i++) {
                var place = ctl.comparePlaces[i];
                $stateParams['place' + (i + 1)] = place ? place.uuid : '';
            }
            $state.go('places.list', $stateParams, {notify: false});
        }

        function filterNeighborhoods() {
            getPlaces();
        }

        function getPlaces(params) {
            params = params || _.merge({}, defaultParams);
            params.ordering = ctl.sortBy.value;
            if (ctl.searchText) {
                params.search = ctl.searchText;
            }

            // Read out pre-set places to compare from the URL. Keep this state in the URL
            // so user can navigate between places list and comparison without losing selections.
            var uuidsToCompare = [$stateParams.place1, $stateParams.place2, $stateParams.place3];

            AnalysisJob.query(params).$promise.then(function(data) {

                ctl.places = _.map(data.results, function(obj) {
                    var neighborhood = new Neighborhood(obj.neighborhood);
                    // get properties from the neighborhood's last run job
                    neighborhood.modifiedAt = obj.modifiedAt;
                    neighborhood.overall_score = obj.overall_score;

                    if (_.includes(uuidsToCompare, neighborhood.uuid)) {
                        addPlaceToCompare(neighborhood);
                    }

                    return neighborhood;
                });
                setMapPlaces(ctl.places);

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

        // Must set ctl.mapPlaces via this so that the object ref gets updated
        function setMapPlaces(places) {
            var mapPlaces = _.reduce(places, function (result, value) {
                result[value.uuid] = mapStyleKeys.DEFAULT;
                return result;
            }, {});
            _.forEach(ctl.comparePlaces, function (place) {
                if (place && place.uuid) {
                    mapPlaces[place.uuid] = mapStyleKeys.COMPARE;
                }
            });
            ctl.mapPlaces = mapPlaces;
        }
    }

    angular
        .module('pfb.places.list')
        .controller('PlaceListController', PlaceListController);
})();
