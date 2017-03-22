(function() {
    'use strict';

    angular
        .module('pfb')
        .config(routerConfig);

    /** @ngInject */
    function routerConfig($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('login', {
                url: '/login/',
                controller: 'LoginController',
                controllerAs: 'login',
                templateUrl: 'app/login/login.html'
            })
            .state('help', {
                url: '/help/',
                controller: 'HelpController',
                controllerAs: 'help',
                templateUrl: 'app/help/help.html'
            })
            .state('request-password-reset', {
                url: '/password-reset-request/',
                controller: 'PasswordResetRequestController',
                controllerAs: 'pw',
                templateUrl: 'app/password-reset/request/password-reset-request.html'
            })
            .state('password-reset', {
                url: '/password-reset/?token',
                controller: 'PasswordResetController',
                controllerAs: 'pw',
                templateUrl: 'app/password-reset/reset/password-reset.html'
            })
            .state('organizations', {
                abstract: true,
                url: '/organizations/',
                template: '<ui-view/>'
            })
            .state('organizations.list', {
                url: '',
                controller: 'OrganizationListController',
                controllerAs: 'orgList',
                templateUrl: 'app/organizations/list/organizations-list.html'
            })
            .state('organizations.create', {
                url: 'create/',
                controller: 'OrganizationDetailController',
                controllerAs: 'org',
                templateUrl: 'app/organizations/detail/organizations-detail.html'
            })
            .state('organizations.edit', {
                url: 'edit/:uuid',
                controller: 'OrganizationDetailController',
                controllerAs: 'org',
                templateUrl: 'app/organizations/detail/organizations-detail.html'
            })
            .state('users', {
                abstract: true,
                url: '/users/',
                template: '<ui-view/>'
            })
            .state('users.list', {
                url: '',
                controller: 'UserListController',
                controllerAs: 'userList',
                templateUrl: 'app/users/list/users-list.html'
            })
            .state('users.create', {
                url: 'create/',
                controller: 'UserDetailController',
                controllerAs: 'user',
                templateUrl: 'app/users/detail/users-detail.html'
            })
            .state('users.edit', {
                url: 'edit/:uuid',
                controller: 'UserDetailController',
                controllerAs: 'user',
                templateUrl: 'app/users/detail/users-detail.html'
            })
            .state('analysis-jobs', {
                abstract: true,
                url: '/analysis-jobs/?limit&offset',
                template: '<ui-view/>'
            })
            .state('analysis-jobs.list', {
                url: '',
                controller: 'AnalysisJobListController',
                controllerAs: 'analysisJobList',
                templateUrl: 'app/analysis-jobs/list/analysis-jobs-list.html'
            })
            .state('neighborhoods', {
                abstract: true,
                url: '/neighborhoods/?limit&offset',
                template: '<ui-view/>'
            })
            .state('neighborhoods.create', {
                url: 'create/',
                controller: 'NeighborhoodCreateController',
                controllerAs: 'neighborhoodCreate',
                templateUrl: 'app/neighborhoods/create/neighborhoods-create.html'
            })
            .state('neighborhoods.list', {
                url: '',
                controller: 'NeighborhoodListController',
                controllerAs: 'neighborhoodList',
                templateUrl: 'app/neighborhoods/list/neighborhoods-list.html'
            });
        $urlRouterProvider.otherwise('/login/');
    }

})();
