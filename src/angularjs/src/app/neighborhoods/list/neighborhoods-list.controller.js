/**
 * @ngdoc controller
 * @name pfb.neighborhood.list.controller:NeighborhoodListController
 *
 * @description
 * Controller for listing analysis jobs
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function NeighborhoodListController($state, $stateParams, $scope, Pagination, Neighborhood) {
        var ctl = this;

        var defaultParams = {
            limit: null,
            offset: null
        };
        var nextParams = {};
        var prevParams = {};

        initialize();

        function initialize() {
            ctl.hasNext = false;
            ctl.getNext = getNext;

            ctl.hasPrev = false;
            ctl.getPrev = getPrev;
            ctl.neighborhoods = [];

            ctl.deleteUpload = deleteUpload;
            ctl.filters = {};

            getNeighborhoods();
        }

        function getNeighborhoods(params) {
            params = params || $stateParams;
            Neighborhood.query(params).$promise.then(function(data) {
                ctl.neighborhoods = _.map(data.results, function(obj) {
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
            $state.go('neighborhood.list', params, {notify: false});
            getNeighborhoods(params);
        }

        function getPrev() {
            var params = _.merge({}, defaultParams, prevParams);
            $state.go('neighborhood.list', params, {notify: false});
            getNeighborhoods(params);
        }

        function deleteUpload (Neighborhood) {
            Neighborhood.$delete().then(function() {
                getNeighborhoods();
            });
        }

    }

    angular
        .module('pfb.neighborhoods.list')
        .controller('NeighborhoodListController', NeighborhoodListController);
})();
