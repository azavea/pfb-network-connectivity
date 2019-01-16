#neighborhood_census_blocks[overall_score != null] {
  polygon-opacity: 0.65;
}

#neighborhood_census_blocks[overall_score >= 0][overall_score < 6] {
  polygon-fill: #FF3300;
}
#neighborhood_census_blocks[overall_score >= 6][overall_score < 12] {
  polygon-fill: #D04628;
}
#neighborhood_census_blocks[overall_score >= 12][overall_score < 18] {
  polygon-fill: #B9503C;
}
#neighborhood_census_blocks[overall_score >= 18][overall_score < 24] {
  polygon-fill: #A25A51;
}
#neighborhood_census_blocks[overall_score >= 24][overall_score < 30] {
  polygon-fill: #8B6465;
}
#neighborhood_census_blocks[overall_score >= 30][overall_score < 36] {
  polygon-fill: #736D79;
}
#neighborhood_census_blocks[overall_score >= 36][overall_score < 42] {
  polygon-fill: #5C778D;
}
#neighborhood_census_blocks[overall_score >= 42][overall_score < 48] {
  polygon-fill: #4581A2;
}
#neighborhood_census_blocks[overall_score >= 48][overall_score < 54] {
  polygon-fill: #2E8BB6;
}
#neighborhood_census_blocks[overall_score >= 54][overall_score <= 100] {
  polygon-fill: #009FDF;
}
