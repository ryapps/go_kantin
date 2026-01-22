import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, icon, imageUrl];

  // Konstanta kategori
  static const Category anekaNasi = Category(
    id: 'aneka_nasi',
    name: 'Aneka Nasi',
    icon: '🍚',
    imageUrl: 'https://i.pinimg.com/1200x/23/ed/d0/23edd0b146ffc32ab856ea9c1d1fcf94.jpg',
  );

  static const Category lalapan = Category(
    id: 'lalapan',
    name: 'Lalapan',
    icon: '🥗',
    imageUrl: 'https://i.pinimg.com/736x/c2/20/42/c22042170116e5dcbd7e3cbe1ad149cf.jpg',
  );

  static const Category bakso = Category(
    id: 'bakso',
    name: 'Bakso',
    icon: '🍜',
    imageUrl: 'https://i.pinimg.com/736x/d3/9b/5e/d39b5e96efd26149d0cebbe8ca888007.jpg',
  );

  static const Category minuman = Category(
    id: 'minuman',
    name: 'Minuman',
    icon: '🥤',
    imageUrl: 'https://i.pinimg.com/736x/23/f3/be/23f3becd2e47f98ff0844a90bdaa25de.jpg',
  );

  static const Category masakanRumahan = Category(
    id: 'masakan_rumahan',
    name: 'Masakan Rumahan',
    icon: '🍲',
    imageUrl: 'https://i.pinimg.com/1200x/58/c8/8b/58c88bcad51b4afc2d7eb32d6915884f.jpg',
  );

  static const Category mieAyam = Category(
    id: 'mie_ayam',
    name: 'Mie Ayam',
    icon: '🍝',
    imageUrl: 'https://img.pikbest.com/png-images/20240726/a-bowl-of-chicken-noodles-with-delicious-toppings_10683074.png!bw700',
  );

  static const Category jajanan = Category(
    id: 'jajanan',
    name: 'Jajanan',
    icon: '🍡',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_cQMPklWnsiJNS9k65Tivy9hTE6gnmRbc2A&s',
  );

  // List semua kategori
  static const List<Category> all = [
    anekaNasi,
    lalapan,
    bakso,
    minuman,
    masakanRumahan,
    mieAyam,
    jajanan,
  ];
}
