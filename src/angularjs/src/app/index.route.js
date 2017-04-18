(function() {
    'use strict';

    angular
        .module('pfb')
        .config(routerConfig);

    /** @ngInject */
    function routerConfig($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('home', {
                url: '/',
                templateUrl: 'app/home/home.html'
            })
            .state('places', {
                url: '/places/',
                templateUrl: 'app/places/places.html'
            })
            .state('login', {
                url: '/login/',
                controller: 'LoginController',
                controllerAs: 'login',
                templateUrl: 'app/login/login.html'
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
            .state('admin', {
                abstract: true,
                url: '/admin/',
                template: '<ui-view/>'
            })
            .state('admin.help', {
                url: 'help/',
                controller: 'HelpController',
                controllerAs: 'help',
                templateUrl: 'app/help/help.html'
            })
            .state('admin.organizations', {
                abstract: true,
                url: 'organizations/',
                template: '<ui-view/>'
            })
            .state('admin.organizations.list', {
                url: '',
                controller: 'OrganizationListController',
                controllerAs: 'orgList',
                templateUrl: 'app/organizations/list/organizations-list.html'
            })
            .state('admin.organizations.create', {
                url: 'create/',
                controller: 'OrganizationDetailController',
                controllerAs: 'org',
                templateUrl: 'app/organizations/detail/organizations-detail.html'
            })
            .state('admin.organizations.edit', {
                url: 'edit/:uuid',
                controller: 'OrganizationDetailController',
                controllerAs: 'org',
                templateUrl: 'app/organizations/detail/organizations-detail.html'
            })
            .state('admin.users', {
                abstract: true,
                url: 'users/',
                template: '<ui-view/>'
            })
            .state('admin.users.list', {
                url: '',
                controller: 'UserListController',
                controllerAs: 'userList',
                templateUrl: 'app/users/list/users-list.html'
            })
            .state('admin.users.create', {
                url: 'create/',
                controller: 'UserDetailController',
                controllerAs: 'user',
                templateUrl: 'app/users/detail/users-detail.html'
            })
            .state('admin.users.edit', {
                url: 'edit/:uuid',
                controller: 'UserDetailController',
                controllerAs: 'user',
                templateUrl: 'app/users/detail/users-detail.html'
            })
            .state('admin.analysis-jobs', {
                abstract: true,
                url: 'analysis-jobs/?limit&offset',
                template: '<ui-view/>'
            })
            .state('admin.analysis-jobs.list', {
                url: '',
                controller: 'AnalysisJobListController',
                controllerAs: 'analysisJobList',
                templateUrl: 'app/analysis-jobs/list/analysis-jobs-list.html'
            })
            .state('admin.analysis-jobs.create', {
                url: 'create/',
                controller: 'AnalysisJobCreateController',
                controllerAs: 'analysisJobCreate',
                templateUrl: 'app/analysis-jobs/create/analysis-jobs-create.html'
            })
            .state('admin.analysis-jobs.detail', {
                url: ':uuid/',
                controller: 'AnalysisJobDetailController',
                controllerAs: 'analysisJobDetail',
                templateUrl: 'app/analysis-jobs/detail/analysis-jobs-detail.html'
            })
            .state('admin.neighborhoods', {
                abstract: true,
                url: 'neighborhoods/?limit&offset',
                template: '<ui-view/>'
            })
            .state('admin.neighborhoods.create', {
                url: 'create/',
                controller: 'NeighborhoodCreateController',
                controllerAs: 'neighborhoodCreate',
                templateUrl: 'app/neighborhoods/create/neighborhoods-create.html'
            })
            .state('admin.neighborhoods.list', {
                url: '',
                controller: 'NeighborhoodListController',
                controllerAs: 'neighborhoodList',
                templateUrl: 'app/neighborhoods/list/neighborhoods-list.html'
            });
        $urlRouterProvider.otherwise('/');
    }

})();
