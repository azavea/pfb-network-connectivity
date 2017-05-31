/**
 * @ngdoc service
 * @name pfb.components:ScoreMetadata
 *
 * @description
 * Resource for Analysis score metadata
 */
(function() {
    'use strict';

    /**
     Sort metrics in metadata by category, with total first in the category.
     Add subscoreClass property to metrics that should be indented under the total.
     */
    function orderCategories(response) {
        var metadata = [];

        // remove overall score and group into categories
        var groupedMetadata = _.chain(response).reject(function(m) {
            return m.name === 'overall_score';
        }).groupBy('category').value();

        // sort by category name (note population category is blank string and sorts to top)
        var categories = _.keys(groupedMetadata).sort();

        // Build metadata array, sorted by category.
        // Category total metric comes first within a category, if it exists.
        // If it does exist, the other metrics within its category have a special property added,
        // 'subscoreClass', which can be used to format sub-scores under the total.
        _.each(categories, function(category) {
            var metrics = groupedMetadata[category];
            var totalMetric = _.remove(metrics, function(metric) {
                return metric.label && metric.label.indexOf(' Total') > -1;
            });

            if (totalMetric && totalMetric.length) {
                totalMetric = totalMetric[0]; // remove returns an array
                metadata.push(totalMetric);
                _.each(metrics, function(metric) {
                    metric.subscoreClass = 'subscore';
                    metadata.push(metric);
                });
            } else {
                _.each(metrics, function(metric) {
                    metadata.push(metric);
                });
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
                return orderCategories(metadata);
            });
        }
    }

    angular.module('pfb.components')
        .factory('ScoreMetadata', ScoreMetadata);
})();
