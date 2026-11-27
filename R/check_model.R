# A zero-discount two-year fixture with hand-calculable costs.
fixture <- c(events=2,people=60,delay=30,value=10,years=2,rate=0,share=50,
             ready=20,backup=80,crew=30,capital=200,upkeep=10,days=2,workload=3)
stopifnot(isTRUE(all.equal(evaluate(fixture)$npv,c(0,60,200))))
fixture["share"] <- 0
stopifnot(all(evaluate(fixture)$annual_hours_saved == 0))
