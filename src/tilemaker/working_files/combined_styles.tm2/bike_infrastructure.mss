@width-tight: 2;
@width-med: 1.5;
@width-wide: 1;
@width-multiplier: 5;
@light-blue: #00aeef;
@dark-blue: #005e83;
@green: #006b3e;
@white: #fff;

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
  [TF_BIKE_IN = "track"],
  [FUNCTIONAL = "path"] {
    line-opacity: 1;
  }
  
  [FUNCTIONAL = "path"] {
  	line-color: @green;
  }
  
  [TF_BIKE_IN = "lane"] {
    line-color: @light-blue;
  }
  
  [TF_BIKE_IN = "buffered_lane"],
  [TF_BIKE_IN = "track"] {
  	line-color: @dark-blue;
    
    [TF_BIKE_IN = "track"] {
      ::fill {
        line-width: @width-tight;
        line-color: @white;
        line-dasharray: 8, 4;
        
        [zoom > 13] { 
          line-offset: -@width-tight * @width-multiplier / 2;
        }
        [zoom <= 13][zoom >= 10] {
          line-offset: -@width-med * @width-multiplier / 2;
        }
        [zoom < 10] { 
          line-offset: -@width-wide * @width-multiplier / 2;
        }
      }
    }
    
    [zoom > 13] { 
      line-width: @width-tight * @width-multiplier;
      line-offset: -@width-tight * @width-multiplier / 2;
    }
    [zoom <= 13][zoom >= 10] {
      line-width: @width-med * @width-multiplier;
      line-offset: -@width-med * @width-multiplier / 2;
    }
    [zoom < 10] { 
      line-width: @width-wide * @width-multiplier;
      line-offset: -@width-wide * @width-multiplier / 2;
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
  [FT_BIKE_IN = "track"],
  [FUNCTIONAL = "path"] {
    line-opacity: 1;
  }
  
  [FUNCTIONAL = "path"] {
  	line-color: @green;
  }
  
  [FT_BIKE_IN = "lane"] {
    line-color: @light-blue;
  }
  
  [FT_BIKE_IN = "buffered_lane"],
  [FT_BIKE_IN = "track"] {
  	line-color: @dark-blue;
    
    [FT_BIKE_IN = "track"] {
      ::fill {
        line-width: @width-tight;
        line-color: @white;
        line-dasharray: 8, 4;
        
        [zoom > 13] { 
          line-offset: @width-tight * @width-multiplier / 2;
        }
        [zoom <= 13][zoom >= 10] {
          line-offset: @width-med * @width-multiplier / 2;
        }
        [zoom < 10] { 
          line-offset: @width-wide * @width-multiplier / 2;
        }
      }
    }
    
    [zoom > 13] { 
      line-width: @width-tight * @width-multiplier;
      line-offset: @width-tight * @width-multiplier / 2;
    }
    [zoom <= 13][zoom >= 10] {
      line-width: @width-med * @width-multiplier;
      line-offset: @width-med * @width-multiplier / 2;
    }
    [zoom < 10] { 
      line-width: @width-wide * @width-multiplier;
      line-offset: @width-wide * @width-multiplier / 2;
    }
  }
}
