
(function() {

    /* @ngInject */
    function ThumbnailMapController(MapConfig) {
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
                MapConfig.baseLayers.Stamen.url, {
                    attribution: MapConfig.baseLayers.Stamen.attribution,
                    maxZoom: MapConfig.conusMaxZoom
                });
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;
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
