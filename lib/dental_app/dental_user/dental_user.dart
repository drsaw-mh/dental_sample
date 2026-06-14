import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:4000';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:4000';
  }

  return 'http://127.0.0.1:4000';
}

class DentalApp extends StatelessWidget {
  const DentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0B7285);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DentalOps',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF17212B),
          displayColor: const Color(0xFF17212B),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE1E7EC)),
          ),
        ),
      ),
      home: const ClinicShell(),
    );
  }
}

class ClinicShell extends StatefulWidget {
  const ClinicShell({super.key});

  @override
  State<ClinicShell> createState() => _ClinicShellState();
}

class _ClinicShellState extends State<ClinicShell> {
  int selectedIndex = 0;
  RoleFilter selectedRole = RoleFilter.all;

  final pages = const [
    _NavigationItem(
      Icons.dashboard_outlined,
      Icons.dashboard,
      'Dashboard',
      'Dash',
    ),
    _NavigationItem(
      Icons.people_alt_outlined,
      Icons.people_alt,
      'Users',
      'Users',
    ),
    _NavigationItem(
      Icons.event_available_outlined,
      Icons.event_available,
      'Booking',
      'Book',
    ),
    _NavigationItem(
      Icons.medical_services_outlined,
      Icons.medical_services,
      'Doctors',
      'Doctors',
    ),
    _NavigationItem(
      Icons.point_of_sale_outlined,
      Icons.point_of_sale,
      'Cashier',
      'Cash',
    ),
    _NavigationItem(
      Icons.event_repeat_outlined,
      Icons.event_repeat,
      'Follow Up',
      'Follow',
    ),
    _NavigationItem(Icons.healing_outlined, Icons.healing, 'Procedure', 'Proc'),
    _NavigationItem(Icons.work_outline, Icons.work, 'Projects', 'Projects'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              _SideNav(
                items: pages,
                selectedIndex: selectedIndex,
                onSelected: (index) => setState(() => selectedIndex = index),
              ),
            Expanded(
              child: _ClinicPage(
                title: pages[selectedIndex].label,
                selectedIndex: selectedIndex,
                selectedRole: selectedRole,
                onRoleChanged: (role) => setState(() => selectedRole = role),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => selectedIndex = index),
              destinations: [
                for (final item in pages)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.shortLabel,
                  ),
              ],
            ),
    );
  }
}

