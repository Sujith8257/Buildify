import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backend/embedded_backend.dart';

void main() {
  runApp(const ProviderScope(child: BuildifyApp()));
}

class BuildifyPalette {
  static const bg = Color(0xFF0D0D0D);
  static const surface = Color(0xFF111111);
  static const text = Color(0xFFE8E2D9);
  static const primary = Color(0xFFDF795E);
  static const success = Color(0xFF7EC8A4);
  static const error = Color(0xFFE2704A);
  static const muted = Color(0xFF666666);
  static const border = Color(0xFF222222);
}

final embeddedBackendProvider = Provider<EmbeddedBackendService>((ref) {
  final service = EmbeddedBackendService();
  unawaited(service.devLogin(userName: 'user'));
  ref.onDispose(service.dispose);
  return service;
});

final serverProvider = StateNotifierProvider<ServerController, ServerState>((
  ref,
) {
  final backend = ref.watch(embeddedBackendProvider);
  return ServerController(backend);
});

class ServerState {
  const ServerState({
    required this.isRunning,
    required this.requestCount,
    required this.rps,
    required this.publicUrl,
    required this.uptime,
    required this.lowBattery,
    required this.tunnelProvider,
    required this.logs,
    required this.projects,
    this.activeProjectId,
    required this.userName,
    this.statusMessage,
  });

  final bool isRunning;
  final int requestCount;
  final double rps;
  final String publicUrl;
  final Duration uptime;
  final bool lowBattery;
  final String tunnelProvider;
  final List<LogLine> logs;
  final List<BackendProject> projects;
  final String? activeProjectId;
  final String userName;
  final String? statusMessage;

