######################### the original cs1.nas ################################
# This aircraft is for acrobatic - so, no G-Problems
# setprop("/sim/rendering/redout/enabled", 0);

# Trim action
var applyTrimWheels = func(v, which = 0) {
   # nothing to do for copilot - do nothing on function call by copilot
}

# Door action
var PilotDoor = func {
   # nothing to do for copilot - do nothing on function call by copilot
}
var CopilotDoor = func {
   # nothing to do for copilot - do nothing on function call by copilot
}

# gear-warning
setlistener("/position/gear-agl-ft", func(agl){
    var agl = agl.getValue() or 0;
    var gear = getprop("/gear/gear[1]/position-norm") or 0;
    var pitch = getprop("/orientation/pitch-deg") or 0;

    if( agl < 1000 and gear < 1 and pitch < 0){
        setprop("/sim/alarms/gear-warning", 1);
    }else{
        setprop("/sim/alarms/gear-warning", 0);
    }
},1,0);



####  piston engine electrical system    #### 
####    Syd Adams    ####

var ammeter_ave = 0.0;
var outPut = "systems/electrical/outputs/";
var BattVolts = props.globals.getNode("systems/electrical/batt-volts",1);
var Volts = props.globals.getNode("/systems/electrical/volts",1);
var Amps = props.globals.getNode("/systems/electrical/amps",1);
var EXT  = props.globals.getNode("/controls/electric/external-power",1); 
var switch_list=[];
var output_list=[];
var watt_list=[];


strobe_switch = props.globals.getNode("controls/lighting/strobe", 0);
aircraft.light.new("controls/lighting/strobe-state", [0.05,0.1,0.05,0.1,0.05,1.30], strobe_switch);
beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);

#var battery = Battery.new(switch-prop,volts,amps,amp_hours,charge_percent,charge_amps);
Battery = {
    new : func(swtch,vlt,amp,hr,chp,cha){
    m = { parents : [Battery] };
            m.switch = props.globals.getNode(swtch,1);
            m.switch.setBoolValue(0);
            m.ideal_volts = vlt;
            m.ideal_amps = amp;
            m.amp_hours = hr;
            m.charge_percent = chp; 
            m.charge_amps = cha;
    return m;
    },
    apply_load : func(load,dt) {
        if(me.switch.getValue()){
        var amphrs_used = load * dt / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
        }
        var output =me.amp_hours * me.charge_percent;
        return output;
        }else return 0;
    },

    get_output_volts : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_volts * factor;
            return output;
        }else return 0;
    },

    get_output_amps : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_amps * factor;
            return output;
        }else return 0;
    }
};

# var alternator = Alternator.new(num,switch,rpm_source,rpm_threshold,volts,amps);
Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(0);
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.meter.setDoubleValue(0);
        m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.gen_output.setDoubleValue(0);
        m.meter.setDoubleValue(0);
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        return m;
    },

    apply_load : func(load) {
        var cur_volt=me.gen_output.getValue();
        var cur_amp=me.meter.getValue();
        if(cur_volt >1){
            var factor=1/cur_volt;
            gout = (load * factor);
            if(gout>1)gout=1;
        }else{
            gout=0;
        }
        if(cur_amp > gout)me.meter.setValue(cur_amp - 0.01);
        if(cur_amp < gout)me.meter.setValue(cur_amp + 0.01);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        return out;
    },

    get_output_amps : func {
        var ampout =0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
    }
};

var battery = Battery.new("/controls/electric/battery-switch",24,30,34,1.0,7.0);
var alternator1 = Alternator.new(0,"controls/electric/engine[0]/generator","/engines/engine[0]/rpm",100.0,28.0,60.0);

#####################################
setlistener("/sim/signals/fdm-initialized", func {
    BattVolts.setDoubleValue(0);
    init_switches();
    settimer(update_electrical,5);
    print("Electrical System ... ok");

});

