(function() {

    /* @ngInject */
    function PlaceMapController($filter, $http, $sanitize, MapConfig, Neighborhood) {
        var ctl = this;
        ctl.map = null;
        ctl.layerControl = null;

        ctl.$onInit = function () {
            ctl.mapOptions = {
                scrollWheelZoom: true
            };

            // set center and zoom level by zooming to fit geojson polygon bounds, once loaded
            ctl.boundsConus = MapConfig.conusBounds;
            ctl.baselayer = L.tileLayer(
                MapConfig.baseLayers.Positron.url, {
                    attribution: MapConfig.baseLayers.Positron.attribution,
                    maxZoom: MapConfig.conusMaxZoom
            });
        };

        ctl.$onChanges = function(changes) {
            // set map layers once received from parent scope (paret-detail.controller)
            if (ctl.map) {
                if (changes.pfbPlaceMapLayers && changes.pfbPlaceMapLayers.currentValue) {
                    setLayers(changes.pfbPlaceMapLayers.currentValue);
                }

                if (changes.pfbPlaceMapUuid && changes.pfbPlaceMapUuid.currentValue) {
                    addBounds(changes.pfbPlaceMapUuid.currentValue);
                }
            }
        };

        ctl.onMapReady = function (map) {
            ctl.map = map;

            ctl.baselayer.addTo(ctl.map);

            // in case map layers set before map was ready, add layers now map is ready to go
            if (ctl.pfbPlaceMapLayers) {
                setLayers(ctl.pfbPlaceMapLayers);
            }
        };

        function addBounds(uuid) {
            Neighborhood.bounds({uuid: uuid}).$promise.then(function (data) {
                ctl.boundsLayer = L.geoJSON(data, {});
                ctl.map.addLayer(ctl.boundsLayer);
                ctl.map.fitBounds(ctl.boundsLayer.getBounds());
                ctl.layerControl.addBaseLayer(ctl.boundsLayer, 'area boundary');
            });
        }

        function setLayers(layers) {
            if (!layers) {
                return;
            }

            if (!ctl.layerControl) {
                var options = {
                    sortLayers: true
                };
                ctl.layerControl = L.control.layers({}, {}, options).addTo(ctl.map);
            }

            _.map(layers.tileLayers, function(layerObj) {
                var label = $sanitize(layerObj.name.replace(/_/g, ' '));
                var layer = L.tileLayer(layerObj.url, {
                    maxZoom: MapConfig.conusMaxZoom
                });
                ctl.layerControl.addBaseLayer(layer, label);
            });

            _.map(layers.featureLayers, function(layerObj) {
                var label = $sanitize(layerObj.name.replace(/_/g, ' '));
                $http.get(layerObj.url).then(function(response) {
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
                pfbPlaceMapLayers: '<',
                pfbPlaceMapUuid: '<'
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
