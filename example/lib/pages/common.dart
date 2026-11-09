import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

/// Scrolling page body: centered, max 900 px wide, sections spaced apart.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key, required this.children, this.controller});

  final List<Widget> children;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: UiSpace.xl),
      children: [
        UiContent(
          maxWidth: 900,
          child: UiColumn(gap: UiSpace.xxl, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ],
    );
  }
}

/// One titled demo block.
class Demo extends StatelessWidget {
  const Demo(this.title, {super.key, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => UiSection(title: title, subtitle: subtitle, child: child);
}

/// Wrapping row of demo widgets.
class DemoWrap extends StatelessWidget {
  const DemoWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: UiSpace.sm,
    runSpacing: UiSpace.sm,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}

/// Small fake data set shared by the pages.
class Person {
  const Person(this.name, this.role, this.avatar, this.city, this.score);
  final String name;
  final String role;
  final String avatar;
  final String city;
  final int score;
}

const people = [
  Person('Ana Ruiz', 'Designer', 'assets/images/avatars/ana.jpg', 'Madrid', 92),
  Person('Ben Okafor', 'Engineer', 'assets/images/avatars/ben.jpg', 'Lagos', 78),
  Person('Cy Tanaka', 'Product', 'assets/images/avatars/cy.jpg', 'Tokyo', 85),
  Person('Dee Walsh', 'Research', 'assets/images/avatars/dee.jpg', 'Dublin', 64),
  Person('Eli Novak', 'Engineer', 'assets/images/avatars/eli.jpg', 'Prague', 71),
  Person('Fay Chen', 'Marketing', 'assets/images/avatars/fay.jpg', 'Taipei', 88),
];

const productImages = [
  'assets/images/products/backpack.jpg',
  'assets/images/products/bag.jpg',
  'assets/images/products/beanie.jpg',
  'assets/images/products/headphones.jpg',
  'assets/images/products/jacket.jpg',
  'assets/images/products/shirt.jpg',
  'assets/images/products/shoe.jpg',
  'assets/images/products/watch.jpg',
];

const contentImages = [
  'assets/images/content/hero1.jpg',
  'assets/images/content/hero2.jpg',
  'assets/images/content/hero3.jpg',
  'assets/images/content/post1.jpg',
  'assets/images/content/post2.jpg',
  'assets/images/content/post3.jpg',
  'assets/images/content/trip.jpg',
];
