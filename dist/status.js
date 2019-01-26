 (function(g){function k(a,c,b){var d=window.location.origin;this.cancelable=this.cancelBubble=this.bubbles=!1;this.data=c||null;this.origin=d||"";this.lastEventId=b||"";this.type=a||"message"}if(!g.EventSource||g.K){var l=(g.K||"")+"EventSource",e=function(a,c){if(!a||"string"!=typeof a)throw new SyntaxError("Not enough arguments");this.URL=a;this.R(c);var b=this;setTimeout(function(){b.G()},0)};e.prototype={CONNECTING:0,OPEN:1,CLOSED:2,w:{F:!1,N:"eventsource",interval:500,m:262144,o:3E5,f:{evs_buffer_size_limit:262144},
J:{Accept:"text/event-stream","Cache-Control":"no-cache","X-Requested-With":"XMLHttpRequest"}},R:function(a){var c=this.w,b;for(b in c)c.hasOwnProperty(b)&&(this[b]=c[b]);for(b in a)b in c&&a.hasOwnProperty(b)&&(this[b]=a[b]);this.f&&this.m&&(this.f.evs_buffer_size_limit=this.m);if("undefined"===typeof console||"undefined"===typeof console.log)this.F=!1},log:function(a){this.F&&console.log("["+this.N+"]:"+a)},G:function(){try{this.readyState!=this.CLOSED&&(this.v(),this.readyState=this.CONNECTING,
this.cursor=0,this.cache="",this.c=new this.h(this),this.H())}catch(a){this.log("There were errors inside the pool try-catch"),this.dispatchEvent("error",{type:"error",data:a.message})}},j:function(a){var c=this;c.readyState=c.CONNECTING;c.dispatchEvent("error",{type:"error",data:"Reconnecting "});this.i=setTimeout(function(){c.G()},a||0)},v:function(){this.log("evs cleaning up");this.i&&(clearInterval(this.i),this.i=null);this.g&&(clearInterval(this.g),this.g=null);this.c&&(this.c.abort(),this.c=
null)},H:function(){if(this.o){this.g&&clearInterval(this.g);var a=this;this.g=setTimeout(function(){a.log("Timeout! silentTImeout:"+a.o);a.j()},this.o)}},close:function(){this.readyState=this.CLOSED;this.log("Closing connection. readyState: "+this.readyState);this.v()},l:function(){var a=this.c;if(a.D()&&!a.B()){this.H();this.readyState==this.CONNECTING&&(this.readyState=this.OPEN,this.dispatchEvent("open",{type:"open"}));var c=a.A();c.length>this.m&&(this.log("buffer.length > this.bufferSizeLimit"),
this.j());0==this.cursor&&0<c.length&&"\ufeff"==c.substring(0,1)&&(this.cursor=1);var b=this.M(c);b[0]>=this.cursor&&(b=b[1],this.P(c.substring(this.cursor,b)),this.cursor=b);a.C()&&(this.log("request.isDone(). reopening the connection"),this.j(this.interval))}else this.readyState!==this.CLOSED&&(this.log("this.readyState !== this.CLOSED"),this.j(this.interval))},P:function(a){a=this.cache+this.O(a);a=a.split("\n\n");var c,b,d,e,f;for(c=0;c<a.length-1;c++){d="message";e=[];parts=a[c].split("\n");
for(b=0;b<parts.length;b++)f=this.S(parts[b]),0==f.indexOf("event")?d=f.replace(/event:?\s*/,""):0==f.indexOf("retry")?(f=parseInt(f.replace(/retry:?\s*/,"")),isNaN(f)||(this.interval=f)):0==f.indexOf("data")?e.push(f.replace(/data:?\s*/,"")):0==f.indexOf("id:")?this.lastEventId=f.replace(/id:?\s*/,""):0==f.indexOf("id")&&(this.lastEventId=null);e.length&&this.dispatchEvent(d,new k(d,e.join("\n"),this.lastEventId))}this.cache=a[a.length-1]},dispatchEvent:function(a,c){var b=this["_"+a+"Handlers"];
if(b)for(var d=0;d<b.length;d++)b[d].call(this,c);this["on"+a]&&this["on"+a].call(this,c)},addEventListener:function(a,c){this["_"+a+"Handlers"]||(this["_"+a+"Handlers"]=[]);this["_"+a+"Handlers"].push(c)},removeEventListener:function(a,c){var b=this["_"+a+"Handlers"];if(b)for(var d=b.length-1;0<=d;--d)if(b[d]===c){b.splice(d,1);break}},i:null,c:null,lastEventId:null,cache:"",cursor:0,onerror:null,onmessage:null,onopen:null,readyState:0,I:function(a,c){var b=[];if(c){var d,e,f=encodeURIComponent;
for(d in c)c.hasOwnProperty(d)&&(e=f(d)+"="+f(c[d]),b.push(e))}return 0<b.length?-1==a.indexOf("?")?a+"?"+b.join("&"):a+"&"+b.join("&"):a},M:function(a){var c=a.lastIndexOf("\n\n"),b=a.lastIndexOf("\r\r");a=a.lastIndexOf("\r\n\r\n");return a>Math.max(c,b)?[a,a+4]:[Math.max(c,b),Math.max(c,b)+2]},S:function(a){return a.replace(/^(\s|\u00A0)+|(\s|\u00A0)+$/g,"")},O:function(a){return a.replace(/\r\n|\r/g,"\n")}};if(window.XDomainRequest&&window.XMLHttpRequest&&void 0===(new XMLHttpRequest).responseType){e.L=
"IE_8-9";var h=e.prototype.w;h.J=null;h.f.evs_preamble=2056;e.prototype.h=function(a){this.a=request=new XDomainRequest;request.onprogress=function(){request.u=!0;a.l()};request.onload=function(){this.s=!0;a.l()};request.onerror=function(){this.b=!0;a.readyState=a.CLOSED;a.dispatchEvent("error",{type:"error",data:"XDomainRequest error"})};request.ontimeout=function(){this.b=!0;a.readyState=a.CLOSED;a.dispatchEvent("error",{type:"error",data:"XDomainRequest timed out"})};var c={};if(a.f){var b=a.f,
d;for(d in b)b.hasOwnProperty(d)&&(c[d]=b[d]);a.lastEventId&&(c.evs_last_event_id=a.lastEventId)}request.open("GET",a.I(a.URL,c));request.send()};e.prototype.h.prototype={a:null,u:!1,s:!1,b:!1,D:function(){return this.a.u},C:function(){return this.a.s},B:function(){return this.a.b},A:function(){var a="";try{a=this.a.responseText||""}catch(c){}return a},abort:function(){this.a&&this.a.abort()}}}else e.L="XHR",e.prototype.h=function(a){this.a=request=new XMLHttpRequest;a.c=this;request.onreadystatechange=
function(){1<request.readyState&&a.readyState!=a.CLOSED&&(200==request.status||300<=request.status&&400>request.status?a.l():(request.b=!0,a.readyState=a.CLOSED,a.dispatchEvent("error",{type:"error",data:"The server responded with "+request.status}),a.close()))};request.onprogress=function(){};request.open("GET",a.I(a.URL,a.f),!0);var c=a.J,b;for(b in c)c.hasOwnProperty(b)&&request.setRequestHeader(b,c[b]);a.lastEventId&&request.setRequestHeader("Last-Event-Id",a.lastEventId);request.send()},e.prototype.h.prototype=
{a:null,b:!1,D:function(){return 2<=this.a.readyState},C:function(){return 4==this.a.readyState},B:function(){return this.b||400<=this.a.status},A:function(){var a="";try{a=this.a.responseText||""}catch(c){}return a},abort:function(){this.a&&this.a.abort()}};g[l]=e}})(this);

