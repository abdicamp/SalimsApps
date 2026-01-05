import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/core/widgets/language_selector.dart';
import 'package:salims_apps_new/state_global/state_global.dart';
import 'package:salims_apps_new/ui/views/profile/profile_viewmodel.dart';
import 'package:stacked/stacked.dart';
import '../../../core/utils/colors.dart';
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
      viewModelBuilder: () => ProfileViewModel(ctx: context),
      builder: (context, vm, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.isBusy
              ? context.read<GlobalLoadingState>().show()
              : context.read<GlobalLoadingState>().hide();
        });
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
                              AppColors.skyBlue,
                              AppColors.limeLight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)?.profile ?? "Profile",
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
                                backgroundColor: const Color(0xFF15C01E),
                                child: CircleAvatar(
                                  radius: 42,
                                  backgroundColor: Colors.white,
                                  backgroundImage: vm.profileImage != null && vm.profileImage!.isNotEmpty
                                      ? NetworkImage(vm.profileImage!)
                                      : null,
                                  child: vm.profileImage == null || vm.profileImage!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey[400],
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "${vm.username ?? ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
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
                            child: vm.isChangePassword == true
                                ? Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter value';
                                            }
                                            return null;
                                          },
                                          controller: vm.oldPassword,
                                          obscureText: vm.isShowPasswordOld!,
                                          decoration: InputDecoration(
                                            suffixIcon: vm.isShowPasswordOld!
                                                ? IconButton(
                                                    icon: Icon(
                                                        Icons.visibility_off),
                                                    onPressed: () {
                                                      setState(() {
                                                        vm.isShowPasswordOld = !vm
                                                            .isShowPasswordOld!;
                                                      });
                                                    },
                                                  )
                                                : IconButton(
                                                    icon:
                                                        Icon(Icons.visibility),
                                                    onPressed: () {
                                                      setState(() {
                                                        vm.isShowPasswordOld = !vm
                                                            .isShowPasswordOld!;
                                                      });
                                                    },
                                                  ),
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                            ),
                                            hintText: AppLocalizations.of(context)?.oldPassword ?? 'Old Password',
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 16),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter value';
                                            }
                                            return null;
                                          },
                                          controller: vm.newPassword,
                                          obscureText: vm.isShowPasswordNew!,
                                          decoration: InputDecoration(
                                            suffixIcon: vm.isShowPasswordNew!
                                                ? IconButton(
                                                    icon: Icon(
                                                        Icons.visibility_off),
                                                    onPressed: () {
                                                      setState(() {
                                                        vm.isShowPasswordNew = !vm
                                                            .isShowPasswordNew!;
                                                      });
                                                    },
                                                  )
                                                : IconButton(
                                                    icon:
                                                        Icon(Icons.visibility),
                                                    onPressed: () {
                                                      setState(() {
                                                        vm.isShowPasswordNew = !vm
                                                            .isShowPasswordNew!;
                                                      });
                                                    },
                                                  ),
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                            ),
                                            hintText: AppLocalizations.of(context)?.newPassword ?? 'New Password',
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 16),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            vm.changePassword();
                                          });
                                        },
                                        icon: const Icon(Icons.lock_outline,
                                            color: Colors.white),
                                        label: Text(
                                          AppLocalizations.of(context)?.save ?? "Save",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1565C0),
                                          minimumSize:
                                              const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 3,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            vm.isChangePassword = false;
                                          });
                                        },
                                        label: Text(
                                          AppLocalizations.of(context)?.cancel ?? "Cancel",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          minimumSize:
                                              const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 3,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.accountInformation ?? "Account Information",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoRow(
                                        AppLocalizations.of(context)?.phone ?? "Phone", 
                                        "${vm.phone ?? '-'}"
                                      ),
                                      _buildInfoRow(
                                        AppLocalizations.of(context)?.email ?? "Email", 
                                        "${vm.email ?? '-'}"
                                      ),
                                     
                                    ],
                                  ),
                          ),
                        ),
                      ),
//                       const SizedBox(height: 25),
//                       vm.isChangePassword == true
//                           ? Stack()
//                           : Padding(
//                             padding: const EdgeInsets.only(left: 20, right: 20),
//                             child: Container(
//                                                     decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [
//                                         // putih
//                                 Color(0xFF4CAF50),     // hijau
//                                 Color(0xFF2196F3),     // biru
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(14),
//                                                     ),
//                                                     child: ElevatedButton.icon(
//                             onPressed: () {
//                               setState(() {
//                                 vm.isChangePassword = true;
//                               });
//                             },
//                             icon: const Icon(
//                               Icons.lock_outline,
//                               color: Colors.white,
//                             ),
//                             label: Text(
//                               AppLocalizations.of(context)?.changePassword ?? "Change Password",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,      // penting: biar kelihatan gradient
//                               shadowColor: Colors.transparent,          // hilangin bayangan default
//                               surfaceTintColor: Colors.transparent,     // buat Material 3
//                               minimumSize: const Size.fromHeight(50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               elevation: 0,
//                             ),
//                                                     ),
//                                                   ),
//                           )
// ,

                      const SizedBox(height: 25),
                      
                      // Language Selector
                      if (vm.isChangePassword == false) const LanguageSelector(),

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
                color: Colors.green,
              )),
        ],
      ),
    );
  }
}
