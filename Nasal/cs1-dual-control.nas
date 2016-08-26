###############################################################################
##  Nasal for dual control of the Common-Spruce CS 1 over the multiplayer network.
##
##  Copyright (C) 2007 - 2008  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
##  For the CS 1, written in January 2012 by Marc Kraus
##
###############################################################################

## Renaming (almost :)
var DCT = dual_control_tools;

## Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type   = "Aircraft/Common-Spruce-CS1/Models/CS-1.xml";
var copilot_type = "Aircraft/Common-Spruce-CS1/Models/CS-1-Copilot.xml";

############################ PROPERTIES MP ###########################

#####
# pilot properties
##
var rpm              = "engines/engine/rpm";
var gear             = "gear/gear[1]/position-norm";

var elevator_trim    = "sim/multiplay/generic/float[7]";
var rudder_trim      = "sim/multiplay/generic/float[8]";
var aileron_trim     = "sim/multiplay/generic/float[9]";
var throttle         = "sim/multiplay/generic/float[10]";
var mixture          = "sim/multiplay/generic/float[11]";
var groundspeed      = "sim/multiplay/generic/float[12]";

var switch_mpp       = "sim/multiplay/generic/int[0]";
var lights_mpp       = "sim/multiplay/generic/int[1]";
var TDM_mpp1         = "sim/multiplay/generic/string[0]";
var TDM_mpp2         = "sim/multiplay/generic/string[2]";
var TDM_mpp3         = "sim/multiplay/generic/string[3]";

var voice_str        = "sim/multiplay/generic/string[4]";

var fuel_select      = "sim/multiplay/generic/int[7]";
var banner_show      = "sim/multiplay/generic/int[8]";
var smoke_active     = "sim/multiplay/generic/int[9]";


######################################################################
# Useful instrument related property paths.

# Flight controls
var elevator_trim_cmd = "controls/flight/elevator-trim";
var rudder_trim_cmd   = "controls/flight/rudder-trim";
var aileron_trim_cmd  = "controls/flight/aileron-trim";

# Engine controls
var throttle_cmd      = "controls/engines/engine/throttle";
var mixture_cmd       = "engines/engine/mixture";
var magnetos_cmd      = "controls/engines/engine/magnetos";
var rpm_cmd           = "engines/engine/rpm";

# Sound
var gear_cmd          = "gear/gear[1]/position-norm";

# FlightRalleyWatch
var frw_cmd           = ["instrumentation/frw/flight-time/hours", 
                         "instrumentation/frw/flight-time/minutes", 
                         "instrumentation/frw/flight-time/seconds"];

# Other controls
var comm_cmd          = ["instrumentation/comm/frequencies/selected-mhz", 
                         "instrumentation/comm/frequencies/standby-mhz"];
var nav_cmd           = ["instrumentation/nav/frequencies/selected-mhz", "instrumentation/nav/frequencies/standby-mhz"];
var adf_cmd           = ["instrumentation/adf/frequencies/selected-khz", "instrumentation/adf/frequencies/standby-khz"];
var fuel_select_cmd   = "controls/fuel/switch-position";
var tank_cmd          = ["consumables/fuel/tank/level-gal_us", 
                         "consumables/fuel/tank[1]/level-gal_us", 
                         "consumables/fuel/tank[2]/level-gal_us", 
                         "consumables/fuel/tank[3]/level-gal_us"];
var banner_show_cmd   = "controls/banner/show";
var smoke_active_cmd  = "smoke/active";
var smoke_sel_col_cmd = "smoke/color";
var smoke_cc_cmd      = ["smoke/colors/knob-blue",
                         "smoke/colors/knob-green",
                         "smoke/colors/knob-red"];

var groundspeed_cmd   = "velocities/groundspeed-kt";

