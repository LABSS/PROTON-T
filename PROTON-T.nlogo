__includes [ "scenario.nls" "reporters.nls" ]

extensions [ table profiler rnd csv ]

globals [
  initial-random-seed
  local           ; table with values for setup
  areas
  area-names
  area-population
  population-details
  migrant-muslims-ratio
  soc-counter
  soc-online-counter
  rec-counter
  printed
  fail-activity-counter
  radicalization-threshold
]

patches-own [
  area-id
]

breed [ locations location ]

breed [ citizens citizen ]
citizens-own [
  area
  residence
  birth-year
  recruited?
  attributes
  current-task
  countdown
  propensity
  current-activity
  hours-to-recruit
  special-type
  recruit-target
  my-links-cap
  fundamentalism-score ; this exists only to calculate the value of authoritarian?
]

breed [ activity-types activity-type ]
activity-types-own [
  is-job?
  is-mandatory?
  location-type ; string with the name of the location (ex. community center)
  max-agents
  start-time
  duration
  criteria
  task
  priority
  make-special
]

breed [ activities activity ]
activities-own [
  my-activity-type ; turtle of breed activity-type
]

breed [ topics topic ]
topics-own  [
  topic-name
  criteria  ; a boolean reporter taking a speaker and a listener
  risk-weight
  protective-weight ; weights that contribute or protect against risk
  mean-value
  sd-value ; used to calculate outliers like recruiters
]

breed [ police the-police ]

directed-link-breed [ activity-links activity-link ] ; links from citizens to activities
activity-links-own [ value ]                         ; value of activity for the citizen

directed-link-breed [ topic-links topic-link ]       ; links from citizens to topics
topic-links-own [ value ]                            ; opinion dynamics score from -1 to 1

to setup
  clear-all
  reset-timer
  set initial-random-seed random 4294967295 - 2147483648
  random-seed initial-random-seed
  load-totals
  if male-ratio != "from scenario" [
    change-global-gender-ratio male-ratio / 100
  ]
  setup-world  ; warning: this kills all turtles and links in case of resize
  setup-topics ; topic names are needed for plots
  reset-ticks  ; we need the tick counter started for `age` to work
  set-default-shape citizens "person"
  setup-communities-citizens ; citizens are created and moved to their home
  set printed (list one-of citizens)
  load-opinions ; also sets fundamentalism, so that we can
  calculate-topics-stats
  calculate-propensity
  setup-activity-types
  setup-mandatory-activities
  setup-jobs
  set radicalization-threshold calc-radicalization-threshold
  make-specials
  setup-police
  setup-free-time-activities
  ask links [ set hidden? true ]
  ask activities [ set hidden? true ]
  ask activity-types [ set hidden? true ]
  update-plots
  display
  ; TODO: write some test code to make sure the schedule is consistent.
end

to calculate-topics-stats
  ask topics [
    set mean-value mean [ value ] of my-in-links
    set sd-value standard-deviation [ value ] of my-in-links
  ]
end

to set-extreme-opinions [ number-of-sd ] ; citizen procedure. -1.5
  ask topics [
    if in-topic-link-from myself != nobody [
      ask in-topic-link-from myself [
        set value [ mean-value ] of myself + number-of-sd * [ sd-value ] of myself
      ]
    ]
  ]
end

; assumes citizens are at their residence after setup, jobs exist but are not assigned
to make-specials
  make-radical-public-speakers
  make-community-workers
  make-recruiters
end

to make-radical-public-speakers
  ask locations with [ shape = "propaganda place" ] [ set color red ]
  ask turtle-set [ activity-link-neighbors ] of activities with [
    [ is-job? and location-type = "propaganda place" ] of my-activity-type
  ] [
    set-extreme-opinions 1.5
    set printed lput self printed
    set special-type "PS"
  ]
end

to make-community-workers
  ask turtle-set [ activity-link-neighbors ] of activities with [
    [ is-job? and location-type = "community center" ] of my-activity-type
  ] [
    set-extreme-opinions -1.5
    set printed lput self printed
    set special-type "CW"
  ]
end

to make-recruiters
  let t nobody
  create-activity-types 1 [
    set is-job?       true
    set is-mandatory? false
    set start-time    8
    set duration      16
    set location-type test-location-type
    set task          [ -> socialize-and-recruit ]
    set criteria      [ -> false ]
    set t self
  ]
  ask n-of 5 locations with [ shape = [ location-type ] of t ] [
    hatch-activities 1 [
      set my-activity-type t
      ask one-of citizens in-radius activity-radius with [
        age >= 21 and
        get "male?"
      ] [
        ask activity-link-neighbors with [ [ is-job? ] of my-activity-type ] [ die ]
        create-activity-link-to myself
        set-extreme-opinions 1.5
        set printed lput self printed
        set special-type "R"
      ]
    ]
  ]
