enum TrackStatus {
  reading,
  completed,
  on_hold,
  dropped,
  plan_to_read,
}

TrackStatus getMALStatus(String incoming) {
  if (incoming == "reading") return TrackStatus.reading;
  if (incoming == "completed") return TrackStatus.completed;
  if (incoming == "on_hold") return TrackStatus.on_hold;
  if (incoming == "dropped") return TrackStatus.dropped;
  if (incoming == "plan_to_read")
    return TrackStatus.plan_to_read;
  else
    return TrackStatus.reading;
}

TrackStatus getAniStatus(String incoming) {
  if (incoming == "CURRENT") return TrackStatus.reading;
  if (incoming == "COMPLETED") return TrackStatus.completed;
  if (incoming == "PAUSED") return TrackStatus.on_hold;
  if (incoming == "DROPPED") return TrackStatus.dropped;
  if (incoming == "PLANNING")
    return TrackStatus.plan_to_read;
  else
    return TrackStatus.reading;
}

String getAniPublishStatus(String incoming) {
  if (incoming == "FINISHED") return 'Completed';
  if (incoming == "RELEASING")
    return 'Ongoing';
  else
    return 'Unknown';
}

String getMALStatusString(TrackStatus s) {
  if (s == TrackStatus.reading) return "reading";
  if (s == TrackStatus.completed) return "completed";
  if (s == TrackStatus.on_hold) return "on_hold";
  if (s == TrackStatus.dropped) return "dropped";
  if (s == TrackStatus.plan_to_read)
    return "plan_to_read";
  else
    return "reading";
}

String getAnilistStatusString(TrackStatus s) {
  if (s == TrackStatus.reading) return "CURRENT";
  if (s == TrackStatus.completed) return "COMPLETED";
  if (s == TrackStatus.on_hold) return "PAUSED";
  if (s == TrackStatus.dropped) return "DROPPED";
  if (s == TrackStatus.plan_to_read)
    return "PLANNING";
  else
    return "CURRENT";
}

String convertToPresentable(TrackStatus s, int type) {
  if (s == TrackStatus.reading) return "Reading";
  if (s == TrackStatus.completed) return "Completed";
  if (s == TrackStatus.on_hold) return type == 2 ? "On Hold" : "Paused";
  if (s == TrackStatus.dropped) return "Dropped";
  if (s == TrackStatus.plan_to_read)
    return "Plan to Read";
  else
    return "Reading";
}
