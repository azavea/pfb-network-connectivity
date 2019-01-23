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
    function NeighborhoodCreateController($log, $state, $filter, toastr, Upload, Neighborhood,
                                          Country, State) {
        var ctl = this;

        var DEFAULT_COUNTRY = {abbr: 'US', name: 'United States'};

        function initialize() {
            ctl.country = DEFAULT_COUNTRY;
            ctl.states = State.query();
            ctl.states.$promise.then(function(response) {
                ctl.states = response;
            });
            ctl.countries = Country.query();
            ctl.countries.$promise.then(function(response) {
                ctl.countries = response;
            });
            // TODO: De-dupe from API?
            ctl.visibilities = [
                ['public', 'Public'],
                ['private', 'Private']
            ]
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
                    state_abbrev: ctl.state && ctl.isDefaultCountry() ? ctl.state.abbr : '',
                    country: ctl.country.abbr || DEFAULT_COUNTRY,
                    visibility: ctl.visibility,
                    label: ctl.label
                }
            }).then(function() {
                toastr.clear(uploadToast);
                toastr.success('Successfully created neighborhood');
                $state.go('admin.neighborhoods.list');
            }).catch(function(error) {
                toastr.clear(uploadToast);
                $log.error(error);
                var msg = 'Unable to create neighborhood:';
                if (error.data && error.data.non_field_errors) {
                    $log.debug('found non_field_errors');
                    for (var i in error.data.non_field_errors) {
                        msg += ' ' + error.data.non_field_errors[i];
                    }
                } else {
                    msg += ' ' + error;
                }
                toastr.error(msg);
            });
        };

        ctl.isDefaultCountry = function() {
            return ctl.country && ctl.country.abbr === 'US';
        }
    }
    angular
        .module('pfb.neighborhoods.create')
        .controller('NeighborhoodCreateController', NeighborhoodCreateController);
})();
