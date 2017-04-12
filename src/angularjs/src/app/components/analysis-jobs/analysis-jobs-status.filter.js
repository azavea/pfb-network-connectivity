/**
 * @ngdoc filter
 * @name pfb.analysis-jobs.status:displayStatus
 *
 * @description
 * Transforms analysis job status into user friendly long description string
 */
(function () {
    'use strict';

    /* ngInject */
    function displayStatus($log, JOB_STATUSES) {

        return function (input) {
            if (input in JOB_STATUSES) {
                return JOB_STATUSES[input].long;
            }

            $log.warn(input + ' is not a recognized job status');
            return input;
        };
    }

    angular.module('pfb.components.analysis-jobs')
        .filter('displayStatus', displayStatus);
})();
