/**
 * @ngdoc filter
 * @name pfb.boundary-uploads.status:displayStatus
 *
 * @description
 * Transforms boundary upload status into user friendly string
 */
(function () {
    'use strict';

    /* ngInject */
    function displayStatus() {
        var statuses = {
            IN_PROGRESS: 'In Progress',
            UPLOADED: 'Uploaded',
            VERIFIED: 'Verified',
            ERROR: 'Error'
        };

        return function (input) {
            return statuses[input];
        };
    }

    angular.module('pfb.components.boundary-uploads')
        .filter('displayStatus', displayStatus);
})();
