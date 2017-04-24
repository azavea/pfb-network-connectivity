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
            ctl.place = null;
            ctl.lastJobScore = null;
            ctl.jobResults = null;
            ctl.getPlace = getPlace;

            ctl.downloads = null;

            $log.debug('place one: ');
            $log.debug($stateParams.place1);
            $log.debug('place two: ');
            $log.debug($stateParams.place2);
            $log.debug('place three: ');
            $log.debug($stateParams.place3);
        }

        function getPlace(uuid) {
            Neighborhood.query({uuid: uuid}).$promise.then(function(data) {
                ctl.place = new Neighborhood(data);
            });

            AnalysisJob.query({neighborhood: uuid, latest: 'True'}).$promise.then(function(data) {

                if (!data.results || !data.results.length) {
                    $log.warn('no matching analysis job found for neighborhood ' + uuid);
                    ctl.lastJobScore = null;
                    ctl.downloads = null;
                    return;
                }
            });
        }
    }

    angular
        .module('pfb.compare')
        .controller('CompareController', CompareController);
})();
