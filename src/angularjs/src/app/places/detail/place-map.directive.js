(function() {

    /* @ngInject */
    function PlaceMapController($filter, $log, $http, $sanitize, $q, $window, MapConfig, Neighborhood) {
        var ctl = this;
        ctl.map = null;
        ctl.layerControl = null;

        ctl.$onInit = function () {
            ctl.mapOptions = {
                scrollWheelZoom: true
            };

            // set center and zoom level by zooming to fit geojson polygon bounds, once loaded
            ctl.boundsConus = MapConfig.conusBounds;
            ctl.baseLayer = L.tileLayer(
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

        ctl.onLayerAdd = function (event) {
            var layer = event.layer;
            var legend = layer.legend;
            if (legend) {
                legend.addTo(ctl.map);
            }
        }

        ctl.onLayerRemove = function (event) {
            var layer = event.layer;
            var legend = layer.legend;
            if (legend) {
                legend.remove();
            }
        }

        ctl.onMapReady = function (map) {
            ctl.map = map;
            ctl.map.on('layeradd', ctl.onLayerAdd);
            ctl.map.on('layerremove', ctl.onLayerRemove);

            // in case map layers set before map was ready, add layers now map is ready to go
            if (ctl.pfbPlaceMapLayers) {
                setLayers(ctl.pfbPlaceMapLayers);
            }
        };

        function addBounds(uuid) {
            Neighborhood.bounds({uuid: uuid}).$promise.then(function (data) {
                ctl.boundsLayer = L.geoJSON(data, {});
                ctl.map.fitBounds(ctl.boundsLayer.getBounds());
                ctl.layerControl.addOverlay(ctl.boundsLayer, 'Area boundary', 'Overlays');
            });
        }

        function setLayers(layers) {
            if (!layers) {
                return;
            }
            var satelliteLayer = L.tileLayer(MapConfig.baseLayers.Satellite.url, {
                attribution: MapConfig.baseLayers.Satellite.attribution,
                maxZoom: MapConfig.conusMaxZoom
            });

            if (!ctl.layerControl) {
                ctl.layerControl = L.control.groupedLayers({
                    'Positron': ctl.baseLayer,
                    'Satellite': satelliteLayer
                }, {
                    'Overlays': {},
                    'Data': {},
                    'Destinations': {}
                }, {
                    exclusiveGroups: ['Overlays', 'Data','Destinations']
                }).addTo(ctl.map);
            }
            if (!ctl.printButton) {
                ctl.printButton = L.control.mapButton({
                    controlClasses: ['leaflet-control-layers'],
                    iconClasses: ['leaflet-btn icon-print']
                }, function () {
                    $window.print();
                }).addTo(ctl.map);
            }
            if (ctl.pfbPlaceMapSpeedLimit && !ctl.speedLimitLegend) {
                var speedLimitLegendOptions = MapConfig.legends["speedLimit"];
                speedLimitLegendOptions.speedLimit = ctl.pfbPlaceMapSpeedLimit;
                ctl.speedLimitLegend = L.control.speedLegend(speedLimitLegendOptions).addTo(ctl.map);
            }

            _.map(layers.tileLayers, function(layerObj) {
                // Get desired label
                var label = {
                    'ways': 'Stress Network',
                    'census_blocks': 'Census blocks with access',
                    'bike_infrastructure': 'Bike Infrastructure'
                }[layerObj.name];
                var layer = L.tileLayer(layerObj.url, {
                    maxZoom: MapConfig.conusMaxZoom
                });

                // Add legend object to layer so it can be toggled in layer event handler
                var legendOptions = MapConfig.legends[layerObj.name];
                if (legendOptions) {
                    layer.legend = L.control.legend(legendOptions);
                }
                // Desired default view is showing the network, so add that to the map
                if (layerObj.name === 'ways') {
                    ctl.map.addLayer(layer);
                }
                ctl.layerControl.addOverlay(layer, label, 'Overlays');
            });

            // We need to fetch and do some processing on each destination layer, which means
            // they could come back and get inserted in arbitrary order.
            // Loading them all before adding them to the picker lets us sort.
            var destLayerPromises = _.map(layers.featureLayers, function(layerObj) {
                var label = $sanitize(layerObj.name.replace(/_/g, ' '));
                label = label[0].toUpperCase() + label.slice(1);
                return $http.get(layerObj.url).then(function(response) {
                    if (response.data && response.data.features) {
                        var layer = L.geoJSON(response.data, {
                            onEachFeature: onEachFeature
                        });
                        return {'layer': layer, 'label': label};
                    }
                });
            });

            $q.all(destLayerPromises).then(function (layers) {
                if (!ctl.destinationsNoneLayer && layers && layers.length) {
                    var noneLayer = L.geoJSON({type:'FeatureCollection', features: []});
                    ctl.destinationsNoneLayer = noneLayer
                    ctl.layerControl.addOverlay(ctl.destinationsNoneLayer, 'None', 'Destinations');
                    ctl.map.addLayer(ctl.destinationsNoneLayer);
                }
                _.forEach(_.sortBy(layers, 'label'), function (layer) {
                    ctl.layerControl.addOverlay(layer.layer, layer.label, 'Destinations');
                });
            });

            var dataLayerPromises = _.map(layers.dataLayers, function(layerObj) {
                var label = $sanitize(layerObj.name.replace(/_/g, ' '));
                label = label[0].toUpperCase() + label.slice(1);
                return $http.get(layerObj.url).then(function(response) {
                    if (response.data && response.data.features) {
                        var layer = L.geoJSON(response.data, {
                            onEachFeature: onEachFeature,
                            pointToLayer: function (feature, latlng) {
                                var coords = [latlng.lat, latlng.lng]
                                var iconUrl;
                                if (feature.properties.fatality_type === 'ACTIVE') {
                                    iconUrl = 'assets/images/fatality-active-icon.png'
                                } else if (feature.properties.fatality_type === 'MOTOR_VEHICLE') {
                                    iconUrl = 'assets/images/fatality-motor-icon.png'
                                } else {
                                    iconUrl = 'assets/images/fatality-bike-icon.png'
                                }
                                var icon = L.icon({
                                    iconUrl: iconUrl,
                                    iconSize: [30, 30]
                                });

                                return L.marker(coords, { icon: icon })
                            }
                        }
                        );
                        return {'layer': layer, 'label': label};
                    }
                });
            });

            $q.all(dataLayerPromises).then(function (layers) {
                if (!ctl.dataNoneLayer && layers && layers.length) {
                    var noneLayer = L.geoJSON({type:'FeatureCollection', features: []});
                    ctl.dataNoneLayer = noneLayer
                    ctl.layerControl.addOverlay(ctl.dataNoneLayer, 'None', 'Data');
                    ctl.map.addLayer(ctl.dataNoneLayer);
                }
                _.forEach(_.sortBy(layers, 'label'), function (layer) {
                    var cluster = L.markerClusterGroup({
                        iconCreateFunction: function(cluster) {
                            var childCount = cluster.getChildCount()
                            var radius = 18
                            if (childCount < 10) radius = 12
                            else if (childCount < 100) radius = 15
                            var iconHTML = [
                                '<svg',
                                'width="' + radius*2 + '"',
                                'height="' + radius*2 + '"',
                                'viewBox="-' + radius, '-' + radius, radius*2, radius*2 + '"',
                                'xmlns="http://www.w3.org/2000/svg">',
                                '<style>.text { font: bold 13px sans-serif; fill: #fff; text-anchor: middle; dominant-baseline: central; }</style>',
                                '<circle r="' + radius + '" />',
                                '<text class="text">',
                                childCount,
                                '</text></svg>'
                            ].join(' ')
                            
                            return L.divIcon({
                                html: iconHTML,
                                className: ''
                            });
                        }
                    });
                    layer.layer.addTo(cluster)
                    ctl.layerControl.addOverlay(cluster, layer.label, 'Data');
                });
            });

            function onEachFeature(feature, layer) {
                // TODO: Style marker and popup
                layer.on({
                    click: function () {
                        if (feature && feature.geometry &&
                            feature.geometry.coordinates) {
                            var popup = L.popup({
                                offset: [0, -5]
                            })
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
                var ignore = ['blockid10', 'osm_id', 'fatality_type'];
                properties = _.omitBy(properties, function(val, key) {
                    return _.find(ignore, function(i) {return i === key;});
                });

                var snippet = '<ul>';
                snippet += _.map(properties, function(val, key) {
                    // humanize numbers: round to 3 digits and add commas
                    if (key !== 'year' && Number.parseFloat(val)) {
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
                pfbPlaceMapUuid: '<',
                pfbPlaceMapSpeedLimit: '<'
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
