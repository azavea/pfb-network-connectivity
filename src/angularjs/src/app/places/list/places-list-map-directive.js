(function() {

    /* @ngInject */
    function PlacesListMapController(Neighborhood) {
        var ctl = this;
        ctl.map = null;
        ctl.layerControl = null;

        ctl.$onInit = function () {
            ctl.mapOptions = {
                scrollWheelZoom: true
            };

            ctl.boundsConus = [[24.396308, -124.848974], [49.384358, -66.885444]];
            ctl.baselayer = L.tileLayer(
                'https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png', {
                    attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
                    maxZoom: 18
                });
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;

            var esriSatelliteAttribution = [
                '&copy; <a href="http://www.esri.com/">Esri</a> ',
                'Source: Esri, DigitalGlobe, GeoEye, Earthstar Geographics, CNES/Airbus DS, USDA, USGS, ',
                'AEX, Getmapping, Aerogrid, IGN, IGP, swisstopo, and the GIS User Community'
            ].join('');

            var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
                attribution: esriSatelliteAttribution,
                maxZoom: 18
            });

            if (!ctl.layerControl) {
                ctl.layerControl = L.control.layers({
                        'Stamen': ctl.baselayer,
                        'Satellite': satelliteLayer
                    },
                    []).addTo(ctl.map);
            }

            Neighborhood.geojson().$promise.then(function (data) {
                ctl.count = data && data.features ? data.features.length : '0';
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
