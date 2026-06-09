import 'package:flutter/material.dart';

void main() => runApp(const App());

const seed = Color(0xFF6750A4);

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'UI Prototype',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
    ),
    initialRoute: '/login',
    routes: {
      '/login': (_) => const LoginScreen(),
      '/main': (_) => const MainShell(),
      '/detail': (_) => const DetailScreen(),
    },
  );
}

// ---------- LOGIN ----------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  // FIX 1: Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.bolt, size: 64, color: seed),
                    const SizedBox(height: 12),
                    Text('Welcome back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    const Text('Sign in to continue',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pass,
                      obscureText: _hide,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_hide
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      (v == null || v.length < 4) ? 'Min 4 chars' : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Sign in'),
                    ),
                    TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- MAIN SHELL (Bottom Nav) ----------
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  static const _labels = <String>['Home', 'Explore', 'Create', 'Profile'];

  // FIX 2: Use IndexedStack so pages preserve their state across tab switches
  final List<Widget> _pages = const [
    HomeScreen(),
    ExploreScreen(),
    CreateScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_labels[_idx]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          )
        ],
      ),
      // FIX 2: IndexedStack keeps all pages alive and preserves scroll/state
      body: IndexedStack(
        index: _idx,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Create'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------- HOME ----------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning',
                // FIX 3: withOpacity() is deprecated — use withValues(alpha:)
                style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 4),
              Text(
                'Your dashboard',
                style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Quick actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (ctx, c) {
          final cross = c.maxWidth > 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cross,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: const [
              _StatCard(icon: Icons.task_alt, label: 'Tasks', value: '12'),
              _StatCard(
                  icon: Icons.message_outlined,
                  label: 'Messages',
                  value: '4'),
              _StatCard(
                  icon: Icons.bar_chart, label: 'Reports', value: '8'),
              _StatCard(
                  icon: Icons.star_outline, label: 'Starred', value: '23'),
            ],
          );
        }),
        const SizedBox(height: 24),
        const Text('Recent',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...List.generate(
          5,
              (i) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text('Item ${i + 1}'),
              subtitle: const Text('Tap for details'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/detail'),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;

  // FIX 4: Added key passthrough for correct widget identity in tree
  const _StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.primary, size: 28),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ---------- EXPLORE ----------
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _q = '';
  final _all = List.generate(
    20,
        (i) => {
      'title': 'Result ${i + 1}',
      'tag': ['Design', 'Code', 'Music', 'Art'][i % 4],
    },
  );

  @override
  Widget build(BuildContext context) {
    final items = _all
        .where((e) =>
    e['title']!.toLowerCase().contains(_q.toLowerCase()) ||
        e['tag']!.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: LayoutBuilder(builder: (ctx, c) {
            final cross =
            c.maxWidth > 700 ? 3 : c.maxWidth > 450 ? 2 : 1;
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/detail'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(label: Text(items[i]['tag']!)),
                        const Spacer(),
                        Text(
                          items[i]['title']!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ---------- CREATE (Form) ----------
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'General';
  bool _notify = true;

  // FIX 1: Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState!.validate()) {
      final savedTitle = _title.text;
      // FIX 5: Clear controllers BEFORE reset so form reverts cleanly
      _title.clear();
      _desc.clear();
      _form.currentState!.reset();
      setState(() {
        _category = 'General';
        _notify = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $savedTitle')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder()),
                  items: const ['General', 'Work', 'Personal', 'Urgent']
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  // FIX 6: Null-safe dropdown handler with fallback
                  onChanged: (v) =>
                      setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Send notification'),
                  value: _notify,
                  onChanged: (v) => setState(() => _notify = v),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- PROFILE ----------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(children: [
            CircleAvatar(
                radius: 48,
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.person,
                    size: 56, color: cs.onPrimaryContainer)),
            const SizedBox(height: 12),
            const Text('Jane Doe',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('jane@example.com'),
          ]),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(children: [
            const ListTile(
                leading: Icon(Icons.settings), title: Text('Settings')),
            const Divider(height: 0),
            const ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications')),
            const Divider(height: 0),
            const ListTile(
                leading: Icon(Icons.help), title: Text('Help & Support')),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title:
              Text('Logout', style: TextStyle(color: cs.error)),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
            ),
          ]),
        ),
      ],
    );
  }
}

// ---------- DETAIL ----------
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient:
              LinearGradient(colors: [cs.primary, cs.secondary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
                child:
                Icon(Icons.image, color: Colors.white, size: 64)),
          ),
          const SizedBox(height: 16),
          const Text('Item title',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'This is a sample detail screen showing rich content, gradients, and clean Material 3 styling. Navigation works from the home or explore screens.'),
          const SizedBox(height: 16),
          Row(children: [
            FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Share')),
            const SizedBox(width: 12),
            OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back')),
          ]),
        ],
      ),
    );
  }
}