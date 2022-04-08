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
    function Places($q, $http, $log, Neighborhood, AnalysisJob) {

        var module = {
            getPlace: getPlace
        };

        return module;

        function scoreKeyToDestinationsUrlName(key)  {
            return key
                // one-to-one mappings
                .replace("core_services_grocery","supermarkets")
                .replace("opportunity_k12_education","schools")
                .replace("opportunity_technical_vocational_college","colleges")
                .replace("opportunity_higher_education","universities")
                // prefixes to strip
                .replace("core_services_", "")
                .replace("recreation_","")
                .replace("opportunity_","");
        }

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
                    place.scores = results.overall_scores;

                    var destinations_promises = [];
                    _.each(results.overall_scores, function (scores, key) {
                        scores.score_normalized = key === "population_total"
                            ? scores.score_original
                            : Math.round(scores.score_normalized);          
                        if (scores.score_normalized === 0) {
                            var found_destinations_url = results.destinations_urls.find(function(destinations_url) {
                                return scoreKeyToDestinationsUrlName(key) === destinations_url.name;
                            });
                            if (found_destinations_url) {
                                var destinations_promise = $http.get(found_destinations_url.url).then(function(response) {
                                    if (response.data.features.length === 0) {
                                        scores.score_normalized = 'N/A' ;
                                    }
                                    return scores;
                                });
                                destinations_promises.push(destinations_promise)
                            }
                        }
                    });
                    place.scores.default_speed_limit = {
                        score_normalized: results.residential_speed_limit
                    };
                    $q.all(destinations_promises).then(function() {
                        dfd.resolve(place);
                    });
                });
            });
            return dfd.promise;
        }
    }

    angular.module('pfb.components')
        .factory('Places', Places);
})();
