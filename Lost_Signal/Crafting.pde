public static HashMap<HashSet<ResourceType>, ResourceType> recipes = new HashMap<>();
public static HashMap<HashSet<ResourceType>, Float[]> costs = new HashMap<>();
static {
  addRecipe(ResourceType.coal, 17.6, ResourceType.iron, 15.2, ResourceType.steel);
  addRecipe(ResourceType.iron, 19, ResourceType.copper, 20, ResourceType.emag);
  addRecipe(ResourceType.coal, 26.4, ResourceType.copper, 24, ResourceType.conductor);
  
  addRecipe(ResourceType.coal, 8.8, ResourceType.leaves, 18, ResourceType.carbonFiber);
  
  addRecipe(ResourceType.coal, 8.8, ResourceType.wood, 7.2, ResourceType.charcoal);
  addRecipe(ResourceType.leaves, 18, ResourceType.wood, 7.2, ResourceType.charcoal);
  
  addRecipe(ResourceType.wood, 9, ResourceType.iron, 9.5, ResourceType.planks);
  addRecipe(ResourceType.sap, 6, ResourceType.iron, 7.6, ResourceType.nails);
  addRecipe(ResourceType.copper, 24, ResourceType.wood, 21.6, ResourceType.lamp);
  addRecipe(ResourceType.copper, 32, ResourceType.sap, 24, ResourceType.circuit);
  addRecipe(null, 10, null, 10, ResourceType.scrap);
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
