// Number of generation loop
int loopNum = 500;

// ArrayList to store all eye class
ArrayList<Eye> eyes = new ArrayList<Eye>();

// Colors
int pupilColor = #D20103;
int fleshColor = #FA5C5C;
int skinColor = #5A5A5A;
int backgroundColor = #2F2F2F;
int shadowColor = #242424;
int pinkEyeColor = #FFA6A7;
int normalEyeColor = 255;
color light = color(255, 180);

// Offset factor of pupil when looking at the corner
float pupilOffset = 1.2;

// Factors of blink time
int maxBlinkTime = 4000;
int minBlinkTime = 1000;
int eyeCloseTime = 200;
int maxPinkEyeBlinkTime = 500;
int minPinkEyeBlinkTime = 50;
int minEyeCloseTime = 50;
int maxEyeCloseTime = 150;

float minDistractRate = 0.05;
float maxDistractRate = 0.3;


void setup() {
  // Canvas initial settings
  size(400, 400);
  noStroke();
  
  // Initial eye generation
  for (int i =0; i < loopNum; i=i+1) {
    PVector position = new PVector(random(0, width), random(0, height));
    float size = random(20, 100);
    if (i == 0) {
      eyes.add(new Eye(position.x, position.y, size, random(0, 360)));
    } else {
      boolean fits = true;
      int s = eyes.size();      
      for (int j = 0; j < s; j++) {
        Eye e = (Eye) eyes.get(j);
        float d = dist(position.x, position.y, e.position.x, e.position.y);
        if (d < size + e.size) {
          fits = false;
          break;
        }
      }
      if (fits) {
        eyes.add(new Eye(position.x, position.y, size, random(0, 360)));
      }
    }
  }
}

void draw() {
  // Refresh board
  background(backgroundColor);
  
  // Update & draw every eye
  for (int i =0; i < eyes.size(); i=i+1) {
    eyes.get(i).update(mouseX, mouseY);
    eyes.get(i).display();
  }
}

// Eye class
class Eye {
  // Eye information
  PVector position;
  float size;
  // Rtation of eye
  float angle;
  
  // Flag for mouse touch eye. Will set true if mouse is in eye range
  boolean mouseOnEye = false;
  
  // Blink timer. Record milliseconds of how long the eye is open or close
  int blinkTime = 0;
  int blinkTimer = 0;
  // Blink flag. True for close, false for open
  boolean blink = false;
  
  // Pinkeye exist time
  int pinkEyeTime = 5000;
  int pinkEyeTimer = 0;
  // If the eye currently pink
  boolean pinkEye = false;
  // Use flag to change pinkeye status after blink
  boolean pinkEyeFlag = false;
  
  // Mpvement of pupil
  // Movement factor every frame
  float smoothness = random(0.15, 0.01);
  PVector pupilVector = new PVector(0, 0);
  PVector targetVector = new PVector(0, 0);
  PVector targetPupilVector = new PVector(0, 0);
  float pupilAngle = 0.0;
  float distRatio = 0;
  PVector maxDistance = new PVector(0, 0);
  float targetAngle = 0.0;
  PVector xRange = new PVector(0, 0);
  PVector yRange = new PVector(0, 0);
  
  float litAngle = 0.0;
  
  // Eye has a chance looking at random direction after blink
  float distractRate = random(minDistractRate, maxDistractRate);
  boolean distract = false;
  
  Eye(float x, float y, float s, float a) {
    this.position = new PVector(x, y);
    this.size = s;
    this.angle = a;
    xRange = new PVector(-position.x, width-position.x);
    yRange = new PVector(-position.y, height-position.y);
  }
  
  // Calculate variables based on mouse position
  void update(int mX, int mY) {
    if (!distract){
      // Calculate pupil position. Eye will look like looking at the cursor IF the pupil is in this position
      targetVector = new PVector(mX - position.x, mY - position.y);
    }
    targetAngle = atan2(targetVector.y, targetVector.x);
    targetPupilVector = new PVector(targetVector.x, targetVector.y);
    // Calculate the magnitude of pupilVector. Furtherer the distance between eye and cursor, closer the pupil with the edge of eye.
    distRatio = map(targetVector.mag(), 0, width/2, 0, size/4);
    if (distRatio>size/4) {
      distRatio = size/4;
    }
    targetPupilVector.normalize();
    targetPupilVector.mult(distRatio);
    
    pupilVector = pupilVector.add(targetPupilVector.sub(pupilVector).mult(smoothness));
    pupilAngle = atan2(pupilVector.y, pupilVector.x);
    
    // Calculate if mouse is on the eye
    mouseOnEye = size / 2 >= dist(mX, mY, position.x, position.y);
    if (mouseOnEye){
      blink = true;
      blinkTime = 0;
      if (mousePressed && mouseOnEye) {
        // If mouse press eye, start pinkeye timer
        pinkEye = true;
        pinkEyeFlag = true;
        pinkEyeTimer = millis();
      }
    }
    if (pinkEye && pinkEyeTime <= millis() - pinkEyeTimer) {
      // If pinkeye timer ends, pinkeye should stop after next blink
      pinkEyeFlag = false;
    }
    
    // Setup blink timer
    if (blinkTime <= millis() - blinkTimer) {
      blinkTimer = millis();
      if (blink) {
        blink = false;
        if (pinkEye) {
          blinkTime = int(random(minPinkEyeBlinkTime, maxPinkEyeBlinkTime));
        } else {
          blinkTime = int(random(minBlinkTime, maxBlinkTime));
        }
        if (distract) {
          distract = false;
        } else if (!pinkEye) {
          if (distractRate >= random(1.0)) {
            distract = true;
            targetVector = PVector.random2D();
            targetVector.normalize();
            targetVector.mult(width);
          }
        }
      } else {
        blink = true;
        blinkTime = int(random(minEyeCloseTime, maxEyeCloseTime));;
        pinkEye = pinkEyeFlag;
      }
      
    }
  }
  
  // Draw eye
  void display() {
    // Set matrix centered in eye's center
    pushMatrix();
    translate(position.x, position.y);
    // Draw shadow
    rotate(-PI/8);
    fill(shadowColor);
    arc(0, 0, size, size*1.3, 0, PI, OPEN);
    
    // Draw eyeball
    rotate(PI/8);
    if (mouseOnEye||blink){
        fill(skinColor);
        ellipse(0, 0, size, size);
    } else {
      // Set eye color. Pinkeye has a different color with normal eye
      if (pinkEye) {
        fill(pinkEyeColor);
      } else {
        fill(normalEyeColor);
      }
      ellipse(0, 0, size, size);
      
      // Draw pupil
      fill(pupilColor);
      ellipse(pupilVector.x, pupilVector.y, size/2, size/2);
      fill(backgroundColor);
      ellipse(pupilVector.x * pupilOffset, pupilVector.y * pupilOffset, size/4, size/4);
      
      //Draw highlight
      fill(light);
      ellipse(pupilVector.x-size/8, pupilVector.y-size/8, size/8, size/8);
      
      // Draw eyelid
      rotate(radians(angle));
      fill(skinColor);
      litAngle = asin((size/2*sin(pupilAngle+2*PI-radians(angle))-size/2)/size);
      arc(0, 0, size, size, PI-litAngle, 2*PI+litAngle, OPEN);
    }
    popMatrix();
  }
}
