(function() {
    'use strict';

    angular
        .module('repository')
        .config(config);

    /** @ngInject */
    function config($logProvider, $httpProvider, $resourceProvider, $compileProvider,
                    cfpLoadingBarProvider, toastrConfig) {
        // Enable log
        $logProvider.debugEnabled(true);

        // Do not strip trailing slashes
        $resourceProvider.defaults.stripTrailingSlashes = false;

        // Set options third-party lib
        toastrConfig.allowHtml = true;
        toastrConfig.timeOut = 1500;
        toastrConfig.positionClass = 'toast-top-right';
        toastrConfig.preventDuplicates = false;
        toastrConfig.progressBar = false;

        // set csrf token stuff
        $httpProvider.defaults.xsrfCookieName = 'csrftoken';
        $httpProvider.defaults.xsrfHeaderName = 'X-CSRFToken';

        // logout if 401 is returned, will return to login page
        $httpProvider.interceptors.push(function($q, $injector) {
            return {
                'responseError': function(response) {
                    if(response.status === 401) {
                        $injector.get('AuthService').logout();
                    }
                    return $q.reject(response);
                }
            };
        });

        // disable debug info for performance
        $compileProvider.debugInfoEnabled(false);

        // disable spinner
        cfpLoadingBarProvider.includeSpinner = false;
    }
})();
