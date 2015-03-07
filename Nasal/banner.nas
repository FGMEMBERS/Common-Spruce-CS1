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

