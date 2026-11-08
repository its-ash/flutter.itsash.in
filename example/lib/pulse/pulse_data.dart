import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theme/theme.dart';

/// Asset paths for the Pulse demo. Every image and video ships in `example/assets/`.
abstract final class PulseAssets {
  static String product(String key) => 'assets/images/products/$key.jpg';
  static String avatar(String key) => 'assets/images/avatars/$key.jpg';
  static String content(String key) => 'assets/images/content/$key.jpg';
  static String video(String key) => 'assets/video/$key.mp4';

  static final heroes = [content('hero1'), content('hero2'), content('hero3')];
  static final butterfly = video('butterfly');
  static final bee = video('bee');
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.brand,
    required this.category,
    required this.price,
    required this.compareAt,
    required this.rating,
    required this.reviews,
    required this.stock,
    required this.image,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        title: j['title'] as String,
        brand: j['brand'] as String,
        category: j['category'] as String,
        price: (j['price'] as num).toDouble(),
        compareAt: (j['compareAt'] as num?)?.toDouble(),
        rating: (j['rating'] as num).toDouble(),
        reviews: j['reviews'] as int,
        stock: j['stock'] as int,
        image: PulseAssets.product(j['image'] as String),
        description: j['description'] as String,
      );

  final String id;
  final String title;
  final String brand;
  final String category;
  final double price;
  final double? compareAt;
  final double rating;
  final int reviews;
  final int stock;

  /// Asset path.
  final String image;
  final String description;

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class Person {
  const Person({required this.id, required this.name, required this.handle, required this.avatar, required this.bio, required this.verified});

  factory Person.fromJson(Map<String, dynamic> j) => Person(
        id: j['id'] as String,
        name: j['name'] as String,
        handle: j['handle'] as String,
        avatar: PulseAssets.avatar(j['avatar'] as String),
        bio: j['bio'] as String,
        verified: j['verified'] as bool,
      );

  final String id;
  final String name;
  final String handle;

  /// Asset path.
  final String avatar;
  final String bio;
  final bool verified;

  @override
  bool operator ==(Object other) => other is Person && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class Post {
  const Post({
    required this.id,
    required this.author,
    required this.time,
    required this.text,
    required this.images,
    required this.video,
    required this.likes,
    required this.comments,
  });

  final String id;
  final Person author;
  final DateTime time;
  final String text;

  /// Asset paths.
  final List<String> images;

  /// Asset path, or null.
  final String? video;
  final int likes;
  final int comments;
}

@immutable
class Exercise {
  const Exercise({required this.name, required this.sets, required this.reps, required this.unit});

  final String name;
  final int sets;
  final int reps;

  /// `reps`, `s`, or `min`.
  final String unit;
}

@immutable
class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.coach,
    required this.minutes,
    required this.calories,
    required this.level,
    required this.image,
    required this.exercises,
  });

  final String id;
  final String title;
  final Person coach;
  final int minutes;
  final int calories;

  /// `beginner`, `intermediate`, or `advanced`.
  final String level;

  /// Asset path.
  final String image;
  final List<Exercise> exercises;
}

@immutable
class Txn {
  const Txn({required this.id, required this.title, required this.category, required this.icon, required this.amount, required this.date, required this.pending});

  final String id;
  final String title;
  final String category;
  final IconData icon;

  /// Negative = money out.
  final double amount;
  final DateTime date;
  final bool pending;
}

/// All demo data, loaded once from `assets/data/`.
class PulseData {
  PulseData._(this.products, this.people, this.posts, this.workouts);

  final List<Product> products;
  final List<Person> people;
  final List<Post> posts;
  final List<Workout> workouts;

  static Future<List<dynamic>> _json(String name) async => jsonDecode(await rootBundle.loadString('assets/data/$name.json')) as List<dynamic>;

