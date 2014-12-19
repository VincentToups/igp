load './igp.ijs'

heatmapbody =: dyad define
  g =. x
  data =. ,>y
  g send 'set view map' 
  g send 'set dgrid3d'
  'splot "%s" using 1:2:3 with pm3d' g gpfmt <data
)

gridToHeatmapData =: verb define
  xs =. i. 1 { $y
  ys =. i. 0 { $y
  (xs;ys) gridToHeatmapData y
:

  'xs ys' =. x 
  data =. y

  nxs =. #xs
  nys =. #ys

  xs =. (nys, nxs) $ xs
  ys =. |: ((nys, nxs) $ ys)

  l =. ((,ys) (,"(0 0)) (,data) )
  ((,xs)) (,"0 1) l

)

heatmap =: dyad define
  x heatmapbody withFilenames <(gridToHeatmapData y)
)

NB. gp =: setupGnuPlot''


NB. gp title 'testing title'
NB. gp xlabel 'test-x'
NB. gp ylabel 'test-y'
NB. gp xrange (0,3)
NB. gp heatmap (5 < (? (10 10 $ 10)))

title 'testing image'
xlabel 'test-x'
ylabel 'test-y'

image (5 < (? (10 10 $ 10)))

