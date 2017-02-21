/**
 * @ngdoc controller
 * @name repository.password-reset.controller:PasswordResetController
 *
 * @description
 * Controller for password reset page
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function PasswordResetController($stateParams, $state, toastr, PasswordResetService) {
        var ctl = this;

        initialize();

        function initialize() {
            ctl.resetPassword = resetPassword;
            ctl.formSubmitted = false;
        }

        function resetPassword() {
            var reset = PasswordResetService.resetPassword(ctl.password, $stateParams.token);
            ctl.formSubmitted = true;
            reset.then(function() {
                toastr.info('Password reset succesfully, return to login to use new password');
            }).catch(function() {
                // TODO: Return more meaningful error messages based on response
                toastr.error('Unable to reset password with provided token and password.');
                $state.go('request-password-reset');
            });
        }
    }

    angular
        .module('repository.passwordReset')
        .controller('PasswordResetController', PasswordResetController);
})();
