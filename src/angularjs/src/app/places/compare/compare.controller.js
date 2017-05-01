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
    function CompareController($stateParams, Neighborhood, AnalysisJob, Places, $log, $q, $state) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.places = new Array(3);
            ctl.clearSelection = clearSelection;
            ctl.goToPlacesList = goToPlacesList;

            getPlaces([$stateParams.place1, $stateParams.place2, $stateParams.place3]);
        }

        function getPlaces(uuids) {
            var promises = _.map(uuids, function(uuid) {
                return Places.getPlace(uuid);
            });

            // do not display any place until all places have been retrieved
            $q.all(promises).then(function(results) {
                ctl.places = results;
            }, function(error) {
                $log.error('Failed to retrieve places to compare:');
                $log.error(error);
                ctl.places = new Array(3);
            });
        }

        function clearSelection(num) {
            var newParams = _.extend({}, $stateParams);
            newParams['place' + (num + 1)] = '';
            $state.go('places.compare', newParams);
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
