(function() {
  'use strict';

  angular
    .module('pfb')
    .run(runBlock);

  /** @ngInject */
  function runBlock($rootScope, $window) {
    // Ignore on-watch rule, since we're attaching to $rootScope
    /*eslint angular/on-watch: 0*/
    $rootScope.$on('$stateChangeSuccess', function ($event, toState) {
      var event = {
        'app_name': 'PFB BNA Score',
        'screen_name': toState.name,
        'environment': $window.location.hostname
      }
      gtag('event', 'screen_view', event);
    });
  }
})();