  ServerState copyWith({
    bool? isRunning,
    int? requestCount,
    double? rps,
    String? publicUrl,
    Duration? uptime,
    bool? lowBattery,
    String? tunnelProvider,
    List<LogLine>? logs,
    List<BackendProject>? projects,
    String? activeProjectId,
    String? userName,
    String? statusMessage,
  }) {
    return ServerState(
      isRunning: isRunning ?? this.isRunning,
      requestCount: requestCount ?? this.requestCount,
      rps: rps ?? this.rps,
      publicUrl: publicUrl ?? this.publicUrl,
      uptime: uptime ?? this.uptime,
      lowBattery: lowBattery ?? this.lowBattery,
      tunnelProvider: tunnelProvider ?? this.tunnelProvider,
      logs: logs ?? this.logs,
      projects: projects ?? this.projects,
      activeProjectId: activeProjectId ?? this.activeProjectId,
      userName: userName ?? this.userName,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

enum LogType { request, error, system }

class LogLine {
  const LogLine({required this.text, required this.type});
  final String text;
  final LogType type;
}

class ServerController extends StateNotifier<ServerState> {
  ServerController(this._backend)
    : super(
        const ServerState(
          isRunning: false,
          requestCount: 0,
          rps: 0,
          publicUrl: 'https://myproject.buildify.app',
          uptime: Duration.zero,
          lowBattery: false,
          tunnelProvider: 'cloudflare',
          logs: [LogLine(text: '-- buildify booted --', type: LogType.system)],
          projects: [],
          activeProjectId: null,
          userName: 'user',
          statusMessage: 'idle',
        ),
      ) {
    _syncSubscription = _backend.stream.listen(_syncFromBackend);
    _syncFromBackend(_backend.state);
  }

  final EmbeddedBackendService _backend;
  StreamSubscription<BackendState>? _syncSubscription;

  void startServer() {
    final projectId =
        state.activeProjectId ??
        (state.projects.isNotEmpty ? state.projects.first.id : null);
    if (projectId == null) return;
    unawaited(_backend.startSession(projectId: projectId));
  }

  void stopServer() {
    final sessionId = _backend.state.activeSession?.id;
    if (sessionId == null) return;
    unawaited(_backend.stopSession(sessionId: sessionId));
  }

  Future<void> importProjectAndStart({
    required String sourceType,
    required bool zipChosen,
  }) async {
    final projectName =
        zipChosen
            ? 'zip-site-${state.projects.length + 1}'
            : '$sourceType-site-${state.projects.length + 1}';
    final project = await _backend.createProject(
      name: projectName,
      sourceType: sourceType,
    );
    await _backend.createDeployment(
      projectId: project.id,
      framework: 'plain html',
      sourceType: zipChosen ? 'zip upload' : sourceType,
    );
    await _backend.startSession(projectId: project.id);
  }

  void _syncFromBackend(BackendState backendState) {
    final session = backendState.activeSession;
    final mappedLogs = backendState.logs
        .map(
          (e) => LogLine(
            text: e.message,
            type: switch (e.type) {
              BackendLogType.request => LogType.request,
              BackendLogType.error => LogType.error,
              BackendLogType.system => LogType.system,
            },
          ),
        )
        .toList(growable: false);
    final uptime =
        session == null
            ? Duration.zero
            : DateTime.now().difference(session.startedAt);
    state = state.copyWith(
      isRunning: session?.isRunning ?? false,
      requestCount: session?.requestCount ?? 0,
      rps: session?.rps ?? 0,
      publicUrl:
          session?.publicUrl ??
          (backendState.projects.isNotEmpty
              ? backendState.projects.first.url
              : 'https://myproject.buildify.app'),
      uptime: uptime,
      lowBattery: session?.lowBattery ?? false,
      tunnelProvider: session?.tunnelProvider ?? 'cloudflare',
      logs: mappedLogs,
      projects: backendState.projects,
      activeProjectId:
          session?.projectId ??
          (backendState.projects.isNotEmpty
              ? backendState.projects.first.id
              : null),
      userName: backendState.userName,
      statusMessage: session == null ? 'idle' : 'your site is live.',
    );
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }
}

class BuildifyApp extends ConsumerWidget {
  const BuildifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.spaceMonoTextTheme(base.textTheme).apply(
      bodyColor: BuildifyPalette.text,
      displayColor: BuildifyPalette.text,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'buildify',
      theme: base.copyWith(
        scaffoldBackgroundColor: BuildifyPalette.bg,
        textTheme: textTheme,
        colorScheme: base.colorScheme.copyWith(
          primary: BuildifyPalette.primary,
          secondary: BuildifyPalette.success,
          surface: BuildifyPalette.surface,
          error: BuildifyPalette.error,
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/import',
      builder: (context, state) => const ImportProjectScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navShell) => ShellScaffold(shell: navShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (c, s) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/deploy',
              builder: (c, s) => const DeployWizardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/logs', builder: (c, s) => const LogsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/domains', builder: (c, s) => const DomainsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (c, s) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: BuildifyPalette.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                'Bd',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: BuildifyPalette.bg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'buildify',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: BuildifyPalette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 2, width: 240, color: BuildifyPalette.primary),
            const SizedBox(height: 10),
            Text(
              'your phone. your server. go live.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: BuildifyPalette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'sign in to buildify',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'deploy from anywhere',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BuildifyPalette.muted),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/dashboard'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: BuildifyPalette.primary,
              ),
              child: const Text('continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.shell, super.key});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      floatingActionButton:
          shell.currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  context.push('/import');
                },
                backgroundColor: BuildifyPalette.primary,
                foregroundColor: BuildifyPalette.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: BuildifyPalette.bg),
                ),
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: BuildifyPalette.bg,
        indicatorColor: BuildifyPalette.primary.withValues(alpha: 0.18),
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'home'),
          NavigationDestination(
            icon: Icon(Icons.upload_file_outlined),
            label: 'deploy',
          ),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'logs'),
          NavigationDestination(
            icon: Icon(Icons.language_outlined),
            label: 'domains',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}

class ImportProjectScreen extends ConsumerStatefulWidget {
  const ImportProjectScreen({super.key});

  @override
  ConsumerState<ImportProjectScreen> createState() =>
      _ImportProjectScreenState();
}

class _ImportProjectScreenState extends ConsumerState<ImportProjectScreen> {
  String? selectedProvider;
  bool zipChosen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuildifyPalette.bg,
      appBar: AppBar(
        backgroundColor: BuildifyPalette.surface,
        foregroundColor: BuildifyPalette.text,
        title: Row(
          children: [
            const Icon(
              Icons.terminal,
              color: BuildifyPalette.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'buildify',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BuildifyPalette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: BuildifyPalette.bg,
                border: Border.all(color: const Color(0xFF555555)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const Text(
            'step 1 of 2',
            style: TextStyle(fontSize: 14, color: Color(0xFF55423E)),
          ),
          const SizedBox(height: 6),
          Text(
            'connect to git',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _providerButton(
            icon: Icons.code,
            label: 'github',
            selected: selectedProvider == 'github',
            onTap: () => setState(() => selectedProvider = 'github'),
          ),
          const SizedBox(height: 10),
          _providerButton(
            icon: Icons.api,
            label: 'gitlab',
            selected: selectedProvider == 'gitlab',
            onTap: () => setState(() => selectedProvider = 'gitlab'),
          ),
          const SizedBox(height: 10),
          _providerButton(
            icon: Icons.integration_instructions,
            label: 'bitbucket',
            selected: selectedProvider == 'bitbucket',
            onTap: () => setState(() => selectedProvider = 'bitbucket'),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFF555555))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('or', style: TextStyle(color: Color(0xFF55423E))),
              ),
              Expanded(child: Divider(color: Color(0xFF555555))),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => setState(() => zipChosen = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
              decoration: BoxDecoration(
                color: BuildifyPalette.surface,
                border: Border.all(
                  color:
                      zipChosen
                          ? BuildifyPalette.primary
                          : const Color(0xFF555555),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.folder, size: 34, color: Color(0xFFA38B86)),
                  const SizedBox(height: 8),
                  const Text('upload zip file', style: TextStyle(fontSize: 16)),
                  Text(
                    zipChosen
                        ? 'zip selected'
                        : 'drag and drop or click to browse',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF55423E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _onContinueAndStartServer,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              backgroundColor: BuildifyPalette.primary,
              foregroundColor: BuildifyPalette.bg,
            ),
            child: const Text('continue and start server'),
          ),
        ],
      ),
    );
  }

  Widget _providerButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        alignment: Alignment.centerLeft,
        side: BorderSide(
          color: selected ? BuildifyPalette.primary : const Color(0xFF555555),
        ),
        backgroundColor: BuildifyPalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: BuildifyPalette.text),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: BuildifyPalette.text, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinueAndStartServer() async {
    if (selectedProvider == null && !zipChosen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('select git provider or upload zip first'),
        ),
      );
      return;
    }
    await ref
        .read(serverProvider.notifier)
        .importProjectAndStart(
          sourceType: selectedProvider ?? 'zip upload',
          zipChosen: zipChosen,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('your site is live.')));
    context.go('/dashboard');
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverProvider);
    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: BuildifyPalette.bg,
            border: Border(bottom: BorderSide(color: BuildifyPalette.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.terminal,
                color: BuildifyPalette.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'buildify',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: BuildifyPalette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: BuildifyPalette.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: BuildifyPalette.text,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(
                'good morning, ${server.userName}.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _MetricChip(
                      label: 'projects live',
                      value: '${server.projects.where((p) => p.isLive).length}',
                    ),
                    const SizedBox(width: 12),
                    _MetricChip(
                      label: 'requests today',
                      value: '${server.requestCount}',
                    ),
                    const SizedBox(width: 12),
                    _MetricChip(
                      label: 'bandwidth used',
                      value: '${(server.requestCount * 18) ~/ 100}mb',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'recent projects',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: BuildifyPalette.text.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                ),
              ),
              ...server.projects.map((project) {
                final deployedAt =
                    project.lastDeployedAt == null
                        ? 'last deployed never'
                        : 'last deployed ${DateTime.now().difference(project.lastDeployedAt!).inMinutes}m ago';
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _ProjectCard(
                    name: project.name,
                    url: project.url,
                    deployedAt: deployedAt,
                    isLive: project.isLive,
                  ),
                );
              }),
              if (server.projects.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'no projects yet. tap + to start.',
                    style: TextStyle(color: Color(0xFFA38B86)),
                  ),
                ),
              const SizedBox(height: 14),
              _panel(
                context,
                title: 'live server',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton(
                      onPressed: () {
                        final ctrl = ref.read(serverProvider.notifier);
                        server.isRunning
                            ? ctrl.stopServer()
                            : ctrl.startServer();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            server.isRunning
                                ? BuildifyPalette.error
                                : BuildifyPalette.primary,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(
                        server.isRunning ? 'stop server' : 'start server',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'public url: ${server.publicUrl}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'tunnel: ${server.tunnelProvider}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'uptime: ${_formatUptime(server.uptime)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DeployWizardScreen extends StatefulWidget {
  const DeployWizardScreen({super.key});

  @override
  State<DeployWizardScreen> createState() => _DeployWizardScreenState();
}

class _DeployWizardScreenState extends State<DeployWizardScreen> {
  String source = 'zip upload';
  String framework = 'react';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'deploy wizard',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _panel(
          context,
          title: 'source',
          child: DropdownButton<String>(
            isExpanded: true,
            value: source,
            dropdownColor: BuildifyPalette.surface,
            items: const [
              DropdownMenuItem(value: 'zip upload', child: Text('zip upload')),
              DropdownMenuItem(
                value: 'github repo',
                child: Text('github repo'),
              ),
            ],
            onChanged: (v) => setState(() => source = v ?? source),
          ),
        ),
        const SizedBox(height: 12),
        _panel(
          context,
          title: 'framework auto-detection',
          child: DropdownButton<String>(
            isExpanded: true,
            value: framework,
            dropdownColor: BuildifyPalette.surface,
            items: const [
              DropdownMenuItem(value: 'react', child: Text('react')),
              DropdownMenuItem(value: 'vue', child: Text('vue')),
              DropdownMenuItem(value: 'plain html', child: Text('plain html')),
            ],
            onChanged: (v) => setState(() => framework = v ?? framework),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed:
              () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('deploying...'))),
          style: FilledButton.styleFrom(
            backgroundColor: BuildifyPalette.primary,
          ),
          child: const Text('go live'),
        ),
      ],
    );
  }
}

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  LogType? filter;
  bool autoScroll = true;
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(serverProvider).logs;
    final shown =
        filter == null ? logs : logs.where((l) => l.type == filter).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!autoScroll || !controller.hasClients) return;
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('logs terminal'),
        backgroundColor: BuildifyPalette.bg,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Wrap(
              spacing: 8,
              children: [
                _filterButton(
                  'all',
                  filter == null,
                  () => setState(() => filter = null),
                ),
                _filterButton(
                  'errors',
                  filter == LogType.error,
                  () => setState(() => filter = LogType.error),
                ),
                _filterButton(
                  'requests',
                  filter == LogType.request,
                  () => setState(() => filter = LogType.request),
                ),
                _filterButton(
                  autoScroll ? 'auto-scroll: on' : 'auto-scroll: off',
                  autoScroll,
                  () => setState(() => autoScroll = !autoScroll),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: BuildifyPalette.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                controller: controller,
                itemCount: shown.length,
                itemBuilder: (context, index) {
                  final log = shown[index];
                  final color = switch (log.type) {
                    LogType.error => BuildifyPalette.primary,
                    LogType.system => BuildifyPalette.muted,
                    LogType.request => BuildifyPalette.text,
                  };
                  return Text(
                    log.text,
                    style: TextStyle(fontSize: 11, color: color),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _filterButton(String label, bool selected, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            selected ? BuildifyPalette.primary : BuildifyPalette.text,
        side: BorderSide(
          color: selected ? BuildifyPalette.primary : BuildifyPalette.border,
        ),
      ),
      child: Text(label),
    );
  }
}

class DomainsScreen extends StatelessWidget {
  const DomainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'domains',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _panel(
          context,
          title: 'custom domain',
          child: const Text('myproject.buildify.app'),
        ),
        const SizedBox(height: 12),
        _panel(context, title: 'ssl', child: const Text('auto ssl active')),
        const SizedBox(height: 12),
        _panel(
          context,
          title: 'qr share',
          child: const Text('qr preview placeholder'),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'settings',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _panel(
          context,
          title: 'env vars',
          child: const Text('.env manager (encrypted at rest)'),
        ),
        const SizedBox(height: 12),
        _panel(
          context,
          title: 'analytics',
          child: const Text('requests/hr, bandwidth, top pages'),
        ),
        const SizedBox(height: 12),
        _panel(
          context,
          title: 'profile',
          child: const Text('builder profile controls'),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuildifyPalette.surface,
        border: Border.all(color: const Color(0xFF555555)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFDBC1BA)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: BuildifyPalette.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.name,
    required this.url,
    required this.deployedAt,
    required this.isLive,
  });

  final String name;
  final String url;
  final String deployedAt;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final textColor = isLive ? BuildifyPalette.text : const Color(0xFFA38B86);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuildifyPalette.surface,
        border: Border.all(color: const Color(0xFF555555)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isLive ? BuildifyPalette.success : BuildifyPalette.muted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_vert, size: 20, color: Color(0xFFDBC1BA)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFF3D3230)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(url, style: TextStyle(fontSize: 13, color: textColor)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Color(0xFFA38B86)),
              const SizedBox(width: 4),
              Text(
                deployedAt,
                style: const TextStyle(fontSize: 13, color: Color(0xFFA38B86)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _panel(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: BuildifyPalette.surface,
      border: Border.all(color: BuildifyPalette.border),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: BuildifyPalette.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

String _formatUptime(Duration d) {
  final hh = d.inHours.toString().padLeft(2, '0');
  final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
  final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$hh:$mm:$ss';
}
