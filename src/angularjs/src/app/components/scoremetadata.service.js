/**
 * @ngdoc service
 * @name pfb.components:ScoreMetadata
 *
 * @description
 * Resource for Analysis score metadata
 */
(function() {
    'use strict';

    // Add subscoreClass property to metrics that should be indented under the total.
    function labelSubcategories(response) {

        // remove overall score and group into categories
        var metadata = _.reject(response, function(m) {
            return m.name === 'overall_score';
        });

        // Rely on API ordering to have all metrics grouped by category, with the total
        // for the category, if it exists, listed first.
        // Set here 'subscoreClass' as a property on the other metrics,
        // which can be used to format sub-scores under the total.
        var lastCategory = null;
        var haveTotal = false;
        _.each(metadata, function(metric) {
            if (lastCategory !== metric.category) {
                lastCategory = metric.category;
                haveTotal = metric.label && metric.label.indexOf(' Total') > -1;
                metric.subscoreClass = null;
            } else {
                metric.subscoreClass = haveTotal ? 'subscore': null;
            }
        });
        return metadata;
    }

    /* @ngInject */
    function ScoreMetadata($http) {
        return {
            query: query
        };

        function query() {
            return $http.get('/api/score_metadata/', {cache: true}).then(function (response) {
                var metadata = response.data || [];
                return labelSubcategories(metadata);
            });
        }
    }

    angular.module('pfb.components')
        .factory('ScoreMetadata', ScoreMetadata);
})();
