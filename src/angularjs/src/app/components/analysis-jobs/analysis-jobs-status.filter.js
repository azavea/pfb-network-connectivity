/**
 * @ngdoc filter
 * @name pfb.analysis-jobs.status:displayStatus
 *
 * @description
 * Transforms analysis job status into user friendly string
 */
(function () {
    'use strict';

    /* ngInject */
    function displayStatus() {
        var statuses = {
            CREATED: 'Created',
            IMPORTING: 'Importing Data',
            BUILDING: 'Building Network Graph',
            CONNECTIVITY: 'Calculating Connectivity',
            METRICS: 'Calculating Graph Metrics',
            EXPORTING: 'Exporting Results',
            COMPLETE: 'Complete',
            ERROR: 'Error'
        };

        return function (input) {
            return statuses[input];
        };
    }

    angular.module('pfb.components.analysis-jobs')
        .filter('displayStatus', displayStatus);
})();
