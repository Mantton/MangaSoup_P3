
enum MangaDexFollow{
  NONE,
  READING,
  COMPLETED,
  ON_HOLD,
  PLAN_TO_READ,
  DROPPED,
  RE_READING
}

String getCategory(int id){
  if (id == MangaDexFollow.READING.index)
    return "Reading";
  if (id == MangaDexFollow.COMPLETED.index)
    return "Completed";
  if (id == MangaDexFollow.ON_HOLD.index)
    return "On Hold";
  if (id == MangaDexFollow.PLAN_TO_READ.index)
    return "Plan To Read";
  if (id == MangaDexFollow.DROPPED.index)
    return "Dropped";
  if (id == MangaDexFollow.RE_READING.index)
    return "Re-Reading";
  else return "Unknown";

}