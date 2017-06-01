/**
 * @ngdoc controller
 * @name pfb.analysis-jobs.detail.controller:CompareController
 *
 * @description
 * Controller for showing details about an analysis job
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function CompareController($stateParams, AnalysisJob, Neighborhood, Places, ScoreMetadata,
                               $log, $q, $state) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.places = new Array(3);
            ctl.metadata = {};
            ctl.clearSelection = clearSelection;
            ctl.goToPlacesList = goToPlacesList;

            getPlaces([$stateParams.place1, $stateParams.place2, $stateParams.place3]);
        }

        function getPlaces(uuids) {
            var promises = _.map(uuids, function(uuid) {
                return Places.getPlace(uuid);
            });

            // first request score metadata
            promises.unshift(ScoreMetadata.query());

            // do not display any place until all places have been retrieved
            $q.all(promises).then(function(results) {
                // first element in results is the metadata; rest are the places
                ctl.metadata = _.head(results);
                ctl.places = _.drop(results);
            }, function(error) {
                $log.error('Failed to retrieve places to compare:');
                $log.error(error);
                ctl.places = new Array(3);
            });
        }

        /**
         * Remove a place selected for comparison. Update URL and clear card without reloading.
         *
         * @param {Integer} num Offset to clear in list of three slots for places to compare
         */
        function clearSelection(num) {
            $stateParams['place' + (num + 1)] = '';
            ctl.places[num] = null;
            $state.go('places.compare', $stateParams, {notify: false});
        }

        // navigate to places list, preserving route parameters for selected places to compare
        function goToPlacesList() {
            $state.go('places.list', $stateParams);
        }
    }

    angular
        .module('pfb.places.compare')
        .controller('CompareController', CompareController);
})();
