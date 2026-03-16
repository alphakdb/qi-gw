/ Seamless gateway - allows free form queries
/ -> queries both rdb(s) and hdb(s)
/ e.g. select sum size by price by date from T where date within 2026.01.01 2026.01.10

query:{eval iquery $[10=type x;-5!x;x]}

iquery:{
  if[0<>type x;:x];
  a:.z.s each x;
  if[any first[a]~/:(?;!);
    if[count[a]within 4 6;
      a:process a]];
  a
  }

process:{
  a:x;
  tb:x 1; / table
  wc:raze x 2;  / where constraint
  if[not count db:`d xasc select from .gw.tmap where tb in't;'tb];
  if[hasdate:any dc:`date=wc[;1];
    if[0<>dc?1b;'"date must be the first constraint"];
    db:select from db where name in ?[.gw.pdates;1#wc;();`name]];
  if[not hasdate;db:delete from db where name like"hdb*"];
  mr:();oby:();oagg:key a 4;
  h:.ipc.conn each exec name from db;
  if[1<count db;
    if[0<count byc:a 3;
      oby:a 3;a[3]:0b;
      if[count m:first mr:.Q.ua a 4;
        a[4]:oby,m]]];
  r:raze{[hasdate;x;db] 
    h:.ipc.conn nm:db`name;
    a:$[hasdate&nm like"rdb*";.[x;(2;0);1_];x];
    h(eval;a)}[hasdate;a]each 0!db;
  $[count oby;?[r;();oby;mr 1];r]
  }