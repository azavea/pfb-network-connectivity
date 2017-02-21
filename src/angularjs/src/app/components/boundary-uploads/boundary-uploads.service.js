(function() {
    'use strict';

    /**
     * @ngdoc service
     * @name repository.boundary-uploads.BoundaryUpload:BoundaryUpload
     *
     * @description
     * Resource for boundary uploads
     */
    /* @ngInject */
    function BoundaryUpload($resource) {

        return $resource('/api/boundary-results/:uuid/', {uuid: '@uuid'}, {
            'query': {
                method: 'GET',
                isArray: false
            }
        });
    }

    /**
     * @ngdoc service
     * @name repository.boundary-uploads.BoundaryUploadStatuses:BoundaryUploadStatuses
     *
     * @description
     * Resource for boundary upload statuses
     */
    function BoundaryUploadStatuses() {
        var statuses = [
            'In Progress', 'Uploaded', 'Verified', 'Error'
        ];
        var filterMap = {
            'In Progress': 'IN_PROGRESS',
            'Uploaded': 'UPLOADED',
            'Verified': 'VERIFIED',
            'Error': 'ERROR'
        };
        var module = {
            statuses: statuses,
            filterMap: filterMap
        };
        return module;
    }

    angular.module('repository.components.boundary-uploads')
        .factory('BoundaryUpload', BoundaryUpload)
        .factory('BoundaryUploadStatuses', BoundaryUploadStatuses);
})();
