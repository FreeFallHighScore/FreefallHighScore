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
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval: 1 / 30.0];

    filePrefix = "DROP_RECORD_"+ofToString(ofGetMinutes()) +  "_" + ofToString(ofGetHours()) + "_" + ofToString(ofGetDay()) + "_";
}


//--------------------------------------------------------------
void testApp::update() {
    if(recording){
        ofVec3f currentAccel = ofxAccelerometer.getForce();
        AccelSample sample;
        sample.accel = currentAccel;
        sample.time = ofGetElapsedTimef() - recordStartTime;
        accelRecord.push_back( sample );
    }
}

//--------------------------------------------------------------
void testApp::draw() {
    
    ofBackground(255);
    if(recording){
        ofSetColor(255, 0, 0);
        ofRect(0, 0, ofGetWidth(), 10);
        ofSetColor(0);
        ofDrawBitmapString("samples: " + ofToString( accelRecord.size()) + "  \t" +
                           "smp/sec: " + ofToString( accelRecord.size()/(ofGetElapsedTimef() - recordStartTime), 10),ofPoint(30,30) );
    }
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
        //TODO: save the file!
		recording = false;
        recordedData.clear();
        recordedData.addTag("vals");
        recordedData.pushTag("vals");
        for(int i = 0; i < accelRecord.size(); i++){
            AccelSample samp = accelRecord[i];
            recordedData.addValue("samp", ofToString(samp.time, 10) + "," + 
                                  ofToString(samp.accel.x, 10) + "," + 
                                  ofToString(samp.accel.y, 10) + "," + 
                                  ofToString(samp.accel.z, 10));
        }
        
        recordedData.popTag();
        
        string output;
        string outputFileName = filePrefix + ofToString(outfileNumber) + ".xml";
        recordedData.copyXmlToString(output);
        outfile.open(outputFileName, OFX_IPHONE_FILE_WRITE);
        outfile.write(output);
        outfileNumber++;
        
        cout << "wrote file " << outputFileName << endl;// << " contents " + output << endl;; 
    }
    else{
        recordStartTime = ofGetElapsedTimef();
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

