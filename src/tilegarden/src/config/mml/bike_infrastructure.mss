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
  
  [functional = "path"] {
    line-opacity: 1;
  	line-color: @color-path;
    
    [xwalk = 1] {
      line-opacity: 0;
    }
  }
  
  [tf_bike_in = "lane"] {
    line-opacity: 1;
    line-color: @color-lane;
  }
  
  [tf_bike_in = "buffered_lane"] {
    line-opacity: 1;
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
  
  [tf_bike_in = "track"] {
    line-opacity: 1;
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
  
  [functional = "path"] {
    line-opacity: 1;
  	line-color: @color-path;
    
    [xwalk = 1] {
      line-opacity: 0;
    }
  }
  
  [ft_bike_in = "lane"] {
    line-opacity: 1;
    line-color: @color-lane;
  }
  
  [ft_bike_in = "buffered_lane"] {
    line-opacity: 1;
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
  
  [ft_bike_in = "track"] {
    line-opacity: 1;
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
