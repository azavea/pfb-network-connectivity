/**
 * @ngdoc controller
 * @name pfb.home.home.controller:HomeController
 *
 * @description
 * Controller handling interactions on index page
 *
 */
(function() {
    'use strict';

    /** @ngInject */
    function HomeController($log) {
        var ctl = this;

        ctl.$onInit = function () {
            ctl.conusMapOptions = { scrollWheelZoom: false };
            ctl.conusBounds = [[24.396308, -124.848974], [49.384358, -66.885444]];
            ctl.baselayer = L.tileLayer(
                'https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png', {
                    attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
                    maxZoom: 18
                });
        };

        ctl.onConusMapReady = function (map) {
            $log.debug(map.getBounds());
        };
    }

    angular
        .module('pfb.home')
        .controller('HomeController', HomeController);

})();
