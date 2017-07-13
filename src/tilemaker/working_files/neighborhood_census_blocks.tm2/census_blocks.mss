#neighborhood_census_blocks[OVERALL_SC != null] {
  polygon-opacity: 0.65;
}

#neighborhood_census_blocks[OVERALL_SC >= 0][OVERALL_SC < 6] {
  polygon-fill: #FF3300;
}
#neighborhood_census_blocks[OVERALL_SC >= 6][OVERALL_SC < 12] {
  polygon-fill: #D04628;
}
#neighborhood_census_blocks[OVERALL_SC >= 12][OVERALL_SC < 18] {
  polygon-fill: #B9503C;
}
#neighborhood_census_blocks[OVERALL_SC >= 18][OVERALL_SC < 24] {
  polygon-fill: #A25A51;
}
#neighborhood_census_blocks[OVERALL_SC >= 24][OVERALL_SC < 30] {
  polygon-fill: #8B6465;
}
#neighborhood_census_blocks[OVERALL_SC >= 30][OVERALL_SC < 36] {
  polygon-fill: #736D79;
}
#neighborhood_census_blocks[OVERALL_SC >= 36][OVERALL_SC < 42] {
  polygon-fill: #5C778D;
}
#neighborhood_census_blocks[OVERALL_SC >= 42][OVERALL_SC < 48] {
  polygon-fill: #4581A2;
}
#neighborhood_census_blocks[OVERALL_SC >= 48][OVERALL_SC < 54] {
  polygon-fill: #2E8BB6;
}
#neighborhood_census_blocks[OVERALL_SC >= 54][OVERALL_SC <= 100] {
  polygon-fill: #009FDF;
}
