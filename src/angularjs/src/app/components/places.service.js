/**
 * @ngdoc service
 * @name pfb.components.Places:Places
 *
 * @description
 * Wrapper to get and compose the parts needed for place views (neighborhood, job info, results)
 */
(function() {
    'use strict';

    /* @ngInject */
    function Places($q, $log, Neighborhood, AnalysisJob) {

        var module = {
            getPlace: getPlace
        };

        return module;

        function getPlace(uuid) {
            var dfd = $q.defer();
            if (!uuid) {
                dfd.resolve({});
                return dfd.promise;
            }

            var place = {};
            Neighborhood.query({uuid: uuid}).$promise.then(function(data) {
                place.neighborhood = new Neighborhood(data);
            });

            AnalysisJob.query({neighborhood: uuid, latest: 'True'}).$promise.then(function(data) {
                if (!data.results || !data.results.length) {
                    $log.warn('no matching analysis job found for neighborhood ' + uuid);
                    dfd.resolve({});
                    return dfd.promise;
                }

                var lastJob = new AnalysisJob(data.results[0]);
                place.lastJob = lastJob;

                AnalysisJob.results({uuid: lastJob.uuid}).$promise.then(function(results) {
                    if (!results.overall_scores) {
                        $log.warn('no job results found for neighborhood ' + lastJob.uuid);
                        dfd.resolve({});
                        return dfd.promise;
                    }

                    place.results = results;

                    // sort alphabetically by metric name so they will line up by row
                    place.scores = _(results.overall_scores).map(function(obj, key) {
                        return {
                            metric: key,
                            score: obj.score,
                            score_normalized: obj.score_normalized
                        };
                    }).sortBy(function(result) { return result.metric; }).value();

                    dfd.resolve(place);
                });
            });
            return dfd.promise;
        }
    }

    angular.module('pfb.components')
        .factory('Places', Places);
})();
