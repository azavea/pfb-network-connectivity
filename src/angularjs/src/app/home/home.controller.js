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
        ctl.scoreCards = [{
            title: 'People',
            description: 'Sometimes you want to meet at a friend’s house or visit your parents. It is important for bike networks to connect people to each other. Our People measure uses population data from the U.S. Census to determine how well you are connected by bike to the people around you.'
        }, {
            title: 'Opportunity',
            description: 'Jobs and education are critical to ensuring that everyone has opportunities to improve their situation. Our Opportunity measure uses job data from the U.S. Census along with locations of K-12 schools, vocational and technical colleges, and institutes of higher education to evaluate how easily you can access these opportunities by bike.'
        }, {
            title: 'Core Services',
            description: 'Core Services are destinations that serve critical needs such as food and health care. Our Core Services measure evaluates your access by bike to doctors, hospitals, and related medical services, along with groceries and social services.'
        }, {
            title: 'Shopping',
            description: 'Businesses rely on cities to connect people to them; people need to shop for goods and services. Our Shopping measure finds retail districts near you and scores your city based on how well it connects you to the retail destinations around you by bike.'
        }, {
            title: 'Recreation',
            description: 'Our Recreation measure describes how effectively your city connects people to places to get out and play. The score is based on your access to nearby parks and community centers by bike. In addition, we look for off-street bike paths and trails which offer opportunities for people of all experience levels to get out and feel the joy of riding a bike.'
        }, {
            title: 'Transit',
            description: 'Public transportation is an excellent way to include the bike on longer trips. Combining the bike and bus, subway, streetcar, light rail, or commuter rail is a win-win: you enjoy the benefits of active transportation while gaining access to a broader area of opportunities, goods, and services. Our Transit measure reflects how well your rail stations and major transit hubs connect to the people around them.'
        }];

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