init_switches = func() {
    var tprop=props.globals.getNode("controls/electric/ammeter-switch",1);
    tprop.setBoolValue(1);
    tprop=props.globals.getNode("controls/lighting/instrument-lights",1);
    tprop.setBoolValue(0);

    setprop("controls/lighting/instrument-lights-norm",0.8);
    setprop("controls/lighting/efis-norm",0.8);
    setprop("controls/lighting/panel-norm",0.8);

    append(switch_list,"controls/engines/engine/starter");
    append(output_list,"starter");
    append(watt_list,10.0);

    append(switch_list,"controls/lighting/landing-lights");
    append(output_list,"landing-lights");
    append(watt_list,1.0);

    append(switch_list,"controls/lighting/beacon-state/state");
    append(output_list,"beacon");
    append(watt_list,0.5);

    append(switch_list,"controls/lighting/strobe-state/state");
    append(output_list,"strobe");
    append(watt_list,0.5);

    append(switch_list,"controls/lighting/nav-lights");
    append(output_list,"nav-lights");
    append(watt_list,0.5);

    append(switch_list,"controls/engines/engine/fuel-pump");
    append(output_list,"fuel-pump");
    append(watt_list,0.5);

    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"adf");
    append(watt_list,0.2);

    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"dme");
    append(watt_list,0.2);

#    append(switch_list,"controls/electric/avionics-switch");
#    append(output_list,"gps");
#    append(watt_list,0.5);

    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"DG");
    append(watt_list,0.2);

    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"transponder");
    append(watt_list,0.2);

#    append(switch_list,"controls/electric/avionics-switch");
#    append(output_list,"mk-viii");
#    append(watt_list,0.2);

#    append(switch_list,"controls/electric/avionics-switch");
#    append(output_list,"tacan");
#    append(watt_list,0.2);

    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"turn-coordinator");
    append(watt_list,0.2);

    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"comm");
    append(watt_list,0.2);

    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"nav");
    append(watt_list,0.2);

    for(var i=0; i<size(switch_list); i+=1) {
        var tmp = props.globals.getNode(switch_list[i],1);
        tmp.setBoolValue(0);
    }
setprop("controls/electric/avionics-switch",1);
}

update_virtual_bus = func( dt ) {
    var PWR = getprop("systems/electrical/serviceable");
    var battery_volts = battery.get_output_volts();
    BattVolts.setValue(battery_volts);
    var alternator1_volts = alternator1.get_output_volts();
    var external_volts = 24.0;

    load = 0.0;
    bus_volts = 0.0;
    power_source = nil;
        
        bus_volts = battery_volts;
        power_source = "battery";

    if (alternator1_volts > bus_volts) {
        bus_volts = alternator1_volts;
        power_source = "alternator1";
        }

    if ( EXT.getBoolValue() and ( external_volts > bus_volts) ) {
        bus_volts = external_volts;
        }

    bus_volts *=PWR;

    load += electrical_bus(bus_volts);

    ammeter = 0.0;

    if ( power_source == "battery" ) {
        ammeter = -load;
        } else {
        ammeter = battery.charge_amps;
    }

    if ( power_source == "battery" ) {
        battery.apply_load( load, dt );
        } elsif ( bus_volts > battery_volts ) {
        battery.apply_load( -battery.charge_amps, dt );
        }

    ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

   Amps.setValue(ammeter_ave);
   Volts.setValue(bus_volts);
    alternator1.apply_load(load);

return load;
}

electrical_bus = func(bv) {
    var bus_volts = bv;
    var load = 0.0;
    var srvc = 0.0;


    for(var i=0; i<size(switch_list); i+=1) {
        var srvc = getprop(switch_list[i]);
        load = load + srvc * watt_list[i];
        setprop(outPut~output_list[i],bus_volts * srvc);
    }

    var DIMMER = bus_volts * getprop("controls/lighting/instrument-lights-norm");
    EFIS_DIMMER = getprop("controls/lighting/efis-norm");
    var INSTR_SWTCH = getprop("controls/lighting/instrument-lights");
    DIMMER=DIMMER*INSTR_SWTCH;

    setprop(outPut~"instrument-lights",DIMMER);
    setprop(outPut~"instrument-lights-norm",DIMMER * 0.0357);
    setprop(outPut~"efis-lights",(bus_volts * EFIS_DIMMER));

    return load;
}

