evaluate <- function(p, annual_hours = p["events"] * p["people"] * p["delay"] / 60,
                     days = p["days"]) {
  annuity <- sum((1 + p["rate"] / 100)^-seq_len(p["years"]))
  avoided <- annual_hours * p["share"] / 100 * c(0, p["ready"], p["backup"]) / 100
  benefit <- avoided * p["value"] * annuity
  cost <- c(0, p["crew"] * annuity,
            p["capital"] + p["upkeep"] * annuity + days * p["workload"] * p["value"])
  data.frame(strategy = c("Current practice", "Standby response", "Backup retrofit"),
             annual_hours_saved = unname(avoided), pv_benefit = unname(benefit),
             pv_cost = unname(cost), npv = unname(benefit - cost))
}
