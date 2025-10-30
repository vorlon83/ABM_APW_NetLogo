;; Define global variables
globals [total-apw month sea-contamination]  ;; Total agricultural plastic waste generated, current month, and sea contamination

;; Define the land types, plastic types, and their respective APW generation rates (kg/month for different seasons)
turtles-own [land-type plastic-type degradation-rate apw-rate apw-generated]

;; Setup procedure to initialize the model
to setup
  clear-all

  ;; Create a 10x10 grid of patches with random land types
  ask patches [
    if pxcor = max-pxcor or pycor = min-pycor [
      ;; If the patch is at the rightmost column or bottom row, set it as sea
      set pcolor blue
    ]
    if not (pxcor = max-pxcor or pycor = min-pycor) [
      ;; Create a turtle (agent) on each non-sea patch to represent the land type
      sprout 1 [
        setxy pxcor pycor
        set land-type one-of ["Olive Groves" "Vineyards" "Greenhouses" "Pasture Land" "Ornamental" "Vegetables" "Cereals" "Orchards" "Nurseries" "Other"]

        ;; If the land type is Greenhouses, assign a random plastic type and corresponding degradation rate
        if land-type = "Greenhouses" [
          set plastic-type one-of ["Plastic A" "Plastic B" "Plastic C" "Biodegradable Covering"]

          ;; Set degradation rates based on eco-friendliness
          if plastic-type = "Plastic A" [ set degradation-rate 0.1 ]  ;; 10% degradation per year
          if plastic-type = "Plastic B" [ set degradation-rate 0.33 ]  ;; 33% degradation per year
          if plastic-type = "Plastic C" [ set degradation-rate 0.5 ]  ;; 50% degradation per year
          if plastic-type = "Biodegradable Covering" [ set degradation-rate 0.9 ]  ;; 90% degradation per year
        ]

        set apw-generated 0
        set shape "square"  ;; Set the turtle shape to a square
        set size 1  ;; Adjust the size to fit the grid nicely
        set color land-color-of land-type  ;; Set color based on land type
      ]
    ]
  ]

  set total-apw 0
  set month 1  ;; Start in January
  set sea-contamination 0  ;; Initialize sea contamination counter
  reset-ticks

  ;; Set up the plot
  set-current-plot "Monthly APW Generation"
  clear-plot
end

;; Define monthly APW generation rates for each land type (kg/month)
to-report seasonal-apw-rate [land-type1 current-month]
  if land-type1 = "Olive Groves" [
    if member? current-month [9 10 11] [ report 3 ]  ;; Higher waste during harvest months
    if member? current-month [3 4 5 6 7 8] [ report 1 ]  ;; Lower waste during growing season
    if member? current-month [12 1 2] [ report 0.5 ]  ;; Minimal waste during winter dormancy
  ]
  if land-type1 = "Vineyards" [
    if member? current-month [3 4 9 10] [ report 2 ]
    if member? current-month [5 6 7 8] [ report 1 ]  ;; Moderate waste during growing season
    if member? current-month [11 12 1 2] [ report 0.5 ]  ;; Minimal waste during winter dormancy
  ]
  if land-type1 = "Greenhouses" [
    ;; Monthly variations in waste generation based on plastic type
    if plastic-type = "Plastic A" [
      report random-float 4 + 1  ;; Generate between 1 and 5 kg/month
    ]
    if plastic-type = "Plastic B" [
      report random-float 3 + 2  ;; Generate between 2 and 5 kg/month
    ]
    if plastic-type = "Plastic C" [
      report random-float 2 + 3  ;; Generate between 3 and 5 kg/month
    ]
    if plastic-type = "Biodegradable Covering" [
      report random-float 1 + 1  ;; Generate between 1 and 2 kg/month
    ]
  ]
  if land-type1 = "Pasture Land" [
    if member? current-month [3 4 9 10] [ report 0.5 ]  ;; Slightly more waste during seasonal transitions
    if member? current-month [5 6 7 8 11 12 1 2] [ report 0.2 ]  ;; Lower waste
  ]
  if land-type1 = "Ornamental" [
    if member? current-month [4 5 6 7 8] [ report 1.5 ]  ;; Peak during growing season
    if member? current-month [3 9 10] [ report 1 ]  ;; Moderate waste during transitions
    if member? current-month [11 12 1 2] [ report 0.5 ]  ;; Minimal waste in winter
  ]
  if land-type1 = "Vegetables" [
    if member? current-month [4 5 8 9 10] [ report 3 ]  ;; Peak during planting/harvest
    if member? current-month [6 7 11] [ report 1.5 ]  ;; Moderate during growing
    if member? current-month [12 1 2 3] [ report 0.5 ]  ;; Minimal waste in winter
  ]
  if land-type1 = "Cereals" [
    if member? current-month [5 6 9 10] [ report 2 ]  ;; Peak during planting/harvest
    if member? current-month [3 4 7 8] [ report 1 ]  ;; Moderate waste during growing
    if member? current-month [11 12 1 2] [ report 0.3 ]  ;; Minimal waste in winter
  ]
  if land-type1 = "Orchards" [
    if member? current-month [8 9 10] [ report 2.5 ]  ;; Higher waste during harvest
    if member? current-month [4 5 6 7] [ report 1.5 ]  ;; Moderate waste during growing season
    if member? current-month [11 12 1 2 3] [ report 0.5 ]  ;; Minimal waste in winter and early spring
  ]
  if land-type1 = "Nurseries" [
    if member? current-month [3 4 5 6] [ report 2.5 ]  ;; Higher waste during peak growing
    if member? current-month [7 8 9 10 11 12 1 2] [ report 2 ]  ;; Consistent waste throughout the year
  ]
  if land-type1 = "Other" [
    report 0.2
  ]
  ;; Default case: If no condition matches, report 0 to avoid errors
  report 0
