import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  Product({
    required this.productId,
    required this.isRunning,
    required this.title,
    required this.price,
    required this.description,
    required this.location,
    required this.datePosted,
    required this.currBidder,
    required this.sellerName,
    required this.sellerId,
    required this.sellerDate,
    required this.sellerImage,
    required this.images,
  });

  String productId;
  bool isRunning;
  String title;
  String price;
  String description;
  String location;
  DateTime datePosted;
  String currBidder;
  String sellerName;
  String sellerId;
  DateTime sellerDate;
  String sellerImage;
  List<String> images;
  // NetworkImage sellerImage;

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'is_running': isRunning,
      'title': title,
      'price': price,
      'description': description,
      'location': location,
      'date_posted': datePosted,
      'curr_bidder': currBidder,
      'seller_name': sellerName,
      'seller_id': sellerId,
      'seller_date': sellerDate,
      'seller_image': sellerImage,
      'images': images
    };
  }

  static Product jsonToMap(Map<String, dynamic> json) {
    return Product(
      productId: json['id'],
      isRunning: json['is_running'],
      title: json['title'],
      price: json['price'],
      description: json['description'],
      location: json['location'],
      datePosted: (json['date_posted'] as Timestamp).toDate(),
      currBidder: json['curr_bidder'],
      sellerName: json['seller_name'],
      sellerId: json['seller_id'],
      sellerDate: (json['seller_date'] as Timestamp).toDate(),
      sellerImage: json['seller_image'],
      images: List.from(json['images']),
    );
  }
}