update_electrical = func {
    var scnd = getprop("sim/time/delta-sec");
    update_virtual_bus( scnd );
settimer(update_electrical, 0);
}



######################### the original cs1.nas ################################
# This aircraft is for acrobatic - so, no G-Problems
setprop("/sim/rendering/redout/enabled", 0);
# Livery initialisation
aircraft.livery.init("Aircraft/Common-Spruce-CS1/Models/Liveries");
# Now start the work with init
var volume=props.globals.initNode("/sim/sound/sim-volume",0.0);
var idle_volume=props.globals.initNode("/sim/sound/idle-volume",0.0);
var floats = 0;
var beacon_light = props.globals.initNode("/controls/lighting/beacon", 0.0);
var strobe_light = props.globals.initNode("/controls/lighting/strobe", 0.0);

var TireSpeed = {
    new : func(number){
        m = { parents : [TireSpeed] };
            m.num=number;
            m.circumference=[];
            m.tire=[];
            m.rpm=[];
            for(var i=0; i<m.num; i+=1) {
                var diam =arg[i];
                var circ=diam * math.pi;
                append(m.circumference,circ);
                append(m.tire,props.globals.initNode("gear/gear["~i~"]/tire-rpm",0,"DOUBLE"));
                append(m.rpm,0);
            }
        m.count = 0;
        return m;
    },
    #### calculate and write rpm ###########
    get_rotation: func (fdm1){
        var speed=0;
        if(fdm1=="yasim"){
            speed =getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
            speed=speed*60;
            }elsif(fdm1=="jsb"){
                speed =getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
                speed=speed*18.288;
            }
        var wow = getprop("gear/gear["~me.count~"]/wow");
        if(wow){
            me.rpm[me.count] = speed / me.circumference[me.count];
        }else{
            if(me.rpm[me.count] > 0) me.rpm[me.count]=me.rpm[me.count]*0.95;
        }
        me.tire[me.count].setValue(me.rpm[me.count]);
        me.count+=1;
        if(me.count>=me.num)me.count=0;
    },
};