  static Future<PulseData> load() async {
    final now = DateTime.now();
    final people = [for (final j in await _json('people')) Person.fromJson(j as Map<String, dynamic>)];
    Person who(String id) => people.firstWhere((p) => p.id == id);
    final products = [for (final j in await _json('products')) Product.fromJson(j as Map<String, dynamic>)];
    final posts = [
      for (final j in (await _json('posts')).cast<Map<String, dynamic>>())
        Post(
          id: j['id'] as String,
          author: who(j['author'] as String),
          time: now.subtract(Duration(minutes: j['minutesAgo'] as int)),
          text: j['text'] as String,
          images: [for (final k in j['images'] as List<dynamic>) PulseAssets.content(k as String)],
          video: j['video'] == null ? null : PulseAssets.video(j['video'] as String),
          likes: j['likes'] as int,
          comments: j['comments'] as int,
        ),
    ];
    final workouts = [
      for (final j in (await _json('workouts')).cast<Map<String, dynamic>>())
        Workout(
          id: j['id'] as String,
          title: j['title'] as String,
          coach: who(j['coach'] as String),
          minutes: j['minutes'] as int,
          calories: j['calories'] as int,
          level: j['level'] as String,
          image: PulseAssets.content(j['image'] as String),
          exercises: [
            for (final e in (j['exercises'] as List<dynamic>).cast<Map<String, dynamic>>())
              Exercise(name: e['name'] as String, sets: e['sets'] as int, reps: e['reps'] as int, unit: e['unit'] as String),
          ],
        ),
    ];
    return PulseData._(products, people, posts, workouts);
  }

  Person person(String id) => people.firstWhere((p) => p.id == id);

  Product product(String id) => products.firstWhere((p) => p.id == id);

  List<String> get categories => ['All', ...{for (final p in products) p.category}];

  /// Fake paged product API. Simulates a short network delay.
  Future<List<Product>> fetchProducts(int page, int size, {String category = 'All', String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final q = query.trim().toLowerCase();
    final all = [
      for (final p in products)
        if ((category == 'All' || p.category == category) && (q.isEmpty || p.title.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q))) p,
    ];
    final start = (page - 1) * size;
    if (start >= all.length) return const [];
    return all.sublist(start, math.min(start + size, all.length));
  }

  /// Search for autocomplete fields.
  Future<List<Product>> searchProducts(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    return [for (final p in products) if (p.title.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q)) p];
  }

  static const _merchants = [
    ('Green Grocer', 'Groceries', Icons.local_grocery_store_rounded, 18.0, 95.0),
    ('Metro Transit', 'Transport', Icons.directions_subway_rounded, 2.5, 30.0),
    ('Cafe Nord', 'Food & drink', Icons.local_cafe_rounded, 3.5, 14.0),
    ('Streamly', 'Subscriptions', Icons.live_tv_rounded, 9.99, 15.99),
    ('Pulse Shop', 'Shopping', Icons.shopping_bag_rounded, 19.0, 249.0),
    ('City Gym', 'Health', Icons.fitness_center_rounded, 39.0, 39.0),
    ('Power & Light', 'Bills', Icons.bolt_rounded, 45.0, 120.0),
  ];

  /// Fake paged transaction API: 240 rows, newest first. Page 4 fails once to show retry.
  Future<List<Txn>> fetchTransactions(int page, int size) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (page == 4 && !_failedOnce) {
      _failedOnce = true;
      throw Exception('Network timeout');
    }
    const total = 240;
    final start = (page - 1) * size;
    if (start >= total) return const [];
    final now = DateTime.now();
    return [
      for (var i = start; i < math.min(start + size, total); i++) _txn(i, now),
    ];
  }

  bool _failedOnce = false;

  static Txn _txn(int i, DateTime now) {
    final r = math.Random(i * 7919);
    if (i % 11 == 3) {
      return Txn(
        id: 't$i',
        title: i % 2 == 0 ? 'Salary' : 'Transfer from Ana Lee',
        category: 'Income',
        icon: Icons.south_west_rounded,
        amount: i % 2 == 0 ? 3200 : 25 + r.nextInt(200).toDouble(),
        date: now.subtract(Duration(hours: i * 9)),
        pending: false,
      );
    }
    final m = _merchants[r.nextInt(_merchants.length)];
    final amt = m.$4 + r.nextDouble() * (m.$5 - m.$4);
    return Txn(
      id: 't$i',
      title: m.$1,
      category: m.$2,
      icon: m.$3,
      amount: -(amt * 100).roundToDouble() / 100,
      date: now.subtract(Duration(hours: i * 9 + r.nextInt(8))),
      pending: i < 2,
    );
  }
}

