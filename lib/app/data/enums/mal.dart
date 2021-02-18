enum MALTrackStatus {
  reading,
  completed,
  on_hold,
  dropped,
  plan_to_read,
}

MALTrackStatus getMALStatus(String incoming) {
  if (incoming == "reading") return MALTrackStatus.reading;
  if (incoming == "completed") return MALTrackStatus.completed;
  if (incoming == "on_hold") return MALTrackStatus.on_hold;
  if (incoming == "dropped") return MALTrackStatus.dropped;
  if (incoming == "plan_to_read")
    return MALTrackStatus.plan_to_read;
  else
    return MALTrackStatus.reading;
}

String getMALStatusString(MALTrackStatus s) {
  if (s == MALTrackStatus.reading) return "reading";
  if (s == MALTrackStatus.completed) return "completed";
  if (s == MALTrackStatus.on_hold) return "on_hold";
  if (s == MALTrackStatus.dropped) return "dropped";
  if (s == MALTrackStatus.plan_to_read)
    return "plan_to_read";
  else
    return "reading";
}

String convertToPresentatble(MALTrackStatus s) {
  if (s == MALTrackStatus.reading) return "Reading";
  if (s == MALTrackStatus.completed) return "Completed";
  if (s == MALTrackStatus.on_hold) return "On Hold";
  if (s == MALTrackStatus.dropped) return "Dropped";
  if (s == MALTrackStatus.plan_to_read)
    return "Plan to Read";
  else
    return "Reading";
}
