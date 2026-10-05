const fs=require('fs'),vm=require('vm'),assert=require('assert');
(async()=>{for(const scenario of ['foreground','background','failure','stop','two']){
 const events=[],prompts=[],nodes=new Map(),records=new Map();let saved={},ctx;
 const node=id=>{if(!nodes.has(id))nodes.set(id,{value:id==='target'?'all':'',checked:scenario!=='background',disabled:false,textContent:''});return nodes.get(id);};
 const participants=scenario==='two'?['ChatGPT','Grok']:['ChatGPT','Grok','Gemini'];
 const chrome={storage:{local:{get:async key=>key==='foreground'?{foreground:scenario!=='background'}:key==='sharedBrief'?{sharedBrief:'User wants practical ideas.'}:{},set:async data=>{saved={...saved,...JSON.parse(JSON.stringify(data))};}}},tabs:{getCurrent:async()=>({id:99}),get:async id=>({id,windowId:1}),update:async id=>events.push('focus:'+id),sendMessage:async(id,m)=>{
 if(m.type==='start'){const stage=m.requestId.split('-')[1];prompts.push({stage,id,prompt:m.prompt});events.push('start:'+stage+':'+id);records.set(m.requestId,{stage,id});return {ok:true};}
 const {stage}=records.get(m.requestId);events.push('done:'+stage+':'+id);
 if(scenario==='failure'&&stage==='Discuss'&&id===2)return {pending:false,ok:false,error:'timeout'};
 if(scenario==='stop'&&stage==='Propose'){ctx.cancelTestRound();return {pending:true};}
 return {pending:false,ok:true,sent:true,conversation:'/c/test',text:stage==='Finalize'?'One combined answer.\n===COUNCIL_BRIEF===\nGoal and open questions.':stage+' contribution from '+id};
 }},windows:{update:async()=>{}}};
 const document={getElementById:node,querySelectorAll:s=>s==='[data-name]:checked'?participants.map(name=>({dataset:{name}})):[]};
 ctx={chrome,document,crypto:{randomUUID:()=> 'round'},setTimeout:f=>{f();return 1;},clearTimeout(){},console};vm.createContext(ctx);
 let source=fs.readFileSync('council/room.js','utf8').split("$('form').addEventListener")[0];source+='\nglobalThis.cancelTestRound=()=>{roundId=null;};render=()=>{};connections={ChatGPT:1,Grok:2,Gemini:3};await run("Invent a useful idea.");globalThis.result={messages,sharedBrief,busy};';
 await vm.runInContext('(async()=>{'+source+'})()',ctx);
 const result=ctx.result,card=result.messages.at(-1);
 assert.equal(result.messages.length,2);assert.equal(card.role,'Council');
 if(scenario==='failure'||scenario==='stop'){assert.equal(card.state,'interrupted');assert(!prompts.some(p=>p.stage==='Finalize'));assert(card.work.length>0||scenario==='stop');}
 else{
 assert.equal(card.state,'complete');assert.equal(card.text,'One combined answer.');assert.equal(result.sharedBrief,'Goal and open questions.');assert.equal(prompts.length,scenario==='two'?7:10);assert.equal(result.busy,false);
 assert.equal(prompts.filter(p=>p.stage==='Finalize').length,1);assert.equal(prompts.find(p=>p.stage==='Finalize').id,2);
 for(const p of prompts.filter(p=>p.stage==='Discuss'))for(const id of participants.map(n=>({ChatGPT:1,Grok:2,Gemini:3})[n]))assert(p.prompt.includes('Propose contribution from '+id));
 assert(prompts.find(p=>p.stage==='Finalize').prompt.includes('Review contribution from 1'));
 assert(events.indexOf('start:Discuss:1')>Math.max(...participants.map(n=>events.indexOf('done:Propose:'+({ChatGPT:1,Grok:2,Gemini:3})[n]))));
 if(scenario!=='background')assert.equal(events.at(-1),'focus:99');else assert(!events.some(x=>x.startsWith('focus:')));
 }
 assert.equal(saved.messages.at(-1).state,card.state);
 }
 console.log('PASS: shared phase barriers, draft reviews, single final, brief, two/three models, background/foreground, failure and Stop');
})();
