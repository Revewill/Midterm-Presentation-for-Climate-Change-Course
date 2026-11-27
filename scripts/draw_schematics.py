import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyArrowPatch, Circle, Polygon, FancyBboxPatch
from pathlib import Path
out=Path(__file__).resolve().parents[1] / 'assets'
navy='#23424D'; teal='#207F79'; water='#B8DBE5'; soil='#F1E7D7'; road='#546777'; pale='#EFF5F1'; gold='#BE694F'
def block(x,y,w,h,c,edge='none',lw=1):
 ax.add_patch(Rectangle((x,y),w,h,facecolor=c,edgecolor=edge,lw=lw))
def line(xs,ys,c=navy,lw=2,ls='-'):ax.plot(xs,ys,color=c,lw=lw,ls=ls,solid_capstyle='round')
def arrow(x,y,X,Y,c=teal):ax.add_patch(FancyArrowPatch((x,y),(X,Y),arrowstyle='-|>',mutation_scale=19,lw=2.8,color=c))
def txt(x,y,s,size=13,c=navy):ax.text(x,y,s,fontsize=size,color=c,ha='center',va='center',linespacing=1.2)
def street(x,y,w):block(x,y,w,.35,road);line([x+.1,x+w-.1],[y+.175]*2,'white',1.1,'--')
def bus(x,y,c=gold):
 block(x,y,.88,.42,c)
 for i in range(3):block(x+.09+i*.25,y+.18,.18,.17,'#DCEBF0')
 for xx in [x+.17,x+.70]:ax.add_patch(Circle((xx,y),.09,fc=navy))
def tank(x,y,w,h):
 block(x,y,w,h,'white',navy,2);block(x+.035,y+.035,w-.07,.6*h,water)
def terrain():block(.4,1.45,9.2,2.05,soil);line([.4,9.6],[3.5,3.5],teal,1.8)
def new(loc,title,sub):
 global fig,ax
 fig,ax=plt.subplots(figsize=(12.8,7.2));fig.subplots_adjust(0,0,1,1);ax.set(xlim=(0,10),ylim=(0,6));ax.axis('off');fig.patch.set_facecolor('#FCFCF8')
 ax.text(.42,5.56,loc,fontsize=13,color=teal,fontweight='bold');ax.text(.42,5.06,title,fontsize=25,color=navy,fontweight='bold');ax.text(.42,4.66,sub,fontsize=13,color=road)
def save(fn,source):
 ax.text(.42,.34,'Conceptual diagram • not to scale',fontsize=10,color=road);ax.text(9.58,.34,source,fontsize=10,color=road,ha='right');fig.savefig(out/(fn+'.png'),dpi=375);plt.close(fig)
