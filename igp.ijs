load 'format/printf'

spawn =:2!:0
fopen =: 1!:21
fwrite =: 1!:2
writenl =. '%s\n'&sprintf@:<@:[ fwrite ]
send =: writenl~

randstr =. ] , ":@:(?&10000)@:1:

tmpfiledir =: '/tmp/'

mkfifo =: monad define
 name =. tmpfiledir,(randstr y)
 (spawn 'mkfifo ',name)
 name ; (fopen <name)  
)

mainGnuPlot =: 0$0

ensureGnuPlot =: monad define 
if. mainGnuPlot -: 0$0 do.
	mainGnuPlot =: setupGnuPlot''
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

title =: verb define 
  ensureGnuPlot'' title y
  :
  'set title "%s"' (x gpfmt) <y
)

xlabel =: verb define 
  ensureGnuPlot'' xlabel y
  :
  'set xlabel "%s"' (x gpfmt) <y
)

ylabel =: verb define 
  ensureGnuPlot'' ylabel y
  :
  'set ylabel "%s"' (x gpfmt) <y
)

yrange =: verb define 
  ensureGnuPlot'' yrange y
  :
  'set yrange [%f:%f]' (x gpfmt) y
)

xrange =: verb define 
  ensureGnuPlot'' xrange y
  :
  'set xrange [%f:%f]' (x gpfmt) y
)

imagebody_raw =: dyad define 
  data =. ,>y
  'plot "%s" matrix with image' x gpfmt <data
)

image_raw =: verb define 
  ensureGnuPlot'' image y 
:
  x (imagebody withFilenames) <y
)


image =: verb define 
  ensureGnuPlot'' image y 
:
  smoutput (_0.5,((1{$y)-0.5))
  x xrange (_0.5,((1{$y)-0.5))
  x yrange (_0.5,((0{$y)-0.5))
  x size 'square'
  x (imagebody_raw withFilenames) <y
)

size =: dyad define 
 x size y
:
 'set size %s' x gpfmt <y
)
