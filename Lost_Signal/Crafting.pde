public static HashMap<HashSet<ResourceType>, ResourceType> recipes = new HashMap<>();
static {
  addRecipe(ResourceType.coal, ResourceType.iron, ResourceType.steel);
  addRecipe(ResourceType.iron, ResourceType.copper, ResourceType.electromagnet);
  addRecipe(ResourceType.coal, ResourceType.copper, ResourceType.thermoConductor);
  
  addRecipe(ResourceType.coal, ResourceType.leaves, ResourceType.carbonFiber);
  
  addRecipe(ResourceType.coal, ResourceType.wood, ResourceType.charcoal);
  addRecipe(ResourceType.leaves, ResourceType.wood, ResourceType.charcoal);
  
  addRecipe(ResourceType.wood, ResourceType.iron, ResourceType.planks);
  addRecipe(ResourceType.sap, ResourceType.iron, ResourceType.nails);
  addRecipe(ResourceType.copper, ResourceType.wood, ResourceType.lamp);
  addRecipe(ResourceType.copper, ResourceType.sap, ResourceType.circuit);
}
static void addRecipe(ResourceType a, ResourceType b, ResourceType result) {
  HashSet<ResourceType> keyValue = new HashSet<>();
  keyValue.add(a); keyValue.add(b);
  recipes.put(keyValue, result);
}
static ResourceType craftResult(ResourceType a, ResourceType b) {
  HashSet<ResourceType> craftInputs = new HashSet<>();
  craftInputs.add(a); craftInputs.add(b);
  return recipes.getOrDefault(craftInputs, ResourceType.scrap);
}