end

to setup-police
  create-police (4 * total-citizens / 1000) [
    set shape "person soldier"
    let police-topic-link get-or-create-link-with topic-by-name "Institutional distrust"
    set-extreme-opinions 1.5
  ]
  ask n-of round (count police * cpo-% / 100) police [ set-extreme-opinions -1.5 ]
end

to move-police
  ask police [
    let best-patches patches with [ count citizens-here >= 4 and area-id = [ area-id ] of [ patch-here ] of myself ]
    if not any? best-patches [
      set best-patches patches with [ any? citizens-here and area-id = [ area-id ] of [ patch-here ] of myself ]
      if not any? best-patches [
        set best-patches patch-here; if none, can as well stay there
      ]
    ]
    move-to one-of best-patches
    if any? citizens-here [
      let dummy talk-to (turtle-set one-of citizens-here) topic-by-name "Institutional distrust"
    ]
  ]
end

to go
  move-police
  ask citizens [
    assert [ -> countdown >= 0 ]
    if countdown = 0 [ ; end of activity or activity without duration
      set current-task nobody
      set current-activity nobody
      ; first: try job or compulsory
      let new-job-or-mand one-of activity-link-neighbors with [
        [ start-time = current-time and is-mandatory? ] of my-activity-type
      ]
      if new-job-or-mand = nobody [
        set new-job-or-mand one-of activity-link-neighbors with [
          [ workday? ] of myself and [ start-time = current-time and is-job? ] of my-activity-type
        ]
      ]
      ifelse new-job-or-mand != nobody [
        start-activity new-job-or-mand
      ] [  ; otherwise find something to do. Worse thing you'll go back home to socialize.
        let candidate-activities activity-link-neighbors with [
          [ not is-mandatory? and not is-job? ] of my-activity-type and not is-full?
        ]
        start-activity rnd:weighted-one-of candidate-activities [
          (([ value ] of link-with myself + 2) / 4) + (1 / (1 + distance myself)) ; this weights value the same as inverse distance.
        ]
      ]
      ;assert [ -> current-task != nobody and current-activity != nobody ]
      ; here the citizen is on free time so he has a probability to browse the web.
    ]
    if current-task != nobody [
      set fail-activity-counter fail-activity-counter + 1
      run current-task
      set countdown countdown - 1
    ]
  ]
  if activity-debug? [ update-output ]
  tick
  if behaviorspace-experiment-name != "" [
    show (word behaviorspace-run-number "." ticks)
  ]
end

; activity reporter
to-report is-full?
  report ifelse-value ([location-type] of my-activity-type = "coffee") [
    count citizens-here >= 20
  ] [
    false
  ]
end

to start-activity [ new-activity ] ; citizen procedure
  move-to new-activity
  set countdown [ duration ] of [ my-activity-type ] of new-activity
  set current-activity new-activity
  set current-task [ task ] of [ my-activity-type ] of new-activity
end

; finds at random simlilar people and talk with them. The interaction has only 50% of the effect it would have when face to face.
to socialize-online ; citizen context
  let potential-contacts n-of 50 other citizens  ; limit contacts to avoid sorting long lists of citizens
  let the-topic one-of topics
  let my-opinion [ value ] of out-topic-link-to the-topic
  let the-contact rnd:weighted-one-of potential-contacts [ abs ([ value ] of out-topic-link-to the-topic - my-opinion) ]
  let _unused talk-to-tuned turtle-set the-contact the-topic 0.5
  ask the-contact [ set _unused talk-to-tuned turtle-set self the-topic 0.5 ]
  set soc-online-counter soc-online-counter + 1
end

to setup-topics
  foreach topic-definitions [ def ->
    create-topics 1 [
      set topic-name        item 0 def
      set criteria          item 1 def
      set risk-weight       item 2 def
      set protective-weight item 3 def
      set hidden? true
    ]
  ]
end

to setup-world
  let world-side community-side-length * sqrt length areas
  resize-world 0 (world-side - 1) 0 (world-side - 1)
  set-patch-size floor (800 / world-side)
  let colors [7.4 9.4]; map [ c -> c - 4 ] [turquoise cyan]
end

