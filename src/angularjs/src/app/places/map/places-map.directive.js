(function() {

    /* @ngInject */
    function PlacesMapController($log, $scope) {
        var ctl = this;
        ctl.map = null;

        ctl.$onInit = function () {
            ctl.mapOptions = {
                scrollWheelZoom: true
            };

            // TODO: set center and zoom level by zooming to fit geojson polygon bounds
            ctl.mapCenter = [39.963277, -75.142971];
            ctl.baselayer = L.tileLayer(
                'https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png', {
                    attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
                    maxZoom: 18
                });

            $scope.$watch(function(){return ctl.pfbPlacesMapLayers;}, setLayers);
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;

            $log.debug('ready!');
            $log.debug(ctl.pfbPlacesMapLayers);

            if (ctl.pfbPlacesMapLayers) {
                setLayers(ctl.pfbPlacesMapLayers);
            }
        };

        function setLayers(layers) {
            $log.debug('setLayers');
            $log.debug(layers);
            //$log.debug(ctl.pfbPlacesMapLayers);
        }
    }

    function PlacesMapDirective() {
        var module = {
            restrict: 'E',
            scope: {
                pfbPlacesMapLayers: '='
            },
            controller: 'PlacesMapController',
            controllerAs: 'ctl',
            bindToController: true,
            templateUrl: 'app/places/map/places-map.html'
        };
        return module;
    }


    angular.module('pfb.places.map')
        .controller('PlacesMapController', PlacesMapController)
        .directive('pfbPlacesMap', PlacesMapDirective);

})();
