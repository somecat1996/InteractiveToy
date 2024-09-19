// Number of eyes on each colum or row
int eyeNum = 5;
// Array to store all eye class
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
float pupilOffset = 1.2;


int maxBlinkTime = 4000;
int minBlinkTime = 1000;
int eyeCloseTime = 200;
int maxPinkEyeBlinkTime = 500;
int minPinkEyeBlinkTime = 50;

void setup() {
  // Initial settings
  size(400, 400);
  noStroke();
  
  // Initiate eye position
  
  //for (int i =0; i < eyeNum*eyeNum; i=i+1) {
  //  Eye eye = new Eye((400/(eyeNum-1))*(i%eyeNum), (400/(eyeNum-1))*(i/eyeNum), int(random(50, 100)), random(0, 360));
  //  eyes.add(eye);
  //}
  Eye eye = new Eye(200, 200, int(random(50, 100)), 0);
  eyes.add(eye);
}

void draw() {
  // Refresh board
  background(backgroundColor);
  
  // Draw every eye
  for (int i =0; i < eyes.size(); i=i+1) {
    eyes.get(i).update(mouseX, mouseY);
    eyes.get(i).display();
  }
}

class Eye {
  PVector position;
  float size;
  float angle;
  boolean mouseOnEye = false;
  
  int blinkTime = 0;
  int blinkTimer = 0;
  boolean blink = false;
  
  int pinkEyeTime = 5000;
  int pinkEyeTimer = 0;
  // Use flag to make pinkeye cured after blink
  boolean pinkEye = false;
  boolean pinkEyeFlag = false;
  
  // Mpvement of pupil
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
  
  Eye(int x, int y, float s, float a) {
    this.position = new PVector(x, y);
    this.size = s;
    this.angle = a;
    xRange = new PVector(-position.x, width-position.x);
    yRange = new PVector(-position.y, height-position.y);
  }
  
  // Calculate variables based on mouse position
  void update(int mX, int mY) {
    // Calculate pupil position, make pupil looks at mouse
    targetVector = new PVector(mX - position.x, mY - position.y);
    targetAngle = atan2(targetVector.y, targetVector.x);
    targetPupilVector = new PVector(targetVector.x, targetVector.y);
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
    if (mousePressed && mouseOnEye) {
      pinkEye = true;
      pinkEyeFlag = true;
      pinkEyeTimer = millis();
    }
    if (pinkEye && pinkEyeTime <= millis() - pinkEyeTimer) {
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
      } else {
        blink = true;
        blinkTime = eyeCloseTime;
        pinkEye = pinkEyeFlag;
      }
      
    }
  }
  
  // Draw eye
  void display() {
    pushMatrix();
    translate(position.x, position.y);
    // Draw shadow
    rotate(-45);
    fill(shadowColor);
    arc(0, 0, size, size*1.3, 0, PI, OPEN);
    
    // Draw eyeball
    rotate(45);
    if (!mouseOnEye) {
      if (blink){
        fill(skinColor);
        ellipse(0, 0, size, size);
      } else {
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
        rotate(angle);
        fill(skinColor);
        float litAngle = asin((size/2*sin(pupilAngle)-size/2)/size);
        arc(0, 0, size, size, PI-litAngle, 2*PI+litAngle, OPEN);
      }
    } else {
      fill(skinColor);
      ellipse(0, 0, size, size);
    }
    popMatrix();
  }
}
