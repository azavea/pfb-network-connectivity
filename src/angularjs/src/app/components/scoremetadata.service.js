/**
 * @ngdoc service
 * @name pfb.components:ScoreMetadata
 *
 * @description
 * Resource for Analysis score metadata
 */
(function() {
    'use strict';

    /* @ngInject */
    function ScoreMetadata($resource) {
        return $resource('/api/score_metadata/', {}, {});
    }

    angular.module('pfb.components')
        .factory('ScoreMetadata', ScoreMetadata);
})();
