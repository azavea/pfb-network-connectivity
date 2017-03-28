/**
 * @ngdoc controller
 * @name pfb.analysis-jobs.detail.controller:AnalysisJobDetailController
 *
 * @description
 * Controller for showing details about an analysis job
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function AnalysisJobDetailController($stateParams, AnalysisJob) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.job = null;
            ctl.cancel = cancel;
            ctl.getAnalysisJob = getAnalysisJob;

            getAnalysisJob($stateParams.uuid);
        }

        function cancel(jobId) {
            AnalysisJob.cancel({uuid: jobId}).$promise.then(function() {
                getAnalysisJob(jobId);
            });
        }

        function getAnalysisJob(jobId) {
            AnalysisJob.get({uuid: jobId}).$promise.then(function(data) {
                ctl.job = data;
            });
            AnalysisJob.results({uuid: jobId}).$promise.then(function(data) {
                ctl.results = data;
            });
        }
    }

    angular
        .module('pfb.analysisJobs.detail')
        .controller('AnalysisJobDetailController', AnalysisJobDetailController);
})();
