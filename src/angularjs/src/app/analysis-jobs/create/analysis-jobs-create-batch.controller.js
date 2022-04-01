/**
 * @ngdoc controller
 * @name pfb.analysisJobs.create-batch.controller:AnalysisJobCreateBatchController
 *
 * @description
 * Controller for creating/running an analysis batch
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function AnalysisJobCreateBatchController($log, $state, $filter, toastr, Upload) {
        var ctl = this;

        function initialize() {}

        initialize();

        ctl.create = function() {
            var uploadToast = toastr.info('Submitting analysis batch. Please wait...',
                                          {autoDismiss: false});

            Upload.upload({
                url: '/api/analysis_batches/',
                method: 'POST',
                data: {
                    file: ctl.file,
                    max_trip_distance: ctl.maxTripDistance
                }
            }).then(function(data) {
                var jobs = data.length;
                toastr.clear(uploadToast);
                toastr.success('Successfully created AnalysisBatch with ' + jobs + ' jobs.');
                $state.go('admin.analysis-jobs.list');
            }).catch(function(error) {
                toastr.clear(uploadToast);
                $log.error(error);
                toastr.error('Unable to create new AnalysisBatch. Error printed to console.');
            });
        };
    }
    angular
        .module('pfb.analysisJobs.create')
        .controller('AnalysisJobCreateBatchController', AnalysisJobCreateBatchController);
})();