#Engine sensors class 
# ie: var Eng = Engine.new(engine number);
var Engine = {
    new : func(eng_num){
        m = { parents : [Engine]};
        m.air_temp = props.globals.initNode("environment/temperature-degc");
        m.oat = m.air_temp.getValue() or 0;
        m.ot_target=60;
        m.eng = props.globals.initNode("engines/engine["~eng_num~"]");
        m.running = 0;
        m.mp = m.eng.initNode("mp-inhg");
        m.cutoff = props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff");
        m.mixture = props.globals.initNode("controls/engines/engine["~eng_num~"]/mixture");
        m.mixture_lever = props.globals.initNode("engines/engine["~eng_num~"]/mixture",1,"DOUBLE");
        m.rpm = m.eng.initNode("rpm",1);
        m.oil_temp=m.eng.initNode("oil-temp-c",m.oat,"DOUBLE");
        m.carb_temp=m.eng.initNode("carb-temp-c",m.oat,"DOUBLE");
        m.oil_psi=m.eng.initNode("oil-pressure-psi",0.0,"DOUBLE");
        m.smoke=m.eng.initNode("smoke",0,"BOOL");
        m.firing=m.eng.initNode("firing",0.0,"DOUBLE");
        m.fuel_psi=m.eng.initNode("fuel-psi-norm",0,"DOUBLE");
        m.fuel_out=m.eng.initNode("out-of-fuel",0,"BOOL");
        m.fuel_switch=props.globals.initNode("controls/fuel/switch-position",-1,"INT");
        m.hpump=props.globals.initNode("systems/hydraulics/pump-psi["~eng_num~"]",0,"DOUBLE");

        m.smk0=0.0;
        m.smk1=0.0;

    m.Lrunning = setlistener("engines/engine["~eng_num~"]/running",func (rn){m.running=rn.getValue();},1,0);
    return m;
    },
#### update ####
    update : func{
        var mx =me.mixture_lever.getValue();
    me.mixture.setValue(mx);
        var hpsi =me.rpm.getValue();
        var fpsi =me.fuel_psi.getValue();
        var oilpsi=hpsi * 0.001;
        if(oilpsi>0.7)oilpsi =0.7;
        me.oil_psi.setValue(oilpsi);
        if(hpsi>60)hpsi = 60;
        me.hpump.setValue(hpsi);
        var rpm = me.rpm.getValue();
        var mp=me.mp.getValue();
    var OT= me.oil_temp.getValue();
    var cooling=(getprop("velocities/airspeed-kt") * 0.1) *2;
    cooling+=(mx * 5);
    var tgt=me.ot_target + mp;
    var tgt-=cooling;
    if(me.running){
        if(OT < tgt) OT+=rpm * 0.00001;
        if(OT > tgt) OT-=cooling * 0.001;
        }else{
        if(OT > me.air_temp.getValue()) OT-=0.001; 
    }
        me.oil_temp.setValue(OT);
        var fpVolts =getprop("systems/electrical/outputs/fuel-pump");
        if(fpVolts==nil)fpVolts=0;
    var ctemp=me.air_temp.getValue();
    ctemp -= (rpm * 0.007);
    me.carb_temp.setValue(ctemp);
        if(fpVolts>5){
            if(fpsi<0.5000)fpsi += 0.01;
        }else{
            if(fpsi>0.000) fpsi -= 0.01;
        }
        me.fuel_psi.setValue(fpsi);
        if(fpsi < 0.2){
            me.mixture.setValue(fpsi);
        }
        var idlesnd=(rpm-500)*0.001;
        if(idlesnd>1)idlesnd=1;
        idlesnd=1-idlesnd;
        idle_volume.setValue(idlesnd);

    me.smk1=me.firing.getValue();
    if((me.smk1 - me.smk0)>0.000000)me.smoke.setValue(1) else me.smoke.setValue(0);
    me.smk0=me.smk1;
    },

    fuel_select : func (sw){
        print("tank selection ... only pilot can do this");
    },

};
##################################

var WaspJr = Engine.new(0);
var tire=TireSpeed.new(3,0.76,0.76,0.33);

setlistener("/sim/signals/fdm-initialized", func {
    WaspJr.fuel_select(0);
    volume.setValue(0.5);
    if(getprop("sim/aero")=="cs1F")floats=1;
    settimer(update,1);
});

setlistener("/sim/current-view/internal", func(vw){
    if(vw.getValue()){
        volume.setValue(0.4);
    }else{
        volume.setValue(1.0);
    }
},1,0);

setlistener("systems/electrical/outputs/beacon", func(bn){
    var beacon = bn.getValue()or 0;

    if( beacon > 5){
        setprop("/controls/lighting/beacon-light", 1);
    }else{
        setprop("/controls/lighting/beacon-light", 0);
    }
},1,0);

setlistener("systems/electrical/outputs/strobe", func(bn){
    var strobe = bn.getValue()or 0;

    if( strobe > 5){
        setprop("/controls/lighting/strobe-light", 1);
    }else{
        setprop("/controls/lighting/strobe-light", 0);
    }
},1,0);

var secure = func{
    props.globals.getNode("/controls/winch/place").setBoolValue(1);
    settimer(set_winch,1);
}

var set_winch = func{
    props.globals.getNode("/controls/winch/place").setBoolValue(0);
}


controls.startEngine = func(v = 1) {
    var vlt = getprop("systems/electrical/volts") or 0;
    if(vlt < 15) v=0;
    setprop("controls/engines/engine/starter",v);
}


var update = func {
    WaspJr.update();
        if(floats ==0)tire.get_rotation("yasim");
        var ia=getprop("velocities/airspeed-kt");
        if(ia>40){
            if(getprop("/controls/doors/position-norm[0]"))setprop("/controls/doors/position-norm[0]",0);
            if(getprop("/controls/doors/position-norm[1]"))setprop("/controls/doors/position-norm[1]",0);
        }
    settimer(update,0);
}

