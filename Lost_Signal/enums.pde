// enum for building types
public enum BuildingType {
  none,
  
  // testing
  test,
  
  // first stage
  mine,
  relay,
  
  // mid 1 stage
  
  // mid 2 stage
  
  // end stage
  /// export
}

// enum for resource types
public enum ResourceType {
  // 1
  /// miners
  coal, // material, fuel
  iron, // material
  copper, // material
  
  // 2
  steel, // coal + iron
  electromagnet, // iron + copper
  thermoConductor, // coal + copper
  
  // 3
  pulseCore, // steel + electromagnet
  fluxium,   // thermoConductor + electromagnet
  pyroSteel, // thermoConductor + steel
  
  // ruined
  scrap,
  
  
}
