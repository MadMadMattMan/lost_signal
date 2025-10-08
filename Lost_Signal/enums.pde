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
  
  // second stage
  factory,
  
  /// export
  bank,
}

// enum for info panel actions
public enum ButtonAction {
  destroy,
  toggle,
  next,
  back,
}

// enum for the type of ui
public enum UIType {
  buildings,
  resources,
  stats,
}

// enum for resource types
public enum ResourceType {
  none,
  
  // 0
  /// miners
  coal, // material, fuel
  iron, // material
  copper, // material
  /// lumber
  wood, // material, fuel
  sap,  // material
  leaves, // fuel
  
  // 1
  steel, // fuel + coal + iron
  electromagnet, // fuel + iron + copper
  thermoConductor, // fuel + coal + copper
  carbonFiber,  // fuel + coal + leaves
  charcoal, // fuel + fuel + lumber - equiv to coal
  planks, // fuel + wood + iron
  nails, // fuel + sap + iron
  lamp, // fuel + copper + wood
  circuit, // fuel + copper + sap
  
  // 2
  pulseCore, // steel + electromagnet
  fluxium,   // thermoConductor + electromagnet
  pyroSteel, // thermoConductor + steel
  
  // ruined
  mulch, // sap + wood|leaves
  scrap, // everything else
}
public static ArrayList<Float> targets = new ArrayList<>();
static {
  targets.add(0, 50f);
  targets.add(1, 1000f);
  targets.add(2, 50000f);
}

public static HashMap<ResourceType, PVector> resourceSignalColor = new HashMap<>();
static {
  resourceSignalColor.put(ResourceType.none, new PVector(214, 37, 152));
  
  resourceSignalColor.put(ResourceType.coal, new PVector(0, 0, 0));
  resourceSignalColor.put(ResourceType.iron, new PVector(165, 156, 148));
  resourceSignalColor.put(ResourceType.copper, new PVector(203, 96, 21));
  
  resourceSignalColor.put(ResourceType.wood, new PVector(150, 60, 0));
  resourceSignalColor.put(ResourceType.leaves, new PVector(20, 100, 50));
  resourceSignalColor.put(ResourceType.sap, new PVector(150, 150, 20));
}
public static HashMap<BuildingType, Float> buildingCosts = new HashMap<>();
static {
  buildingCosts.put(BuildingType.test, 10f);
  
  buildingCosts.put(BuildingType.mine, 25f);
  buildingCosts.put(BuildingType.lumber, 25f);
  
  buildingCosts.put(BuildingType.relay, 50f);
  buildingCosts.put(BuildingType.storage, 50f);
  
  buildingCosts.put(BuildingType.factory, 75f);
  
  buildingCosts.put(BuildingType.bank, 0f);
}
public static HashMap<ResourceType, Float> resourceValue = new HashMap<>();
static {
  resourceValue.put(ResourceType.none, 0f);
  
  resourceValue.put(ResourceType.coal, 0.015f);
  resourceValue.put(ResourceType.iron, 0.020f);
  resourceValue.put(ResourceType.copper, 0.020f);
  
  resourceValue.put(ResourceType.wood, 0.0175f);
  resourceValue.put(ResourceType.leaves, 0.008f);
  resourceValue.put(ResourceType.sap, 0.0215f);
}
public static HashMap<ResourceType, Float> resourceSpeed = new HashMap<>();
static {
  resourceSpeed.put(ResourceType.coal, 1.1); 
  resourceSpeed.put(ResourceType.iron, 0.95); 
  resourceSpeed.put(ResourceType.copper, 1f);
  
  resourceSpeed.put(ResourceType.wood, 0.9f); 
  resourceSpeed.put(ResourceType.leaves, 2.25f); 
  resourceSpeed.put(ResourceType.sap, 0.75f); 
}
