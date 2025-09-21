class Producer{
  String name;
  String type;
  ArrayList<Wave> sentWaves = new ArrayList<Wave>();
  
  //Constructors
  Producer(){
    //sentWaves.add(new Wave());
  }
  
  //Methods
  void updateProducer(){
    for (Wave w : sentWaves){
    w.updateWave();
    }
  }
}