to setup-communities-citizens
  let n sqrt length areas
  foreach range n [ row ->
    foreach range n [ col ->
      let the-area item (col + row * n) areas
      let community-patches patches with [
        floor (pxcor / community-side-length) = row and
        floor (pycor / community-side-length) = col
      ]
      let c ifelse-value (row mod 2 = col mod 2) [ 7.4 ] [ 9.4 ]
      ask community-patches [
        set area-id the-area
        set pcolor c + random-float 0.5
      ]
      setup-locations community-patches the-area
      let residences setup-residences community-patches with [
        not any? locations-here with [ shape = "coffee" ] and not any? locations in-radius 1.75 with [ shape != "residence" and shape != "coffee" ]
      ]
      create-citizens table:get area-population the-area [
        setup-citizen residences the-area
      ]
      ;if police-interaction = "cpo" [ setup-cpos community-patches ]
    ]
  ]
end

;to setup-cpos [ the-patches ]
;  ask n-of cpo-numerousness the-patches [
;    sprout-cpos 1 [
;      set shape "flag"
;      set color red
;      create-topic-link-to topic-by-name "Institutional distrust" [
;        set value -1
;      ]
;    ]
;  ]
;end

to setup-locations [ target-patches the-area ]
  set target-patches target-patches with [ count neighbors = 8 ]
  let center patchset-center target-patches
  foreach location-definitions the-area [ def ->
    repeat item 0 def [
      ; locations need to be created one at a time so `territory` is initialized
      create-locations 1 [
        set size       item 2 def
        set shape      item 1 def
        set color      change-brightness peach random 10
        let candidates target-patches with [
          not any? other locations with [
            abs (pxcor - [ pxcor ] of myself) < 3 and abs (pycor - [ pycor ] of myself) < 3
          ]
        ]
        move-to rnd:weighted-one-of candidates [ 1 / (1 + (distance center ^ 2)) ]
      ]
    ]
  ]
end

to-report patchset-center [patchset]
  ; TODO: extension candidate
  let min-x min [ pxcor ] of patchset
  let max-x max [ pxcor ] of patchset
  let min-y min [ pycor ] of patchset
  let max-y max [ pycor ] of patchset
  report patch (min-x + ((max-x - min-x) / 2)) ((min-y + ((max-y - min-y) / 2)))
end

to-report setup-residences [ target-patches ]
  let residences []
  ask target-patches [
    sprout-locations 1 [
      set shape          "residence"
      set color          pcolor - 2
      set residences lput self residences
    ]
  ]
  report turtle-set residences
end

to setup-citizen [ residences the-area ]
  set attributes make-attributes-set the-area ; sets also age
  set area             the-area
  set color            lput 150 one-of teals
  set current-task     nobody ; used to indicate "none"
  set current-activity nobody
  set countdown        0
  set residence        one-of residences
  set recruited?       false
  set hours-to-recruit random (2 * recruit-hours-threshold)
  set recruit-target   nobody
  set my-links-cap     5 + random (2 * links-cap-mean - 5)
  move-to residence
end

to calculate-propensity
  ask citizens [ set propensity sum-factors propensity-factors ]
end

to setup-activity-types
  ; ok we keep the specials ALSO in here so we will have the activity in place at the location.
  foreach job-definition-list [ def ->
    create-activity-types 1 [
      set is-job?       true
      set is-mandatory? true
      set max-agents    item 0 def
      set start-time    item 1 def
      set duration      item 2 def
      set location-type item 3 def
      set task          item 4 def
      set criteria      item 5 def
      set priority      item 6 def
    ]
  ]
  foreach mandatory-activity-definition-list [ def ->
    create-activity-types 1 [
      set is-job?       false
      set is-mandatory? true
      set max-agents    nobody
      set start-time    item 0 def
      set duration      item 1 def
      set location-type item 2 def
      set task          item 3 def
      set criteria      item 4 def
    ]
  ]
  foreach free-time-activity-definition-list [ def ->
    create-activity-types 1 [
      set is-job?       false
      set is-mandatory? false
      set max-agents    nobody
      set start-time    nobody
      set duration      1
      set location-type item 0 def
      set task          item 1 def
      set criteria      item 2 def
    ]
  ]
  ask locations [
    foreach [ self ] of activity-types with [
      location-type = [ shape ] of myself
    ] [ t ->
      hatch-activities 1 [ set my-activity-type t ]
    ]
  ]
end

