(function() {

    // Custom private Leaflet control implements a simple legend for all map layers
    L.Control.SpeedLegend = L.Control.extend({
        initialize: function (options) {
            L.Util.setOptions(this, options);
            this.speedLimit = options.speedLimit;
            if (this.speedLimit <= 25) {
                this.stressLevel = 'Low'

            } else {
                this.stressLevel = 'High'
            }
        },
        onAdd: function () {
            var div = L.DomUtil.create('div', 'leaflet-control-layers pfb-speed-limit-legend');
            var kphLimit = Math.round(this.speedLimit * 1.609);
            div.innerHTML += '<h6>Residential Speed Limit</h6>';
            div.innerHTML += '<div class="speed-limit-inner">' +
                '<div class="speed-limit-block"><div class="speed-limit">' + this.speedLimit + '</div><div>mph</div></div>' +
                '<div class="speed-limit-block"><div class="speed-limit">' + kphLimit + '</div><div>km/h</div></div>' +
                '</div>';
            div.innerHTML += '<div class="speed-limit-footer"><div class="speed-stress">Stress impact: '  + this.stressLevel + '</div></div>';
            return div;
        },
        stressLevel: function () {

        }
    });
    if (!L.control.speedLegend) {
        L.control.speedLegend = function (opts) {
            return new L.Control.SpeedLegend(opts);
        }
    }
})();
