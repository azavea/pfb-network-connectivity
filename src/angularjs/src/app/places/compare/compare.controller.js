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
    function CompareController($stateParams, Neighborhood, AnalysisJob, $log, $q, $state) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.places = new Array(3);
            ctl.getPlace = getPlace;
            ctl.clearSelection = clearSelection;

            getPlaces([$stateParams.place1, $stateParams.place2, $stateParams.place3]);
        }

        function getPlaces(uuids) {
            var promises = _.map(uuids, function(uuid, offset) {
                return getPlace(offset, uuid);
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

        function getPlace(num, uuid) {
            var dfd = $q.defer();
            if (!uuid) {
                dfd.resolve({});
                return dfd.promise;
            }

            var place = {};
            Neighborhood.query({uuid: uuid}).$promise.then(function(data) {
                place.neighborhood = new Neighborhood(data);
            });

            AnalysisJob.query({neighborhood: uuid, latest: 'True'}).$promise.then(function(data) {
                if (!data.results || !data.results.length) {
                    $log.warn('no matching analysis job found for neighborhood ' + uuid);
                    dfd.resolve({});
                    return dfd.promise;
                }

                var lastJob = new AnalysisJob(data.results[0]);
                place.lastJob = lastJob;

                AnalysisJob.results({uuid: lastJob.uuid}).$promise.then(function(results) {
                    if (!results.overall_scores) {
                        $log.warn('no job results found for neighborhood ' + lastJob.uuid);
                        dfd.resolve({});
                        return dfd.promise;
                    }

                    // sort alphabetically by metric name so they will line up by row
                    place.jobResults = _(results.overall_scores).map(function(obj, key) {
                        return {
                            metric: key.replace(/_/g, ' '),
                            score: obj.score_normalized
                        };
                    }).sortBy(function(result) { return result.metric; }).value();

                    dfd.resolve(place);
                });
            });
            return dfd.promise;
        }

        function clearSelection(num) {
            var newParams = _.extend({}, $stateParams);
            newParams['place' + (num + 1)] = '';
            $state.go('places.compare', newParams);
        }
    }

    angular
        .module('pfb.places.compare')
        .controller('CompareController', CompareController);
})();