; assumes people are at their residence
to setup-jobs
  foreach sort-on [ priority ] activity-types with [ is-job? ] [ the-type ->
    ask activities with [ my-activity-type = the-type ] [
      let candidates citizens with [ runresult [ criteria ] of the-type and schedule-free [ start-time ] of the-type [ duration ] of the-type ]
      let n min (list (count candidates) ([ max-agents ] of the-type))
      ; this approach allows citizens to work in areas that are not their residence if they are on a border
      ask rnd:weighted-n-of n candidates [ distance myself ^ 2 ] [
        create-activity-link-to myself
      ]
    ]
  ]
end

; citizen procedure
to-report schedule-free [ the-start the-duration ]
  let the-end the-start + the-duration
  report ifelse-value all? activity-link-neighbors [
    [ (start-time < the-start and start-time + duration <= the-start) or
      (start-time >= the-end) ] of my-activity-type
  ] [ true ] [ false ]
end

to setup-mandatory-activities ; citizen procedure
  ask activity-types with [ is-mandatory? and not is-job? ] [
    let the-type self
    let get-activity [ ->
      one-of ([ activities-here ] of residence) with [ my-activity-type = the-type ]
    ]
    if shape != "residence" [
      let possible-activities activities with [ my-activity-type = the-type ]
      set get-activity [ -> min-one-of possible-activities [ distance myself ] ]
    ]
    ask citizens with [ runresult [ criteria ] of myself ] [
      create-activity-link-to runresult get-activity
    ]
  ]
end

to setup-free-time-activities
  ask citizens [
    ; look for possible free-time activities around current activities
    let the-citizen self
    let reachable-activities my-nearby-activities with [
      [ not is-mandatory? and not is-job? ] of my-activity-type and [ can-do? myself ] of the-citizen
    ]
    create-activity-links-to n-of min list my-links-cap count reachable-activities reachable-activities [
      set value -2 + random-float 4 ; TODO: how should this be initialized?
    ]
  ]
end

to-report my-nearby-activities ; citizen reporter
  let reachable-activities (turtle-set [
    other activities in-radius activity-radius
  ] of activity-link-neighbors) with [
    not member? self [ activity-link-neighbors ] of myself
  ]
  report reachable-activities
end

to-report can-do? [ the-activity ] ; citizen reporter
  let the-location-type [ location-type ] of [ my-activity-type ] of the-activity
  if the-location-type = "residence" and not is-at-my-residence? the-activity [
    report false
  ]
  let the-criteria [ criteria ] of [ my-activity-type ] of the-activity
  report runresult the-criteria
end

to-report is-at-my-residence? [ the-turtle ] ; citizen reporter
  report [ patch-here ] of the-turtle = [ patch-here ] of residence
end

to-report intervals [ n the-range ]
  ; TODO: extension candidate
  report n-values n [ i -> i * (the-range / n) ]
end

to-report ticks-per-day  report 24                             end
to-report ticks-per-year report ticks-per-day * 365            end
to-report current-year   report floor (ticks / ticks-per-year) end
to-report current-time   report ticks mod ticks-per-day        end
to-report age            report current-year - birth-year      end
; days are already there in the rest of the division by seven. I'd keep them that way. It won't be done too often; if it does, it should be cached;
; a routine could set all the reporters at the beginning of the step, making them into globals. To do in the optimization phase.
; so we could say 0 = Sunday, 1 = Monday, .. , 6 = Friday, 7 = Saturday.
to-report week-num          report (floor (ticks / ticks-per-day)) mod 7                                                    end


to-report sum-factors [ factors ]
  report sum map runresult factors
end

to-report topic-risk-contribution ; opinion-on-topic reporter.
  ; The link must have been called from a citizen in order to make use of other-end.
  report value * ifelse-value (value > 0) [ [ risk-weight ] of other-end ] [ [ protective-weight ] of other-end ]
end

to-report risk ; citizen reporter
  report sum [ topic-risk-contribution ] of my-out-topic-links + propensity
end

to sleep
  ; do nothing
end
                                   ;agentset
to-report select-opinion-and-talk [ receiver ]
  let speaker self
  let candidate-opinions my-opinions with [ meets-criteria? speaker receiver ]
  let the-object [ other-end ] of rnd:weighted-one-of candidate-opinions [ abs value ]
  let success? talk-to receiver the-object
  ask link-with current-activity [ update-activity-value success? ]
  ask receiver [
    ; the receiver will enjoy the place via any of the activities that brought him there
    ask one-of activities-here with [ in-link-neighbor? myself ] [
      ask my-in-activity-links [
        update-activity-value success?
      ]
    ]
  ]
  report success?
