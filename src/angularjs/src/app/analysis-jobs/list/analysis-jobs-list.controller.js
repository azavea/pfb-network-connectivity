/**
 * @ngdoc controller
 * @name pfb.analysis-jobs.list.controller:AnalysisJobListController
 *
 * @description
 * Controller for listing analysis jobs
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function AnalysisJobListController($state, $stateParams, $scope, Pagination, AuthService,
                                       AnalysisJob) {
        var ctl = this;

        var defaultParams = {
            limit: null,
            offset: null
        };
        var nextParams = {};
        var prevParams = {};

        initialize();

        function initialize() {
            ctl.isAdminUser = AuthService.isAdminUser();

            ctl.hasNext = false;
            ctl.getNext = getNext;

            ctl.hasPrev = false;
            ctl.getPrev = getPrev;
            ctl.analysisJobs = [];

            ctl.deleteUpload = deleteUpload;
            ctl.filters = {};

            $scope.$watch(function(){return ctl.filters;}, filterJobs);
            getAnalysisJobs();
        }

        function filterJobs(filters) {
            var params = _.merge({}, defaultParams);

            if (filters.neighborhood) {
                params.search = filters.neighborhood;
            }
            if (filters.status) {
                params.status = filters.status;
            }
            if (filters.batch) {
                params.batch = filters.batch;
            }
            if (filters.state_abbrev) {
                params.neighborhood__state_abbrev = filters.state_abbrev
            }
            if (filters.city_fips) {
                params.neighborhood__city_fips = filters.city_fips
            }
            getAnalysisJobs(params);
        }

        function getAnalysisJobs(params) {
            params = params || $stateParams;
            AnalysisJob.query(params).$promise.then(function(data) {
                ctl.analysisJobs = _.map(data.results, function(obj) {
                    return new AnalysisJob(obj);
                });

                if (data.next) {
                    ctl.hasNext = true;
                    nextParams = Pagination.getLinkParams(data.next);
                } else {
                    ctl.hasNext = false;
                    nextParams = {};
                }

                if (data.previous) {
                    ctl.hasPrev = true;
                    prevParams = Pagination.getLinkParams(data.previous);
                } else {
                    ctl.hasPrev = false;
                    prevParams = {};
                }

            });
        }

        function getNext() {
            var params = _.merge({}, defaultParams, nextParams);
            $state.go('admin.analysis-jobs.list', params, {notify: false});
            getAnalysisJobs(params);
        }

        function getPrev() {
            var params = _.merge({}, defaultParams, prevParams);
            $state.go('admin.analysis-jobs.list', params, {notify: false});
            getAnalysisJobs(params);
        }

        function deleteUpload (AnalysisJob) {
            AnalysisJob.$delete().then(function() {
                getAnalysisJobs();
            });
        }

    }

    angular
        .module('pfb.analysisJobs.list')
        .controller('AnalysisJobListController', AnalysisJobListController);
})();
