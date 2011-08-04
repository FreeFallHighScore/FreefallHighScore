#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	
	ofBackground(225, 225, 225);
	ofSetCircleResolution(80);
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
	// register touch events
	ofxRegisterMultitouch(this);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);

	recording = false;
    inFreefall = false;
    longestTimeInFreefall = 0;
}


//--------------------------------------------------------------
void testApp::update() {
    if(recording){
        ofVec3f currentAccel = ofxAccelerometer.getForce();
        accelRecord.push_back( currentAccel );
        if(accelRecord.size() > ofGetWidth()){
            accelRecord.erase(accelRecord.begin());
        }
        
        float accelMagnitude = currentAccel.length();
        if (inFreefall) {
            float curretFreefallTime = ofGetElapsedTimef() - freefallStartTime;
            if(curretFreefallTime > longestTimeInFreefall){
                longestTimeInFreefall = curretFreefallTime;
            }
        }
        
        if(!inFreefall && accelMagnitude < .2){
            freefallStartTime = ofGetElapsedTimef();
            inFreefall = true;
        }
        else if(inFreefall && accelMagnitude >= .2){
            inFreefall = false;
        }
    }
}

//--------------------------------------------------------------
void testApp::draw() {
    
    ofBackground(255);
    if(recording){
        ofSetColor(255, 0, 0);
        ofRect(0, 0, ofGetWidth(), 10);
    }
    
    ofSetColor(0);
    ofVec3f curAccel = ofxAccelerometer.getForce();
    ofDrawBitmapString("MAG: " + ofToString( ofxAccelerometer.getForce().length(), 4) + " RAW ACCEL: " + ofToString(curAccel.x, 2) + " " + ofToString(curAccel.y, 2) + " " + ofToString(curAccel.z, 2), ofPoint(10, 10) );
    ofDrawBitmapString("LONGEST FALL: " + ofToString(longestTimeInFreefall), ofPoint(10, 30));
    
    if(accelRecord.size() > 0){
        ofPushStyle();
        //graph the accel
        //X
        int idx;
        ofNoFill();
        ofSetLineWidth(1);
        ofBeginShape();
        float thirdHeight = (ofGetHeight()-10)/3.0;
        for(int i = 0; i < ofGetWidth(); i+=2){
            ofSetColor(255, 0, 0);
            idx = ofMap(i, 0, ofGetWidth(), 0, accelRecord.size()-1);
            ofVertex(i, thirdHeight*.5 + ofClamp(accelRecord[idx].x, -1.0, 1.0)*thirdHeight*.5); 
        }
        ofEndShape(false);
        ofSetColor(0);
        ofLine(0, thirdHeight, ofGetWidth(), thirdHeight);
        
        //Y
        ofSetColor(0, 255, 0);
        ofBeginShape();

        for(int i = 0; i < ofGetWidth(); i+=2){
            idx = ofMap(i, 0, ofGetWidth(), 0, accelRecord.size()-1);
            ofVertex(i, thirdHeight+thirdHeight*.5 + ofClamp(accelRecord[idx].y, -1.0, 1.0)*thirdHeight*.5); 
        }
        ofEndShape(false);
        
        ofSetColor(0);
        ofLine(0, thirdHeight*2, ofGetWidth(), thirdHeight*2);
        
        //Z
        ofSetColor(0, 0, 255);
        ofBeginShape();
        for(int i = 0; i < ofGetWidth(); i+=2){
            idx = ofMap(i, 0, ofGetWidth(), 0, accelRecord.size()-1);
            ofVertex(i, thirdHeight*2+thirdHeight*.5 + ofClamp(accelRecord[idx].z,-1.0, 1.0)*thirdHeight*.5); 
        }
        ofEndShape(false);
        
        ofPopStyle();
    }
    
    /*
	float angle = 180 - RAD_TO_DEG * atan2( ofxAccelerometer.getForce().y, ofxAccelerometer.getForce().x );

	ofEnableAlphaBlending();
	ofSetColor(255);
	ofPushMatrix();
		ofTranslate(ofGetWidth()/2, ofGetHeight()/2, 0);
		ofRotateZ(angle);
		arrow.draw(0,0);
	ofPopMatrix();

	ofPushStyle();
		ofEnableBlendMode(OF_BLENDMODE_MULTIPLY);
		for(int i = 0; i< balls.size(); i++){
			balls[i].draw();
		}
	ofPopStyle();
    */
}

//--------------------------------------------------------------
void testApp::exit() {

}

//--------------------------------------------------------------
void testApp::touchDown(int x, int y, int id){
    
//	printf("touch %i down at (%i,%i)\n", id, x,y);
//	balls[id].moveTo(x, y);
//	balls[id].bDragged = true;
}

//--------------------------------------------------------------
void testApp::touchMoved(int x, int y, int id){
//	printf("touch %i moved at (%i,%i)\n", id, x, y);
//	balls[id].moveTo(x, y);
//	balls[id].bDragged = true;	
}

//--------------------------------------------------------------
void testApp::touchUp(int x, int y, int id){
//	balls[id].bDragged = false;
//	printf("touch %i up at (%i,%i)\n", id, x, y);
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(int x, int y, int id){
    if(recording){
        recording = false;
    }
    else{
        accelRecord.clear();
        recording = true;
    }
//	printf("touch %i double tap at (%i,%i)\n", id, x, y);
}

//--------------------------------------------------------------
void testApp::lostFocus() {
}

//--------------------------------------------------------------
void testApp::gotFocus() {
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning() {
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){
	
}

