/**
 * @ngdoc controller
 * @name pfb.boundary-uploads.list.controller:BoundaryUploadListController
 *
 * @description
 * Controller for listing boundary uploads
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function BoundaryUploadListController($state, $stateParams, $scope, Pagination, BoundaryUpload) {
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
            ctl.boundaryUploads = [];

            ctl.deleteUpload = deleteUpload;
            ctl.filters = {};

            $scope.$watch(function(){return ctl.filters;}, filterUploads);
            getUploads();
        }

        function filterUploads(filters) {
            var params = {};
            if (filters.neighborhood) {
                params.neighborhood = filters.neighborhood;
            }
            if (filters.status) {
                params.status = filters.status;
            }
            getUploads(params);
        }

        function getUploads(params) {
            params = params || $stateParams;
            BoundaryUpload.query(params).$promise.then(function(data) {
                ctl.boundaryUploads = _.map(data.results, function(obj) {
                    return new BoundaryUpload(obj);
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
            $state.go('boundary-uploads.list', params, {notify: false});
            getUploads(params);
        }

        function getPrev() {
            var params = _.merge({}, defaultParams, prevParams);
            $state.go('boundary-uploads.list', params, {notify: false});
            getUploads(params);
        }

        function deleteUpload (boundaryUpload) {
            boundaryUpload.$delete().then(function() {
                getUploads();
            });
        }

    }

    angular
        .module('pfb.boundaryUploads.list')
        .controller('BoundaryUploadListController', BoundaryUploadListController);
})();
