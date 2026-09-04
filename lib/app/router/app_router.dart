import 'package:go_router/go_router.dart';

import '../../features/home/pages/home_page.dart';
import '../../features/bucket_list/pages/bucket_list_page.dart';
import '../../features/memories/pages/memories_page.dart';
import '../../features/add_item/pages/add_item_page.dart';
import '../../features/item_details/pages/item_details_page.dart';
import '../../features/settings/pages/settings_page.dart';
import 'app_shell.dart';

/// Root navigation graph. The bottom-nav tabs (home, bucket-list, memories)
/// live under a StatefulShellRoute so each tab keeps its own scroll/state,
/// and the selected nav index always matches the current route.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bucket-list',
              builder: (context, state) => const BucketListPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddItemPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      ItemDetailsPage(itemId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) =>
                          AddItemPage(itemId: state.pathParameters['id']),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/memories',
              builder: (context, state) => const MemoriesPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
