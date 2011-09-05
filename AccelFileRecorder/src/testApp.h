#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxXmlSettings.h"
#include "ofxiPhoneFile.h"

typedef struct{
    ofVec3f accel;
    float time;
} AccelSample;

class testApp : public ofxiPhoneApp {
	
  public:
	void setup();
	void update();
	void draw();
	void exit();

	void touchDown(int x, int y, int id);
	void touchMoved(int x, int y, int id);
	void touchUp(int x, int y, int id);
	void touchDoubleTap(int x, int y, int id);
	void touchCancelled(ofTouchEventArgs &touch);
	
	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
	
	void gotMessage(ofMessage msg);
	
	vector<AccelSample> accelRecord;
    
    string filePrefix;
    ofxXmlSettings recordedData;
    ofxiPhoneFile outfile;
    int outfileNumber;
    
    float recordStartTime;
    bool recording;
};
