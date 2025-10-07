// enum for building types
public enum BuildingType {
  none,
  
  // testing
  test,
  
  // first stage
  mine,
  lumber,
  relay,
  storage,
  
  
  // end stage
  /// export
}

// enum for info panel actions
public enum ButtonAction {
  destroy,
  toggle,
}

// enum for resource types
public enum ResourceType {
  none,
  
  // 1
  /// miners
  coal, // material, fuel
  iron, // material
  copper, // material
  /// lumber
  wood,
  
  
  // 2
  steel, // coal|wood + iron
  electromagnet, // iron + copper
  thermoConductor, // coal|wood + copper
  
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
  
  resourceSignalColor.put(ResourceType.wood, new PVector(150, 60, 0));
}