end

to socialize; citizen procedure
  let receiver turtle-set one-of other citizens-here
  if any? receiver [
    let _unused select-opinion-and-talk receiver
  ]
  set soc-counter soc-counter + 1
end

to socialize-and-recruit; citizen procedure
  let receiver rnd:weighted-one-of other citizens-here with [ special-type = 0 and not recruited? and risk > radicalization-threshold ] [ recruit-allure ]
  if receiver != nobody [
    if select-opinion-and-talk turtle-set receiver [
      if recruit-target = nobody [ set recruit-target receiver ]
      ask receiver [ check-recruitment ]
    ]
  ]
  set rec-counter rec-counter + 1
end

to update-activity-value [ success? ] ; link procedure
  ;if [ special-type ] of myself = 0 [
    set value value + activity-value-update * (ifelse-value success? [ 2 ][ -2 ] - value)
end

to-report find-criteria-by-breed ; link reporter
  if breed = activity-links [
    report [ criteria ] of [ my-activity-type ] of other-end
  ]
  if breed = topic-links [
    report [ criteria ] of other-end
  ]
end

to-report meets-criteria? [ speaker receiver ]; link reporter
  let the-criteria find-criteria-by-breed
  let result [ [ runresult the-criteria ] of receiver ]  of speaker
  ifelse is-list? result [
   report reduce and result
  ] [
   report result
  ]
  ; report item 0 [ [ runresult the-criteria ] of receiver ] of speaker
end

to-report my-opinions ; citizen reporter
  report (link-set
    my-topic-links
    my-activity-links with [
      [ not is-mandatory? and location-type != "residence" ] of [ my-activity-type ] of other-end
    ]
  )
end

; https://arxiv.org/ftp/arxiv/papers/0803/0803.3879.pdf
to-report talk-to [ recipients the-object ] ; citizen procedure
  report talk-to-tuned recipients the-object 1
end

; introduced to allow interaction at a reduced rate of persuasion). In most cases, effect-size should be 1.
to-report talk-to-tuned [ recipients the-object effect-size ] ; citizen procedure
  let success? false
  if any? recipients [
    let l1 link-with the-object
    let v1 [ value ] of l1
    ask recipients [
      let l2 get-or-create-link-with the-object
      let v2 [ value ] of l2
      let t 2 - alpha * abs v2
      if abs (v1 - v2) < t [
        ask l2 [ set value v2 + t * (v1 - v2) / 2 * effect-size ]
        set success? true
      ]
    ]
  ]
  report success?
end

to-report get-or-create-link-with [ the-object ] ; citizen reporter
  let the-link link-with the-object
  if the-link = nobody [
    if is-activity? the-object [
      create-activity-link-to the-object [ set the-link self ]
      if any? my-activity-links [
        if count my-activity-links > my-links-cap [
          ask min-one-of my-activity-links with [
            [ [ not is-mandatory? and not is-job? ] of my-activity-type ] of other-end and not member? other-end [ turtles-here ] of myself and not (the-link = self)
          ] [ value ] [ die ]
        ]
      ]
    ]
    if is-topic?    the-object [ create-topic-link-to    the-object [ set the-link self ] ]
    ask the-link [
      hide-link
      set value 0
    ]
  ]
report the-link
end

to check-recruitment ; citizen procedure
  set hours-to-recruit hours-to-recruit - 1
  if risk > radicalization-threshold and hours-to-recruit <= 0 [
    set recruited? true
    ask citizens with [ recruit-target = myself ] [ set recruit-target nobody ]
    set color lput 150 hsb 360 100 (item 2 extract-hsb color)
  ]
end

to-report get [ attribute-name ]
  report table:get attributes attribute-name
end

to-report opinion-on-topic [ the-topic-name ] ; citizen reporter
  report [ value ] of out-topic-link-to topic-by-name the-topic-name
end

to-report teals
  report [[0 62 63] [0 98 100] [0 129 132] [65 182 185]]
end

to-report peach
  report [245 157 101]
end

to-report change-brightness [ c delta-b ]
  let hsb-list extract-hsb c
  report hsb (item 0 hsb-list) (item 1 hsb-list) (item 2 hsb-list + delta-b)
end

; called by behaviorspace
to-report citizens-occupations-hist
  report reduce sentence list [
    (list location-type "job" count citizens with [ current-activity != nobody and [ my-activity-type ] of current-activity = myself ])
  ] of activity-types with [ is-job? ] [
    (list location-type "notjob" count citizens with [ current-activity != nobody and [ my-activity-type ] of current-activity = myself ])
  ] of activity-types with [ not is-job? ]
