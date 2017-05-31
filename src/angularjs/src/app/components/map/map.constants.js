(function() {
  'use strict';

  var config = {
    baseLayers: {
        'Positron': {
            url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
            attribution: [
                '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, ',
                '&copy; <a href="https://carto.com/attribution">CARTO</a>'].join('')
        },
        'Stamen' : {
            url: 'https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png',
            attribution: ['Map tiles by <a href="http://stamen.com">Stamen Design</a>, ',
                'under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. ',
                'Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under ',
                '<a href="http://www.openstreetmap.org/copyright">ODbL</a>.'
            ].join('')
        },
        'Satellite': {
            url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            attribution: [
                '&copy; <a href="http://www.esri.com/">Esri</a> ',
                'Source: Esri, DigitalGlobe, GeoEye, Earthstar Geographics, CNES/Airbus DS, USDA, USGS, ',
                'AEX, Getmapping, Aerogrid, IGN, IGP, swisstopo, and the GIS User Community'
            ].join('')
        }
    },
    conusBounds: [[24.396308, -124.848974], [49.384358, -66.885444]],
    conusMaxZoom: 17,
    legends: {
        census_blocks: {
            position: 'bottomright',
            colors: ['#e2231a', '#c92433', '#b1264d', '#982766', '#802980', '#664396', '#4c5eac', '#3378c2', '#1993d8', '#00aeef'],
            labels: ['0 - 6', '6 - 12', '12 - 18', '18 - 24', '24 - 30', '30 - 36', '36 - 42', '42 - 48', '48 - 54', '54 - 100'],
            title: 'BNA Score'
        },
        ways: {
            position: 'bottomright',
            colors: ['#00aeef', '#e2231a'],
            labels: ['Low Stress', 'High Stress']
        }
    }
  };

  angular
    .module('pfb.components.map')
    .constant('MapConfig', config);

})();
