(function() {

    // Custom private Leaflet control implements a simple button with a click handler
    L.Control.MapButton = L.Control.extend({
        initialize: function (options, callback) {
            if (!callback) {
                throw 'L.Control.MapButton requires click handler as second argument';
            }
            this.iconClasses = options.iconClasses || [];
            this.controlClasses = options.controlClasses || [];
            this.controlClasses.push('pfb-control-map-button');
            this.onClick = function (event) {
                callback(event);
                event.preventDefault();
                event.stopPropagation();
            }
        },
        onAdd: function () {
            var self = this;

            this.div = L.DomUtil.create('div');
            _.forEach(this.controlClasses, function (c) {
                L.DomUtil.addClass(self.div, c);
            });
            L.DomEvent.on(this.div, 'click', this.onClick, this);

            var icon = L.DomUtil.create('i');
            _.forEach(this.iconClasses, function (c) {
                L.DomUtil.addClass(icon, c);
            });
            this.div.appendChild(icon);

            return this.div;
        },
        onRemove: function () {
            L.DomEvent.off(this.div, 'click', this.onClick, this);
        }
    });
    if (!L.control.mapButton) {
        L.control.mapButton = function (opts, callback) {
            return new L.Control.MapButton(opts, callback);
        }
    }
})();
