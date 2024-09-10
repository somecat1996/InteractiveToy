// Number of eyes on each colum or row
int eyeNum = 5;
// Array to store all eye class
Eye[] eyes = new Eye[eyeNum*eyeNum];
// Colors
int pupilColor = #D20103;
int backgroundColor = 0;
int pinkEyeColor = #FFA6A7;
int normalEyeColor = 255;

void setup() {
  // Initial settings
  size(400, 400);
  noStroke();
  
  // Initiate eye position
  for (int i =0; i < eyeNum*eyeNum; i=i+1) {
    eyes[i] = new Eye((400/(eyeNum-1))*(i%eyeNum), (400/(eyeNum-1))*(i/eyeNum), int(random(50, 100)), random(0, 360));
  }
}

void draw() {
  // Refresh board
  background(backgroundColor);
  
  // Draw every eye
  for (int i =0; i < eyeNum*eyeNum; i=i+1) {
    eyes[i].update(mouseX, mouseY);
    eyes[i].display();
  }
}

class Eye {
  int positionX, positionY;
  int size;
  float angle;
  float pupilAngle = 0.0;
  boolean mouseOnEye = false;
  
  int blinkTime = 0;
  int maxBlinkTime = 4000;
  int minBlinkTime = 1000;
  int eyeCloseTime = 200;
  int blinkTimer = 0;
  boolean blink = false;
  
  int pinkEyeTime = 5000;
  int pinkEyeTimer = 0;
  // Use flag to make pinkeye cured after blink
  boolean pinkEye = false;
  boolean pinkEyeFlag = false;
  int maxPinkEyeBlinkTime = 500;
  int minPinkEyeBlinkTime = 50;
  
  Eye(int x, int y, int s, float a) {
    positionX = x;
    positionY = y;
    size = s;
    angle = a;
  }
  
  // Calculate variables based on mouse position
  void update(int mX, int mY) {
    // Calculate pupil angle, make pupil looks at mouse
    pupilAngle = atan2(mY - positionY, mX - positionX);
    
    // Calculate if mouse is on the eye
    mouseOnEye = size / 2 >= dist(mX, mY, positionX, positionY);
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
    translate(positionX, positionY);
    rotate(angle);
    if (!mouseOnEye) {
      if (blink){
        fill(pupilColor);
        ellipse(0, 0, size, 2);
      } else {
        if (pinkEye) {
          fill(pinkEyeColor);
        } else {
          fill(normalEyeColor);
        }
        ellipse(0, 0, size, size);
        quad(0, 0, size / 2 * 0.71, size / 2 * 0.71, size / 2 * 1.41, 0, size / 2 * 0.71, -size / 2 * 0.71);
        quad(0, 0, -size / 2 * 0.71, size / 2 * 0.71, -size / 2 * 1.41, 0, -size / 2 * 0.71, -size / 2 * 0.71);
        rotate(pupilAngle - angle);
        fill(pupilColor);
        ellipse(size/4, 0, size/2, size/2);
      }
    } else {
      fill(pupilColor);
      ellipse(0, 0, size, 2);
    }
    popMatrix();
  }
}
