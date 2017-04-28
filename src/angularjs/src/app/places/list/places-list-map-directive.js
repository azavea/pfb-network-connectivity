(function() {

    /* @ngInject */
    function PlacesListMapController(MapConfig, Neighborhood) {
        var ctl = this;
        ctl.map = null;
        ctl.layerControl = null;

        ctl.$onInit = function () {
            ctl.boundsConus = MapConfig.conusBounds;
            ctl.baselayer = L.tileLayer(
                MapConfig.baseLayers.Stamen.url, {
                    attribution: MapConfig.baseLayers.Stamen.attribution,
                    maxZoom: MapConfig.conusMaxZoom
                });
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;

            var satelliteLayer = L.tileLayer(MapConfig.baseLayers.Satellite.url, {
                attribution: MapConfig.baseLayers.Satellite.attribution,
                maxZoom: MapConfig.conusMaxZoom
            });

            if (!ctl.layerControl) {
                ctl.layerControl = L.control.layers({
                        'Stamen': ctl.baselayer,
                        'Satellite': satelliteLayer
                    },
                    []).addTo(ctl.map);
            }

            Neighborhood.geojson().$promise.then(function (data) {
                ctl.neighborhoodLayer = L.geoJSON(data, {
                    onEachFeature: onEachFeature
                });
                ctl.layerControl.addOverlay(ctl.neighborhoodLayer, 'Places');
                map.addLayer(ctl.neighborhoodLayer);
            });

            function onEachFeature(feature, layer) {
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

    function PlacesListMapDirective() {
        var module = {
            restrict: 'E',
            scope: {
                pfbPlacesListMapLayers: '<'
            },
            controller: 'PlacesListMapController',
            controllerAs: 'ctl',
            bindToController: true,
            templateUrl: 'app/places/list/places-list-map.html'
        };
        return module;
    }


    angular.module('pfb.places.list')
        .controller('PlacesListMapController', PlacesListMapController)
        .directive('pfbPlacesListMap', PlacesListMapDirective);

})();
