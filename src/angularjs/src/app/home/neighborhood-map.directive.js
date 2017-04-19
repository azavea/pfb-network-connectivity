
(function() {

    /* @ngInject */
    function NeighborhoodMapController(Neighborhood) {
        var ctl = this;
        ctl.map = null;

        ctl.$onInit = function () {
            ctl.mapOptions = { scrollWheelZoom: false };
            ctl.boundsConus = [[24.396308, -124.848974], [49.384358, -66.885444]];
            ctl.baselayer = L.tileLayer(
                'https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png', {
                    attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
                    maxZoom: 18
                });
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;
            Neighborhood.geojson().$promise.then(function (data) {
                ctl.count = data && data.features ? data.features.length : '0';
                ctl.neighborhoodLayer = L.geoJSON(data, {
                    onEachFeature: onEachFeature
                });
                map.addLayer(ctl.neighborhoodLayer);
            });

            function onEachFeature(feature, layer) {
                // TODO: Style marker and popup
                // TODO: Add link to neighborhood detail in popup
                layer.on({
                    click: function () {
                        if (feature && feature.geometry &&
                            feature.geometry.coordinates) {
                            var popup = L.popup()
                                .setLatLng([
                                    feature.geometry.coordinates[1],
                                    feature.geometry.coordinates[0]
                                ])
                                .setContent(feature.properties.label);
                            ctl.map.openPopup(popup);
                        }
                    }
                });
            }
        };
    }

    function NeighborhoodMapDirective() {
        var module = {
            restrict: 'E',
            controller: 'NeighborhoodMapController',
            controllerAs: 'ctl',
            bindToController: true,
            templateUrl: 'app/home/neighborhood-map.html'
        };
        return module;
    }


    angular.module('pfb.home')
        .controller('NeighborhoodMapController', NeighborhoodMapController)
        .directive('pfbNeighborhoodMap', NeighborhoodMapDirective);

})();
