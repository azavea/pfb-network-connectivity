@width-tight: 2;
@width-med: 1.5;
@width-wide: 1;
@color-low-stress: #009fdf;
@color-high-stress: #ff3300;

#neighborhood_waysFT, #neighborhood_waysTF {
  [zoom > 13] { 
    line-width: @width-tight;
  }
  [zoom <= 13][zoom >= 10] {
    line-width: @width-med;
  }
  [zoom < 10] { 
    line-width: @width-wide;
  }
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
  [TF_SEG_STR > 1] {
  	line-color: @color-high-stress;
  }
  [TF_SEG_STR = 1] {
 	 line-color: @color-low-stress;
  }
  [TF_SEG_STR < 1] {
 	 line-opacity: 0;
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
  [FT_SEG_STR > 1] {
  	line-color: @color-high-stress;
  }
  [FT_SEG_STR = 1] {
 	 line-color: @color-low-stress;
  }
  [FT_SEG_STR < 1] {
 	 line-opacity: 0;
  }
}
