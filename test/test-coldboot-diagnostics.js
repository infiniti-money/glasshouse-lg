/** Read-only startup diagnostics on webOS: missing hook and healthy hook. */
'use strict';
var assert=require('assert'),fs=require('fs'),os=require('os'),path=require('path'),cp=require('child_process');
// The fake filesystem uses recent Node test helpers; TV Node 0.10/0.12/8
// still exercise boot scripts through the separate compatibility checks.
if (Number(process.versions.node.split('.')[0]) < 16) {
  console.log('Cold boot diagnostics test skipped on Node <16');
  process.exit(0);
}
var root=fs.mkdtempSync(path.join(os.tmpdir(),'glasshouse-coldboot-'));
var sh=path.join(__dirname,'..','server','diagnose-startup.sh');
function put(file,data,mode) {
 var p=path.join(root,file); fs.mkdirSync(path.dirname(p),{recursive:true});
 fs.writeFileSync(p,data);if(mode)fs.chmodSync(p,mode);
 return p;
}
function run(){
 return cp.execFileSync('sh',[sh],{encoding:'utf8',env:Object.assign({},process.env,{GLASSHOUSE_DIAG_ROOT:root})});
}
try{
 cp.execFileSync('sh',['-n',sh]);
 var missing=run();
 assert.ok(/GLASSHOUSE HOOK: Không tồn tại/.test(missing));
 assert.ok(/Không tìm thấy dấu hiệu/.test(missing));
 assert.ok(!fs.existsSync(path.join(root,'var/lib/webosbrew/init.d/50-tvweb')),'must not create files');
 put('var/lib/webosbrew/startup.sh','# boot\n');
 put('tmp/webosbrew_startup','1\n');
 put('usr/bin/node','#!/bin/sh\n',493);
 put('var/lib/tvweb/tvweb.js','// mock\n');
 put('var/lib/tvweb/home.json','{"enabled":true,"privateToken":"DO_NOT_PRINT"}\n');
 put('var/lib/tvweb/tvwebctl','#!/bin/sh\necho running\n',493);
 put('var/lib/webosbrew/init.d/50-tvweb','#!/bin/sh\n',493);
 put('var/lib/webosbrew/tvweb-boot.log','secret?k=1234567890\nSun: starting\nSun: Glasshouse Home opened over com.webos.app.livetv\n');
 var healthy=run();
 assert.ok(/GLASSHOUSE HOOK: Có và có quyền thực thi/.test(healthy));
 assert.ok(/Đã chạy trong phiên/.test(healthy));
 assert.ok(/GLASSHOUSE HOME: Đã bật/.test(healthy));
 assert.ok(/running/.test(healthy));
 assert.ok(!/DO_NOT_PRINT|secret\?k=/.test(healthy),'do not reveal secrets');
 var hook=path.join(root,'var/lib/webosbrew/init.d/50-tvweb');
 fs.unlinkSync(hook);
 fs.symlinkSync('/does/not/exist',hook);
 var broken=run();
 assert.ok(/Liên kết hỏng/.test(broken));
 put('var/luna/preferences/webosbrew_failsafe','1\n');
 var failsafe=run();
 assert.ok(/FAILSAFE: ĐANG BẬT/.test(failsafe));
 console.log('Cold boot diagnostics: missing, healthy, broken symlink, failsafe and no writes passed');
} finally {fs.rmSync(root,{recursive:true,force:true});}
