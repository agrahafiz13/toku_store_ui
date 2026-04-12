import 'package:toku_store/features/dashboard/data/models/product_models.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
  });
  Future<ProductModel> getProductById(int id);
}