end

;; Define colors for each land type and plastic types for greenhouses
to-report land-color-of [land]
  if land = "Olive Groves" [ report green ]
  if land = "Vineyards" [ report violet ]
  if land = "Greenhouses" [
    ;; Use shades of red for different plastic types
    if plastic-type = "Plastic A" [ report red ]  ;; 10% degradation
    if plastic-type = "Plastic B" [ report magenta ]  ;; 33% degradation
    if plastic-type = "Plastic C" [ report orange ]  ;; 50% degradation
    if plastic-type = "Biodegradable Covering" [ report pink ]  ;; Biodegradable covering
  ]
  if land = "Pasture Land" [ report brown ]
  if land = "Ornamental" [ report yellow ]
  if land = "Vegetables" [ report lime ]
  if land = "Cereals" [ report pink ]
  if land = "Orchards" [ report black ]
  if land = "Nurseries" [ report sky ]
  if land = "Other" [ report white ]
end

;; Simulation procedure that generates APW, tracks it over time, and handles wind/water transfer
to go
  ;; Update APW rates based on the current month
  ask turtles [
    set apw-rate seasonal-apw-rate land-type month
    if land-type = "Greenhouses" [
      ;; Apply degradation based on the degradation rate of the plastic type
      set apw-rate apw-rate * (1 - degradation-rate)
    ]
    set apw-generated apw-generated + apw-rate  ;; Generate APW for the current month
  ]

  ;; Apply wind-based transfer (left to right)
  ask turtles with [pxcor < max-pxcor] [
    let right-patch patch-at 1 0
    if right-patch != nobody [
      if [pcolor] of right-patch = blue [
        ;; If the right patch is sea, transfer plastic directly into sea contamination
        let transfer-amount min list 1 apw-generated
        set apw-generated apw-generated - transfer-amount
        set sea-contamination sea-contamination + transfer-amount
      ]
      if [pcolor] of right-patch != blue [
        ;; If not sea, transfer plastic to the turtle in the right patch
        let right-turtle one-of turtles-on right-patch
        if right-turtle != nobody [
          let transfer-amount min list 1 apw-generated
          set apw-generated apw-generated - transfer-amount
          ask right-turtle [
            set apw-generated apw-generated + transfer-amount
          ]
        ]
      ]
    ]
  ]

  ;; Apply water-based transfer (top to bottom)
  ask turtles with [pycor > min-pycor] [
    let below-patch patch-at 0 -1
    if below-patch != nobody [
      if [pcolor] of below-patch = blue [
        ;; If the below patch is sea, transfer plastic directly into sea contamination
        let transfer-amount min list 1 apw-generated
        set apw-generated apw-generated - transfer-amount
        set sea-contamination sea-contamination + transfer-amount
      ]
      if [pcolor] of below-patch != blue [
        ;; If not sea, transfer plastic to the turtle in the below patch
        let below-turtle one-of turtles-on below-patch
        if below-turtle != nobody [
          let transfer-amount min list 1 apw-generated
          set apw-generated apw-generated - transfer-amount
          ask below-turtle [
            set apw-generated apw-generated + transfer-amount
          ]
        ]
      ]
    ]
  ]

  ;; Update total APW and plot the total APW for the current month
  set total-apw sum [apw-generated] of turtles
  set-current-plot "Monthly APW Generation"
  plot total-apw

  ;; Display the total APW and sea contamination in the command center
  print (word "Month " month " (Year " (1 + floor (ticks / 12)) "): Total APW = " total-apw " kg, Sea Contamination = " sea-contamination " kg")

  ;; Advance the month
  set month month + 1
  if month > 12 [ set month 1 ]  ;; Reset to January after December

  tick
  ;; Stop after 10 years (120 months)
  if ticks >= 120 [ stop ]
end

