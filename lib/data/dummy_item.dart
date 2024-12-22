import 'package:shopping_app/data/category.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';

final groceryItems = [
  // Now 'const' works here
  GroceryItem(
    id: "a",
    name: "Milk",
    quantity: 1,
    category:
        categories[Categories.dairy]!, // Use '!' to assert non-nullability
  ),
  GroceryItem(
    id: 'b',
    name: 'Bananas',
    quantity: 5,
    category:
        categories[Categories.fruit]!, // Use '!' to assert non-nullability
  ),
  GroceryItem(
    id: 'c',
    name: 'Beef Steak',
    quantity: 1,
    category: categories[Categories.meat]!, // Use '!' to assert non-nullability
  ),
];
