(function(){
const $=s=>document.querySelector(s),svg=p=>`<svg viewBox="0 0 24 24" aria-hidden="true">${p}</svg>`;
const I={
home:svg('<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>'),
meets:svg('<path d="M5 21V4m0 0h11l-2 4 2 4H5"/>'),
results:svg('<circle cx="12" cy="13.5" r="7.5"/><path d="M12 9.5v4l2.5 2M9.5 2.5h5"/>'),
progress:svg('<path d="m3 17 6-6 4 4 8-8M15 7h6v6"/>'),
more:svg('<rect x="4" y="4" width="6.5" height="6.5" rx="1.6"/><rect x="13.5" y="4" width="6.5" height="6.5" rx="1.6"/><rect x="4" y="13.5" width="6.5" height="6.5" rx="1.6"/><rect x="13.5" y="13.5" width="6.5" height="6.5" rx="1.6"/>'),
goals:svg('<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1"/>'),
family:svg('<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c.5-3.5 3-5.5 6.5-5.5s6 2 6.5 5.5M16 4.8a3.5 3.5 0 0 1 0 6.4M18 14.8c2 .6 3.3 2.4 3.5 5.2"/>'),
portal:svg('<path d="M12 20s-7.5-4.6-9-9.5C2 6.8 4.5 4 7.5 4c1.9 0 3.4 1 4.5 2.6C13.1 5 14.6 4 16.5 4c3 0 5.5 2.8 4.5 6.5-1.5 4.9-9 9.5-9 9.5z"/>'),
kid:svg('<path d="M2 9c2.5-2 4.5-2 7 0s4.5 2 7 0 4.5-2 6 0M2 16c2.5-2 4.5-2 7 0s4.5 2 7 0 4.5-2 6 0"/>'),
out:svg('<path d="M9 21H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h4M16 17l5-5-5-5M21 12H9"/>')};
const MAIN=[['home','Home'],['meets','Meets'],['results','Results'],['progress','Progress']];
const TITLES={meets:'Meets',results:'Results',goals:'Goals',family:'People & access'};
const SUB={goals:'Targets and time standards',family:'Swimmers, members, devices',portal:'Follow swimmers',kid:'The swimmer page'};
const dock=document.createElement('nav');dock.id='dock';dock.setAttribute('aria-label','Main');dock.hidden=true;
dock.innerHTML=MAIN.map(([k,l])=>`<button type="button" data-go="${k}">${I[k]}<span>${l}</span></button>`).join('')+`<button type="button" data-go="more">${I.more}<span>More</span></button>`;
document.body.appendChild(dock);
function go(tab){const b=$('#tabs [data-tab="'+tab+'"]');if(b){b.click();window.scrollTo(0,0)}}
function closeMore(){const m=$('#moreSheet');if(m)m.remove()}
function openMore(){closeMore();const tabs=[...document.querySelectorAll('#tabs button[data-tab]')].filter(b=>!MAIN.some(m=>m[0]===b.dataset.tab)&&!b.hidden);
const m=document.createElement('div');m.id='moreSheet';
m.innerHTML='<div class="panel"><div class="grab"></div>'+tabs.map(b=>`<button type="button" class="row2" data-go="${b.dataset.tab}">${I[b.dataset.tab]||''}<span>${b.textContent}<small>${SUB[b.dataset.tab]||''}</small></span></button>`).join('')+`<button type="button" class="row2 out" data-out>${I.out}<span>Sign out</span></button></div>`;
m.addEventListener('click',e=>{if(e.target===m){closeMore();return}const o=e.target.closest('[data-out]');if(o){closeMore();$('#logout')?.click();return}const g=e.target.closest('[data-go]');if(g){closeMore();go(g.dataset.go)}});
document.body.appendChild(m)}
dock.addEventListener('click',e=>{const b=e.target.closest('[data-go]');if(!b)return;b.dataset.go==='more'?openMore():(closeMore(),go(b.dataset.go))});
function sync(){const app=$('#app'),tabs=$('#tabs'),show=!!(app&&tabs&&!app.hidden&&!tabs.hidden);
dock.hidden=!show;document.body.classList.toggle('has-dock',show);if(!show)closeMore();
const act=$('#tabs button.active')?.dataset.tab||'home',inMain=MAIN.some(m=>m[0]===act);
dock.querySelectorAll('[data-go]').forEach(b=>b.classList.toggle('active',b.dataset.go===act||(b.dataset.go==='more'&&!inMain)));
const v=$('#view');if(v){if(TITLES[act]&&show)v.dataset.title=TITLES[act];else v.removeAttribute('data-title')}}
const mo=new MutationObserver(sync);
['#tabs','#app'].forEach(s=>{const n=$(s);if(n)mo.observe(n,{attributes:true,subtree:true,attributeFilter:['hidden','class'],childList:true})});
sync();
if('serviceWorker' in navigator&&location.protocol==='https:')addEventListener('load',()=>navigator.serviceWorker.register('sw.js').catch(()=>{}));
})();