var instr_cmd         = ["instrumentation/nav/radials/selected-deg", 
                         "instrumentation/altimeter/setting-inhg", 
                         "instrumentation/heading-indicator/offset-deg",
                         "autopilot/settings/target-speed-kt", 
                         "autopilot/settings/target-pitch-deg", 
                         "autopilot/settings/target-altitude-ft", 
                         "autopilot/settings/heading-bug-deg"];

var agl_cmd           = ["position/gear-agl-ft", "position/gear-agl-m"];

var voice_cmd         = "controls/airport/stewardess";
var voice_str_cmd     = "controls/airport/airport-country-id";

var landing_lights    = "controls/lighting/landing-lights";
var nav_lights        = "controls/lighting/nav-lights";
var instrument_lights = "controls/lighting/instrument-lights";

# Switch controls
var battery_switch    = "controls/electric/battery-switch";
var starter_switch    = "controls/engines/engine/starter";
var fuelpump_switch   = "controls/engines/engine/fuel-pump";
var generator_switch  = "controls/electric/engine/generator";
var adf_switch        = "instrumentation/adf/adf-btn";
var gear_down_switch  = "controls/gear/gear-down";
var crashed_switch    = "sim/crashed";

# Boolean properties
var running        = "engines/engine/running";
var cranking       = "engines/engine/cranking";
var brake_parking  = "controls/gear/brake-parking";
var gear_wow       = ["gear/gear[0]/wow", "gear/gear[1]/wow", "gear/gear[2]/wow"];
var smoke_scale    = ["smoke/colors/color[0]/scale",
                      "smoke/colors/color[1]/scale",
                      "smoke/colors/color[2]/scale",
                      "smoke/colors/color[3]/scale"];
var ap_switch      = ["autopilot/switches/ap",
                      "autopilot/switches/hdg",
                      "autopilot/switches/alt",
                      "autopilot/switches/ias",
                      "autopilot/switches/nav",
                      "autopilot/switches/appr"];

var l_dual_control    = "dual-control/active";

######################################################################
###### Used by dual_control to set up the mappings for the pilot #####
######################## PILOT TO COPILOT ############################
######################################################################

var pilot_connect_copilot = func (copilot) {
  # Make sure dual-control is activated in the FDM FCS.
  print("Pilot section");
  setprop(l_dual_control, 1);

  return [
      ##################################################
      # Map copilot properties to buffer properties

      # copilot to pilot

      DCT.TDMEncoder.new
        ([
          props.globals.getNode(magnetos_cmd),
          props.globals.getNode(nav_cmd[0]),
          props.globals.getNode(nav_cmd[1]),
          props.globals.getNode(comm_cmd[0]),
          props.globals.getNode(comm_cmd[1]),
          props.globals.getNode(adf_cmd[0]),
          props.globals.getNode(adf_cmd[1]),
          props.globals.getNode(instr_cmd[0]),
          props.globals.getNode(instr_cmd[1]),
          props.globals.getNode(instr_cmd[2]),
          props.globals.getNode(instr_cmd[3]),
          props.globals.getNode(instr_cmd[4]),
          props.globals.getNode(instr_cmd[5]),
          props.globals.getNode(instr_cmd[6])
         ], props.globals.getNode(TDM_mpp1)),      
      DCT.TDMEncoder.new
        ([
          props.globals.getNode(tank_cmd[0]),
          props.globals.getNode(tank_cmd[1]),
          props.globals.getNode(tank_cmd[2]),
          props.globals.getNode(tank_cmd[3]),
          props.globals.getNode(frw_cmd[0]),
          props.globals.getNode(frw_cmd[1]),
          props.globals.getNode(frw_cmd[2]),
          props.globals.getNode(smoke_sel_col_cmd),
          props.globals.getNode(smoke_cc_cmd[0]),
          props.globals.getNode(smoke_cc_cmd[1]),
          props.globals.getNode(smoke_cc_cmd[2]),
          props.globals.getNode(agl_cmd[0]),
          props.globals.getNode(agl_cmd[1])
         ], props.globals.getNode(TDM_mpp2)),
      DCT.SwitchEncoder.new
        ([
          props.globals.getNode(battery_switch),
          props.globals.getNode(starter_switch),
          props.globals.getNode(fuelpump_switch),
          props.globals.getNode(generator_switch),
          props.globals.getNode(running),
          props.globals.getNode(cranking),
          props.globals.getNode(brake_parking),
          props.globals.getNode(adf_switch),
          props.globals.getNode(gear_down_switch),
          props.globals.getNode(crashed_switch),
          props.globals.getNode(gear_wow[0]),
          props.globals.getNode(gear_wow[1]),
          props.globals.getNode(gear_wow[2])
         ], props.globals.getNode(switch_mpp)),
      DCT.SwitchEncoder.new
        ([
          props.globals.getNode(landing_lights),
          props.globals.getNode(nav_lights),
          props.globals.getNode(instrument_lights),
          props.globals.getNode(voice_cmd),
          props.globals.getNode(smoke_scale[0]),
          props.globals.getNode(smoke_scale[1]),
          props.globals.getNode(smoke_scale[2]),
          props.globals.getNode(smoke_scale[3]),
          props.globals.getNode(ap_switch[0]),
          props.globals.getNode(ap_switch[1]),
          props.globals.getNode(ap_switch[2]),
          props.globals.getNode(ap_switch[3]),
          props.globals.getNode(ap_switch[4]),
          props.globals.getNode(ap_switch[5])
         ], props.globals.getNode(lights_mpp)),

  ];
}

