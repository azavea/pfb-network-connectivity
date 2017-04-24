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
    function CompareController($stateParams, Neighborhood, AnalysisJob, $log) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.places = [null, null, null];
            ctl.getPlace = getPlace;

            $log.debug('place one: ');
            $log.debug($stateParams.place1);
            $log.debug('place two: ');
            $log.debug($stateParams.place2);
            $log.debug('place three: ');
            $log.debug($stateParams.place3);

            getPlace(0, $stateParams.place1);
            getPlace(1, $stateParams.place2);
            getPlace(2, $stateParams.place3);
        }

        function getPlace(num, uuid) {
            if (!uuid) {
                return;
            }

            ctl.places[num] = {};

            Neighborhood.query({uuid: uuid}).$promise.then(function(data) {
                ctl.places[num].neighborhood = new Neighborhood(data);
            });

            AnalysisJob.query({neighborhood: uuid, latest: 'True'}).$promise.then(function(data) {
                if (!data.results || !data.results.length) {
                    $log.warn('no matching analysis job found for neighborhood ' + uuid);
                    ctl.places[num] = null;
                    return;
                }

                var lastJob = new AnalysisJob(data.results[0]);
                ctl.places[num].lastJob = lastJob;

                if (lastJob) {
                    AnalysisJob.results({uuid: lastJob.uuid}).$promise.then(function(results) {
                        if (!results.overall_scores) {
                            $log.warn('no job results found for neighborhood ' + lastJob.uuid);
                            return;
                        }

                        ctl.places[num].jobResults = _.map(results.overall_scores, function(obj, key) {
                            return {
                                metric: key.replace(/_/g, ' '),
                                score: obj.score_normalized
                            };
                        });
                    });
                }
            });
        }
    }

    angular
        .module('pfb.compare')
        .controller('CompareController', CompareController);
})();
