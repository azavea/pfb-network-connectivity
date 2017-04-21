
(function() {

    /* @ngInject */
    function ThumbnailMapController($log) {
        var ctl = this;
        ctl.map = null;

        ctl.$onInit = function () {
            ctl.mapOptions = {
                scrollWheelZoom: false,
                interactive: false,
                zoomControl: false,
                attributionControl: false
            };

            // TODO: set center and zoom level by zooming to fit geojson polygon bounds
            ctl.mapCenter = [39.963277, -75.142971];
            ctl.baselayer = L.tileLayer(
                'https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png', {
                    attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
                    maxZoom: 18
                });
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;

            $log.debug('ready!');
        };
    }

    function ThumbnailMapDirective() {
        var module = {
            restrict: 'E',
            scope: true,
            controller: 'ThumbnailMapController',
            controllerAs: 'ctl',
            bindToController: true,
            templateUrl: 'app/components/thumbnail-map/thumbnail-map.html'
        };
        return module;
    }


    angular.module('pfb.components.thumbnailMap')
        .controller('ThumbnailMapController', ThumbnailMapController)
        .directive('pfbThumbnailMap', ThumbnailMapDirective);

})();
