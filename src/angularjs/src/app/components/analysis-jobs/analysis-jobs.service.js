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
        var statuses = [];  // short labels
        var filterMap = {}; // short label -> key
        angular.forEach(JOB_STATUSES, function(labels, key) {
            statuses.push(labels.short);
            filterMap[labels.short] = key;
        });

        var module = {
            statuses: statuses,
            filterMap: filterMap
        };
        return module;
    }

    angular.module('pfb.components.analysis-jobs')
        .factory('AnalysisJob', AnalysisJob)
        .factory('AnalysisJobStatuses', AnalysisJobStatuses);
})();
