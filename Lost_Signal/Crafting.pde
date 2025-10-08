public static HashMap<HashSet<ResourceType>, ResourceType> recipes = new HashMap<>();
public static HashMap<HashSet<ResourceType>, Float[]> costs = new HashMap<>();
static {
  addRecipe(ResourceType.coal, 25, ResourceType.iron, 20, ResourceType.steel);
  addRecipe(ResourceType.iron, 20, ResourceType.copper, 30, ResourceType.emagnet);
  addRecipe(ResourceType.coal, 25, ResourceType.copper, 30, ResourceType.conductor);
  
  addRecipe(ResourceType.coal, 25, ResourceType.leaves, 50, ResourceType.carbonFiber);
  
  addRecipe(ResourceType.coal, 25, ResourceType.wood, 25, ResourceType.charcoal);
  addRecipe(ResourceType.leaves, 50, ResourceType.wood, 25, ResourceType.charcoal);
  
  addRecipe(ResourceType.wood, 25, ResourceType.iron, 20, ResourceType.planks);
  addRecipe(ResourceType.sap, 15, ResourceType.iron, 25, ResourceType.nails);
  addRecipe(ResourceType.copper, 30, ResourceType.wood, 25, ResourceType.lamp);
  addRecipe(ResourceType.copper, 30, ResourceType.sap, 15, ResourceType.circuit);
  addRecipe(null, 20, null, 20, ResourceType.scrap);
}
static void addRecipe(ResourceType a, float aC, ResourceType b, float bC, ResourceType result) {
  HashSet<ResourceType> keyValue = new HashSet<>();
  keyValue.add(a); keyValue.add(b);
  Float[] craftCost = new Float[2];
  craftCost[0] = aC; craftCost[1] = bC;
  recipes.put(keyValue, result);
  costs.put(keyValue, craftCost);
}
static ResourceType craftResult(ResourceType a, ResourceType b) {
  HashSet<ResourceType> craftInputs = new HashSet<>();
  craftInputs.add(a); craftInputs.add(b);
  return recipes.getOrDefault(craftInputs, ResourceType.scrap);
}
static Float[] getCraftCost(ResourceType a, ResourceType b) {
  HashSet<ResourceType> craftInputs = new HashSet<>();
  craftInputs.add(a); craftInputs.add(b);
  Float[] result = costs.get(craftInputs);
  if (result == null) { // making scrap
    Float[] defaulter = new Float[2]; defaulter[0] = 50f; defaulter[1] = 50f;
    result = defaulter;
  }
  return result;
}
