import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/utils/colors.dart';
import 'package:salims_apps_new/core/utils/style.dart';
import 'package:salims_apps_new/state_global/loading_overlay.dart';
import 'package:salims_apps_new/state_global/state_global.dart';
import 'package:salims_apps_new/ui/views/history/history_view.dart';
import 'package:salims_apps_new/ui/views/home/home_view.dart';
import 'package:salims_apps_new/ui/views/profile/profile_view.dart';
import 'package:salims_apps_new/ui/views/task_list/task_list_view.dart';
import 'package:provider/provider.dart';

class BottomNavigatorView extends StatefulWidget {
  const BottomNavigatorView({super.key});

  @override
  State<BottomNavigatorView> createState() => _BottomNavigatorViewState();
}

class _BottomNavigatorViewState extends State<BottomNavigatorView> {
  int _selectedIndex = 0;

  final _widgets = [
    const HomeView(),
    const TaskListView(),
    const HistoryView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<GlobalLoadingState>().isLoading;
    return LoadingOverlay(
      isLoading: isLoading,
      child: Stack(
        children: [
          Scaffold(
            // extendBodyBehindAppBar: true,
            body: IndexedStack(index: _selectedIndex, children: _widgets),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF7F4FB), // lebih terang di atas
                    const Color(0xFFF0E6FA), // ungu muda di bawah
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                      0.08,
                    ), // glow ungu halus
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  useLegacyColorScheme: false,
                  currentIndex: _selectedIndex,
                  onTap: (value) => setState(() => _selectedIndex = value),
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: const TextStyle(color: AppColors.primary),
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.primary,
                  ),
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home_outlined,
                        color: _selectedIndex == 0
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.art_track_sharp,
                        color: _selectedIndex == 1
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                      label: 'Taking Sample',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.history,
                        color: _selectedIndex == 2
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                      label: 'History',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.people_alt_sharp,
                        color: _selectedIndex == 3
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? Stack(
                  children: [
                    ModalBarrier(
                      dismissible: false,
                      color: const Color.fromARGB(118, 0, 0, 0),
                    ),
                    Center(child: loadingSpinWhite),
                  ],
                )
              : Stack(),
        ],
      ),
    );
  }
}
