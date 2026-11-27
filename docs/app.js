const fields=[
['events','每年中断次数','Disruptions per year','次','events',5,0,30,1],
['people','每次受影响人数','People per disruption','人','people',2000,100,10000,100],
['share','停电所致延误占比','Share of delay due to power loss','%','%',50,0,100,1],
['delay','每人额外出行时间','Extra travel per person','分钟','min',20,0,90,1],
['value','出行时间价值','Travel time value','元/人时','CNY/person-h',40,5,150,1],
['years','评价期','Planning horizon','年','yr',20,1,40,1],['rate','实际折现率','Real discount rate','%','%',4,0,12,.5],
['ready','待命可挽回的停电延误','Recoverable power-related delay: standby','%','%',30,0,100,1],
['backup','改造可挽回的停电延误','Recoverable power-related delay: retrofit','%','%',85,0,100,1],
['crew','每年新增待命费','Annual standby cost','元','CNY',15000,0,150000,500],
['capital','改造建设费','Retrofit capital cost','元','CNY',350000,0,3000000,5000],
['upkeep','每年新增维护费','Annual retrofit upkeep','元','CNY',10000,0,150000,500],
['days','高峰施工天数','Peak construction days','天','days',8,0,120,1],
['work','施工每日新增延误','Extra work-zone delay per day','人时','person-h',100,0,2000,10]];
const $=id=>document.getElementById(id),p={};let en=false;const T=(zh,english)=>en?english:zh;
const fmt=n=>Math.round(n).toLocaleString(en?'en-US':'zh-CN');
function defaults(){for(const [k,,,,,v] of fields)p[k]=v}
function calc(p){
 const H=p.events*p.people*p.delay/60,A=Array.from({length:p.years},(_,i)=>(1+p.rate/100)**-(i+1)).reduce((a,b)=>a+b,0);
 return [[0,0,0],[p.ready,p.crew,0],[p.backup,p.upkeep,p.capital+p.days*p.work*p.value]].map(([e,annual,initial])=>{
 const benefit=H*p.share*e/10000*p.value*A,cost=annual*A+initial;return {benefit,cost,npv:benefit-cost};});
}
function labels(){
 document.documentElement.lang=en?'en':'zh-CN';document.title=T('雨天通行 · 防涝决策','Rain Route · Flood decisions');
 for(const [id,zh,eng] of [
 ['lang','English','中文'],['title','下一笔防涝预算，花在哪里？','Where should the flood budget go?'],
 ['lead','为一处易涝桥区选择应对方案。拖动参数，看哪种方案节省的出行时间最值得投入。','Choose a response for a flood-prone bridge. Adjust the assumptions to see when travel-time savings cover the investment.'],
 ['inputsTitle','设定暴雨情景','Set the scenario'],['advanced','更多成本与模型参数','More costs and assumptions'],['reset','恢复默认情景','Reset scenario'],
 ['bestLabel','本情景下净收益最高','Highest net benefit in this scenario'],['ct','三种方案的净收益','Net benefit by strategy'],['method','模型如何计算？哪些是观测值？','Method and evidence'],['src','交通委处置记录','Transport authority record'],['src2','道路中断通报','Closure bulletin'],
 ['scope','景泰桥个案有断路及复通记录。滑块数值均为教学假设。年延误＝中断次数 × 每次人数 × 人均额外分钟 ÷ 60。仅计供电故障相关延误中可挽回的部分。按年末折现出行时间收益与新增维护费，期初计入建设费用及施工延误。人员安全、财产损失及其他防洪收益未货币化。','Jingtai Bridge has a documented closure and reopening. All sliders are teaching assumptions. Annual delay equals events × people × extra minutes / 60. Each intervention recovers a fraction of power-related delay. Annual travel savings and operating costs are discounted at year end; construction and its disruption enter at year zero. Safety and property effects are outside this valuation.']])$(id).textContent=T(zh,eng);
 $('basic').replaceChildren();$('other').replaceChildren();
 fields.forEach(([k,z,e,u,v,def,min,max,step],i)=>{const l=document.createElement('label');l.textContent=T(z,e);const o=document.createElement('output');o.id='o'+k;l.append(o);const s=document.createElement('input');s.type='range';s.min=min;s.max=max;s.step=step;s.value=p[k];s.setAttribute('aria-label',T(z,e));s.oninput=()=>{p[k]=+s.value;render()};l.append(s);$(i<3?'basic':'other').append(l)});render()
}
function render(){for(const [k,,,u,v] of fields)$('o'+k).value=p[k]+' '+T(u,v);
 const r=calc(p),names=[T('维持现状','Current practice'),T('提前待命','Standby'),T('备用电源','Backup power')],peak=Math.max(...r.map(v=>v.npv)),w=r.map((v,i)=>Math.abs(v.npv-peak)<.005?names[i]:null).filter(Boolean);
 $('best').textContent=w.join(' / ');$('net').textContent=T('相对现状净收益 ','Net benefit vs current practice: ')+fmt(peak)+T(' 元',' CNY');
 const cols=['#577077','#168378','#bf674e'],lo=Math.min(0,...r.map(v=>v.npv)),hi=Math.max(0,...r.map(v=>v.npv)),span=hi-lo||1,X=v=>142+262*(v-lo)/span;
 let g='<path stroke="#a4b4ae" d="M'+X(0)+' 8v142"/>';
 r.forEach((v,i)=>{let y=28+45*i,amount=(v.npv/(en?1000:10000)).toLocaleString(en?'en-US':'zh-CN',{maximumFractionDigits:1});g+='<text x="2" y="'+(y+6)+'">'+names[i]+'</text><rect x="'+Math.min(X(0),X(v.npv))+'" y="'+(y-8)+'" width="'+Math.max(2,Math.abs(X(0)-X(v.npv)))+'" height="16" fill="'+cols[i]+'"/><text x="530" y="'+(y+6)+'" text-anchor="end">'+amount+'</text>'});
 $('chart').innerHTML='<g font-size="17" fill="#193f40">'+g+'<text x="530" y="167" text-anchor="end" font-size="14">'+T('单位：万元','thousand CNY')+'</text></g>';$('chart').setAttribute('aria-label',$('ct').textContent);
 $('heads').innerHTML='<tr>'+[T('方案','Strategy'),T('收益','Benefit'),T('成本','Cost'),T('净收益','Net')].map(x=>'<th>'+x+'</th>').join('')+'</tr>';
 $('rows').innerHTML=r.map((v,i)=>'<tr><td>'+names[i]+'</td>'+[v.benefit,v.cost,v.npv].map(n=>'<td>'+(n/(en?1000:10000)).toLocaleString(en?'en-US':'zh-CN',{maximumFractionDigits:1})+'</td>').join('')+'</tr>').join('');
 $('explain').textContent=T('表中为评价期内折现总额（万元）。收益来自少耽误的出行时间；待命费、设备费和施工延误按方案计入成本。','Table: discounted totals in thousands of CNY. Benefits measure time saved; costs include standby, equipment or construction disruption as applicable.');
}
$('lang').onclick=()=>{en=!en;labels()};$('reset').onclick=()=>{defaults();labels()};defaults();labels();
