import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/ui/views/profile/profile_viewmodel.dart';
import 'package:stacked/stacked.dart';
import '../../../core/utils/rounded_clipper.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FB),
          body: Column(
            children: [
              // Header dengan gradasi dan judul
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: BottomRoundedClipper(),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1565C0), // Biru navy
                              Color(0xFF42A5F5), // Biru terang
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Profile",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Konten profil
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Avatar dan nama
                      Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 30),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: const Color(0xFF1565C0),
                                child: const CircleAvatar(
                                  radius: 42,
                                  backgroundImage:
                                      AssetImage('assets/images/salims.png'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "${vm.username ?? ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Tombol Change Password

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Account Information",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow("Employee ID", "EMP001"),
                                _buildInfoRow("Division", "Quality Control"),
                                _buildInfoRow("Join Date", "01 Jan 2020"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigasi ke halaman ubah password
                            // vm.navigateToChangePassword(context);
                          },
                          icon: const Icon(Icons.lock_outline,
                              color: Colors.white),
                          label: Text(
                            "Change Password",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),

                      // Informasi tambahan (optional)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              )),
          Text(value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1565C0),
              )),
        ],
      ),
    );
  }
}