enum PulseStage { onboarding, auth, app }

/// App state shared by all Pulse screens: sign-in stage, cart, wishlist, and following.
class PulseStore extends ChangeNotifier {
  PulseStore(this.data);

  final PulseData data;

  PulseStage _stage = PulseStage.onboarding;
  PulseStage get stage => _stage;

  /// The signed-in user (always Ana Lee in the demo).
  Person get me => data.person('u1');

  final Map<String, int> _cart = {'p03': 1};
  final Set<String> _wishlist = {'p06'};
  final Set<String> _following = {'u4'};
  final Set<String> _liked = {};
  double balance = 4820.55;

  void finishOnboarding() => _set(PulseStage.auth);
  void signIn() => _set(PulseStage.app);
  void signOut() => _set(PulseStage.auth);

  void _set(PulseStage s) {
    _stage = s;
    notifyListeners();
  }

  Map<Product, int> get cart => {for (final e in _cart.entries) data.product(e.key): e.value};
  int get cartCount => _cart.values.fold(0, (a, b) => a + b);
  double get subtotal => cart.entries.fold(0, (s, e) => s + e.key.price * e.value);
  double get savings => cart.entries.fold(0, (s, e) => s + ((e.key.compareAt ?? e.key.price) - e.key.price) * e.value);

  void addToCart(Product p, [int qty = 1]) {
    _cart[p.id] = (_cart[p.id] ?? 0) + qty;
    notifyListeners();
  }

  void setQty(Product p, int qty) {
    if (qty <= 0) {
      _cart.remove(p.id);
    } else {
      _cart[p.id] = qty;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  bool isWished(Product p) => _wishlist.contains(p.id);
  void toggleWish(Product p) {
    _wishlist.contains(p.id) ? _wishlist.remove(p.id) : _wishlist.add(p.id);
    notifyListeners();
  }

  bool isFollowing(Person p) => _following.contains(p.id);
  void setFollowing(Person p, bool on) {
    on ? _following.add(p.id) : _following.remove(p.id);
    notifyListeners();
  }

  bool isLiked(Post p) => _liked.contains(p.id);
  void setLiked(Post p, bool on) {
    on ? _liked.add(p.id) : _liked.remove(p.id);
    notifyListeners();
  }

  void pay(double amount) {
    balance -= amount;
    notifyListeners();
  }
}

/// Gives every Pulse screen access to [PulseStore] (and through it, [PulseData]).
/// `PulseScope.of(context)` also rebuilds the caller when the store changes.
class PulseScope extends InheritedNotifier<PulseStore> {
  const PulseScope({super.key, required PulseStore store, required super.child}) : super(notifier: store);

  static PulseStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<PulseScope>()!.notifier!;

  /// Read without subscribing to changes (use in callbacks).
  static PulseStore read(BuildContext context) => context.getInheritedWidgetOfExactType<PulseScope>()!.notifier!;
}

/// Push a page that keeps access to the Pulse store and theme.
Future<T?> pulsePush<T>(BuildContext context, Widget page, {bool fullscreen = false}) {
  final store = PulseScope.read(context);
  return Navigator.of(context).push<T>(
    MaterialPageRoute(fullscreenDialog: fullscreen, builder: (_) => PulseScope(store: store, child: page)),
  );
}

String money(num v, {bool sign = false}) => UiMoney.format(v, sign: sign);
