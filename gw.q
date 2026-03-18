/ Gateway process for querying rdb(s) / hdb(s)
/ .conf.GW_MODE can be
/ 1) `seamless (free form queries)
/ 2) `sync (query and wait for result)
/ 3) `async (requires a gwresponse callback to be defined on the caller)


if[not .qi.isproc;'"A gateway must be started as a process e.g. gw1"];
if[not(MODE:.qi.tosym .conf.GW_MODE)in`seamless`sync`asyc;'"Unrecognized .conf.GW_MODE"];

.qi.frompkg[`gw;MODE]

.gw.init:{
  if[not count .gw.DB::$[count db:.proc.self.options`point_to;(),`$db;exec name from .proc.self.mystack where pkg in`hdb`rdb];
    '"A gateway must be part of a stack with at least one rdb/hdb"];
  .gw.refreshmap[];
  /.gw.query "select avg open by sym from BinanceKline2s";
  }

.gw.dconns:{$[count n:where null c:.gw.DB!.ipc.conn each .gw.DB;'"Could not connect to ",","sv string n;c]}

.gw.refreshmap:{
  if[not count d:.gw.dconns`;()];
  tmap::`name xkey{[d;k] h:d k;update name:k from`d`t!$[k like"hdb*";h"(date;tables`)";((),.z.d;h"tables`")]}[d]each key d;
  pdates::ungroup select date:d,name from tmap;
  }

tcounts:{
  if[not count d:.gw.dconns`;:()];
  $[98=type r:raze{[d;k] `name`date xcols $[98<>type r:update name:k from d[k]"tcounts`";r;k like"hdb*";r;update date:.z.d from r]}[d]each key d;`date xasc r;r]
  }