##############
var pilot_disconnect_copilot = func {
  setprop(l_dual_control, 0);
}

######################################################################
##### Used by dual_control to set up the mappings for the copilot ####
######################## COPILOT TO PILOT ############################
######################################################################

var copilot_connect_pilot = func (pilot) {
  # Make sure dual-control is activated in the FDM FCS.
  print("Copilot section");
  setprop(l_dual_control, 1);

  return [

      ##################################################
      # Map pilot properties to buffer properties
      DCT.StableTrigger.new(pilot.getNode(throttle), func(v){props.globals.getNode(throttle_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(mixture), func(v){props.globals.getNode(mixture_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(elevator_trim), func(v){props.globals.getNode(elevator_trim_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(rudder_trim), func(v){props.globals.getNode(rudder_trim_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(aileron_trim), func(v){props.globals.getNode(aileron_trim_cmd, 1).setValue(v);}),

      DCT.Translator.new(pilot.getNode(rpm), props.globals.getNode(rpm_cmd, 1)),
      DCT.Translator.new(pilot.getNode(gear), props.globals.getNode(gear_cmd, 1)),
      DCT.Translator.new(pilot.getNode(groundspeed), props.globals.getNode(groundspeed_cmd, 1)),
      DCT.Translator.new(pilot.getNode(fuel_select), props.globals.getNode(fuel_select_cmd, 1)),
      DCT.Translator.new(pilot.getNode(banner_show), props.globals.getNode(banner_show_cmd, 1)),
      DCT.Translator.new(pilot.getNode(smoke_active), props.globals.getNode(smoke_active_cmd, 1)),
      DCT.Translator.new(pilot.getNode(voice_str), props.globals.getNode(voice_str_cmd, 1)),

      ##################################################
      # Map pilot properties to buffer properties
      DCT.TDMDecoder.new
        (pilot.getNode(TDM_mpp1), 
        [func(v){pilot.getNode(magnetos_cmd, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~magnetos_cmd, 1).setValue(v);},
         func(v){pilot.getNode(nav_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~nav_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(nav_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~nav_cmd[1], 1).setValue(v);},
         func(v){pilot.getNode(comm_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~comm_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(comm_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~comm_cmd[1], 1).setValue(v);},
         func(v){pilot.getNode(adf_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~adf_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(adf_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~adf_cmd[1], 1).setValue(v);},
         func(v){pilot.getNode(instr_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instr_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(instr_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instr_cmd[1], 1).setValue(v);},
         func(v){pilot.getNode(instr_cmd[2], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instr_cmd[2], 1).setValue(v);},
         func(v){pilot.getNode(instr_cmd[3], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instr_cmd[3], 1).setValue(v);},
         func(v){pilot.getNode(instr_cmd[4], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instr_cmd[4], 1).setValue(v);},
         func(v){pilot.getNode(instr_cmd[5], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instr_cmd[5], 1).setValue(v);},
         func(v){pilot.getNode(instr_cmd[6], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instr_cmd[6], 1).setValue(v);},
        ]),

      DCT.TDMDecoder.new
        (pilot.getNode(TDM_mpp2), 
        [
         func(v){pilot.getNode(tank_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~tank_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(tank_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~tank_cmd[1], 1).setValue(v);},
         func(v){pilot.getNode(tank_cmd[2], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~tank_cmd[2], 1).setValue(v);},
         func(v){pilot.getNode(tank_cmd[3], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~tank_cmd[3], 1).setValue(v);},
        func(v){pilot.getNode(frw_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~frw_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(frw_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~frw_cmd[1], 1).setValue(v);},
         func(v){pilot.getNode(frw_cmd[2], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~frw_cmd[2], 1).setValue(v);},
         func(v){pilot.getNode(smoke_sel_col_cmd, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~smoke_sel_col_cmd, 1).setValue(v);},
         func(v){pilot.getNode(smoke_cc_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~smoke_cc_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(smoke_cc_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~smoke_cc_cmd[1], 1).setValue(v);},
         func(v){pilot.getNode(smoke_cc_cmd[2], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~smoke_cc_cmd[2], 1).setValue(v);},
         func(v){pilot.getNode(agl_cmd[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~agl_cmd[0], 1).setValue(v);},
         func(v){pilot.getNode(agl_cmd[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~agl_cmd[1], 1).setValue(v);},
        ]),

      DCT.SwitchDecoder.new
        (pilot.getNode(switch_mpp),
        [func(b){props.globals.getNode(battery_switch).setValue(b);},
         func(b){props.globals.getNode(starter_switch).setValue(b);},
         func(b){props.globals.getNode(fuelpump_switch).setValue(b);},
         func(b){props.globals.getNode(generator_switch).setValue(b);},
         func(b){props.globals.getNode(running).setValue(b);},
         func(b){props.globals.getNode(cranking).setValue(b);},
         func(b){props.globals.getNode(brake_parking).setValue(b);},
         func(b){props.globals.getNode(adf_switch).setValue(b);},
         func(b){props.globals.getNode(gear_down_switch).setValue(b);},
         func(b){props.globals.getNode(crashed_switch).setValue(b);},
         func(b){props.globals.getNode(gear_wow[0]).setValue(b);},
         func(b){props.globals.getNode(gear_wow[1]).setValue(b);},
         func(b){props.globals.getNode(gear_wow[2]).setValue(b);}
        ]),

      DCT.SwitchDecoder.new
        (pilot.getNode(lights_mpp),
        [func(b){props.globals.getNode(landing_lights).setValue(b);},
         func(b){props.globals.getNode(nav_lights).setValue(b);},
         func(b){props.globals.getNode(instrument_lights).setValue(b);},
         func(b){props.globals.getNode(voice_cmd).setValue(b);},
         func(b){props.globals.getNode(smoke_scale[0]).setValue(b);},
         func(b){props.globals.getNode(smoke_scale[1]).setValue(b);},
         func(b){props.globals.getNode(smoke_scale[2]).setValue(b);},
         func(b){props.globals.getNode(smoke_scale[3]).setValue(b);},
         func(b){props.globals.getNode(ap_switch[0]).setValue(b);},
         func(b){props.globals.getNode(ap_switch[1]).setValue(b);},
         func(b){props.globals.getNode(ap_switch[2]).setValue(b);},
         func(b){props.globals.getNode(ap_switch[3]).setValue(b);},
         func(b){props.globals.getNode(ap_switch[4]).setValue(b);},
         func(b){props.globals.getNode(ap_switch[5]).setValue(b);},
        ]),

      ##################################################
      # Animation of the knobs and more
      
      # copilot to pilot

      # switch_mpp
      DCT.Translator.new(props.globals.getNode(battery_switch, 1), pilot.getNode("/"~battery_switch)),
      DCT.Translator.new(props.globals.getNode(starter_switch, 1), pilot.getNode("/"~starter_switch)),
      DCT.Translator.new(props.globals.getNode(fuelpump_switch, 1), pilot.getNode("/"~fuelpump_switch)),
      DCT.Translator.new(props.globals.getNode(generator_switch, 1), pilot.getNode("/"~generator_switch)),
      DCT.Translator.new(props.globals.getNode(running, 1), pilot.getNode("/"~running)),
      DCT.Translator.new(props.globals.getNode(cranking, 1), pilot.getNode("/"~cranking)),
      DCT.Translator.new(props.globals.getNode(brake_parking, 1), pilot.getNode("/"~brake_parking)),
      DCT.Translator.new(props.globals.getNode(adf_switch, 1), pilot.getNode("/"~adf_switch)),
      DCT.Translator.new(props.globals.getNode(gear_down_switch, 1), pilot.getNode("/"~gear_down_switch)),
      DCT.Translator.new(props.globals.getNode(crashed_switch, 1), pilot.getNode("/"~crashed_switch)),
      DCT.Translator.new(props.globals.getNode(gear_wow[0], 1), pilot.getNode("/"~gear_wow[0])),
      DCT.Translator.new(props.globals.getNode(gear_wow[1], 1), pilot.getNode("/"~gear_wow[1])),
      DCT.Translator.new(props.globals.getNode(gear_wow[2], 1), pilot.getNode("/"~gear_wow[2])),
      # lights_mpp
      DCT.Translator.new(props.globals.getNode(landing_lights, 1), pilot.getNode("/"~landing_lights)),
      DCT.Translator.new(props.globals.getNode(nav_lights, 1), pilot.getNode("/"~nav_lights)),
      DCT.Translator.new(props.globals.getNode(instrument_lights, 1), pilot.getNode("/"~instrument_lights)),
      DCT.Translator.new(props.globals.getNode(voice_cmd, 1), pilot.getNode("/"~voice_cmd)),
      DCT.Translator.new(props.globals.getNode(smoke_scale[0], 1), pilot.getNode("/"~smoke_scale[0])),
      DCT.Translator.new(props.globals.getNode(smoke_scale[1], 1), pilot.getNode("/"~smoke_scale[1])),
      DCT.Translator.new(props.globals.getNode(smoke_scale[2], 1), pilot.getNode("/"~smoke_scale[2])),
      DCT.Translator.new(props.globals.getNode(smoke_scale[3], 1), pilot.getNode("/"~smoke_scale[3])),
      DCT.Translator.new(props.globals.getNode(ap_switch[0], 1), pilot.getNode("/"~ap_switch[0])),
      DCT.Translator.new(props.globals.getNode(ap_switch[1], 1), pilot.getNode("/"~ap_switch[1])),
      DCT.Translator.new(props.globals.getNode(ap_switch[2], 1), pilot.getNode("/"~ap_switch[2])),
      DCT.Translator.new(props.globals.getNode(ap_switch[3], 1), pilot.getNode("/"~ap_switch[3])),
      DCT.Translator.new(props.globals.getNode(ap_switch[4], 1), pilot.getNode("/"~ap_switch[4])),
      DCT.Translator.new(props.globals.getNode(ap_switch[5], 1), pilot.getNode("/"~ap_switch[5])),
      # TDM_mpp1
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~magnetos_cmd, 1), props.globals.getNode(magnetos_cmd), props.globals.getNode(magnetos_cmd), 0.1),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~nav_cmd[0], 1), props.globals.getNode(nav_cmd[0]), props.globals.getNode(nav_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~nav_cmd[1], 1), props.globals.getNode(nav_cmd[1]), props.globals.getNode(nav_cmd[1]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~comm_cmd[0], 1), props.globals.getNode(comm_cmd[0]), props.globals.getNode(comm_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~comm_cmd[1], 1), props.globals.getNode(comm_cmd[1]), props.globals.getNode(comm_cmd[1]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~adf_cmd[0], 1), props.globals.getNode(adf_cmd[0]), props.globals.getNode(adf_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~adf_cmd[1], 1), props.globals.getNode(adf_cmd[1]), props.globals.getNode(adf_cmd[1]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~instr_cmd[0], 1), props.globals.getNode(instr_cmd[0]), props.globals.getNode(instr_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~instr_cmd[1], 1), props.globals.getNode(instr_cmd[1]), props.globals.getNode(instr_cmd[1]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~instr_cmd[2], 1), props.globals.getNode(instr_cmd[2]), props.globals.getNode(instr_cmd[2]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~instr_cmd[3], 1), props.globals.getNode(instr_cmd[3]), props.globals.getNode(instr_cmd[3]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~instr_cmd[4], 1), props.globals.getNode(instr_cmd[4]), props.globals.getNode(instr_cmd[4]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~instr_cmd[5], 1), props.globals.getNode(instr_cmd[5]), props.globals.getNode(instr_cmd[5]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~instr_cmd[6], 1), props.globals.getNode(instr_cmd[6]), props.globals.getNode(instr_cmd[6]), 0.01),
      # TDM_mpp2
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~tank_cmd[0], 1), props.globals.getNode(tank_cmd[0]), props.globals.getNode(tank_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~tank_cmd[1], 1), props.globals.getNode(tank_cmd[1]), props.globals.getNode(tank_cmd[1]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~tank_cmd[2], 1), props.globals.getNode(tank_cmd[2]), props.globals.getNode(tank_cmd[2]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~tank_cmd[3], 1), props.globals.getNode(tank_cmd[3]), props.globals.getNode(tank_cmd[3]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~frw_cmd[0], 1), props.globals.getNode(frw_cmd[0]), props.globals.getNode(frw_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~frw_cmd[1], 1), props.globals.getNode(frw_cmd[1]), props.globals.getNode(frw_cmd[1]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~frw_cmd[2], 1), props.globals.getNode(frw_cmd[2]), props.globals.getNode(frw_cmd[2]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~smoke_sel_col_cmd, 1), props.globals.getNode(smoke_sel_col_cmd), props.globals.getNode(smoke_sel_col_cmd), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~smoke_cc_cmd[0], 1), props.globals.getNode(smoke_cc_cmd[0]), props.globals.getNode(smoke_cc_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~smoke_cc_cmd[1], 1), props.globals.getNode(smoke_cc_cmd[1]), props.globals.getNode(smoke_cc_cmd[1]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~smoke_cc_cmd[2], 1), props.globals.getNode(smoke_cc_cmd[2]), props.globals.getNode(smoke_cc_cmd[2]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~agl_cmd[0], 1), props.globals.getNode(agl_cmd[0]), props.globals.getNode(agl_cmd[0]), 0.01),
      DCT.MostRecentSelector.new(props.globals.getNode("dual-control/pilot/"~agl_cmd[1], 1), props.globals.getNode(agl_cmd[1]), props.globals.getNode(agl_cmd[1]), 0.01),
  ];

}

var copilot_disconnect_pilot = func {
  setprop(l_dual_control, 0);
}
