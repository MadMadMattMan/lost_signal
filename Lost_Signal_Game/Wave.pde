class Wave{
  //Variables
  ArrayList<Signal> signals = new ArrayList<>();
  ArrayList<Signal> lostSignals = new ArrayList<>();
  
  //Constructor
  Wave(PVector pos, PVector iVelo, int count){
    float speed = iVelo.mag();
    for (int i = 0; i < count; i++){
      PVector pV = iVelo.add(new PVector(random(-0.25f, 0.25f), random(-0.25f, 0.25f))).normalize().mult(speed).copy();
      signals.add(new Signal(new PVector(150f, 150f), pV, this));
    }
  }
  
  //Methods
  void updateWave(){
    //Iterates through each signal particle
    for (Signal signalMain : signals){
      signalMain.updateSignal();
        
      for (Signal signalConnection : signals){
         signalMain.addForce(pullForce(signalMain.position, signalConnection.position));
      }
      for (Signal lostSignal : lostSignals){ //Removes here to avoid modification errors
         signals.remove(lostSignal);
      }
    }
  }
  
  PVector pullForce(PVector main, PVector secondary){
     //Relative var
     PVector betweenVector = PVector.sub(secondary, main);
     float dist = PVector.dist(main, secondary);
     //ForceVector var
     float linkStrength = (exp(-dist)*dist);
     PVector pullForce = betweenVector.setMag(linkStrength);
     //Angle var
     float newTheta = PVector.sub(main, pullForce).heading();
     //Set
     PVector forceVector = pullForce.setHeading(newTheta).copy();
     
     if (dist > 50){
       drawVector(main, forceVector.mult(1000));
       //return forceVector;
     }
     return zVector;
  }
  
  public void destroySignal(Signal s){
    lostSignals.add(s); 
  }
}