var indexOf=[].indexOf,status={main:{}};window.Status||(window.Status={});
window.Status.Widget=function(){var u,n,v,w,x,t,y,p,m,g,z,e,l,A,q,r,d=function(a){a=void 0===a?{}:a;var b=this,c,f,d;this.errorListener=this.errorListener.bind(this);this.openListener=this.openListener.bind(this);this.basicEventListener=this.basicEventListener.bind(this);this.initListener=this.initListener.bind(this);this.issueCreatedListener=this.issueCreatedListener.bind(this);this.issueUpdatedListener=this.issueUpdatedListener.bind(this);this.issueResolvedListener=this.issueResolvedListener.bind(this);
this.issueReopenedListener=this.issueReopenedListener.bind(this);this.options=a;d=["hostname","selector"];f=null==this.options;a=0;for(c=d.length;a<c;a++)f=d[a],f=!(f in this.options);this.options==={}||f?r("Options missing or invalid"):(a={ssl:!0,css:!0,debug:!1,outOfOffice:!1,linkTarget:"_blank",display:{hideOnError:!0,pane:!0,paneStatistics:!0,ledOnly:!1,panePosition:"bottom-right",ledPosition:"left",statistic:{uptimeDecimals:4,minIncidentFreeStreak:86400},outOfOffice:{resetStatusLed:!1}},i18n:{heading:"Issues",
toggle:"${state}",loading:"Loading status...",error:"Connection error",statistic:{streak:"No events for ${duration}!",uptime:"${percent}% Uptime"},issue:{scheduled:"Scheduled",empty:{operational:"There are currently no reported issues.",degraded:"There are currently no reported issues, but we have detected that at least one component is degraded.",outage:"There are currently no reported issues, but we have detected outages on at least one component."}},state:{outOfOffice:"Out of Office"},linkBack:"View Status Page",
time:{distanceInWords:{halfAMinute:"half a minute",lessThanXSeconds:{one:"less than 1 second",other:"less than ${count} seconds"},xSeconds:{one:"1 second",other:"${count} seconds"},lessThanXMinutes:{one:"less than a minute",other:"less than ${count} minutes"},xMinutes:{one:"1 minute",other:"${count} minutes"},aboutXHours:{one:"about 1 hour",other:"about ${count} hours"},xDays:{one:"1 day",other:"${count} days"},aboutXMonths:{one:"about 1 month",other:"about ${count} months"},xMonths:{one:"1 month",
other:"${count} months"},aboutXYears:{one:"about 1 year",other:"about ${count} years"},overXYears:{one:"over 1 year",other:"over ${count} years"},almostXYears:{one:"almost 1 year",other:"almost ${count} years"}}}}},this.options=t(a,this.options),this.debug=this.options.debug,this.hostname=this.options.hostname,this.display=this.options.display,this.i18n=this.options.i18n,this.outOfOffice=this.display.outOfOffice,/^https?:\/\//i.test(this.hostname)||(a=this.options.ssl?"https":"http",this.hostname=
a+"://"+this.hostname),this.issues={},this.visibleIssues=[],this.ready(function(){return b.attachWidget()}))};d.prototype.ready=function(a){return"loading"!==document.readyState?a():document.addEventListener("DOMContentLoaded",a)};d.prototype.injectStyles=function(){var a;a=document.createElement("link");a.rel="stylesheet";a.href="https://libraries.hund.io/status-js/status-"+u+".css";return document.head.appendChild(a)};d.prototype.attachWidget=function(){var a;this.elements={};a=this.options.selector;
this.elements.widget=document.querySelector(a);if(null===this.elements.widget)r("Unable to find element with selector: "+a);else if(this.setVisibility("hidden"),this.options.css&&this.injectStyles(),this.connect(),n(this.elements.widget,"status-widget"),this.elements.led=this.createEl("span",this.elements.widget,"led"),this.display.ledOnly||(this.elements.state=this.createEl("span",this.elements.widget,"state"),e(this.elements.state,this.i18n.loading)),this.officeHoursTimeout(),"left"!==this.display.ledPosition&&
this.elements.widget.appendChild(this.elements.led),this.elements.pane=this.createEl("div",this.elements.widget,"pane"),g(this.elements.pane,"open",!1),g(this.elements.pane,"position",this.display.panePosition),this.elements.paneHeader=this.createEl("div",this.elements.pane,"pane__header"),this.elements.paneHeading=this.createEl("strong",this.elements.paneHeader,"pane__heading"),e(this.elements.paneHeading,this.i18n.heading),this.display.paneStatistics&&(this.elements.paneStatistics=this.createEl("div",
this.elements.paneHeader,"pane_statistics"),this.elements.statisticUptime=this.buildStatistic(),this.elements.statisticStreak=this.buildStatistic()),this.elements.paneContainer=this.createEl("div",this.elements.pane,"pane__container"),this.elements.paneText=this.createEl("span",this.elements.paneContainer,"pane__text"),e(this.elements.paneText,this.i18n.loading),this.elements.paneFooter=this.createEl("a",this.elements.pane,"pane__footer"),this.buildLink(this.elements.paneFooter,this.hostname),e(this.elements.paneFooter,
this.i18n.linkBack),this.display.pane){var b=this;n(this.elements.widget,"status-widget--pane-enabled");window.addEventListener("resize",this.debounce(this.alignPane,250));this.elements.widget.addEventListener("click",function(a){a.preventDefault();a.stopPropagation();return g(b.elements.pane,"open","false"===b.elements.pane.dataset.open)},!1);this.elements.pane.addEventListener("click",function(a){return a.stopPropagation()});return document.addEventListener("click",function(a){if(b.elements.pane.dataset.open)return g(b.elements.pane,
"open",!1)},!1)}};d.prototype.setVisibility=function(a){return this.elements.widget.style.visibility=a};d.prototype.connect=function(){var a;return window.EventSource?(a=this.hostname+"/live/v2/",a=null!=this.options.component?a+("component/"+this.options.component):a+"status_page",this.source=new window.EventSource(a),this.source.onerror=this.errorListener,this.source.onopen=this.openListener,this.addEventListeners()):m("Browser unsupported")};d.prototype.reconnect=function(a){a=void 0===a?0:a;var b=
this;clearTimeout(this.reconnectTimer);return this.reconnectTimer=setTimeout(function(){b.source.close();return b.connect()},a)};d.prototype.errorListener=function(){var a;0<this.reconnectAttempt||(this.reconnectAttempt=0);a=v(this.reconnectAttempt);this.debug&&m("Reconnecting in "+a+"ms");this.reconnect(a);this.reconnectAttempt+=1;g(this.elements.led,"state","pending");if(!this.display.hideOnError&&(this.setVisibility("visible"),a=1E4<a?this.i18n.error:this.i18n.loading,this.elements.state))return e(this.elements.state,
a)};d.prototype.openListener=function(){this.reconnectAttempt=0;m("Connected");return this.setVisibility("visible")};d.prototype.addEventListeners=function(){var a,b,c,f;b={init_event:this.initListener,status_created:this.basicEventListener,degraded:this.basicEventListener,restored:this.basicEventListener,issue_created:this.issueCreatedListener,issue_updated:this.issueUpdatedListener,issue_resolved:this.issueResolvedListener,issue_reopened:this.issueReopenedListener,issue_cancelled:this.issueResolvedListener,
issue_started:this.issueCreatedListener,issue_ended:this.issueResolvedListener,cache_grown:this.basicEventListener,cache_rebuilt:this.basicEventListener};f=[];for(a in b)c=b[a],f.push(this.source.addEventListener(a,c,!1));return f};d.prototype.basicEventListener=function(a){return this.parseBasicEventData(a)};d.prototype.initListener=function(a){var b,c,f;a=this.parseBasicEventData(a);if("issues"in a)for(this.issues={},this.visibleIssues=[],f=a.issues,a=0,c=f.length;a<c;a++)b=f[a],this.insertIssue(b);
return this.updateIssues()};d.prototype.issueCreatedListener=function(a){a=this.parseBasicEventData(a);"issue"in a&&(a.issue.updates=[],this.insertIssue(a.issue));return this.updateIssues()};d.prototype.issueUpdatedListener=function(a){var b;a=this.parseBasicEventData(a);if("update"in a&&(b=a.update.issue_id,b in this.issues))return this.issues[b].updates.unshift(a.update),this.updateIssues()};d.prototype.issueResolvedListener=function(a){var b;a=this.parseBasicEventData(a);b="";"update"in a?b=a.update.issue_id:
"issue"in a&&(b=a.issue.id);if(b in this.issues)return this.removeIssue(b),this.updateIssues()};d.prototype.issueReopenedListener=function(a){a=this.parseBasicEventData(a);"update"in a&&this.insertIssue(a.update.issue);return this.updateIssues()};d.prototype.parse=function(a){try{if("data"in a)return JSON.parse(a.data)}catch(b){r("Received invalid event payload")}return{}};d.prototype.parseBasicEventData=function(a){a=this.parse(a);this.humanData={state:this.humanState(a.state),percentUptime:this.humanPercentUptime(a.percent_uptime),
incidentFreeStreak:this.humanIncidentFreeStreak(a.incident_free_streak)};this.updateState(a.state);this.updatePercentUptime(a.percent_uptime,this.humanData.percentUptime);this.updateIncidentFreeStreak(a.incident_free_streak,this.humanData.incidentFreeStreak);this.updateToggle(this.humanData);return a};d.prototype.updateState=function(a){null==a&&(a="pending");this.isOutOfOffice()?g(this.elements.led,"state","pending"):g(this.elements.led,"state",a);this.state=a;return this.updateIssuePaneText()};
d.prototype.updateToggle=function(a){var b;if(null!=this.elements.state)return this.stateText=b=l(this.i18n.toggle,a),this.isOutOfOffice()&&(a=Object.assign({},a),a.state=this.humanState("outOfOffice"),b=l(this.i18n.toggle,a)),e(this.elements.state,b),this.alignPane()};d.prototype.updatePercentUptime=function(a,b){if(this.elements.statisticUptime)return e(this.elements.statisticUptime,b)};d.prototype.updateIncidentFreeStreak=function(a,b){var c;if(this.elements.statisticStreak)return c=this.incidentFreeStreakLessThanMin(a),
this.toggleStatistic(this.elements.statisticStreak,c),e(this.elements.statisticStreak,b)};d.prototype.updateIssues=function(){var a,b,c,f,d;null!=this.elements.paneIssues&&this.elements.paneContainer.removeChild(this.elements.paneIssues);this.elements.paneIssues=this.createEl("div",this.elements.paneContainer,"pane__issues");if(this.issuesPresent()){g(this.elements.paneText,"hidden",!0);f=this.visibleIssues;d=[];a=0;for(c=f.length;a<c;a++)b=f[a],b in this.issues&&d.push(this.createIssue(this.issues[b]));
return d}this.updateIssuePaneText()};d.prototype.updateIssuePaneText=function(){if(!this.issuesPresent())return e(this.elements.paneText,this.i18n.issue.empty[this.state])};d.prototype.humanState=function(a){var b;null==a&&(a="pending");b=a;"state"in this.i18n&&a in this.i18n.state&&(b=this.i18n.state[a]);return b};d.prototype.humanPercentUptime=function(a){var b;b=w(this.display.statistic.uptimeDecimals,0,10);a=+parseFloat(a).toFixed(b);return l(this.i18n.statistic.uptime,{percent:a})};d.prototype.humanIncidentFreeStreak=
function(a){return this.incidentFreeStreakLessThanMin(a)?"":l(this.i18n.statistic.streak,{duration:this.distanceInWords(Math.floor(new Date/1E3)-a)})};d.prototype.insertIssue=function(a){var b;b=a.id;this.issues[b]=a;if(!(0<=indexOf.call(this.visibleIssues,b)))return this.visibleIssues.splice(this.issuePosition(b),0,b)};d.prototype.removeIssue=function(a){delete this.issues[a];if(!(0>indexOf.call(this.visibleIssues,a)))return this.visibleIssues.splice(this.visibleIssues.indexOf(a),1)};d.prototype.createIssue=
function(a){var b,c,f,d;b=this.createEl("div",this.elements.paneIssues,"issue");c=this.issueData(a);c={components:{el:"strong",text:a.components.map(function(a){return a.name}).join(", ")},title:{el:"a",text:a.title+": "},body:{el:"p",html:c.body},label:{el:"span",text:c.label},time:{el:"span",text:c.date}};for(f in c)d=c[f],c[f]=this.createEl(d.el,b,"issue__"+f),"html"in d?z(c[f],d.html):e(c[f],d.text);return this.buildLink(c.title,this.hostname+"/issues/"+a.id)};d.prototype.issueData=function(a){var b,
c,f,d,e;e=!!a.standing;d=!!a.scheduled;b=0<a.updates.length;d&&(e||(f=this.i18n.issue.scheduled),c=a.starts_at);b&&(a=a.updates[0]);b=a.body;e&&(f=a.label);d||(c=a.created_at);c=new Date(1E3*c);A()&&"dates"in this.i18n?(a=this.i18n.dates,c=c.toLocaleString(a.locale,a.options)):c=c.toLocaleString();return{body:b,label:f,date:c}};d.prototype.issuePosition=function(a){var b,c,d,e,g,k,h;e=Math.floor(Date.now()/1E3);h={past:[],future:[]};d=0;g=this.issues;for(b in g)c=g[b],k=(k=!!c.scheduled)?c.starts_at:
c.created_at,h[k>e?"future":"past"].push(k),c.id===a&&(d=k);return 0<=indexOf.call(h.future,d)?h.future.sort().indexOf(d)+h.past.length:h.past.sort().reverse().indexOf(d)};d.prototype.issuesPresent=function(){return 0!==Object.keys(this.issues).length};d.prototype.incidentFreeStreakLessThanMin=function(a){return a<Math.max(0,this.display.statistic.minIncidentFreeStreak)};d.prototype.createEl=function(a,b,c){var d;d="status-widget";null!=c&&(d+="__"+c);return x(a,d,b)};d.prototype.buildLink=function(a,
b){a.href=b;a.target=this.options.linkTarget;a.rel="noopener";return a};d.prototype.buildStatistic=function(){return this.createEl("span",this.elements.paneStatistics,"pane_statistic")};d.prototype.toggleStatistic=function(a,b){return g(a,"hidden",b)};d.prototype.alignPane=function(){var a;a=this.elements.led.offsetLeft;y(this.display.panePosition,"left")?(a-=this.elements.pane.offsetWidth,a+=20+this.elements.led.offsetWidth):a-=20;return this.elements.pane.style.left=a+"px"};d.prototype.resetState=
function(){if(null!=this.state&&null!=this.humanData)return this.updateState(this.state),this.updateToggle(this.humanData)};d.prototype.officeHoursTimeout=function(){var a=this,b,c;b=q().getTime();c=this.officeOpenTimestamp()-b;b=this.officeCloseTimestamp()-b;return setTimeout(function(){a.resetState();return a.officeHoursTimeout()},c<b?c:b)};d.prototype.isOutOfOffice=function(){var a;if(!this.options.outOfOffice)return!1;a=q().getTime();return!(this.officeOpenTimestamp()<=a&&a<=this.officeCloseTimestamp())};
d.prototype.officeOpenTimestamp=function(){return this.officeHourToTimestamp("officeOpenHour")};d.prototype.officeCloseTimestamp=function(){return this.officeHourToTimestamp("officeCloseHour")};d.prototype.officeHourToTimestamp=function(a){var b,c;c=this.outOfOffice[a];a="officeCloseHour"===a&&this.officeHoursOverlapDays();if(window.moment)return b=moment().tz(this.outOfOffice.timezone).startOf("day").add(c,"h"),a&&b.add(1,"d"),b.valueOf();b=q();a&&b.setDate(b.getDate()+1);return b.setHours(c,0,0,
0)};d.prototype.officeHoursOverlapDays=function(){return this.outOfOffice.officeOpenHour<this.outOfOffice.officeCloseHour};d.prototype.debounce=function(a,b,c){var d=this,e;e=null;return function(g){for(var k=[],h=0;h<arguments.length;++h)k[h-0]=arguments[h];e?clearTimeout(e):c&&a.apply(d,k);return e=setTimeout(function(){c||a.apply(d,k);return e=null},b||100)}};d.prototype.distanceInWords=function(a,b){b=void 0===b?Math.floor(new Date/1E3):b;var c,d;a>b&&(b=a=b);d=b-a;c=Math.round(d/60);switch(!1){case !(0<=
c&&1>=c):switch(!1){case !(0<=d&&4>=d):return this.timeT("lessThanXSeconds",5);case !(5<=d&&9>=d):return this.timeT("lessThanXSeconds",10);case !(10<=d&&19>=d):return this.timeT("lessThanXSeconds",20);case !(20<=d&&39>=d):return this.timeT("halfAMinute");case !(40<=d&&59>=d):return this.timeT("lessThanXMinutes",1);default:return this.timeT("xMinutes",1)}case !(2<=c&&45>=c):return this.timeT("xMinutes",c);case !(45<=c&&90>=c):return this.timeT("aboutXHours",1);case !(90<=c&&1440>=c):return this.timeT("aboutXHours",
Math.round(c/60));case !(1440<=c&&2520>=c):return this.timeT("xDays",1);case !(2520<=c&&43200>=c):return this.timeT("xDays",Math.round(c/1440));case !(43200<=c&&86400>=c):return this.timeT("aboutXMonths",Math.round(c/43200));case !(86400<=c&&525600>=c):return this.timeT("xMonths",Math.round(c/43200));default:return d=c%525600,c=Math.floor(c/525600),131400>d?this.timeT("aboutXYears",c):394200>d?this.timeT("overXYears",c):this.timeT("almostXYears",c+1)}};d.prototype.timeT=function(a,b){b=void 0===b?
null:b;var c;a in this.i18n.time.distanceInWords&&(c=this.i18n.time.distanceInWords[a]);if(null!=c){if("object"===typeof c){if(null==b)return;c=c[1===b?"one":"other"]}return null==b?c:l(c,{count:b})}};u="3.8.0";n=function(a,b){a.classList?a.classList.add(b):a.className+=" "+b;return a};x=function(a,b,c){a=document.createElement(a);n(a,b);c.appendChild(a);return a};e=function(a,b){return void 0!==typeof a.textContent?a.textContent=b:a.innerText=b};z=function(a,b){return a.innerHTML=b};g=function(a,
b,c){return a.setAttribute("data-"+b,c)};A=function(){try{(new Date).toLocaleString("i")}catch(a){return a instanceof RangeError}return!1};y=function(a,b){return-1!==a.indexOf(b,a.length-b.length)};v=function(a,b,c){b=void 0===b?100:b;c=void 0===c?6E4:c;return Math.max(Math.min(1E3*p(a),c),b)};p=function(a){return 2>a?a:p(a-1)+p(a-2)};w=function(a,b,c){return a<=b?b:a>=c?c:a};q=function(){var a;a=new Date;return new Date(a.getTime()+6E4*a.getTimezoneOffset())};t=function(a,b){var c,d,e,g,k,h,l;c=
{};k=Object.keys(a).concat(Object.keys(b));d=0;for(g=k.length;d<g;d++)e=k[d],l=a[e],h=b[e],c[e]=null!=h?"object"===typeof h?t(l||{},h||{}):h:l;return c};l=function(a,b){return a.replace(/\${(\w+)}/g,function(a,d){return b[d]})};m=function(a,b){return console[void 0===b?"log":b]("[Status Widget] "+a)};r=function(a){return m(a,"warn")};return d}.call(this);window.Status=window.Status;window.Status.Widget=window.Status.Widget;