class _ClinicPage extends StatelessWidget {
  const _ClinicPage({
    required this.title,
    required this.selectedIndex,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  final String title;
  final int selectedIndex;
  final RoleFilter selectedRole;
  final ValueChanged<RoleFilter> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final content = switch (selectedIndex) {
      0 => const DashboardView(),
      1 => UsersView(selectedRole: selectedRole, onRoleChanged: onRoleChanged),
      2 => const BookingView(),
      3 => const DoctorsView(),
      4 => const CashierView(),
      5 => const FollowUpView(),
      6 => const ProcedureView(),
      _ => const ProjectsView(),
    };

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(title: title)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverToBoxAdapter(child: content),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: compact ? double.infinity : 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DentalOps',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search patient, invoice, doctor, project',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Filters',
                  onPressed: () {},
                  icon: const Icon(Icons.tune),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDCE3EA)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDCE3EA)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          title: 'Clinic Live Status',
          action: 'Queue now',
          child: Column(
            children: [
              _ResponsiveGrid(
                compactMinTileWidth: 150,
                compactAspectRatio: 1.12,
                minTileWidth: 170,
                wideAspectRatio: 1.35,
                children: const [
                  _ClinicStatusCard(
                    title: 'Now Serving',
                    value: 'B-103',
                    detail: 'Aina Rahman',
                    icon: Icons.campaign_outlined,
                    color: Color(0xFFC2410C),
                  ),
                  _ClinicStatusCard(
                    title: 'Next Booking',
                    value: 'B-104',
                    detail: 'Ben Tan - 10:15',
                    icon: Icons.skip_next_outlined,
                    color: Color(0xFF0B7285),
                  ),
                  _ClinicStatusCard(
                    title: 'Estimated Wait',
                    value: '14m',
                    detail: 'For waiting patients',
                    icon: Icons.timer_outlined,
                    color: Color(0xFF166534),
                  ),
                  _ClinicStatusCard(
                    title: 'Queue Count',
                    value: '17',
                    detail: '8 waiting, 9 in chair',
                    icon: Icons.groups_2_outlined,
                    color: Color(0xFF7C3AED),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _BookingSummaryStrip(
                currentBooking: 'B-103',
                currentPatient: 'Aina Rahman',
                nextBooking: 'B-104',
                estimatedTime: '10:15 - 14 min',
              ),
              const SizedBox(height: 14),
              _QueueFlow(items: sampleQueueStatuses),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ResponsiveGrid(
          compactMinTileWidth: 170,
          compactAspectRatio: 0.95,
          minTileWidth: 210,
          wideAspectRatio: 1.15,
          children: const [
            _MetricCard(
              'Today Appointments',
              '38',
              '+12%',
              Icons.calendar_month,
              Color(0xFF0B7285),
            ),
            _MetricCard(
              'Pending Follow Ups',
              '14',
              '6 urgent',
              Icons.event_repeat,
              Color(0xFFC2410C),
            ),
            _MetricCard(
              'Cash Collected',
              'RM 18,420',
              '+8%',
              Icons.payments,
              Color(0xFF166534),
            ),
            _MetricCard(
              'Active Procedures',
              '27',
              '9 in chair',
              Icons.healing,
              Color(0xFF7C3AED),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TwoColumn(
          left: _Panel(
            title: 'Live Chair Schedule',
            action: 'Today',
            child: Column(
              children: [
                for (final appointment in sampleAppointments)
                  _AppointmentTile(appointment: appointment),
              ],
            ),
          ),
          right: _Panel(
            title: 'Operations Pulse',
            action: 'Clinic',
            child: Column(
              children: const [
                _ProgressRow(
                  label: 'Doctor utilization',
                  value: 0.82,
                  detail: '82%',
                ),
                _ProgressRow(
                  label: 'Procedure room load',
                  value: 0.64,
                  detail: '64%',
                ),
                _ProgressRow(
                  label: 'Cashier queue cleared',
                  value: 0.71,
                  detail: '17 / 24',
                ),
                _ProgressRow(
                  label: 'Follow-up completion',
                  value: 0.58,
                  detail: '58%',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UsersView extends StatelessWidget {
  const UsersView({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  final RoleFilter selectedRole;
  final ValueChanged<RoleFilter> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final users = sampleUsers.where((user) {
      return selectedRole == RoleFilter.all || user.role == selectedRole.label;
    }).toList();

    return _Panel(
      title: 'Users & Roles',
      action: '${users.length} people',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<RoleFilter>(
              segments: [
                for (final role in RoleFilter.values)
                  ButtonSegment(
                    value: role,
                    label: Text(role.label),
                    icon: Icon(role.icon),
                  ),
              ],
              selected: {selectedRole},
              onSelectionChanged: (selection) => onRoleChanged(selection.first),
            ),
          ),
          const SizedBox(height: 16),
          _ResponsiveGrid(
            minTileWidth: 260,
            children: [for (final user in users) _UserCard(user: user)],
          ),
        ],
      ),
    );
  }
}

class DoctorsView extends StatelessWidget {
  const DoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minTileWidth: 300,
      children: [
        for (final doctor in sampleDoctors) _DoctorCard(doctor: doctor),
      ],
    );
  }
}

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResponsiveGrid(
          compactMinTileWidth: 170,
          compactAspectRatio: 1.22,
          minTileWidth: 220,
          wideAspectRatio: 1.45,
          children: const [
            _MetricCard(
              'Open Slots',
              '3',
              'Today',
              Icons.event_available,
              Color(0xFF0B7285),
            ),
            _MetricCard(
              'Confirmed',
              '4',
              '+1',
              Icons.check_circle_outline,
              Color(0xFF166534),
            ),
            _MetricCard(
              'Walk-ins',
              '6',
              '2 waiting',
              Icons.directions_walk,
              Color(0xFFC2410C),
            ),
            _MetricCard(
              'Chair Load',
              '68%',
              '4 rooms',
              Icons.chair_alt,
              Color(0xFF7C3AED),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TwoColumn(
          left: _Panel(
            title: 'New Appointment',
            action: 'Booking',
            child: const _BookingForm(),
          ),
          right: _Panel(
            title: 'Available Slots',
            action: 'Today',
            child: Column(
              children: [
                for (final slot in sampleBookingSlots)
                  _BookingSlotTile(slot: slot),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          title: 'Appointment Queue',
          action: '${sampleAppointments.length} booked',
          child: Column(
            children: [
              for (final appointment in sampleAppointments)
                _AppointmentTile(appointment: appointment),
            ],
          ),
        ),
      ],
    );
  }
}

class CashierView extends StatelessWidget {
  const CashierView({super.key});

  @override
  Widget build(BuildContext context) {
    return _TwoColumn(
      left: _Panel(
        title: 'Payment Queue',
        action: 'RM 6,910 due',
        child: Column(
          children: [
            for (final invoice in sampleInvoices)
              _InvoiceTile(invoice: invoice),
          ],
        ),
      ),
      right: _Panel(
        title: 'Checkout Tools',
        action: 'Cashier',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _ActionButton(icon: Icons.receipt_long, label: 'Create invoice'),
            _ActionButton(icon: Icons.credit_card, label: 'Record payment'),
            _ActionButton(icon: Icons.discount, label: 'Apply package credit'),
            _ActionButton(icon: Icons.print, label: 'Print receipt'),
          ],
        ),
      ),
    );
  }
}

class FollowUpView extends StatelessWidget {
  const FollowUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Follow Up Board',
      action: '14 open',
      child: _ResponsiveGrid(
        minTileWidth: 290,
        children: [
          for (final followUp in sampleFollowUps)
            _FollowUpCard(followUp: followUp),
        ],
      ),
    );
  }
}

class ProcedureView extends StatelessWidget {
  const ProcedureView({super.key});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Procedure Pipeline',
      action: 'Treatment plans',
      child: _ResponsiveGrid(
        minTileWidth: 280,
        children: [
          for (final procedure in sampleProcedures)
            _ProcedureCard(procedure: procedure),
        ],
      ),
    );
  }
}

class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  var projects = [...sampleProjects];
  var isLoading = false;
  var isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  int get dueThisMonth {
    return projects
        .where((project) => project.deadline.startsWith('Jun'))
        .length;
  }

  int get averageProgress {
    if (projects.isEmpty) {
      return 0;
    }

    final total = projects.fold<double>(
      0,
      (sum, project) => sum + project.progress,
    );
    return ((total / projects.length) * 100).round();
  }

  Future<void> loadProjects() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/projects'));

      if (response.statusCode != 200) {
        throw Exception('Project API returned ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;

      if (!mounted) {
        return;
      }

      setState(() {
        projects = data
            .cast<Map<String, dynamic>>()
            .map(ClinicProject.fromJson)
            .toList();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Using local project data')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<bool> addProject(ProjectDraft draft) async {
    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/projects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(draft.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Project API returned ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      if (!mounted) {
        return false;
      }

      setState(() {
        projects.insert(0, ClinicProject.fromJson(data));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${draft.name} added to projects')),
      );
      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not add project. Backend offline?'),
        ),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResponsiveGrid(
          compactMinTileWidth: 170,
          compactAspectRatio: 1.22,
          minTileWidth: 220,
          wideAspectRatio: 1.45,
          children: [
            _MetricCard(
              'Active Projects',
              '${projects.length}',
              isLoading ? 'Syncing' : 'Live',
              Icons.work,
              const Color(0xFF0B7285),
            ),
            _MetricCard(
              'Due This Month',
              '$dueThisMonth',
              'Jun',
              Icons.event_note,
              const Color(0xFFC2410C),
            ),
            _MetricCard(
              'Avg Progress',
              '$averageProgress%',
              '+9%',
              Icons.trending_up,
              const Color(0xFF166534),
            ),
            _MetricCard(
              'Blocked',
              '1',
              'Audit',
              Icons.report_problem_outlined,
              const Color(0xFF7C3AED),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TwoColumn(
          left: _Panel(
            title: 'New Project',
            action: 'Create',
            child: _ProjectForm(isSaving: isSaving, onSubmit: addProject),
          ),
          right: _Panel(
            title: 'Project Templates',
            action: 'Quick start',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _ActionButton(
                  icon: Icons.fact_check,
                  label: 'Compliance audit',
                ),
                _ActionButton(
                  icon: Icons.room_preferences,
                  label: 'Room upgrade',
                ),
                _ActionButton(icon: Icons.campaign, label: 'Recall campaign'),
                _ActionButton(
                  icon: Icons.point_of_sale,
                  label: 'Finance workflow',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          title: 'Clinic Projects',
          action: isLoading ? 'Syncing' : '${projects.length} active',
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: isLoading ? null : loadProjects,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
              const SizedBox(height: 8),
              for (final project in projects) _ProjectTile(project: project),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE1E7EC))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'DentalOps',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++)
            _SideNavButton(
              item: items[i],
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('New visit'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavButton extends StatelessWidget {
  const _SideNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? const Color(0xFFE6F6F8) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF52606D),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFF344054),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.delta, this.icon, this.color);

  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Text(
                  delta,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.action,
    required this.child,
  });

  final String title;
  final String action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(action, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _TwoColumn extends StatelessWidget {
  const _TwoColumn({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Column(children: [left, const SizedBox(height: 16), right]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: left),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: right),
          ],
        );
      },
    );
  }
}

class _ClinicStatusCard extends StatelessWidget {
  const _ClinicStatusCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

class _QueueFlow extends StatelessWidget {
  const _QueueFlow({required this.items});

  final List<QueueStatus> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;

        if (compact) {
          return Column(
            children: [
              for (final item in items) _QueueStatusTile(status: item),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(child: _QueueStatusTile(status: items[index])),
              if (index < items.length - 1)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Icon(
                    Icons.chevron_right,
                    color: Color(0xFF98A2B3),
                    size: 22,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _QueueStatusTile extends StatelessWidget {
  const _QueueStatusTile({required this.status});

  final QueueStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(status.icon, color: status.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.stage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Now ${status.currentBooking} - ${status.currentPatient}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Next ${status.nextBooking} - ETA ${status.estimatedTime}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF344054),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status.currentBooking,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: status.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status.estimatedTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF667085),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingSummaryStrip extends StatelessWidget {
  const _BookingSummaryStrip({
    required this.currentBooking,
    required this.currentPatient,
    required this.nextBooking,
    required this.estimatedTime,
  });

  final String currentBooking;
  final String currentPatient;
  final String nextBooking;
  final String estimatedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EC)),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _BookingSummaryItem(
            label: 'Current booking',
            value: '$currentBooking - $currentPatient',
          ),
          _BookingSummaryItem(label: 'Next booking', value: nextBooking),
          _BookingSummaryItem(label: 'Estimated time', value: estimatedTime),
        ],
      ),
    );
  }
}

class _BookingSummaryItem extends StatelessWidget {
  const _BookingSummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF667085),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    this.compactMinTileWidth,
    this.minTileWidth = 240,
    this.compactAspectRatio = 1.45,
    this.wideAspectRatio = 1.35,
  });

  final List<Widget> children;
  final double? compactMinTileWidth;
  final double minTileWidth;
  final double compactAspectRatio;
  final double wideAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth < 520
            ? compactMinTileWidth ?? minTileWidth
            : minTileWidth;
        final count = (constraints.maxWidth / tileWidth).floor().clamp(1, 4);
        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth < 520
              ? compactAspectRatio
              : wideAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return _ListBlock(
      leading: Icons.chair_alt,
      title: appointment.patient,
      subtitle: '${appointment.time} - ${appointment.procedure}',
      trailing: appointment.doctor,
      color: appointment.color,
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return _ListBlock(
      leading: Icons.receipt,
      title: invoice.patient,
      subtitle: '${invoice.number} - ${invoice.status}',
      trailing: invoice.amount,
      color: invoice.color,
    );
  }
}

class _BookingSlotTile extends StatelessWidget {
  const _BookingSlotTile({required this.slot});

  final BookingSlot slot;

  @override
  Widget build(BuildContext context) {
    return _ListBlock(
      leading: Icons.schedule,
      title: '${slot.time} - ${slot.room}',
      subtitle: '${slot.doctor} - ${slot.type}',
      trailing: slot.status,
      color: slot.color,
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project});

  final ClinicProject project;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          _ListBlock(
            leading: Icons.work,
            title: project.name,
            subtitle: '${project.owner} - ${project.deadline}',
            trailing: '${(project.progress * 100).round()}%',
            color: project.color,
          ),
          LinearProgressIndicator(value: project.progress),
        ],
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.color,
  });

  final IconData leading;
  final String title;
  final String subtitle;
  final String trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(leading, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(subtitle, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(trailing, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _BookingForm extends StatelessWidget {
  const _BookingForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _FormFieldStub(
          icon: Icons.person_outline,
          label: 'Patient name',
          value: 'Search or add patient',
        ),
        _FormFieldStub(
          icon: Icons.medical_services_outlined,
          label: 'Doctor',
          value: 'Dr. Marcus Lee',
        ),
        _FormFieldStub(
          icon: Icons.healing_outlined,
          label: 'Procedure',
          value: 'Consultation / treatment',
        ),
        _FormFieldStub(
          icon: Icons.event_outlined,
          label: 'Date and time',
          value: 'Today, 15:30',
        ),
        _FormFieldStub(
          icon: Icons.notes_outlined,
          label: 'Notes',
          value: 'Symptoms, referral, or billing note',
        ),
        SizedBox(height: 6),
        _ActionButton(icon: Icons.event_available, label: 'Book appointment'),
      ],
    );
  }
}

class _FormFieldStub extends StatelessWidget {
  const _FormFieldStub({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDCE3EA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDCE3EA)),
          ),
        ),
      ),
    );
  }
}

