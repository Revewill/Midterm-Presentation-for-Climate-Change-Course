# Run after run.R from the road-lab directory.
out <- "output"
dest <- "figures"
dir.create(dest, showWarnings = FALSE)
load_table <- function(name) read.csv(file.path(out, paste0(name,".csv")),fileEncoding="UTF-8")
teal <- "#247D78"; navy <- "#203D4C"; coral <- "#AA5443"
slide <- function(name,title,sub,note,draw) {
  png(file.path(dest,paste0(name,".png")),4800,2700,res=375,pointsize=17)
  on.exit(dev.off())
  par(fig=c(.28,.92,.26,.75),mar=c(0,0,0,0),mgp=c(2,.6,0),xaxs="i",
      family="sans",col=navy,col.axis=navy,col.lab=navy,fg=navy)
  draw()
  par(fig=c(0,1,0,1),new=TRUE,mar=rep(0,4))
  plot.new();plot.window(c(0,1),c(0,1),xaxs="i",yaxs="i")
  text(.045,.92,title,adj=0,font=2,cex=1.6)
  text(.045,.835,sub,adj=0,cex=.98)
  text(.045,.05,note,adj=0,cex=.8)
}
horizontal <- function(values,labels,cols,xlab,dots=FALSE,digits=0){
  valid <- is.finite(values)
  if(!any(valid)){plot.new();text(.5,.5,"No finite threshold for this scenario");return()}
  values<-values[valid];labels<-labels[valid];cols<-rep_len(cols,length(valid))[valid]
  y<-rev(seq_along(values));limits<-range(0,values)
  span<-max(1,diff(limits));plot(NA,xlim=limits+c(-.02,.25)*span,
    ylim=c(.5,length(y)+.5),axes=FALSE,xlab="",ylab="")
  axis(1,cex.axis=.9);mtext(xlab,side=1,line=2,cex=.95)
  axis(2,at=y,labels=labels,tick=FALSE,las=1,cex.axis=1)
  segments(0,y,values,y,col=if(dots) "#CEE2DE" else cols,lwd=if(dots) 4 else 12,lend=1)
  if(dots)points(values,y,col=cols,pch=16,cex=1.35)
  text(values+.025*span,y,formatC(values,digits=digits,format="f",big.mark=","),adj=0,font=2)
}
e<-load_table("event_records");known<-e[is.finite(e$duration_min),]
known<-known[order(-known$duration_min),]
slide("Fig1_closures","How long did roads stay closed?","Beijing  /  7 August 2026",
  sprintf("Reopening times were reported for %d of the %d closures in the interim bulletin.",nrow(known),nrow(e)),
  function() horizontal(known$duration_min,sub(" Bridge","",known$location_en),
    ifelse(known$location_en=="Jingtai Bridge",coral,teal),"Reported closure (minutes)"))
b<-load_table("retrofit_boundary");b<-b[b$peak_workdays %in% c(0,8,30,60),]
slide("Fig2_break_even","When does backup power break even?","Required annual flood delay by construction schedule  /  selected scenario",
  "Above the labelled threshold, discounted time savings cover retrofit and disruption costs.",
  function() horizontal(b$annual_person_hours_at_break_even,paste(b$peak_workdays,"peak days"),teal,
    "Annual delay under current practice (person-hours)",TRUE))
r<-load_table("scenario_comparison")
slide("Fig3_net_benefit","What does each strategy return?","Discounted travel-time benefits less incremental costs  /  selected scenario",
  "All values are relative to current practice. Project-specific returns have not been measured.",
  function() horizontal(r$npv/1000,c("Current practice","Standby response","Backup power"),
    c(navy,teal,coral),"Net present value (thousand CNY)",digits=1))
