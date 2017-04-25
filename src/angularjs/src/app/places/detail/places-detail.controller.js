/**
 * @ngdoc controller
 * @name pfb.analysis-jobs.detail.controller:PlaceDetailController
 *
 * @description
 * Controller for showing details about an analysis job
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function PlaceDetailController($stateParams, Neighborhood, AnalysisJob, $log) {
        var ctl = this;

        var downloadOptions = [
            {value: 'ways_url', label: 'Neighborhood Ways (shp)'},
            {value: 'census_blocks_url', label: 'Census Blocks (shp)'},
            {value: 'connected_census_blocks_url', label: 'Connected Census Blocks (csv)'},
            {value: 'overall_scores_url', label: 'Overall Scores (csv)'}
        ];

        initialize();

        function initialize() {
            ctl.place = null;
            ctl.lastJobScore = null;
            ctl.jobResults = null;
            ctl.mapLayers = {};
            ctl.getPlace = getPlace;

            ctl.downloads = null;

            getPlace($stateParams.uuid);
        }

        function getPlace(uuid) {
            Neighborhood.query({uuid: uuid}).$promise.then(function(data) {
                ctl.place = new Neighborhood(data);
            });

            AnalysisJob.query({neighborhood: uuid, latest: 'True'}).$promise.then(function(data) {

                ctl.mapLayers = {};
                if (!data.results || !data.results.length) {
                    $log.warn('no matching analysis job found for neighborhood ' + uuid);
                    ctl.lastJobScore = null;
                    ctl.downloads = null;
                    return;
                }

                var lastJob = new AnalysisJob(data.results[0]);
                ctl.lastJobScore = lastJob.overall_score;

                if (lastJob) {
                    AnalysisJob.results({uuid: lastJob.uuid}).$promise.then(function(results) {
                        $log.debug(results);
                        ctl.mapLayers = results.destinations_urls;
                        $log.debug(ctl.mapLayers);
                        if (results.overall_scores) {
                            ctl.jobResults = _.map(results.overall_scores, function(obj, key) {
                                return {
                                    metric: key.replace(/_/g, ' '),
                                    score: obj.score_normalized
                                };
                            });

                            ctl.downloads = _.map(downloadOptions, function(option) {
                                return {label: option.label, url: results[option.value]};
                            });
                        } else {
                            $log.warn('no job results found');
                            ctl.jobResults = null;
                            ctl.downloads = null;
                        }
                    });
                }
            });
        }
    }

    angular
        .module('pfb.places.detail')
        .controller('PlaceDetailController', PlaceDetailController);
})();
