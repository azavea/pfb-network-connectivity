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
    function AnalysisJobCreateController($state, $filter, toastr, AnalysisJob, Neighborhood,
                                         parseErrorFilter) {
        var ctl = this;

        function initialize() {
            ctl.neighborhoods = Neighborhood.all({ordering: 'label'}).$promise.then(function(data) {
                ctl.neighborhoods = data.results;
            });
        }

        initialize();

        ctl.create = function() {
            var submitToast = toastr.info('Submitting analysis job. Please wait...',
                                          {autoDismiss: false});

            var job = new AnalysisJob({
                max_trip_distance: ctl.maxTripDistance === null ? undefined : ctl.maxTripDistance,
                neighborhood: ctl.neighborhood.uuid,
                osm_extract_url: ctl.osmUrl,
                population_url: ctl.populationUrl,
                jobs_url: ctl.jobsUrl,
                skip_import_jobs: ctl.skipImportJobs
            });
            job.$save().then(function() {
                toastr.clear(submitToast);
                toastr.success('Successfully submitted analysis job');
                $state.go('admin.analysis-jobs.list');
            }).catch(function(error) {
                toastr.clear(submitToast);
                var errorDetails = parseErrorFilter(error);
                toastr.error('Error submitting analysis job' +
                             (errorDetails ? ': <br/>' + errorDetails : ''));
            });
        };
    }
    angular
        .module('pfb.analysisJobs.create')
        .controller('AnalysisJobCreateController', AnalysisJobCreateController);
})();
