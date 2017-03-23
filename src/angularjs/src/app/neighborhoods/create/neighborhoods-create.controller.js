/**
 * @ngdoc controller
 * @name pfb.neighborhoods.create.controller:NeighborhoodCreateController
 *
 * @description
 * Controller for creating a neighborhood upload
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function NeighborhoodCreateController($state, $filter, toastr, Upload, Neighborhood, State) {
        var ctl = this;

        function initialize() {
            ctl.states = State.query();
            ctl.states.$promise.then(function(response) {
                ctl.states = response;
            });
        }

        initialize();

        ctl.create = function() {
            var uploadToast = toastr.info('Creating neighborhood. Please wait...',
                                          {autoDismiss: false});

            Upload.upload({
                url: '/api/neighborhoods/',
                method: 'POST',
                data: {
                    boundary_file: ctl.file,
                    state_abbrev: ctl.state.abbr,
                    label: ctl.label
                }
            }).then(function() {
                toastr.clear(uploadToast);
                toastr.success('Successfully created neighborhood');
                $state.go('neighborhoods.list');
            }).catch(function(error) {
                toastr.clear(uploadToast);
                toastr.error('Unable to create neighborhood: ' + error);
            });
        };
    }
    angular
        .module('pfb.neighborhoods.create')
        .controller('NeighborhoodCreateController', NeighborhoodCreateController);
})();
