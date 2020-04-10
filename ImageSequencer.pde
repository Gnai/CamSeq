//Libraries  
import processing.video.*;
import themidibus.*;
import ipcapture.*;
 
IPCapture cam;
MidiBus MIDI;
PImage img;

int step = 0;
int real_step = 0;
int last_step = 0;
int timing = 0;
int column = 0;

int[] columns = {0, 1, 2, 3};

// SET THESE TWO ARGUMENTS TO MATCH YOUR DEVICES AND MODE
String cameraIP = "192.168.43.215:4747/video";
String midiBus = "Bus 1";
static final int NUM_STEPS = 4; // 4 for drum machine, 16 for melody

void setup() {
  //---------------------------------- CAMERA ------------------------------------------//
  size(640,476);  
  cam = new IPCapture(this, "http://" + cameraIP, "", "");
  cam.start();
  
  //----------------------------------- MIDI -------------------------------------------//
   MIDI = new MidiBus(this, midiBus, midiBus);
}

void draw() {
  background(140);
  
  if (cam.isAvailable() == true) {
    cam.read();
  }
  image(cam, 0, 0);
  
  
  step = real_step % NUM_STEPS;
  column = columns[int((real_step % 16) / 4)];
 
  int sectionH = int(height / 4);
  int sectionW = int(width / 4);
  
  // Rectangle animation
  fill(0,0,0,0);
  rect(sectionW * step, sectionH * column, sectionW, sectionH);
  
  
  if (step != last_step) {
    int auxSectionW = int((width / 4) / 2) + step * sectionW;
    
    color argb;
    if (column == 0) {
      argb = get(auxSectionW, int((height / 4) / 2));
    } else {
      argb = get(auxSectionW, int((height / 4) / 2) + sectionH * column);
    }
    
    int r = (argb >> 16) & 0xFF;
    int g = (argb >> 8) & 0xFF; 
    int b = argb & 0xFF;
    
    println(argb);
    println(r);
    println(g);
    println(b);
    println();
    
    int r_diff1 = r - g;
    int r_diff2 = r - b;
    int g_diff1 = g - r;
    int g_diff2 = g - b;
    
    if (r > 120 && r_diff1 > 40 && r_diff2 > 40) { // RED
      MIDI.sendNoteOn(2, 50, 80);
    }
    else if (g > 120 && g_diff1 > 40 && g_diff2 > 40) { // GREEN
      MIDI.sendNoteOn(3, 50, 80);
    }
    else if (r < 80 && g < 80 && b < 80) { // BLACK
      MIDI.sendNoteOn(4, 50, 80);
    }
  }
  
  last_step = step;
}

void noteOn(int channel, int number, int value) {
  if (channel == 0){
    step = number;
  }
}

void rawMidi(byte[] data) {
  if (data[0] == (byte) 0xF8) {
    timing++; 
    
    if (timing % 6 == 0) {
       real_step++; 
    }
  }
}
