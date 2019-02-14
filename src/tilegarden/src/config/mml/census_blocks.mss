#neighborhood_census_blocks[overall_score != null] {
  polygon-opacity: 0.65;
}

#neighborhood_census_blocks[overall_score >= 0][overall_score < 10] {
  polygon-fill: #FF3300;
}
#neighborhood_census_blocks[overall_score >= 10][overall_score < 20] {
  polygon-fill: #D04628;
}
#neighborhood_census_blocks[overall_score >= 20][overall_score < 30] {
  polygon-fill: #B9503C;
}
#neighborhood_census_blocks[overall_score >= 30][overall_score < 40] {
  polygon-fill: #A25A51;
}
#neighborhood_census_blocks[overall_score >= 40][overall_score < 50] {
  polygon-fill: #8B6465;
}
#neighborhood_census_blocks[overall_score >= 50][overall_score < 60] {
  polygon-fill: #736D79;
}
#neighborhood_census_blocks[overall_score >= 60][overall_score < 70] {
  polygon-fill: #5C778D;
}
#neighborhood_census_blocks[overall_score >= 70][overall_score < 80] {
  polygon-fill: #4581A2;
}
#neighborhood_census_blocks[overall_score >= 80][overall_score < 90] {
  polygon-fill: #2E8BB6;
}
#neighborhood_census_blocks[overall_score >= 90][overall_score <= 100] {
  polygon-fill: #009FDF;
}