class _ProjectForm extends StatefulWidget {
  const _ProjectForm({required this.isSaving, required this.onSubmit});

  final bool isSaving;
  final Future<bool> Function(ProjectDraft draft) onSubmit;

  @override
  State<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<_ProjectForm> {
  final nameController = TextEditingController();
  final ownerController = TextEditingController();
  final deadlineController = TextEditingController();
  final summaryController = TextEditingController();
  var priority = 'Medium';

  @override
  void dispose() {
    nameController.dispose();
    ownerController.dispose();
    deadlineController.dispose();
    summaryController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    final owner = ownerController.text.trim();
    final deadline = deadlineController.text.trim();

    if (name.isEmpty || owner.isEmpty || deadline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project name, owner, and deadline are required'),
        ),
      );
      return;
    }

    final created = await widget.onSubmit(
      ProjectDraft(
        name: name,
        owner: owner,
        deadline: deadline,
        priority: priority,
        summary: summaryController.text.trim(),
      ),
    );

    if (!mounted || !created) {
      return;
    }

    nameController.clear();
    ownerController.clear();
    deadlineController.clear();
    summaryController.clear();
    setState(() => priority = 'Medium');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProjectInput(
          icon: Icons.work_outline,
          label: 'Project name',
          hintText: 'e.g. Inventory barcode rollout',
          controller: nameController,
        ),
        _ProjectInput(
          icon: Icons.account_circle_outlined,
          label: 'Owner',
          hintText: 'Operations lead',
          controller: ownerController,
        ),
        _ProjectInput(
          icon: Icons.event_outlined,
          label: 'Deadline',
          hintText: 'Jul 15',
          controller: deadlineController,
        ),
        DropdownButtonFormField<String>(
          initialValue: priority,
          decoration: _inputDecoration(
            icon: Icons.flag_outlined,
            label: 'Priority',
            hintText: 'Medium',
          ),
          items: const [
            DropdownMenuItem(value: 'Low', child: Text('Low')),
            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
            DropdownMenuItem(value: 'High', child: Text('High')),
          ],
          onChanged: (value) => setState(() => priority = value ?? priority),
        ),
        const SizedBox(height: 10),
        _ProjectInput(
          controller: summaryController,
          icon: Icons.notes_outlined,
          label: 'Summary',
          hintText: 'Scope, expected result, and blockers',
        ),
        const SizedBox(height: 6),
        FilledButton.icon(
          onPressed: widget.isSaving ? null : submit,
          icon: widget.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_task),
          label: Text(widget.isSaving ? 'Adding project' : 'Add project'),
        ),
      ],
    );
  }
}

