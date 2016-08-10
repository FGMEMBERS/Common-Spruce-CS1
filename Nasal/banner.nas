###############################################################################
##  Nasal for Common-Spruce CS 1.
##
##  Copyright (C) 2007 - 20016  Marc Kraus  (info(at)marc-kraus.de)
##  This file is licensed under the GPL license version 2 or later.
##
##  For the CS 1, written in January 2012 by Marc Kraus
##
###############################################################################
# ============================================
#          The banner wave animation 
# ============================================
var p = "controls/banner/";

var banner_start_stop = func {
  var nr   = getprop(p~"selected");
  var show = props.globals.getNode(p~"show");
  var wave = props.globals.getNode(p~"wave");

  if(!show.getValue() > 0){
    # show banner
    show.setValue(nr);
    wave.setValue(-1);
    wave_loop();
  }else{
    # stop banner
    show.setValue(0);
    wave.setValue(0);
  }
}

var wave_loop = func {
  var show = props.globals.getNode(p~"show");
  if(show.getValue() > 0){
    # toggle between -1 and 1
    var waveTime = 0.08;
    var waveState = getprop(p~"wave");
    if (waveState >= 0.9) { interpolate(p~"wave", -0.9, waveTime); }
    if (waveState <= -0.9) { interpolate(p~"wave", 0.9, waveTime); }
    settimer(wave_loop, waveTime);
  }
}

