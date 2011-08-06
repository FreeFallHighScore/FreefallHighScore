//
//  ofxYoutubeUpload.h
//  YoutubeUpload
//
//  Created by Jim on 8/6/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import "GData/GDataEntryYouTubeUpload.h"

class ofxYoutubeUpload
{
  public:
    ofxYoutubeUpload();
    ~ofxYoutubeUpload();
    
    void uploadVideo();
    void setAPIKey(string newKey);
    
};