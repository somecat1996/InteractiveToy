Eye e;

void setup() {
  size(400, 400);
  noStroke();
  e = new Eye(200, 200, 50, 45);
}

void draw() {
  background(0);
  
  e.update(mouseX, mouseY);

  e.display();
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
  
  Eye(int x, int y, int s, float a) {
    positionX = x;
    positionY = y;
    size = s;
    angle = a;
  }
  
  void update(int mX, int mY) {
    //Calculate pupil angle, make pupil looks at mouse
    pupilAngle = atan2(mY - positionY, mX - positionX);
    
    //Calculate if mouse is on the eye
    mouseOnEye = size >= dist(mX, mY, positionX, positionY);
    
    //Setup blink timer
    if (blinkTime <= millis() - blinkTimer) {
      blinkTimer = millis();
      if (blink) {
        blink = false;
        blinkTime = int(random(minBlinkTime, maxBlinkTime));
      } else {
        blink = true;
        blinkTime = eyeCloseTime;
      }
      
    }
  }
  
  void display() {
    pushMatrix();
    translate(positionX, positionY);
    rotate(angle);
    if (!mouseOnEye) {
      if (blink){
        fill(255, 50, 50);
        ellipse(0, 0, size, 2);
      } else {
        fill(255);
        ellipse(0, 0, size, size);
        quad(0, 0, size / 2 * 0.71, size / 2 * 0.71, size / 2 * 1.41, 0, size / 2 * 0.71, -size / 2 * 0.71);
        quad(0, 0, -size / 2 * 0.71, size / 2 * 0.71, -size / 2 * 1.41, 0, -size / 2 * 0.71, -size / 2 * 0.71);
        rotate(pupilAngle - angle);
        fill(255, 50, 50);
        ellipse(size/4, 0, size/2, size/2);
      }
    } else {
      fill(255, 50, 50);
      ellipse(0, 0, size, 2);
    }
    popMatrix();
  }
}
