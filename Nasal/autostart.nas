# if engine running stop starter
setlistener("engines/engine[0]/running", func(run) {
    var run = run.getBoolValue();
    if(run) setprop("controls/engines/engine[0]/starter",0);
});

var switchSoundToggle = func{
  var switchSound = props.globals.getNode("/sim/sound/switch",1);
  if(switchSound.getBoolValue()){
    switchSound.setBoolValue(0);
  }else{
    switchSound.setBoolValue(1);
  }
}

#------------------  Autostart / stop -----------------------

var Startup = func{
  # first close the doors if open
  var pd = getprop("sim/multiplay/generic/float[13]");
  if (pd > 0) cs1.PilotDoor();
  var cpd = getprop("sim/multiplay/generic/float[14]");
  if (cpd > 0) cs1.CopilotDoor();

  # switch on the FlightRallyeMode
  var frwKnob = getprop("instrumentation/frw/btn-mode");
  if (frwKnob == 0) {
    setprop("instrumentation/frw/btn-mode",1);
    frw.frw_mode();
  }

  # if engine is not running continue
  var allreadyRun = props.globals.getNode("engines/engine[0]/running",1);
  if (!allreadyRun.getBoolValue()) {
    # startup procedure
    interpolate("controls/engines/engine[0]/mixture", 1  , 1);
    setprop("controls/engines/engine[0]/propeller-pitch",1);
    setprop("controls/engines/engine[0]/magnetos",3);
    switchSoundToggle();

    settimer(setFuel, 1.0 );
    settimer(setBatterySwitch, 2.0 );
    settimer(setFuelPump, 3.0 );
    settimer(setStarter, 4.0 );
    settimer(setAlt, 5.0 );
    settimer(setAPAlt, 6.0 );
    settimer(setHdg, 6.0 );
    settimer(setInstrLights, 7.0 );
    settimer(setNavLights, 8.0 );
    settimer(openBrake, 10.0 );
  }
}

var Shutdown = func{ 
    settimer(closeBrake, 0.5 );
    settimer(closeMagnetos, 1.0 );
    settimer(closeFuelPump, 2.0 );
    settimer(closeFuel, 3.0 );
    settimer(closeNavLights, 4.0 );
    settimer(closeInstrLights, 5.0 );
    settimer(closeAlt, 6.0 );
    settimer(closeBatterySwitch, 7.0 );
}

  # helper functions and variables for STARTUP
  var setFuel = func{
    var sel0 = getprop("consumables/fuel/tank[0]/selected");
    var sel1 = getprop("consumables/fuel/tank[1]/selected");
    var sel2 = getprop("consumables/fuel/tank[2]/selected");
    if (sel0 == 0 and sel1 == 0 and sel2 == 0) cs1.WaspJr.fuel_select(3);
    switchSoundToggle();
  } 
  var setFuelPump = func{
    setprop("controls/engines/engine[0]/fuel-pump",1);
    switchSoundToggle();
  }
  var setBatterySwitch = func{
    setprop("controls/electric/battery-switch",1);
    switchSoundToggle();
  }
  var setStarter = func{
    setprop("controls/engines/engine[0]/starter",1);
    switchSoundToggle();
  }
  var setAlt = func{
    setprop("controls/electric/engine[0]/generator",1);
    switchSoundToggle();
  }
  var setInstrLights = func{
    setprop("controls/lighting/instrument-lights",1);
    switchSoundToggle();
  }
  var setNavLights = func{
    setprop("controls/lighting/nav-lights",1);
    setprop("controls/lighting/strobe",1);
    switchSoundToggle();
  }
  var openBrake = func{
    setprop("controls/gear/brake-parking",0);
  }
  var setAPAlt = func{
    setprop("autopilot/settings/target-altitude-ft",4000);
  }
  var setHdg = func{
    setprop("autopilot/settings/heading-bug-deg",getprop("orientation/heading-deg"));
  }

  # helper functions and variables for SHUTTDOWN
  var closeFuel = func{
    cs1.WaspJr.fuel_select(-3);
    switchSoundToggle();
  } 
  var closeFuelPump = func{
    setprop("controls/engines/engine[0]/fuel-pump",0);
    interpolate("controls/engines/engine[0]/mixture", 0  , 1);
    switchSoundToggle();
  }
  var closeBatterySwitch = func{
    setprop("controls/electric/battery-switch",0);
    var pd = getprop("sim/multiplay/generic/float[13]");
    if (pd == 0) cs1.PilotDoor();
    switchSoundToggle();
  }
  var closeAlt = func{
    setprop("controls/electric/engine[0]/generator",0);
    switchSoundToggle();
  }
  var closeInstrLights = func{
    setprop("controls/lighting/instrument-lights",0);
    switchSoundToggle();
  }
  var closeNavLights = func{
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/strobe",0);
    switchSoundToggle();
  }
  var closeBrake = func{
    setprop("controls/gear/brake-parking",1);
  }
  var closeMagnetos = func{
    setprop("controls/engines/engine[0]/magnetos",0);
    setprop("/engines/engine[0]/running",0);
    switchSoundToggle();
  }

# ---------------- End of Autostart/stop -----------------------------

