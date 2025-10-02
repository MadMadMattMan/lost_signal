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
public ResourceType randomType() {
  int rand = int(random(3)); 
  switch (rand) {
    case 1:
      return ResourceType.iron;
    case 2:
      return ResourceType.copper;
    default:
      return ResourceType.coal;
  }
}

// enum for resource types
public enum ResourceType {
  none,
  
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

public static HashMap<ResourceType, PVector> resourceSignalColor = new HashMap<>();
static {
  resourceSignalColor.put(ResourceType.none, new PVector(214, 37, 152));
  resourceSignalColor.put(ResourceType.coal, new PVector(0, 0, 0));
  resourceSignalColor.put(ResourceType.iron, new PVector(165, 156, 148));
  resourceSignalColor.put(ResourceType.copper, new PVector(203, 96, 21));
}
