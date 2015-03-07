## Smoke ##
SmokeToggle = func
{
  var smoke=props.globals.getNode("/smoke");
  smoke.getChild("active").setValue(!smoke.getChild("active").getValue());
  # must set the sim/multiplay/gerneric/int[9] manual
  var new = smoke.getChild("active").getValue();
  setprop("/sim/multiplay/generic/int[9]",new);

}

SmokeColor = func
{
  var smoke  = props.globals.getNode("/smoke");

  #from first to second
  if(smoke.getChild("color").getValue()=="0") {
    smoke.getChild("color").setValue("1");
    smoke.getChild("red").setValue(getprop("/smoke/colors/color[1]/red"));
    smoke.getChild("green").setValue(getprop("/smoke/colors/color[1]/green"));
    smoke.getChild("blue").setValue(getprop("/smoke/colors/color[1]/blue"));
  }
  #from second to third
  else if(smoke.getChild("color").getValue()=="1") {
    smoke.getChild("color").setValue("2");
    smoke.getChild("red").setValue(getprop("/smoke/colors/color[2]/red"));
    smoke.getChild("green").setValue(getprop("/smoke/colors/color[2]/green"));
    smoke.getChild("blue").setValue(getprop("/smoke/colors/color[2]/blue"));
  }
  #from third to fourth
  else if(smoke.getChild("color").getValue()=="2") {
    smoke.getChild("color").setValue("3");
    smoke.getChild("red").setValue(getprop("/smoke/colors/color[3]/red"));
    smoke.getChild("green").setValue(getprop("/smoke/colors/color[3]/green"));
    smoke.getChild("blue").setValue(getprop("/smoke/colors/color[3]/blue"));
  }
  #from otherwise to white
  else {
    smoke.getChild("color").setValue("0");
    smoke.getChild("red").setValue(getprop("/smoke/colors/color[0]/red"));
    smoke.getChild("green").setValue(getprop("/smoke/colors/color[0]/green"));
    smoke.getChild("blue").setValue(getprop("/smoke/colors/color[0]/blue"));
  }
}

SmokeSelColor = func(nr)
{
  var smoke  = props.globals.getNode("/smoke");
  smoke.getChild("color").setValue(nr);
  smoke.getChild("red").setValue(getprop("/smoke/colors/color["~nr~"]/red"));
  smoke.getChild("green").setValue(getprop("/smoke/colors/color["~nr~"]/green"));
  smoke.getChild("blue").setValue(getprop("/smoke/colors/color["~nr~"]/blue"));
}

SmokeCounter = func(step)
{
  var smoke=props.globals.getNode("/smoke");
  smoke.getChild("particlepersec").setValue(smoke.getChild("particlepersec").getValue()+step);
  if(smoke.getChild("particlepersec").getValue()<0) {
    smoke.getChild("particlepersec").setValue(0);
  }
  i=0;
  var smokeai=props.globals.getNode("/ai/models/multiplayer[0]/");
  while(smokeai!=nil) {
    if(smokeai.getNode("sim/model/path").getValue()=="Aircraft/Common-Spruce-CS1/Models/cs1.xml") {
      smokeai.getNode("smoke/particlepersec").setValue(smoke.getChild("particlepersec").getValue());
    }
    i=i+1;
    smokeai=props.globals.getNode("/ai/models/multiplayer["~i~"]");
  }
  #print("Smoke particle per second: ",smoke.getChild("particlepersec").getValue());
}

############# the smoke color mixer #####################

ChangeColor = func(nr)
{
  var colors = props.globals.getNode("/smoke/colors").getChildren("color");
  var knobs = props.globals.getNode("/smoke/colors");
  # the selected smoke color 
  var state = colors[nr].getNode("scale").getValue();
  
  # first switch all mixer-colors off
  for(var i=0; i<size(colors); i+=1) {
    colors[i].getNode("scale").setValue(0);
  }

  # if the selected smoke color was off, switch on now and save the knob settings to this color
  if (!state){
    # switch on the selected smoke-color if its off or do nothing
    colors[nr].getNode("scale").setValue(1);
    # map the selected smoke-color-parameters to the knobs
    knobs.getNode("knob-red").setValue(colors[nr].getNode("red").getValue());
    knobs.getNode("knob-green").setValue(colors[nr].getNode("green").getValue());
    knobs.getNode("knob-blue").setValue(colors[nr].getNode("blue").getValue());
  }else{
    # turn back the knobs to zero
    knobs.getNode("knob-red").setValue(0);
    knobs.getNode("knob-green").setValue(0);
    knobs.getNode("knob-blue").setValue(0);
  }
}

KnobScroll = func(step,selectedcolor) {
  var colors = props.globals.getNode("/smoke/colors").getChildren("color");
  # first we set the changings to the properties parameter
  for(var i=0; i<size(colors); i+=1) {
    # if a color is selected for scaling (switch is on)
    if (colors[i].getNode("scale").getValue()) {
      var val=colors[i].getNode(selectedcolor).getValue() + (step);
      if(val >1.0) val = 1.0;
      if(val < 0.0) val = 0.0;
      #save the new val in the pre-selection
      colors[i].getNode(selectedcolor).setValue(val);
      #if this color is active for the moment, change the colors there too
      var actualsmoke  = props.globals.getNode("/smoke");
      if (actualsmoke.getChild("color").getValue() == i){
        actualsmoke.getChild(selectedcolor).setValue(getprop("/smoke/colors/color["~i~"]/"~selectedcolor));
      }
    }
  }
  # then we notice the changings in the knob-"color"
  var path = "/smoke/colors/knob-"~selectedcolor; 
  var knob_val=getprop(path) + (step);
      if(knob_val >1.0) knob_val = 1.0;
      if(knob_val < 0.0) knob_val = 0.0;
  setprop(path,knob_val);
}
