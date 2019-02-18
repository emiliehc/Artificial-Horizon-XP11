import processing.serial.*;

// declaration
float pitch = 0;
float roll = 0;
float skid = 0;
PImage overlay;
Serial myPort;  // The serial port
String data;
String val;
float pitchRaw = 0;
int datarefCount = 0;
boolean ATTINOP = false;
int storedMillis = 0;

void setup() {
  // set canvas size
  size(600, 600);
  overlay = loadImage("AH overlay.png");
  // serial
  // List all the available serial ports:
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 115200);
}

void draw() {
  // serial get data
  while (myPort.available () > 0) {
    String inBuffer = myPort.readString();   
    if (inBuffer != null) {
      data = inBuffer;
      //println(data);
    }
  }
  // check attitude availability
  if (millis() - storedMillis > 2000) {
    ATTINOP = true;
  } else {
    ATTINOP = false;
  }
  println(millis());
  println(storedMillis);
  
  
  // get pitch and roll data
  if (data != null) {

    for (int i = 1; i < data.length (); i++) {
      val+=str(data.charAt(i));
      if (str(data.charAt(i)).equals(",")) {
        val = val.substring(0, val.length() - 1);


        storedMillis = millis();
        datarefCount++;
        switch(datarefCount) {
        case 1:
          pitch = float(val);
          break;
        case 2:
          roll = -float(val);
          break;
        case 3:
          skid = -float(val);
          break;
        }
        //println(datarefCount);
        //println(val);
        val = "";
      }
    }
    println();
    datarefCount = 0;
    val = "";
    //pitch = float(data.substring(1, 7));
    //roll = -float(data.substring(8, 14));
    //skid = float(data.substring(15, 21));
  }

  // background black
  background(0);
  // translate to the center
  translate(300, 300);
  // translate the plane to the desired position
  pushMatrix();
  //pitch+= 0.3;
  //roll+= 0.3;
  if (roll > 180) {
    roll -= 360;
  }
  //roll = int(random(-67, 67));
  rotate(radians(roll));
  translate(0, pitch*8);


  // draw the base artificial horizon
  // sky
  noStroke();
  fill(#0D84FF);
  rect(-1200, -1200, 2400, 1200);
  // ground
  fill(#BF5000);
  rect(-1200, 0, 2400, 1200);
  // white line in the middle
  stroke(255);
  strokeWeight(2);
  line(-600, 0, 600, 0);
  fill(255);
  textSize(17);
  // long pitch divisions
  for (int i = -90; i <= 90; i+=10) {
    if (i != 0) {
      line(-35, -8*i, 35, -8*i);
      // corresponding text
      text(abs(i), -85, -8*i + 6);
      text(abs(i), 65, -8*i + 6);
    }
  }
  // medium pitch divisions
  for (int i = -85; i <= 90; i+=10) {
    line(-17, -8*i, 17, -8*i);
  }
  // short pitch divisions
  for (float i = -87.5; i <= 90; i+=5) {
    line(-7, -8*i, 7, -8*i);
  }
  popMatrix();


  // upper and lower overlay
  pushMatrix();
  // rotate only
  rotate(radians(roll));
  fill(#0D84FF);
  stroke(255);
  rect(-300, -300, 600, 162);
  fill(#BF5000);
  rect(-300, 300, 600, -162);

  // bank angle and skid indication
  stroke(#FFE30A);
  noFill();
  // if higher/lower than +-90 degrees
  if (abs(roll) > 90) {
    beginShape();
    vertex(0, -175 - (180-abs(roll)) * 0.09);
    vertex(-9, -162 - (180-abs(roll)) * 0.09);
    vertex(9, -162 - (180-abs(roll)) * 0.09);
    vertex(0, -175 - (180-abs(roll)) * 0.09);
    endShape();
    // skid
    beginShape();
    vertex(-12 + skid, -157 - (180-abs(roll)) * 0.09);
    vertex(12 + skid, -157 - (180-abs(roll)) * 0.09);
    vertex(17 + skid, -150 - (180-abs(roll)) * 0.09);
    vertex(-17 + skid, -150 - (180-abs(roll)) * 0.09);
    vertex(-13 + skid, -156 - (180-abs(roll)) * 0.09);
    endShape();
  } else {
    beginShape();
    vertex(0, -175 - abs(roll) * 0.09);
    vertex(-9, -162 - abs(roll) * 0.09);
    vertex(9, -162 - abs(roll) * 0.09);
    vertex(0, -175 - abs(roll) * 0.09);
    endShape();
    // skid
    beginShape();
    vertex(-12 + skid * 5, -157 - abs(roll) * 0.09);
    vertex(12 + skid * 5, -157 - abs(roll) * 0.09);
    vertex(17 + skid * 5, -150 - abs(roll) * 0.09);
    vertex(-17 + skid * 5, -150 - abs(roll) * 0.09);
    vertex(-13 + skid * 5, -156 - abs(roll) * 0.09);
    endShape();
  }


  popMatrix();


  // black frame
  noStroke();
  fill(0);
  //rect(-300, -300, 600, 120);
  //rect(-300, -300, 150, 600);
  //rect(-300, 300, 600, -120);
  //rect(300, 300, -150, -600);

  // show the image
  image(overlay, -300, -300, 600, 600);

  // pointer
  // cues
  stroke(#FFE30A);
  strokeWeight(3);
  fill(0);

  // left
  beginShape();
  vertex(-95, 16);
  vertex(-87, 16);
  vertex(-87, -4);
  vertex(-148, -4);
  vertex(-148, 4);
  vertex(-95, 4);
  vertex(-95, 16);
  endShape();
  // right
  beginShape();
  vertex(95, 16);
  vertex(87, 16);
  vertex(87, -4);
  vertex(148, -4);
  vertex(148, 4);
  vertex(95, 4);
  vertex(95, 16);
  endShape();
  // center square
  rectMode(CENTER);
  rect(0, 0, 8.5, 8.5);
  rectMode(CORNER);

  // attitude inop overlay
  if (ATTINOP) {
    fill(0);
    stroke(0);
    rect(-300, -300, 600, 600);
    fill(#FF0000);
    textSize(30);
    text("ATT", -30, 10);
  }

  // delay
  //delay(1000);
}

