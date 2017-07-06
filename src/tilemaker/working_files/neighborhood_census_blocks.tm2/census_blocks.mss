#neighborhood_census_blocks[OVERALL_SC != null] {
  polygon-opacity: 0.5;
}

#neighborhood_census_blocks[OVERALL_SC >= 0][OVERALL_SC < 6] {
  polygon-fill: #E2231A;
}
#neighborhood_census_blocks[OVERALL_SC >= 6][OVERALL_SC < 12] {
  polygon-fill: #C92433;
}
#neighborhood_census_blocks[OVERALL_SC >= 12][OVERALL_SC < 18] {
  polygon-fill: #B1264D;
}
#neighborhood_census_blocks[OVERALL_SC >= 18][OVERALL_SC < 24] {
  polygon-fill: #982766;
}
#neighborhood_census_blocks[OVERALL_SC >= 24][OVERALL_SC < 30] {
  polygon-fill: #802980;
}
#neighborhood_census_blocks[OVERALL_SC >= 30][OVERALL_SC < 36] {
  polygon-fill: #664396;
}
#neighborhood_census_blocks[OVERALL_SC >= 36][OVERALL_SC < 42] {
  polygon-fill: #4C5EAC;
}
#neighborhood_census_blocks[OVERALL_SC >= 42][OVERALL_SC < 48] {
  polygon-fill: #3378C2;
}
#neighborhood_census_blocks[OVERALL_SC >= 48][OVERALL_SC < 54] {
  polygon-fill: #1993D8;
}
#neighborhood_census_blocks[OVERALL_SC >= 54][OVERALL_SC <= 100] {
  polygon-fill: #00AEEF;
}
