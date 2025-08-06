import '../models/product.dart';

class MockWildberriesService {
  static Future<List<Product>> fetchMyModusProducts() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      Product(
        title: "My Modus - Стильная блузка женская",
        price: 2500,
        oldPrice: 3500,
        discount: 29,
        image: "https://images.wbstatic.net/c246x328/new/12345678-1.jpg",
        link: "https://www.wildberries.ru/catalog/12345678/detail.aspx",
      ),
      Product(
        title: "My Modus - Джинсы женские классические",
        price: 4200,
        oldPrice: 5200,
        discount: 19,
        image: "https://images.wbstatic.net/c246x328/new/87654321-1.jpg",
        link: "https://www.wildberries.ru/catalog/87654321/detail.aspx",
      ),
      Product(
        title: "My Modus - Платье летнее женское",
        price: 3800,
        oldPrice: null,
        discount: null,
        image: "https://images.wbstatic.net/c246x328/new/11223344-1.jpg",
        link: "https://www.wildberries.ru/catalog/11223344/detail.aspx",
      ),
      Product(
        title: "My Modus - Кроссовки женские спортивные",
        price: 5600,
        oldPrice: 7200,
        discount: 22,
        image: "https://images.wbstatic.net/c246x328/new/55667788-1.jpg",
        link: "https://www.wildberries.ru/catalog/55667788/detail.aspx",
      ),
      Product(
        title: "My Modus - Сумка женская кожаная",
        price: 3200,
        oldPrice: 4500,
        discount: 29,
        image: "https://images.wbstatic.net/c246x328/new/99887766-1.jpg",
        link: "https://www.wildberries.ru/catalog/99887766/detail.aspx",
      ),
      Product(
        title: "My Modus - Куртка демисезонная женская",
        price: 8900,
        oldPrice: 12000,
        discount: 26,
        image: "https://images.wbstatic.net/c246x328/new/44332211-1.jpg",
        link: "https://www.wildberries.ru/catalog/44332211/detail.aspx",
      ),
      Product(
        title: "My Modus - Футболка женская базовая",
        price: 1800,
        oldPrice: null,
        discount: null,
        image: "https://images.wbstatic.net/c246x328/new/66778899-1.jpg",
        link: "https://www.wildberries.ru/catalog/66778899/detail.aspx",
      ),
      Product(
        title: "My Modus - Юбка миди женская",
        price: 2900,
        oldPrice: 3900,
        discount: 26,
        image: "https://images.wbstatic.net/c246x328/new/22334455-1.jpg",
        link: "https://www.wildberries.ru/catalog/22334455/detail.aspx",
      ),
    ];
  }

  static Future<List<Product>> fetchProductsByCategory(String category) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return different products based on category
    switch (category) {
      case '8126': // Clothing
        return [
          Product(
            title: "My Modus - Блузка женская офисная",
            price: 2800,
            oldPrice: 3800,
            discount: 26,
            image: "https://images.wbstatic.net/c246x328/new/11111111-1.jpg",
            link: "https://www.wildberries.ru/catalog/11111111/detail.aspx",
          ),
          Product(
            title: "My Modus - Платье вечернее",
            price: 6500,
            oldPrice: 8500,
            discount: 24,
            image: "https://images.wbstatic.net/c246x328/new/22222222-1.jpg",
            link: "https://www.wildberries.ru/catalog/22222222/detail.aspx",
          ),
        ];
      case '8127': // Shoes
        return [
          Product(
            title: "My Modus - Туфли женские классические",
            price: 4800,
            oldPrice: 6200,
            discount: 23,
            image: "https://images.wbstatic.net/c246x328/new/33333333-1.jpg",
            link: "https://www.wildberries.ru/catalog/33333333/detail.aspx",
          ),
          Product(
            title: "My Modus - Ботинки женские зимние",
            price: 7200,
            oldPrice: 9500,
            discount: 24,
            image: "https://images.wbstatic.net/c246x328/new/44444444-1.jpg",
            link: "https://www.wildberries.ru/catalog/44444444/detail.aspx",
          ),
        ];
      case '8128': // Accessories
        return [
          Product(
            title: "My Modus - Ремень женский кожаный",
            price: 1500,
            oldPrice: 2200,
            discount: 32,
            image: "https://images.wbstatic.net/c246x328/new/55555555-1.jpg",
            link: "https://www.wildberries.ru/catalog/55555555/detail.aspx",
          ),
          Product(
            title: "My Modus - Шарф зимний теплый",
            price: 1200,
            oldPrice: null,
            discount: null,
            image: "https://images.wbstatic.net/c246x328/new/66666666-1.jpg",
            link: "https://www.wildberries.ru/catalog/66666666/detail.aspx",
          ),
        ];
      case '8129': // Sports
        return [
          Product(
            title: "My Modus - Спортивный костюм женский",
            price: 3800,
            oldPrice: 5200,
            discount: 27,
            image: "https://images.wbstatic.net/c246x328/new/77777777-1.jpg",
            link: "https://www.wildberries.ru/catalog/77777777/detail.aspx",
          ),
          Product(
            title: "My Modus - Леггинсы спортивные",
            price: 2200,
            oldPrice: 3100,
            discount: 29,
            image: "https://images.wbstatic.net/c246x328/new/88888888-1.jpg",
            link: "https://www.wildberries.ru/catalog/88888888/detail.aspx",
          ),
        ];
      default:
        return fetchMyModusProducts();
    }
  }
} 