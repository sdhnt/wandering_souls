import kinect4WinSDK.*;
  
import processing.video.*;
Movie myMovie;


Kinect kinect;
PImage depthImg;
float avgX=0;
float avgY=0;
float prevX=0;
int i=0;

int currentFrame = 0;
PImage[] images = new PImage[26426];
float prevY=0;
int flipflag=0;
String state="Idle";
String prevstate="";
int recordingflag=0;
int playbackflag=0;
// Previous Frame
PImage prevFrame;
float threshold = 50;
int ctr=0;
void setup()
{
  noCursor();
    
  
  //size(640,480);
  fullScreen();
  kinect = new Kinect(this);
  //video = new Capture(this, width, height);
  //video.start(); 
  prevFrame = kinect.GetDepth();
  //depthImg.filter(THRESHOLD, 0.8);
  ////depthImg.filter(INVERT);
  
  depthImg = kinect.GetDepth();
  depthImg.filter(THRESHOLD, 0.7);
  depthImg.filter(INVERT);
  image(depthImg, 0,0);
  
   frameRate(20);
  myMovie = new Movie(this, "smoke.mp4");
  myMovie.frameRate(0.5);
  myMovie.loop();
}



void draw()
{
  
  depthImg = kinect.GetDepth();
  depthImg.filter(THRESHOLD, 0.7);
  depthImg.filter(INVERT);
  
  if(playbackflag!=1)
  {
    
  image(depthImg, 0,0);
   tint(255, 255, 255,20); 

  }
  else if(playbackflag==1)
   {
     
     PImage tempImg=images[i];
     //println(ctr+" "+state);
     
      if(flipflag%2==0){
      pushMatrix();
      translate(tempImg.width,0);
      scale(-1,1); // You had it right!
      
      
      
      image(tempImg,0,0);
    

      
  
      popMatrix();
      }
      else
      {
        image(tempImg,0,0);
        
 
      }
     
     i++;
    if(i==ctr-1 && flipflag%2==0){//if reaches left of screen
      i=0;
      flipflag++;
    }
    
    if(i==ctr-1 && flipflag==1)
    {
      i=0;
      flipflag++;
    }
    
    if(i==ctr-1 && flipflag==3){//if reaches right of screen
      
    ctr=0;
    i=0;
    flipflag=0;
    avgX=0;
    avgY=0;
    prevX=0;
    prevY=0;
    playbackflag=0;
    recordingflag=0;
    state="Idle";
    prevstate="";
    images=new PImage[26426];
    delay(10000);
    depthImg = kinect.GetDepth();
    depthImg.filter(THRESHOLD, 0.7);
    depthImg.filter(INVERT);
  
 
    }
    
    //5 sesconds of playback - reset state to Idle, prevstate to idle. ctr=0;
    
     
   }
   
  
  //////////////////////////
  
  loadPixels();
  depthImg.loadPixels();
  prevFrame.loadPixels();
  
  
  // These are the variables we'll need to find the average X and Y
  float sumX = 0;
  float sumY = 0;
  int motionCount = 0; 
  
  
  // Begin loop to walk through every pixel
  for (int x = 0; x < depthImg.width; x++ ) {
    for (int y = 0; y < depthImg.height; y++ ) {
      // What is the current color
      color current = depthImg.pixels[x+y*depthImg.width];

      // What is the previous color
      color previous = prevFrame.pixels[x+y*depthImg.width];

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current);
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous);
      float b2 = blue(previous);

      // Motion for an individual pixel is the difference between the previous color and current color.
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // If it's a motion pixel add up the x's and the y's
      if (diff > threshold) {
        sumX += x;
        sumY += y;
        motionCount++;
      }
    }
  }

  
  // average location is total location divided by the number of motion pixels.
   avgX = sumX / motionCount; 
   avgY = sumY / motionCount; 
   
   if(abs(prevX-avgX)>1 || abs(prevY-avgY)>1){
     if(prevstate=="Idle")//Turns on during this transition
     {
     state="Motion";
     recordingflag=1;
     }
     if(prevstate=="Reached"){//Correction - we don't go from reached to motion we go from reached to reached
       state="Reached";
       recordingflag=0;
     }
   }
   else if(depthImg.get(int(avgX+300),int(avgY))!=-1)
   {
     
     if(prevstate=="Idle")
     {state="Idle"; print("Florence is osum"); playbackflag=0; }
     else
     {
     state="Reached";
     //somehow introduce two more cycles here
     delay(1000);
    
  
     recordingflag=0;
     playbackflag=1;
     }
     
     
   
   }
   else 
   {
     state="Idle"; 
     if(prevstate=="Motion"){
       state="Motion";
     }
     if(prevstate=="Reached"){
       state="Reached";
     }
   }
   
   prevX=avgX;
   prevY=avgY;
   
   if(recordingflag==1)
   {

     
     
     
    
     images[ctr]=depthImg; ctr++;
   }
   
   
   prevstate=state;
   println(state + " "+ recordingflag + " " + playbackflag);
  
  smooth();
  noStroke();
  fill(0);
  ellipse(avgX+300, avgY, 16, 16);
  
   image(myMovie, 0, 0);
   
  
}
