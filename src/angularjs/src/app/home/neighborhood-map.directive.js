
(function() {

    /* @ngInject */
    function NeighborhoodMapController(MapConfig, Neighborhood) {
        var ctl = this;
        ctl.map = null;

        ctl.$onInit = function () {
            ctl.mapOptions = { scrollWheelZoom: false };
            ctl.boundsConus = MapConfig.conusBounds;
            ctl.baselayer = L.tileLayer(
                MapConfig.baseLayers.Stamen.url, {
                    attribution: MapConfig.baseLayers.Stamen.attribution,
                    maxZoom: MapConfig.conusMaxZoom
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