new('SINGAPORE  /  ORCHARD ROAD','Route part of the flow away upstream','The Stamford Diversion Canal redirects runoff towards the Singapore River.')
line([.8,4,8.9],[2.8,2.8,2.8],water,19);line([4,5.2,8.9],[2.8,1.5,1.5],water,16)
arrow(1,2.8,3.3,2.8);arrow(5.4,1.5,8.2,1.5);arrow(5.4,2.8,8.2,2.8)
street(5.7,3.25,3);bus(6.8,3.60)
txt(2,3.45,'Upstream catchment');txt(7.3,4.15,'Orchard Road');txt(7,2.33,'Stamford Canal');txt(7,.96,'Towards Singapore River')
save('05a_stamford_diversion','PUB  ·  Managing Urban Runoff')
new('HONG KONG, CHINA  /  HAPPY VALLEY','Store peak runoff beneath a recreation ground','An adjustable weir admits water to underground storage as the drainage channel rises.')
terrain();block(3.1,3.5,4.3,.15,'#A6C5A6');street(7.7,3.5,1.7);bus(8.1,3.85);tank(3.2,1.55,4,1.45)
line([.85,2.65,3.3],[2.75,2.75,2.2],water,10);arrow(1.1,2.75,2.55,2.75);arrow(7.25,2.18,9,2.18);txt(1.75,3.91,'Inlet channel');txt(5.15,3.93,'Playing fields');txt(5.18,2.22,'60,000 m³ storage');txt(8.25,1.66,'Later discharge',12)
save('05b_happy_valley','Drainage Services Department  ·  Happy Valley scheme')
new('UNITED KINGDOM  /  LOW PRUDHOE','Move part of the work off the road','The replacement pipe bypasses a collapsed culvert via the station car park.')
street(.8,2.35,8.4);bus(2,2.7);block(4,3.2,4.7,.9,pale,teal);txt(6.35,3.8,'Station car park');line([2.9,4.2,7.8,8.7],[2.37,3.42,3.42,2.37],teal,4)
txt(5.2,1.84,'Station Road');txt(5.1,1.12,'Road resurfacing still required scheduled overnight closures.',13);save('03a_prudhoe','Northumberland County Council  ·  May 2025')
new('JAPAN  /  SUSAKI, ROUTE 56','Keep the drainage pump powered','A standby power supply addresses the failure that stopped pumping during an earlier storm.')
terrain();line([.5,2.6,4,6,7.4,9.5],[3.5,3.5,2.15,2.15,3.5,3.5],road,7)
block(1.2,3.53,1.25,.55,pale,teal);txt(1.82,3.81,'Backup',11);line([1.85,1.85,5.8],[3.5,1.69,1.69],gold,2,'--')
ax.add_patch(Circle((6,1.7),.22,fc=teal));arrow(6.22,1.8,7.65,2.8);txt(5,2.56,'Underpass');txt(6.1,1.08,'Drainage pump')
save('03b_susaki','Japan Cabinet Secretariat  ·  Route 56 case')
new('UNITED STATES  /  NEW YORK CITY','Clear selected inlets before the storm','A forecast triggers inspection and clearing at known street-flooding locations.')
terrain();street(.5,3.48,7.7);block(6.45,3.45,.84,.37,navy)
for i in range(5):line([6.48+i*.16]*2,[3.49,3.79],'white',2)
tank(6.38,1.72,1,1.58);arrow(2.8,3.94,6.12,3.94);arrow(6.9,3.45,6.9,2.38);line([7.38,9.15],[2.01]*2,water,8);txt(3.3,3.03,'Street surface');txt(7,4.23,'Cleared grate');txt(4.05,1.18,'Prioritise locations where a blocked inlet interrupts travel.')
save('06a_nyc_inlets','NYC DEP and Office of the Comptroller')
new('MALAYSIA  /  KUALA LUMPUR','One tunnel, two operating states','The lowest drain can carry stormwater while the traffic decks remain open.')
for cx,full in [(2.8,False),(7.2,True)]:
 ax.add_patch(Circle((cx,2.64),1.33,fc=water if full else pale,ec=navy,lw=3))
 for dy in [-.35,.37]:line([cx-1.20,cx+1.20],[2.64+dy]*2,road,4)
 if not full:
  bus(cx-.42,3.08);bus(cx-.42,2.36);arrow(cx-.63,1.91,cx+.65,1.91)
 else:
  for yy in [2,2.63,3.29]:arrow(cx-.51,yy,cx+.6,yy)
 txt(cx,.95,'Mode 4  ·  traffic evacuated' if full else 'Mode 2  ·  vehicles continue',13)
save('06b_smart_tunnel','SMART Motorway Tunnel  ·  operational modes')
new('CHINA  /  BEIJING','Jingtai Bridge, Dongcheng','South Second Ring corridor • north–south flooding reported on 7 August 2026.')
street(.6,2.7,8.75);block(4.6,1.2,.7,3.0,road);line([4.95,4.95],[1.32,4.07],'white',1,'--')
ax.add_patch(Circle((4.95,2.87),.25,fc=gold,ec='white',lw=2,zorder=10));txt(2.02,3.27,'South Second Ring');txt(7.1,2.2,'Reported bridge area');line([5.24,6.15],[2.72,2.29],gold);arrow(8.8,3.58,8.8,4.18,navy);txt(8.8,4.35,'N')
txt(4.97,.94,'Intersection schematic; precise flood extent and detours unreported.',12)
save('02_jingtai_location','Beijing Municipal Commission of Transport')
