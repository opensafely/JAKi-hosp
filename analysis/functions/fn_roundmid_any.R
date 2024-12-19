# Rounding function for redaction ----------------------------------------------
fn_roundmid_any <- function(x, to=1){
  # centers on (integer) midpoint of the rounding points
  ceiling(x/to)*to - (floor(to/2)*(x!=0))
}