@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
85
117
148
150
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
94
175
157
208
go
go\nplot total-apw
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
23
282
89
327
total-apw
total-apw
17
1
11

PLOT
829
131
1029
281
Monthly APW Generation
month
total APW (kg)
0.0
100.0
0.0
1000.0
true
false
"plot total-apw" ""
PENS
"Total APW" 1.0 0 -16777216 true "plot total-apw" "plot total-apw"

SLIDER
21
42
193
75
Eco-Friendliness
Eco-Friendliness
0
100
16.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?
This model simulates Agricultural Plastic Waste (APW) management in a 10x10 grid of land plots, each representing different types of agricultural activities. The model aims to demonstrate how plastic waste is generated by various crops, how it degrades over time, and how it can spread to neighboring areas due to wind and water flow. It also tracks plastic contamination in the sea, highlighting the environmental impact of plastic waste mismanagement.

## HOW IT WORKS
Each patch in the grid represents a plot of land with a specific land type (e.g., olive groves, vineyards, greenhouses).
Turtles (agents) represent different types of land use on each patch. Greenhouses have specific plastic types (e.g., Plastic A, Plastic B, Plastic C, Biodegradable Covering) with different degradation rates.
The model runs in monthly time steps, where agents generate APW based on the seasonal rates for their land type.
Degradation of the plastic waste is influenced by the eco-friendliness slider, which adjusts how quickly plastic degrades.
Wind moves plastic horizontally from left to right, transferring waste to neighboring cells or the sea if it reaches the rightmost column.
Water flow moves plastic vertically from top to bottom, transferring waste to neighboring cells or the sea if it reaches the bottom row.
The model tracks total APW generation and plastic contamination in the sea.

## HOW TO USE IT
Setup: Initializes the grid, assigns land types to patches, and sets the initial parameters for each plot.
Go: Starts the simulation and runs it over time steps representing months.
Eco-Friendliness Slider: Adjusts the level of eco-friendliness (0-100). Higher values increase the degradation rates of plastic, resulting in less waste accumulation.
Monthly APW Generation Plot: Displays the total amount of APW generated each month.
Command Center Output: Shows monthly progress, including the total amount of APW generated and the amount of plastic waste that ends up in the sea.

## THINGS TO NOTICE
Observe how different crops produce varying amounts of plastic waste during different seasons.
Notice how the wind moves plastic waste horizontally and how water flow moves it vertically.
Watch the impact of eco-friendliness on the rate of plastic degradation and how it affects overall waste accumulation.
Monitor the sea contamination and see how much plastic ends up in the sea over time.

## THINGS TO TRY
Adjust the Eco-Friendliness slider to see how changes in plastic biodegradability affect total APW and sea contamination.
Observe what happens if the model is run with a low eco-friendliness level (e.g., 0) versus a high level (e.g., 100).
Try changing the seasonal rates or degradation rates in the code to represent different scenarios or policies.
Observe how changes in wind and water flow dynamics affect the spread of plastic waste across the grid and into the sea.

## EXTENDING THE MODEL
Add more plastic types with different degradation behaviors to represent more diverse materials used in agriculture.
Include policy measures, such as plastic taxes or subsidies for biodegradable materials, to see their impact on plastic waste generation and management.
Introduce new sources of contamination like human activities (e.g., dumping waste) or natural events (e.g., floods) that might alter the flow of plastic waste.
Extend the wind and water dynamics to consider multi-directional flows or seasonal changes in weather patterns.

## NETLOGO FEATURES
The model uses turtles to represent plots with different land types, allowing for dynamic interactions and easy visualization.
The random-float function is used to simulate variability in waste generation across different months.
The model takes advantage of NetLogo’s spatial positioning for patches and turtles to simulate wind and water flow of plastic contamination.
Plots are used to visualize the cumulative impact of APW generation, making it easy to see trends over time.

## RELATED MODELS
Plastic Pollution model in the NetLogo Models Library: Shows how plastic waste moves in marine environments.
Land Use Change Models: Focus on the impact of human activities on land use, which can be adapted to simulate agricultural practices.
Waste Management Models: Similar models may include simulations of urban waste management and recycling dynamics.

## CREDITS AND REFERENCES
Developed by VT/CEID Upatras team for exploring Agricultural Plastic Waste management using Agent-Based Models.
The model draws on research from the fields of environmental modeling, waste management, and agriculture.
References:
Convertino et al. (2024). The fate of post-use biodegradable PBAT-based mulch films buried in agricultural soil. Science of the Total Environment.
Hachem et al. (2023). Prospective Scenarios for Addressing the Agricultural Plastic Waste Issue: Results of a Territorial Analysis. Applied Sciences.
Nguyen-Trong et al. (2017). Optimization of municipal solid waste transportation by integrating GIS analysis, equation-based, and agent-based model. Waste Management.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