end

; called by behaviorspace
to-report citizens-opinions
  report [ reduce sentence (list who
    map [ i ->  opinion-on-topic i ] topics-list)
   ] of citizens
end

; called by behaviorspace
to-report aggregate-citizens-opinions
  report
    map [ i  -> mean [ opinion-on-topic i ] of citizens] topics-list
end

; called by the test subsystem, *TJobsTests.scala
to-report mean-opinion-on-location [ the-topic-name location-name ]
  report  mean [ value ] of link-set [
    out-topic-link-to topic-by-name the-topic-name
  ] of (citizens-on locations with [ shape = location-name ]) with [
    [ not (is-job? and location-type = location-name) ] of [ my-activity-type ] of current-activity
  ]
end

; citizen reporter
to-report recruit-allure
  report (sum map opinion-on-topic topics-list + 6) / 12 +
  (2 * recruit-hours-threshold - hours-to-recruit) / recruit-hours-threshold +
  ifelse-value (self = [ recruit-target ] of myself) [ 1000 ] [ 0 ]
end

to-report employed?  ; citizen reporter
  report any? activity-link-neighbors with [ [ is-job? ] of my-activity-type ]
end

to-report read-csv [ base-file-name ]
  report but-first csv:from-file (word "inputs/" scenario "/data/" base-file-name ".csv")
end

to-report group-by-first-item [ csv-data ]
  let table table:group-items csv-data first ; group the rows by their first item
  report table-map table [ rows -> map but-first rows ] ; remove the first item of each row
end

to-report group-by-5-keys [ csv-data ]
  let table table:group-items csv-data [ line -> sublist line 0 5 ]; group the rows by lists with initial 5 items
  ;report table-map table [ rows -> map [ i -> last i ] rows ]
  report table-map table [ rows -> map last rows ]
end

to-report table-map [ tbl fn ]
  ; from https://github.com/NetLogo/Table-Extension/issues/6#issuecomment-276109136
  ; (if `table:map` is ever added to the table extension, this could be replaced by it)
  report table:from-list map [ entry ->
    list (first entry) (runresult fn last entry)
  ] table:to-list tbl
end

to-report topic-by-name [ the-name ]
  report one-of topics with [ topic-name = the-name ]
end

to update-output
  print ticks
  foreach printed [ p ->
    ask p [
      output-print (word [ special-type ] of p "-" who ": "
        [ shape ] of one-of locations-here ", "
        current-task ", " ifelse-value (recruit-target = nobody) [ "" ][ [ who ] of recruit-target ])
      ]
    ]
end

to assert [ f ]
  if not runresult f [ error (word "Assertion failed: " f) ]
end
@#$#@#$#@
GRAPHICS-WINDOW
300
10
1078
789
-1
-1
11.0
1
10
1
1
1
0
0
0
1
0
69
0
69
1
1
1
ticks
30.0

BUTTON
25
335
98
368
NIL
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

SLIDER
10
65
290
98
total-citizens
total-citizens
100
2000
500.0
50
1
citizens
HORIZONTAL

MONITOR
10
265
80
310
population
count citizens
17
1
11

SLIDER
10
105
290
138
community-side-length
community-side-length
20
100
35.0
1
1
patches
HORIZONTAL

MONITOR
80
265
135
310
density
count citizens / count patches
2
1
11

BUTTON
140
335
203
368
NIL
go
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
210
335
273
368
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
25
375
145
408
profile 20
setup                  ;; set up the model\nprofiler:start         ;; start profiling\nrepeat 20 [ go ]       ;; run something you want to measure\nprofiler:stop          ;; stop profiling\nprint profiler:report  ;; view the results\nprofiler:reset         ;; clear the data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
145
290
178
activity-radius
activity-radius
1
100
11.0
1
1
patches
HORIZONTAL

