/**
 * @ngdoc controller
 * @name pfb.home.home.controller:HomeController
 *
 * @description
 * Controller handling interactions on index page
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function HomeController(AnalysisJob, Neighborhood) {
        var ctl = this;

        var cityParams = {
            limit: 8,
            offset: null,
            latest: 'True',
            status: 'COMPLETE',
            ordering: '-overall_score'
        };

        ctl.cities = null;

        initialize();

        function initialize() {
            AnalysisJob.query(cityParams).$promise.then(function(data) {

                ctl.cities = _.map(data.results, function(obj) {
                    var neighborhood = new Neighborhood(obj.neighborhood);
                    // get properties from the neighborhood's last run job
                    neighborhood.modifiedAt = obj.modifiedAt;
                    neighborhood.overall_score = obj.overall_score;
                    return neighborhood;
                });
            });
        }
    }

    angular
        .module('pfb.home')
        .controller('HomeController', HomeController);

})();
