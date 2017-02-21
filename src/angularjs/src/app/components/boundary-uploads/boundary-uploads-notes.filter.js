/**
 * @ngdoc filter
 * @name repository.boundary-uploads.status:displayStatus
 *
 * @description
 * Transforms boundary upload status into user friendly string
 */
(function () {
    'use strict';

    /* ngInject */
    function displayNotes() {

        return function (input) {
            var compiled = _.template('<% _.forEach(notes, function(note) { %><li><%- note %></li><% }); %>');
            var list = compiled({'notes': input});
            return '<ul>' + list + '</ul>';
        };
    }

    angular.module('repository.components.boundary-uploads')
        .filter('displayNotes', displayNotes);
})();
