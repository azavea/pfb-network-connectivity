/**
 * @ngdoc controller
 * @name pfb.analysisJobs.create.controller:AnalysisJobCreateController
 *
 * @description
 * Controller for creating/running an analysis job
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function AnalysisJobCreateController($state, $filter, toastr, AnalysisJob, Neighborhood) {
        var ctl = this;

        function initialize() {
            ctl.neighborhoods = Neighborhood.all();
            ctl.neighborhoods.$promise.then(function(data) {
                ctl.neighborhoods = data;
            });
        }

        initialize();

        ctl.create = function() {
            var submitToast = toastr.info('Submitting analysis job. Please wait...',
                                          {autoDismiss: false});

            var job = new AnalysisJob({
                neighborhood: ctl.neighborhood.uuid,
                osm_extract_url: ctl.osmUrl
            });
            job.$save().then(function() {
                toastr.clear(submitToast);
                toastr.success('Successfully submitted analysis job');
                $state.go('analysis-jobs.list');
            }).catch(function(error) {
                toastr.clear(submitToast);
                toastr.error('Error submitting analysis job: ' + error);
            });
        };
    }
    angular
        .module('pfb.analysisJobs.create')
        .controller('AnalysisJobCreateController', AnalysisJobCreateController);
})();
