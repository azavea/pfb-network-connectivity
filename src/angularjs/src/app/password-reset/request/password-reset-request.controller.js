/**
 * @ngdoc controller
 * @name pfb.password-reset.controller:PasswordResetController
 *
 * @description
 * Controller for password reset request page
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function PasswordResetRequestController($log, PasswordResetService, toastr) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.requestReset = requestReset;
        }

        function requestReset() {
            PasswordResetService.requestPasswordReset(ctl.email);
            toastr.info('Password reset successfully requested');
        }
    }

    angular
        .module('pfb.passwordReset.request')
        .controller('PasswordResetRequestController', PasswordResetRequestController);
})();
