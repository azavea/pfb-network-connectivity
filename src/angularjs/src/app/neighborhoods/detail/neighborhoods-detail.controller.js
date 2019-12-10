/**
 * @ngdoc controller
 * @name pfb.neighborhoods.detail.controller:NeighborhoodDetailController
 *
 * @description
 * Controller for creating a neighborhood upload
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function NeighborhoodDetailController($log, $state, toastr, Upload, Neighborhood,
                                          Country) {
        var ctl = this;

        var DEFAULT_COUNTRY = {alpha_2: 'US', name: 'United States'};

        function initialize() {
            ctl.country = DEFAULT_COUNTRY;
            ctl.countries = Country.query();
            ctl.countries.$promise.then(function(response) {
                ctl.countries = response;
                // Use the countries response to fill in states
                if (ctl.country === DEFAULT_COUNTRY) {
                    ctl.country = _.find(ctl.countries,
                        function (c) { return c.alpha_2 === DEFAULT_COUNTRY.alpha_2; });
                }
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
                    // Only send state if it's supported (i.e. if the country has subdivisions)
                    state_abbrev: ctl.state && ctl.country.subdivisions ? ctl.state.code : '',
                    // Only send city FIPS if it's supported (i.e. only for US)
                    city_fips: ctl.city_fips && ctl.isDefaultCountry() ? ctl.city_fips : '',
                    country: ctl.country.alpha_2,
                    visibility: ctl.visibility,
                    label: ctl.label
                }
            }).then(function() {
                toastr.clear(uploadToast);
                toastr.success('Successfully created neighborhood');
                $state.go('admin.neighborhoods.list');
            }).catch(function(error) {
                $log.error(error);
                toastr.clear(uploadToast);
                var msg = 'Unable to create neighborhood:';
                if (error.data && error.data.non_field_errors) {
                    // extract non-field errors
                    for (var i in error.data.non_field_errors) {
                        msg += ' ' + error.data.non_field_errors[i];
                    }
                } else if (error.data) {
                    // extract field errors
                    for (var err in error.data) {
                        msg += ' ' + err + ': ' + error.data[err];
                    }
                    $log.error(msg);
                } else {
                    msg += ' ' + error;
                }
                toastr.error(msg);
                $log.error(msg);
            });
        };

        ctl.isDefaultCountry = function() {
            return ctl.country && ctl.country.alpha_2 === 'US';
        }
    }
    angular
        .module('pfb.neighborhoods.detail')
        .controller('NeighborhoodDetailController', NeighborhoodDetailController);
})();
