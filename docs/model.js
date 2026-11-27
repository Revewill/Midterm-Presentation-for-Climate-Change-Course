function compare(p) {
  let annuity = 0;
  for (let y = 1; y <= p.years; y++) annuity += (1 + p.rate / 100) ** -y;
  const hours = p.events * p.people * p.delay / 60;
  return [[0,0,0],[p.ready,p.crew,0],[p.backup,p.upkeep,p.capital + p.days*p.workload*p.value]].map(([eff,annual,initial]) => {
    const saved = hours*p.share*eff/10000;
    const benefit = saved*p.value*annuity, cost = initial + annual*annuity;
    return {saved,benefit,cost,npv:benefit-cost,initial,netFlow:saved*p.value-annual};
  });
}
