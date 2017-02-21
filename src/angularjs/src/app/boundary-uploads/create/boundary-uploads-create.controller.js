/**
 * @ngdoc controller
 * @name pfb.boundary-uploads.create.controller:BoundaryUploadCreateController
 *
 * @description
 * Controller for creating a boundary upload
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function BoundaryUploadCreateController($log, $state, $filter, toastr, Upload, Area, BoundaryUpload) {
        var ctl = this;

        function initialize() {
            ctl.areas = Area.query();
            ctl.areas.$promise.then(function(result) {
                ctl.area = result[0];
            });
        }

        initialize();

        function uploadFile(putUrl) {

            return Upload.http({
                method: 'PUT',
                headers: {'Content-Type': ctl.file.type },
                url: putUrl,
                data: ctl.file
            });
        }

        ctl.create = function() {
            var uploadToast = toastr.info('Uploading file to pfb. Please wait...',
                                          {autoDismiss: false});
            var upload = BoundaryUpload.save({area: ctl.area.fipsCode})
                .$promise.then(
                    function (result) {
                        return uploadFile(result.url);
                    });
            upload.then(function() {
                toastr.clear(uploadToast);
                toastr.success('Successfully uploaded file for processing');
                $state.go('boundary-uploads.list');
            }).catch(function(error) {
                toastr.clear(uploadToast);
                toastr.error('Unable to upload file: ' + error);
            });
        };
    }
    angular
        .module('pfb.boundaryUploads.create')
        .controller('BoundaryUploadCreateController', BoundaryUploadCreateController);
})();
