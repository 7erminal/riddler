/// A purchasable data bundle for a mobile network.
class DataBundle {
  final String id;
  final String provider;
  final String name;
  final String size;
  final double price;

  const DataBundle({
    required this.id,
    required this.provider,
    required this.name,
    required this.size,
    required this.price,
  });

  factory DataBundle.fromJson(Map<String, dynamic> json) => DataBundle(
    id: json['id'] as String,
    provider: json['provider'] as String,
    name: json['name'] as String,
    size: json['size'] as String,
    price: (json['price'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider': provider,
    'name': name,
    'size': size,
    'price': price,
  };
}

/// Catalogue of available data bundles per network.
const Map<String, List<DataBundle>> dataBundles = {
  'MTN': [
    DataBundle(id: 'mtn-0.5', provider: 'MTN', name: 'Xpress 0.5GB', size: '0.5GB', price: 5),
    DataBundle(id: 'mtn-1', provider: 'MTN', name: 'Xpress 1GB', size: '1GB', price: 10),
    DataBundle(id: 'mtn-2', provider: 'MTN', name: 'Xpress 2GB', size: '2GB', price: 20),
    DataBundle(id: 'mtn-5', provider: 'MTN', name: 'Xpress 5GB', size: '5GB', price: 45),
    DataBundle(id: 'mtn-10', provider: 'MTN', name: 'Xpress 10GB', size: '10GB', price: 80),
  ],
  'Telecel': [
    DataBundle(id: 'tel-0.5', provider: 'Telecel', name: 'Daily 0.5GB', size: '0.5GB', price: 5),
    DataBundle(id: 'tel-1', provider: 'Telecel', name: 'Daily 1GB', size: '1GB', price: 10),
    DataBundle(id: 'tel-3', provider: 'Telecel', name: 'Daily 3GB', size: '3GB', price: 25),
    DataBundle(id: 'tel-6', provider: 'Telecel', name: 'Daily 6GB', size: '6GB', price: 48),
    DataBundle(id: 'tel-12', provider: 'Telecel', name: 'Daily 12GB', size: '12GB', price: 85),
  ],
  'AT': [
    DataBundle(id: 'at-0.5', provider: 'AT', name: 'MyAT 0.5GB', size: '0.5GB', price: 5),
    DataBundle(id: 'at-1', provider: 'AT', name: 'MyAT 1GB', size: '1GB', price: 10),
    DataBundle(id: 'at-2', provider: 'AT', name: 'MyAT 2GB', size: '2GB', price: 18),
    DataBundle(id: 'at-5', provider: 'AT', name: 'MyAT 5GB', size: '5GB', price: 42),
    DataBundle(id: 'at-10', provider: 'AT', name: 'MyAT 10GB', size: '10GB', price: 75),
  ],
};

/// The networks the app sells airtime / data for.
const List<String> serviceNetworks = ['MTN', 'Telecel', 'AT'];
