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
    function PlaceDetailController($stateParams, Neighborhood, AnalysisJob, Places) {
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
            ctl.scores = null;
            ctl.mapLayers = {};

            ctl.downloads = null;

            getPlace($stateParams.uuid);
        }

        function getPlace(uuid) {
            ctl.mapLayers = {};
            Places.getPlace(uuid).then(function (place) {
                ctl.place = place.neighborhood;
                if (place.lastJob) {
                    ctl.lastJobScore = place.lastJob.overall_score;
                    ctl.mapLayers = place.results.destinations_urls;
                    ctl.scores = place.scores;
                    ctl.downloads = _.map(downloadOptions, function(option) {
                        return {label: option.label, url: place.results[option.value]};
                    });
                } else {
                    ctl.lastJobScore = null;
                    ctl.mapLayers = null;
                    ctl.scores = null;
                    ctl.downloads = null;
                }
            });
        }
    }

    angular
        .module('pfb.places.detail')
        .controller('PlaceDetailController', PlaceDetailController);
})();
