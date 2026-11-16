# Demo resources

Mock data and media for the Pulse demo app in `example/lib/pulse/`. Nothing here is loaded over the network.

| Path | Used for |
|---|---|
| `data/products.json` | Shop catalog (16 products, paged into `UiInfiniteGrid`) |
| `data/people.json` | Users, avatars, chat contacts |
| `data/posts.json` | Social feed (image and video posts) |
| `data/workouts.json` | Fitness plans and exercises |
| `images/products/` | Product photos (600×600) |
| `images/avatars/` | Profile photos (240×240) |
| `images/content/` | Banners, posts, and workout covers (1200×800) |
| `video/` | `butterfly.mp4`, `bee.mp4` for `UiVideoPlayer` |

Wallet transactions are generated in code, so the infinite list can page through hundreds of rows.

Photos come from picsum.photos (Unsplash license). The videos are the Flutter sample videos from `flutter.github.io/assets-for-api-docs`.