class _ProjectInput extends StatelessWidget {
  const _ProjectInput({
    required this.controller,
    required this.icon,
    required this.label,
    required this.hintText,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(
          icon: icon,
          label: label,
          hintText: hintText,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required IconData icon,
  required String label,
  required String hintText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDCE3EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDCE3EA)),
    ),
  );
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final double value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(detail, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: value),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final ClinicUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.color.withValues(alpha: 0.15),
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: user.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(user.role),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _StatusPill(label: user.status, color: user.color),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                  tooltip: 'Actions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: doctor.color.withValues(alpha: 0.15),
                  child: Icon(Icons.medical_services, color: doctor.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doctor.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                _StatusPill(label: doctor.status, color: doctor.color),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              doctor.specialty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${doctor.patientsToday} patients today - Room ${doctor.room}',
            ),
            const Spacer(),
            LinearProgressIndicator(value: doctor.utilization),
          ],
        ),
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.followUp});

  final FollowUp followUp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusPill(label: followUp.priority, color: followUp.color),
                const Spacer(),
                Text(
                  followUp.due,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              followUp.patient,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(followUp.reason, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.call_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(followUp.channel)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  tooltip: 'Complete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  const _ProcedureCard({required this.procedure});

  final DentalProcedure procedure;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(procedure.icon, color: procedure.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    procedure.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(procedure.patient),
            const SizedBox(height: 6),
            Text('${procedure.stage} - ${procedure.doctor}'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: procedure.progress),
                ),
                const SizedBox(width: 10),
                Text('${(procedure.progress * 100).round()}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(
    this.icon,
    this.selectedIcon,
    this.label,
    this.shortLabel,
  );

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String shortLabel;
}

enum RoleFilter {
  all('All', Icons.groups_outlined),
  user('User', Icons.person_outline),
  doctor('Doctor', Icons.medical_services_outlined),
  cashier('Cashier', Icons.point_of_sale_outlined);

  const RoleFilter(this.label, this.icon);

  final String label;
  final IconData icon;
}

class ClinicUser {
  const ClinicUser(
    this.name,
    this.role,
    this.status,
    this.initials,
    this.color,
  );

  final String name;
  final String role;
  final String status;
  final String initials;
  final Color color;
}

class Doctor {
  const Doctor(
    this.name,
    this.specialty,
    this.status,
    this.room,
    this.patientsToday,
    this.utilization,
    this.color,
  );

  final String name;
  final String specialty;
  final String status;
  final String room;
  final int patientsToday;
  final double utilization;
  final Color color;
}

class Appointment {
  const Appointment(
    this.patient,
    this.time,
    this.procedure,
    this.doctor,
    this.color,
  );

  final String patient;
  final String time;
  final String procedure;
  final String doctor;
  final Color color;
}

class QueueStatus {
  const QueueStatus(
    this.stage,
    this.currentBooking,
    this.currentPatient,
    this.nextBooking,
    this.estimatedTime,
    this.icon,
    this.color,
  );

  final String stage;
  final String currentBooking;
  final String currentPatient;
  final String nextBooking;
  final String estimatedTime;
  final IconData icon;
  final Color color;
}

class BookingSlot {
  const BookingSlot(
    this.time,
    this.room,
    this.doctor,
    this.type,
    this.status,
    this.color,
  );

  final String time;
  final String room;
  final String doctor;
  final String type;
  final String status;
  final Color color;
}

class Invoice {
  const Invoice(
    this.patient,
    this.number,
    this.status,
    this.amount,
    this.color,
  );

  final String patient;
  final String number;
  final String status;
  final String amount;
  final Color color;
}

class FollowUp {
  const FollowUp(
    this.patient,
    this.reason,
    this.due,
    this.channel,
    this.priority,
    this.color,
  );

  final String patient;
  final String reason;
  final String due;
  final String channel;
  final String priority;
  final Color color;
}

class DentalProcedure {
  const DentalProcedure(
    this.name,
    this.patient,
    this.stage,
    this.doctor,
    this.progress,
    this.icon,
    this.color,
  );

  final String name;
  final String patient;
  final String stage;
  final String doctor;
  final double progress;
  final IconData icon;
  final Color color;
}

class ClinicProject {
  const ClinicProject(
    this.name,
    this.owner,
    this.deadline,
    this.progress,
    this.color,
  );

  final String name;
  final String owner;
  final String deadline;
  final double progress;
  final Color color;

  factory ClinicProject.fromJson(Map<String, dynamic> json) {
    return ClinicProject(
      json['name'] as String? ?? 'Untitled project',
      json['owner'] as String? ?? 'Unassigned',
      json['deadline'] as String? ?? 'TBD',
      (json['progress'] as num?)?.toDouble() ?? 0,
      _parseHexColor(json['color'] as String? ?? '#0B7285'),
    );
  }
}

class ProjectDraft {
  const ProjectDraft({
    required this.name,
    required this.owner,
    required this.deadline,
    required this.priority,
    required this.summary,
  });

  final String name;
  final String owner;
  final String deadline;
  final String priority;
  final String summary;

  Map<String, Object> toJson() {
    return {
      'name': name,
      'owner': owner,
      'deadline': deadline,
      'priority': priority,
      'summary': summary,
      'progress': 0,
      'color': switch (priority) {
        'High' => '#C2410C',
        'Low' => '#166534',
        _ => '#0B7285',
      },
    };
  }
}

Color _parseHexColor(String value) {
  final normalized = value.replaceFirst('#', '');
  final parsed = int.tryParse('FF$normalized', radix: 16);
  return Color(parsed ?? 0xFF0B7285);
}

const sampleUsers = [
  ClinicUser('Aina Rahman', 'User', 'Active', 'AR', Color(0xFF0B7285)),
  ClinicUser('Dr. Marcus Lee', 'Doctor', 'In clinic', 'ML', Color(0xFF7C3AED)),
  ClinicUser('Siti Noor', 'Cashier', 'Front desk', 'SN', Color(0xFF166534)),
  ClinicUser('Dr. Priya Menon', 'Doctor', 'Surgery', 'PM', Color(0xFFC2410C)),
  ClinicUser('Ben Tan', 'User', 'New patient', 'BT', Color(0xFF2563EB)),
  ClinicUser('Farah Lim', 'Cashier', 'Insurance', 'FL', Color(0xFF9333EA)),
];

const sampleDoctors = [
  Doctor(
    'Dr. Marcus Lee',
    'Orthodontics',
    'Available',
    '2A',
    9,
    0.78,
    Color(0xFF0B7285),
  ),
  Doctor(
    'Dr. Priya Menon',
    'Oral surgery',
    'In procedure',
    '3B',
    6,
    0.88,
    Color(0xFFC2410C),
  ),
  Doctor(
    'Dr. Hannah Wong',
    'Paediatric dentistry',
    'Reviewing',
    '1C',
    8,
    0.63,
    Color(0xFF7C3AED),
  ),
  Doctor(
    'Dr. Amir Zain',
    'Implantology',
    'Available',
    '4A',
    4,
    0.52,
    Color(0xFF166534),
  ),
];

const sampleAppointments = [
  Appointment(
    'Aina Rahman',
    '09:00',
    'Scaling and polish',
    'Dr. Wong',
    Color(0xFF0B7285),
  ),
  Appointment(
    'Ben Tan',
    '10:15',
    'Root canal review',
    'Dr. Lee',
    Color(0xFF7C3AED),
  ),
  Appointment(
    'Mei Chen',
    '11:30',
    'Implant consult',
    'Dr. Amir',
    Color(0xFF166534),
  ),
  Appointment(
    'Ravi Kumar',
    '14:00',
    'Extraction',
    'Dr. Priya',
    Color(0xFFC2410C),
  ),
];

const sampleQueueStatuses = [
  QueueStatus(
    'Check-in',
    'B-103',
    'Aina Rahman',
    'B-104',
    '10:15',
    Icons.how_to_reg_outlined,
    Color(0xFFC2410C),
  ),
  QueueStatus(
    'Pre-check',
    'B-102',
    'Nur Iman',
    'B-103',
    '09:52',
    Icons.fact_check_outlined,
    Color(0xFF0B7285),
  ),
  QueueStatus(
    'Treatment',
    'B-101',
    'Ravi Kumar',
    'B-102',
    '18 min',
    Icons.healing_outlined,
    Color(0xFF7C3AED),
  ),
  QueueStatus(
    'Payment',
    'B-100',
    'Mei Chen',
    'B-101',
    '6 min',
    Icons.receipt_long_outlined,
    Color(0xFF166534),
  ),
];

const sampleBookingSlots = [
  BookingSlot(
    '12:30',
    'Room 1C',
    'Dr. Hannah Wong',
    'Hygiene review',
    'Open',
    Color(0xFF166534),
  ),
  BookingSlot(
    '15:30',
    'Room 2A',
    'Dr. Marcus Lee',
    'Orthodontic consult',
    'Open',
    Color(0xFF0B7285),
  ),
  BookingSlot(
    '16:15',
    'Room 4A',
    'Dr. Amir Zain',
    'Implant consult',
    'Hold',
    Color(0xFFC2410C),
  ),
  BookingSlot(
    '17:00',
    'Room 3B',
    'Dr. Priya Menon',
    'Surgery review',
    'Open',
    Color(0xFF7C3AED),
  ),
];

const sampleInvoices = [
  Invoice(
    'Aina Rahman',
    'INV-1048',
    'Ready to pay',
    'RM 280',
    Color(0xFF166534),
  ),
  Invoice(
    'Ben Tan',
    'INV-1049',
    'Insurance check',
    'RM 1,850',
    Color(0xFF7C3AED),
  ),
  Invoice('Ravi Kumar', 'INV-1050', 'Deposit due', 'RM 600', Color(0xFFC2410C)),
  Invoice(
    'Mei Chen',
    'INV-1051',
    'Package balance',
    'RM 4,180',
    Color(0xFF0B7285),
  ),
];

const sampleFollowUps = [
  FollowUp(
    'Ben Tan',
    'Pain score check after root canal review',
    'Today',
    'Phone call',
    'High',
    Color(0xFFC2410C),
  ),
  FollowUp(
    'Mei Chen',
    'Confirm implant scan appointment and deposit',
    'Tomorrow',
    'WhatsApp',
    'Medium',
    Color(0xFF7C3AED),
  ),
  FollowUp(
    'Aina Rahman',
    'Six month hygiene recall',
    'Fri',
    'SMS',
    'Routine',
    Color(0xFF166534),
  ),
  FollowUp(
    'Ravi Kumar',
    'Post extraction bleeding and medication check',
    'Today',
    'Phone call',
    'High',
    Color(0xFFC2410C),
  ),
];

const sampleProcedures = [
  DentalProcedure(
    'Root Canal',
    'Ben Tan',
    'Obturation scheduled',
    'Dr. Lee',
    0.72,
    Icons.healing,
    Color(0xFF7C3AED),
  ),
  DentalProcedure(
    'Dental Implant',
    'Mei Chen',
    'CBCT scan pending',
    'Dr. Amir',
    0.38,
    Icons.biotech,
    Color(0xFF166534),
  ),
  DentalProcedure(
    'Wisdom Tooth',
    'Ravi Kumar',
    'Recovery review',
    'Dr. Priya',
    0.84,
    Icons.local_hospital,
    Color(0xFFC2410C),
  ),
  DentalProcedure(
    'Braces Plan',
    'Sara Wong',
    'Aligner fitting',
    'Dr. Lee',
    0.55,
    Icons.timeline,
    Color(0xFF0B7285),
  ),
];

const sampleProjects = [
  ClinicProject(
    'Digital consent rollout',
    'Operations',
    'Jun 12',
    0.68,
    Color(0xFF0B7285),
  ),
  ClinicProject(
    'Sterilization audit',
    'Nursing lead',
    'Jun 04',
    0.42,
    Color(0xFFC2410C),
  ),
  ClinicProject(
    'Doctor room refresh',
    'Facilities',
    'Jul 01',
    0.31,
    Color(0xFF7C3AED),
  ),
  ClinicProject(
    'Cashier reconciliation upgrade',
    'Finance',
    'Jun 20',
    0.76,
    Color(0xFF166534),
  ),
  ClinicProject(
    'Lab case tracking rollout',
    'Treatment coordinator',
    'Jul 08',
    0.18,
    Color(0xFF2563EB),
  ),
  ClinicProject(
    'Patient recall campaign',
    'Front desk',
    'Jun 28',
    0.44,
    Color(0xFF9333EA),
  ),
];
