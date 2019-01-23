(function() {
    'use strict';

    /**
     * @ngdoc service
     * @name pfb.analysis-jobs.AnalysisJob:AnalysisJob
     *
     * @description
     * Resource for analysis jobs
     */
    /* @ngInject */
    function AnalysisJob($resource) {

        return $resource('/api/analysis_jobs/:uuid/', {uuid: '@uuid'}, {
            'query': {
                method: 'GET',
                isArray: false
            },
            'results': {
                method: 'GET',
                isArray: false,
                url: '/api/analysis_jobs/:uuid/results/'
            },
            'cancel': {
                method: 'POST',
                isArray: false,
                url: '/api/analysis_jobs/:uuid/cancel/'
            }
        });
    }

    /**
     * @ngdoc service
     * @name pfb.analysis-jobs.AnalysisJobStatuses:AnalysisJobStatuses
     *
     * @description
     * Resource for analysis job statuses
     */
    function AnalysisJobStatuses(JOB_STATUSES) {
        var statuses = [];  // labels
        var filterMap = {}; // label -> key
        angular.forEach(JOB_STATUSES, function(labels, key) {
            statuses.push(labels.long);
            filterMap[labels.long] = key;
        });

        var module = {
            statuses: statuses,
            filterMap: filterMap
        };
        return module;
    }

    /**
     * @ngdoc service
     * @name pfb.analysis-jobs.AnalysisJob:AnalysisJobImport
     *
     * @description
     * Resource for import tasks for analysis jobs
     */
    /* @ngInject */
    function AnalysisJobImport($resource) {

        return $resource('/api/local_upload_tasks/', {uuid: '@uuid'}, {
            'query': {
                method: 'GET',
                isArray: false
            }
        });
    }

    angular.module('pfb.components.analysis-jobs')
        .factory('AnalysisJob', AnalysisJob)
        .factory('AnalysisJobStatuses', AnalysisJobStatuses)
        .factory('AnalysisJobImport', AnalysisJobImport);
})();
