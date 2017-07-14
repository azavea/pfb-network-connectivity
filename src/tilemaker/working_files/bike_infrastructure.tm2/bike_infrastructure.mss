@width-tight: 2;
@width-med: 1.5;
@width-wide: 1;
@width-multiplier-medium: 1.5;
@width-multiplier-large: 2;
@color-path: #15bf50;
@color-lane: #8c54de;
@color-buffered-lane: #5072f5;
@color-track: #44a3a6;

#neighborhood_waysTF, #neighborhood_waysFT {
  [zoom > 13] { 
    line-width: @width-tight;
  }
  [zoom <= 13][zoom >= 10] {
    line-width: @width-med;
  }
  [zoom < 10] { 
    line-width: @width-wide;
  }
  line-opacity: 0;
}

#neighborhood_waysTF {
  [zoom > 13] {
    line-offset: -@width-tight;
  }
  [zoom <= 13][zoom >= 10] {
    line-offset: -@width-med;
  }
  [zoom < 10] {
    line-offset: -@width-wide;
  }
  
  [TF_BIKE_IN = "lane"],
  [TF_BIKE_IN = "buffered_lane"],
  [TF_BIKE_IN = "track"] {
    line-opacity: 1;
  }
  
  [FUNCTIONAL = "path"][XWALK != 1] {
    line-opacity: 1;
  	line-color: @color-path;
  }
  
  [TF_BIKE_IN = "lane"] {
    line-color: @color-lane;
  }
  
  [TF_BIKE_IN = "buffered_lane"] {
  	line-color: @color-buffered-lane;
    
    [zoom > 13] {
      line-width: @width-tight * @width-multiplier-medium;
      line-offset: -@width-tight * @width-multiplier-medium;
    }
    [zoom <= 13][zoom >= 10] {
      line-width: @width-med * @width-multiplier-medium;
      line-offset: -@width-med * @width-multiplier-medium;
    }
    [zoom < 10] {
      line-width: @width-wide * @width-multiplier-medium;
      line-offset: -@width-wide * @width-multiplier-medium;
    }
  }
  
  [TF_BIKE_IN = "track"] {
    line-color: @color-track;
    
    [zoom > 13] {
      line-width: @width-tight * @width-multiplier-large;
      line-offset: -@width-tight * @width-multiplier-large;
    }
    [zoom <= 13][zoom >= 10] {
      line-width: @width-med * @width-multiplier-large;
      line-offset: -@width-med * @width-multiplier-large;
    }
    [zoom < 10] {
      line-width: @width-wide * @width-multiplier-large;
      line-offset: -@width-wide * @width-multiplier-large;
    }
  }
}

#neighborhood_waysFT {
  [zoom > 13] {
    line-offset: @width-tight;
  }
  [zoom <= 13][zoom >= 10] {
    line-offset: @width-med;
  }
  [zoom < 10] {
    line-offset: @width-wide;
  }
  
  [FT_BIKE_IN = "lane"],
  [FT_BIKE_IN = "buffered_lane"],
  [FT_BIKE_IN = "track"] {
    line-opacity: 1;
  }
  
  [FUNCTIONAL = "path"][XWALK != 1] {
    line-opacity: 1;
  	line-color: @color-path;
  }
  
  [FT_BIKE_IN = "lane"] {
    line-color: @color-lane;
  }
  
  [FT_BIKE_IN = "buffered_lane"] {
  	line-color: @color-buffered-lane;
    
    [zoom > 13] {
      line-width: @width-tight * @width-multiplier-medium;
      line-offset: @width-tight * @width-multiplier-medium;
    }
    [zoom <= 13][zoom >= 10] {
      line-width: @width-med * @width-multiplier-medium;
      line-offset: @width-med * @width-multiplier-medium;
    }
    [zoom < 10] {
      line-width: @width-wide * @width-multiplier-medium;
      line-offset: @width-wide * @width-multiplier-medium;
    }
  }
  [FT_BIKE_IN = "track"] {
    line-color: @color-track;
    
    [zoom > 13] {
      line-width: @width-tight * @width-multiplier-large;
      line-offset: @width-tight * @width-multiplier-large;
    }
    [zoom <= 13][zoom >= 10] {
      line-width: @width-med * @width-multiplier-large;
      line-offset: @width-med * @width-multiplier-large;
    }
    [zoom < 10] {
      line-width: @width-wide * @width-multiplier-large;
      line-offset: @width-wide * @width-multiplier-large;
    }
  }
}
