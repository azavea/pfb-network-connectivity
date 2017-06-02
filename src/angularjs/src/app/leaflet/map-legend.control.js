(function() {

    // Custom private Leaflet control implements a simple legend for all map layers
    L.Control.Legend = L.Control.extend({
        initialize: function (options) {
            L.Util.setOptions(this, options);
            var labels = options.labels;
            if (!(labels && labels.length)) {
                throw 'L.Control.Legend requires a labels array';
            }
            var colors = options.colors;
            if (!(colors && colors.length)) {
                throw 'L.Control.Legend requires a colors array';
            }
            if (labels.length !== colors.length) {
                throw 'L.Control.Legend requires colors and labels to be the same size';
            }
            this.colors = colors;
            this.labels = labels;
            this.title = options.title || null;
        },
        onAdd: function () {
            var div = L.DomUtil.create('div', 'leaflet-control-layers pfb-control-legend');
            if (this.title) {
                div.innerHTML += '<h5>' + this.title + '</h5>';
            }
            for (var i = 0; i < this.colors.length; i++) {
                div.innerHTML +=
                    '<i style="background:' + this.colors[i] + '"></i> ' + this.labels[i] + '<br>';
            }
            return div;
        }
    });
    if (!L.control.legend) {
        L.control.legend = function (opts) {
            return new L.Control.Legend(opts);
        }
    }
})();
