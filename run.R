# Run from the project root. Requires base R with PNG support.
if (!file.exists("config/scenario.csv")) stop("Set the working directory to road-lab.")
source("R/model.R")
source("R/check_model.R")
cfg <- read.csv("config/scenario.csv")
required <- c("events","people","delay","value","years","rate","share","ready","backup",
              "crew","capital","upkeep","days","workload")
stopifnot(identical(cfg$key, required))
p <- setNames(cfg$default, cfg$key)
stopifnot(p["years"] >= 1, p["years"] == floor(p["years"]), all(p >= 0),
          p["value"] > 0, all(p[c("ready","backup","share")] <= 100))
stopifnot(!anyDuplicated(cfg$key), all(is.finite(p)), all(p >= cfg$min & p <= cfg$max))
dir.create("output", showWarnings = FALSE)
save_table <- function(x, name) write.csv(x, file.path("output", paste0(name, ".csv")), row.names = FALSE, na = "")
chart <- function(name, draw) {
  fn <- file.path("output", paste0(name, ".png"))
  png(fn, width = 4800, height = 2700, res = 360, bg = "white")
  on.exit(dev.off())
  par(mar = c(4.1, 4.5, 2, 1), mgp = c(2.6, .65, 0), las = 1, bty = "l",
      col.axis = "#435564", col.lab = "#233A48", family = "sans")
  draw()
}
navy <- "#213E50"; teal <- "#298887"; amber <- "#C16A4F"; pale <- "#E6EEEE"
events <- read.csv("data/transcribed/closures.csv", fileEncoding = "UTF-8", na.strings = "")
response <- read.csv("data/transcribed/response.csv", fileEncoding = "UTF-8")
# Explicit same-day local clock minutes; missing clocks stay missing.
clock <- function(x) as.numeric(substr(x, 1, 2)) * 60 + as.numeric(substr(x, 4, 5))
events$duration_min <- clock(events$reopen_local) - clock(events$start_local)
stopifnot(all(events$duration_min >= 0, na.rm = TRUE))
save_table(events, "event_records")
chart("Fig1_reported_closures", function() {
  par(mar = c(4.5, 9.7, 2, 1))
  y <- rev(seq_len(nrow(events)))
  start <- clock(events$start_local); end <- clock(events$reopen_local)
  plot(NA, xlim = c(1018, 1135), ylim = c(.45, 9.25), axes = FALSE, xlab = "Local time on 7 August 2026", ylab = "")
  ticks <- seq(1020, 1125, 15); axis(1, ticks, sprintf("%02d:%02d", ticks %/% 60, ticks %% 60))
  abline(v = ticks, col = pale)
  axis(2, y, events$location_en, tick = FALSE, las = 1)
  for (i in seq_along(y)) {
    col <- if (events$location_en[i] == "Jingtai Bridge") amber else teal
    points(start[i], y[i], pch = 16, col = col)
    if (is.na(end[i])) text(start[i]+2, y[i], "End unreported", pos = 4, cex = .75, col = navy)
    else {
      segments(start[i], y[i], end[i], y[i], lwd = 5, col = col)
      points(end[i], y[i], pch = 16, col = col)
      text(end[i], y[i], paste(events$duration_min[i], "min"), pos = 4, cex = .85)
    }
  }
  for (i in 1:2) {
    x <- clock(response$time_local[i])
    points(x, 8.1+i*.38, pch = 17, col = navy)
    text(x, 8.1+i*.38, response$event[i], pos = 4, cex = .78)
  }
})
res <- evaluate(p)
save_table(res, "scenario_comparison")
inputs <- c("data/transcribed/closures.csv","data/transcribed/response.csv",
            "data/transcribed/benchmarks.csv","config/scenario.csv")
save_table(data.frame(input=inputs, md5=unname(tools::md5sum(inputs))), "input_manifest")
bench <- read.csv("data/transcribed/benchmarks.csv", fileEncoding="UTF-8")
bench$value_cny <- ifelse(bench$unit=="ten thousand CNY", bench$value_as_published*10000,
                           ifelse(bench$unit=="CNY per unit",bench$value_as_published,NA))
save_table(bench, "context_benchmarks")

ann <- sum((1+p["rate"]/100)^-seq_len(p["years"]))
fraction <- p["share"] * p["backup"] / 10000
threshold <- function(d) {
  if (fraction == 0) return(rep(Inf,length(d)))
  (p["capital"] + ann*p["upkeep"] + d*p["workload"]*p["value"]) /
    (fraction*p["value"]*ann)
}
days <- 0:max(60,p["days"]); bound <- threshold(days)
save_table(data.frame(peak_workdays = days, annual_person_hours_at_break_even = bound), "retrofit_boundary")
base_h <- unname(p["events"]*p["people"]*p["delay"]/60)
chart("Fig2_break_even", function() {
  lim <- max(c(1000,base_h,bound[is.finite(bound)]))*1.2
  plot(NA,xlim=c(0,lim),ylim=range(days),xlab="Annual flood delay under current practice (person-hours)",ylab="Peak workdays",xaxs="i",yaxs="i")
  rect(0,0,lim,max(days),col="#FBEEE7",border=NA)
  if (all(is.finite(bound))) {
    polygon(c(bound,lim,lim),c(days,max(days),0),col="#DBEDE6",border=NA)
    lines(bound,days,col=navy,lwd=2)
  }
  points(base_h,p["days"],pch=21,bg=navy,col="white",cex=1.7)
  legend("topleft",c("Positive NPV","Negative NPV","Selected scenario"),pch=c(15,15,16),col=c("#9DCABA","#E4AF98",navy),bg="white",cex=.82)
})
eligible_value <- base_h * p["share"] / 100 * p["value"] * ann
required_eff <- if (eligible_value > 0) res$pv_cost / eligible_value else ifelse(res$pv_cost == 0,0,Inf)
save_table(data.frame(strategy=res$strategy, required_effectiveness_within_cause=required_eff,
                      attainable_at_or_below_100pct=required_eff <= 1), "required_effectiveness")
hours <- seq(0,max(10000,2*base_h),length.out=201)
sens <- do.call(rbind,lapply(hours,function(h) transform(evaluate(p,h),annual_delay_h=h)))
save_table(sens,"strategy_curves")
chart("Fig3_strategy_comparison",function(){
  plot(NA,xlim=range(hours),ylim=range(c(-1,1,sens$npv/1000)),xlab="Annual flood delay under current practice (person-hours)",ylab="Incremental NPV (thousand CNY)")
  abline(h=0,col=pale); abline(v=base_h,col="#A4AFB4",lty=3)
  for (i in 1:3) {
    d <- sens[sens$strategy==res$strategy[i],]
    lines(d$annual_delay_h,d$npv/1000,col=c(navy,teal,amber)[i],lwd=2.6)
    points(base_h,res$npv[i]/1000,pch=16,col=c(navy,teal,amber)[i])
  }
  legend("topleft",res$strategy,col=c(navy,teal,amber),lwd=2.6,bty="n",cex=.83)
})
# Write browser inputs directly from the same scenario table (no JSON package).
writeLines(c("window.PARAMS = [", paste(sprintf('["%s","%s","%s",%s,%s,%s,%s]', cfg$key,cfg$label,cfg$unit,cfg$default,cfg$min,cfg$max,cfg$step),collapse=",\n"), "];"),"docs/params.js")
writeLines(c(capture.output(sessionInfo())), "output/session.txt")
message("Finished. See output/ and open docs/index.html.")
