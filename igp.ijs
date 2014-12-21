load 'format/printf'

unboxedP =: -.@:L.
boxedP =: L.

always =: adverb define 
  y
  m
:
  x
  y
  m
)

nil =: (0$0)

rankOne =: 1: -: (#@:$)
rankTwo =: 2: -: (#@:$)
talliesEven =: 0: -: (2: | #)
twoColumns =: 2: -: 1&{@:$

opts =: monad define
  keysandvals =. y
  assert. rankOne keysandvals
  assert. talliesEven keysandvals
  ii =. 2 | (i. #y)
  keys =. (-. ii) # y
  vals =. ii # y
  keys (>@:[ ; ])"(0 0) vals
)

fullTally =: #@:,

cleanFind =: dyad define
  if. fullTally x -: 0 do.
   1
  else.
   x i. y
  end.
)

getoptdft =: monad define
  0$0
)
getopt =: dyad define
  options =. x
  key =. y
  assert. rankTwo options
  assert. twoColumns options
  if. 0 -: #options do.
   nil
  else. 
    ii =. ((i.&1)@:(((key&-:@:>)"0)@:(((0&{)@:|:)))) options
    if. ii < #options do.
      (>@:(ii&{)@:(1&{)@:|:) options
    else.
	  nil
    end.
  end.
)

dft =: conjunction define 
:
  r =. x u y
  if. r -: nil do.
   n
  else.
   r
  end.
)

spawn =:2!:0
fopen =: 1!:21
fwrite =: 1!:2
writenl =. '%s\n'&sprintf@:<@:[ fwrite ]
send =: writenl~

randstr =: ] , ":@:(?&10000)@:1:

tmpfiledir =: '/tmp/'

mkfifo =: monad define
 name =. tmpfiledir,(randstr y)
 (spawn 'mkfifo ',name)
 name ; (fopen <name)  
)

mainGnuPlot =: 0$0

ensureGnuPlot =: monad define 
if. mainGnuPlot -: 0$0 do.
	smoutput 'setting up new gnuplot'
	mainGnuPlot =: setupGnuPlot''
    mainGnuPlot
else.
	mainGnuPlot
end.
)

setupGnuPlot =: monad define
  'name fpr' =. mkfifo 'gnuplot'
  spawn ('gnuplot < ',name, ' &')
  fpr
)

reset =: 'reset'&writenl

gpfmt =: adverb define  
  :
  s =. (x sprintf y)
  smoutput 'Sending to gnuplot:'
  smoutput s
  s fwrite m
  ('\n' sprintf '') fwrite m
)

tmpfile =: monad define
  tmpfiledir,(randstr 'tmpjfile')
)

writeToTmp =: monad define
  'd f' =. y
  d fwrites f
)

withFilenames =: adverb define
  names =. (<@:tmpfile)"0 i. #y
  pairs =. y ,"0 names
  writeToTmp"1 pairs
  u names
  :
  names =. (<@:tmpfile)"0 i. #y
  pairs =. y ,"0 names
  writeToTmp"1 pairs
  x u ((<@:,@:>)"0 names)
)

asFiles =: monad define
  ] withFilenames y
)

asFile =: monad define
  name =. tmpfile''
  y fwrites name
  name
)

title =: verb define 
  (ensureGnuPlot'') title y
  :
  'set title "%s"' (x gpfmt) <y
)

xlabel =: verb define 
  (ensureGnuPlot'') xlabel y
  :
  'set xlabel "%s"' (x gpfmt) <y
)

ylabel =: verb define 
  (ensureGnuPlot'') ylabel y
  :
  'set ylabel "%s"' (x gpfmt) <y
)

yrange =: verb define 
  (ensureGnuPlot'') yrange y
  :
  'set yrange [%f:%f]' (x gpfmt) y
)

xrange =: verb define 
  (ensureGnuPlot'') xrange y
  :
  'set xrange [%f:%f]' (x gpfmt) y
)

imagebody_raw =: dyad define 
  data =. ,>y
  'plot "%s" matrix with image' x gpfmt <data
)

image_raw =: verb define 
  (ensureGnuPlot'') image y 
:
  x (imagebody withFilenames) <y
)


image =: verb define 
  (ensureGnuPlot'') image y 
:
  x xrange (_0.5,((1{$y)-0.5))
  x yrange (_0.5,((0{$y)-0.5))
  x size 'square'
  x (imagebody_raw withFilenames) <y
)

size =: dyad define 
 (ensureGnuPlot'') size y
:
 'set size %s' x gpfmt <y
)

saveScript =: 0 : 0
set terminal push
set terminal %s
set output "%s"
replot
set output
set terminal pop
)

getType =. >@:{:@:(<;._2)@:(,&'.'@:])

saveplot =: verb define
  (ensureGnuPlot'') saveplot y
:
  filename =. y
  type =. getType y
  saveScript x gpfmt (type;filename)
)

asVector =: (#@:,@:] , 1:) $ ,@:]

histogram =: verb define 
  (ensureGnuPlot'') histogram y
:
data =. y
if. boxedP x do.
 options =. x
 gph =. options getopt dft (ensureGnuPlot'') 'gnuplot'
else.
 gph =. x
 options =. (opt '')
end.
mn =. <./ data
mx =. >./ data 
bw =. options getopt dft (0.1&* mx-mn) 'binwidth'
pttl =. options getopt dft '' 'plot-title'
smoutput options getopt dft '___c' 'x'
smoutput (bw;pttl)
'binwidth=%f\n' gph gpfmt <bw
gph send 'set boxwidth binwidth'
gph send 'bin(x,width)=width*floor(x/width) + binwidth/2.0' 
s =. 'plot "%s" using (bin($1,binwidth)):(1.0) smooth freq title "%s" with boxes'
s gph gpfmt ((asFile (asVector data));pttl)
)
