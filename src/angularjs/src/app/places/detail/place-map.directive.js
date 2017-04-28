(function() {

    /* @ngInject */
    function PlaceMapController($filter, $http, $sanitize, MapConfig) {
        var ctl = this;
        ctl.map = null;
        ctl.layerControl = null;

        ctl.$onInit = function () {
            ctl.mapOptions = {
                scrollWheelZoom: true
            };

            // TODO: set center and zoom level by zooming to fit geojson polygon bounds
            ctl.mapCenter = [39.963277, -75.142971];
            ctl.baselayer = L.tileLayer(
                MapConfig.baseLayers.Positron.url, {
                    attribution: MapConfig.baseLayers.Positron.attribution,
                    maxZoom: MapConfig.conusMaxZoom
                });
        };

        ctl.$onChanges = function(changes) {
            // set map layers once received from parent scope (paret-detail.controller)
            if (changes.pfbPlaceMapLayers && changes.pfbPlaceMapLayers.currentValue && ctl.map) {
                setLayers(changes.pfbPlaceMapLayers.currentValue);
            }
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;

            // in case map layers set before map was ready, add layers now map is ready to go
            if (ctl.pfbPlaceMapLayers) {
                setLayers(ctl.pfbPlaceMapLayers);
            }
        };

        function setLayers(layers) {
            if (!layers) {
                return;
            }

            if (!ctl.layerControl) {
                ctl.layerControl = L.control.layers({'Positron': ctl.baselayer}, []).addTo(ctl.map);
            }

            _.map(layers, function(url, metric) {
                var label = $sanitize(metric.replace(/_/g, ' '));
                $http.get(url).then(function(response) {
                    if (response.data && response.data.features) {
                        var layer = L.geoJSON(response.data, {
                            onEachFeature: onEachFeature
                        });
                        ctl.layerControl.addOverlay(layer, label);
                    }
                });
            });

            function onEachFeature(feature, layer) {
                // TODO: Style marker and popup
                layer.on({
                    click: function () {
                        if (feature && feature.geometry &&
                            feature.geometry.coordinates) {
                            var popup = L.popup()
                                .setLatLng([
                                    feature.geometry.coordinates[1],
                                    feature.geometry.coordinates[0]
                                ])
                                .setContent(buildLabel(feature.properties));
                            ctl.map.openPopup(popup);
                        }
                    }
                });
            }

            /**
             Convert GeoJSON properties into HTML snippet for Leaflet popup display.
             */
            function buildLabel(properties) {

                // omit some less-useful properties
                var ignore = ['blockid10', 'osm_id'];
                properties = _.omitBy(properties, function(val, key) {
                    return _.find(ignore, function(i) {return i === key;});
                });

                var snippet = '<ul>';
                snippet += _.map(properties, function(val, key) {
                    // humanize numbers: round to 3 digits and add commas
                    if (Number.parseFloat(val)) {
                        val = $filter('number')(val);
                    }
                    return ['<li>',
                            key.replace(/_/g, ' '),
                            ': ',
                            (val ? val : '--'),
                            '</li>'
                            ].join('');
                }).join('');
                snippet += '</ul>';
                return $sanitize(snippet);
            }
        }
    }

    function PlaceMapDirective() {
        var module = {
            restrict: 'E',
            scope: {
                pfbPlaceMapLayers: '<'
            },
            controller: 'PlaceMapController',
            controllerAs: 'ctl',
            bindToController: true,
            templateUrl: 'app/places/detail/place-map.html'
        };
        return module;
    }


    angular.module('pfb.places.detail')
        .controller('PlaceMapController', PlaceMapController)
        .directive('pfbPlaceMap', PlaceMapDirective);

})();
