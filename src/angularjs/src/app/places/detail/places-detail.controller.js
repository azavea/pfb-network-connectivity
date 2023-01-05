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
    function PlaceDetailController($stateParams,
                                   $log,
                                   $q,
                                   Places,
                                   ScoreMetadata) {
        var ctl = this;

        var downloadOptions = [
            {value: 'ways_url', label: 'Neighborhood Ways (shp)'},
            {value: 'census_blocks_url', label: 'Census Blocks (shp)'},
            {value: 'connected_census_blocks_url', label: 'Connected Census Blocks (csv)'},
            {value: 'overall_scores_url', label: 'Overall Scores (csv)'}
        ];

        initialize();

        function initialize() {
            clearPlace();  // serves to initialize to empty values

            getPlace($stateParams.uuid);
        }

        function getPlace(uuid) {
            ctl.mapLayers = {};
            $q.all([
                Places.getPlace(uuid),
                ScoreMetadata.query()
            ]).then(function (results) {
                var place = results[0];
                ctl.metadata = results[1];
                ctl.place = place.neighborhood;
                if (place.lastJob) {
                    ctl.lastJobScore = place.lastJob.overall_score;
                    ctl.mapLayers = {
                        dataLayers: [{
                            name: 'Fatal Crashes (2016 - 2020)',
                            url: '/api/crashes/?uuid=' + place.lastJob.uuid
                        }],
                        tileLayers: place.results.tile_urls,
                        featureLayers: place.results.destinations_urls
                    };
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
            }).catch(function () {
                $log.warn("could not load place", uuid);
                clearPlace();
            });
        }

        function clearPlace() {
            ctl.place = null;
            ctl.lastJobScore = null;
            ctl.scores = null;
            ctl.mapLayers = {};
            ctl.downloads = null;
        }
    }

    angular
        .module('pfb.places.detail')
        .controller('PlaceDetailController', PlaceDetailController);
})();
