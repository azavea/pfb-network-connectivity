/**
 * @ngdoc controller
 * @name pfb.place.list.controller:PlaceListController
 *
 * @description
 * Controller for listing analysis jobs
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function PlaceListController($state, $stateParams, $scope, Pagination, AuthService,
                                 Neighborhood) {
        var ctl = this;

        var defaultParams = {
            limit: null,
            offset: null
        };
        var nextParams = {};
        var prevParams = {};

        initialize();

        function initialize() {
            ctl.isAdminUser = AuthService.isAdminUser();

            ctl.hasNext = false;
            ctl.getNext = getNext;

            ctl.hasPrev = false;
            ctl.getPrev = getPrev;
            ctl.places = [];

            ctl.filters = {};

            getPlaces();
        }

        function getPlaces(params) {
            params = params || $stateParams;
            Neighborhood.query(params).$promise.then(function(data) {
                ctl.places = _.map(data.results, function(obj) {
                    return new Neighborhood(obj);
                });

                if (data.next) {
                    ctl.hasNext = true;
                    nextParams = Pagination.getLinkParams(data.next);
                } else {
                    ctl.hasNext = false;
                    nextParams = {};
                }

                if (data.previous) {
                    ctl.hasPrev = true;
                    prevParams = Pagination.getLinkParams(data.previous);
                } else {
                    ctl.hasPrev = false;
                    prevParams = {};
                }

            });
        }

        function getNext() {
            var params = _.merge({}, defaultParams, nextParams);
            $state.go('places.list', params, {notify: false});
            getPlaces(params);
        }

        function getPrev() {
            var params = _.merge({}, defaultParams, prevParams);
            $state.go('places.list', params, {notify: false});
            getPlaces(params);
        }

    }

    angular
        .module('pfb.places.list')
        .controller('PlaceListController', PlaceListController);
})();