BUTTON
150
375
272
408
profile setup
profiler:start         ;; start profiling\nsetup                  ;; set up the model\nprofiler:stop          ;; stop profiling\nprint profiler:report  ;; view the results\nprofiler:reset         ;; clear the data
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
195
265
250
310
time
(word (ticks mod 24) \":00\")
17
1
11

SLIDER
10
185
290
218
alpha
alpha
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
10
225
290
258
radicalization-percentage
radicalization-percentage
0.05
1
0.1
.05
1
NIL
HORIZONTAL

PLOT
25
415
275
535
T1
NIL
NIL
0.0
1.0
-1.0
1.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 ticks + 1\nif any? topic-links [\n  let topic-to-plot \"Institutional distrust\"\n  let prec 2\n  let values [ [ value ] of my-in-topic-links ] of one-of topics with [ topic-name = topic-to-plot ]\n  plot-pen-up\n  plotxy ticks -1\n  plot-pen-down\n  let ys map [ n -> precision n prec ] (range -1 1 (10 ^ (0 - prec)))\n  let counts map [ y -> length filter [v -> precision v prec = y] values ] ys\n  let max-count max counts\n  let colors map [ cnt -> 9.9 - (9.9 * cnt / max-count) ] counts\n  (foreach ys colors [ [y c] ->\n    set-plot-pen-color c\n    plotxy ticks y\n  ])\n]"

PLOT
1115
690
1404
820
Propensity and risk
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks > 0 [ plotxy ticks mean [ propensity ] of citizens ]"
"pen-1" 1.0 0 -7500403 true "" "if ticks > 0 [ plotxy ticks mean [ risk ] of citizens ]"

PLOT
1115
485
1450
675
Mean opinions
NIL
NIL
0.0
10.0
-1.0
1.0
true
true
"let n count topics\n(foreach sort topics range n [ [t i] ->\n  ask t [ create-temporary-plot-pen topic-name ]\n  set-plot-pen-color hsb (i * 360 / n) 50 50\n])" "if ticks > 0 [\n  ask topics [\n    set-current-plot-pen topic-name\n    plotxy ticks mean [value] of my-in-topic-links\n  ]\n]"
PENS

SLIDER
15
545
285
578
website-access-probability
website-access-probability
0
1
0.05
0.05
1
NIL
HORIZONTAL

SLIDER
15
585
285
618
work-socialization-probability
work-socialization-probability
0
1
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
15
625
285
658
activity-value-update
activity-value-update
0
1
0.5
0.05
1
NIL
HORIZONTAL

MONITOR
135
265
195
310
NIL
weekday
17
1
11

MONITOR
1100
15
1257
60
propaganda attendance
count citizens with [ [ shape ] of locations-here = [ \"propaganda place\" ] ]
0
1
11

CHOOSER
10
15
290
60
scenario
scenario
"neukolln"
0

SLIDER
1100
65
1302
98
recruit-hours-threshold
recruit-hours-threshold
1
300
20.0
1
1
NIL
HORIZONTAL

MONITOR
1105
110
1177
155
recruited
count citizens with [ recruited? ]
17
1
11

MONITOR
1180
110
1262
155
susceptible
count citizens with [ risk > radicalization-threshold ]
17
1
11

MONITOR
1260
15
1350
60
PS attendance
count citizens with [ [ shape ] of locations-here = [ \"public space\" ] ]
17
1
11

OUTPUT
1115
320
1450
480
10

SWITCH
1270
120
1422
153
activity-debug?
activity-debug?
1
1
-1000

MONITOR
1305
65
1435
110
socialization attempts
soc-counter
0
1
11

MONITOR
1110
165
1267
210
coffee mean attendance
count citizens with [ [ shape ] of locations-here = [ \"coffee\" ] ] / count locations with [ shape = \"coffee\" ]
17
1
11

CHOOSER
1110
260
1248
305
test-location-type
test-location-type
"public space" "coffee"
1

MONITOR
1275
165
1422
210
NIL
rec-counter
17
1
11

MONITOR
1110
210
1330
255
NIL
min [hours-to-recruit] of citizens
17
1
11

MONITOR
1450
15
1527
60
NIL
count links
17
1
11

SLIDER
15
665
285
698
links-cap-mean
links-cap-mean
5
100
10.0
1
1
NIL
HORIZONTAL

MONITOR
1385
15
1447
60
at home
count citizens with [ [ shape ] of locations-here = [ \"residence\" ] ]
0
1
11

CHOOSER
1275
265
1413
310
male-ratio
male-ratio
"from scenario" 45 55
0

SLIDER
15
705
285
738
cpo-%
cpo-%
0
100
50.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

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

coffee
false
0
Rectangle -14835848 true false 210 75 225 255
Rectangle -10899396 true false 90 135 210 255
Rectangle -16777216 true false 165 195 195 255
Line -16777216 false 210 135 210 255
Rectangle -16777216 true false 105 202 135 240
Polygon -13840069 true false 225 150 75 150 150 75
Line -16777216 false 75 150 225 150
Line -16777216 false 195 120 225 150
Polygon -16777216 false false 165 195 150 195 180 165 210 195
Rectangle -16777216 true false 135 105 165 135

community center
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

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

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

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

house efficiency
false
0
Rectangle -7500403 true true 180 90 195 195
Rectangle -7500403 true true 90 165 210 255
Rectangle -16777216 true false 165 195 195 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 165 75 165 150 90
Line -16777216 false 75 165 225 165

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

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

mosque
false
0
Rectangle -7500403 true true 105 210 195 300
Rectangle -7500403 true true 15 195 30 300
Rectangle -7500403 true true 270 195 285 300
Rectangle -7500403 true true 30 240 105 300
Rectangle -7500403 true true 195 240 270 300
Circle -7500403 true true 105 165 90
Circle -7500403 true true 12 182 20
Circle -7500403 true true 268 182 20
Polygon -7500403 true true 143 174 150 144 158 174
Polygon -7500403 true true 15 196 22 166 30 196
Polygon -7500403 true true 270 198 277 168 285 198
Rectangle -16777216 true false 128 242 173 300
Rectangle -16777216 true false 30 270 60 300
Rectangle -16777216 true false 75 270 105 300
Rectangle -16777216 true false 195 270 225 300
Rectangle -16777216 true false 240 270 270 300
Circle -16777216 true false 30 255 30
Circle -16777216 true false 75 255 30
Circle -16777216 true false 195 255 30
Circle -16777216 true false 240 255 30
Circle -16777216 true false 127 219 46
Polygon -16777216 true false 143 240 150 210 158 240

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

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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

propaganda place
false
0
Polygon -2674135 true false 298 180 73 180 148 150 268 150
Rectangle -8630108 true false 15 75 30 255
Rectangle -8630108 true false 30 135 225 255
Rectangle -16777216 true false 113 195 176 256
Rectangle -16777216 true false 45 195 90 240
Rectangle -16777216 true false 165 150 210 180
Rectangle -16777216 true false 45 150 90 180
Line -16777216 false 30 135 30 255
Rectangle -8630108 true false 225 180 285 255
Polygon -2674135 true false 240 135 15 135 60 90 195 90
Line -16777216 false 225 135 225 180
Rectangle -16777216 true false 207 195 270 240
Line -16777216 false 240 135 15 135
Line -16777216 false 45 105 15 135
Line -16777216 false 300 180 225 180
Line -7500403 true 240 195 240 240
Line -7500403 true 146 195 146 255

public space
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

radical mosque
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

residence
false
13
Rectangle -2064490 true true 45 120 255 285
Rectangle -7500403 true false 120 210 180 285
Polygon -2064490 true true 15 120 150 15 285 120
Line -7500403 false 30 120 270 120

school
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

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

workplace
false
0
Rectangle -7500403 true true 60 30 240 300
Rectangle -16777216 true false 75 45 90 75
Rectangle -16777216 true false 105 45 120 75
Rectangle -16777216 true false 180 45 195 75
Rectangle -16777216 true false 210 45 225 75
Rectangle -16777216 true false 135 255 165 300
Rectangle -16777216 true false 75 90 90 120
Rectangle -16777216 true false 75 135 90 165
Rectangle -16777216 true false 75 180 90 210
Rectangle -16777216 true false 75 225 90 255
Rectangle -16777216 true false 105 90 120 120
Rectangle -16777216 true false 105 135 120 165
Rectangle -16777216 true false 105 180 120 210
Rectangle -16777216 true false 105 225 120 255
Rectangle -16777216 true false 180 90 195 120
Rectangle -16777216 true false 180 135 195 165
Rectangle -16777216 true false 180 180 195 210
Rectangle -16777216 true false 180 225 195 255
Rectangle -16777216 true false 180 225 195 255
Rectangle -16777216 true false 210 90 225 120
Rectangle -16777216 true false 210 135 225 165
Rectangle -16777216 true false 210 180 225 210
Rectangle -16777216 true false 210 225 225 255
Rectangle -16777216 true false 135 225 165 240
Rectangle -16777216 true false 135 180 165 195
Rectangle -16777216 true false 135 135 165 150
Rectangle -16777216 true false 135 90 165 105
Rectangle -16777216 true false 135 45 165 60
Rectangle -7500403 true true 45 15 255 30
Rectangle -7500403 true true 45 210 60 300
Rectangle -7500403 true true 240 210 255 300

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
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
1
@#$#@#$#@
