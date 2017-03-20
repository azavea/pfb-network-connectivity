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
    function AnalysisJobStatuses() {
        var statuses = [
            'Created', 'Importing', 'Building', 'Connectivity', 'Metrics', 'Exporting',
            'Complete', 'Error'
        ];
        var filterMap = {
            'Created': 'CREATED',
            'Importing': 'IMPORTING',
            'Building': 'BUILDING',
            'Connectivity': 'CONNECTIVITY',
            'Metrics': 'METRICS',
            'Exporting': 'EXPORTING',
            'Complete': 'COMPLETE',
            'Error': 'ERROR'
        };
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
