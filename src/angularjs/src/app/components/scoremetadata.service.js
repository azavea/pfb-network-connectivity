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
    function ScoreMetadata($http) {
        return {
            query: query
        };

        function query() {
            return $http.get('/api/score_metadata/', {cache: true}).then(function (response) {
                var metadata = response.data || [];
                return _.filter(metadata, function (m) { return m.name !== "overall_score" });
            });
        }
    }

    angular.module('pfb.components')
        .factory('ScoreMetadata', ScoreMetadata);
})();
