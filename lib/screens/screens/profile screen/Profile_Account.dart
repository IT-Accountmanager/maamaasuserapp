import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/subscrptions/user_account.dart';
import '../../../Services/Auth_service/Subscription_authservice.dart';
import 'delete account.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF6F7F9);
  static const surface = Colors.white;
  static const ink = Color(0xFF111827);
  static const sub = Color(0xFF374151);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF2563EB);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);
  static const amber = Color(0xFFF59E0B);

  static const h2 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ink,
  );
  static const body = TextStyle(fontSize: 13, color: muted, height: 1.4);
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: muted,
    letterSpacing: 0.6,
  );
}

enum ProfileSectionType { basic, personal, education, occupation, interests }

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String ageGroup = "26–35";
  String language = "English";
  String educationField = "OTHER";
  String occupation = "Job Seeker";
  String subType = "";
  String educationLevel = "SCHOOL";
  int completion = 0;
  bool isLoading = false;
  String gender = "MALE";

  final cityCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phonenumberCtrl = TextEditingController();

  final genderOptions = ["MALE", "FEMALE", "OTHER"];
  final selectedInterests = <String>{};

  final educationLevelItems = [
    "SCHOOL",
    "INTERMEDIATE_DIPLOMA",
    "GRADUATE",
    "POST_GRADUATE",
  ];
  final educationFieldItems = [
    "SCIENCE",
    "COMMERCE",
    "ARTS",
    "ENGINEERING",
    "IT",
    "MANAGEMENT",
    "MEDICAL",
    "OTHER",
  ];
  final interests = [
    "JOBS",
    "FOOD",
    "EDUCATION",
    "OFFERS",
    "REAL_ESTATE",
    "ONLINE_COURSES",
    "BAKERY",
    "HEALTH",
    "TRAVEL",
    "ENTERTAINMENT",
  ];
  final Map<String, List<String>> occupationOptions = {
    "Student": ["School", "College"],
    "Employed": ["IT", "Government", "Private"],
    "Freelancer": ["Design", "Tech", "Marketing"],
    "Entrepreneur": ["Startup", "Business"],
    "Homemaker": ["Household"],
    "Job Seeker": ["Fresher", "Experienced"],
  };

  // Which section is expanded
  ProfileSectionType? _expanded;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    cityCtrl.dispose();
    areaCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phonenumberCtrl.dispose();
    super.dispose();
  }

  Future<int> _userId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId')!;
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    try {
      final data = await subscription_AuthService.getAccount();
      if (data == null) return;
      setState(() {
        nameCtrl.text = data.userName ?? "";
        emailCtrl.text = data.emailId ?? "";
        phonenumberCtrl.text = data.phoneNumber ?? "";
        gender = data.gender ?? "MALE";
        cityCtrl.text = data.city ?? "";
        areaCtrl.text = data.area ?? "";
        language = data.languagePreference ?? "English";
        completion = data.completionPercentage ?? 0;
        educationLevel = data.educationLevel ?? "SCHOOL";
        educationField = data.fieldOfStudy ?? "SCIENCE";
        selectedInterests
          ..clear()
          ..addAll(data.interests ?? []);
      });
    } catch (e) {
      if (mounted) AppAlert.error(context, "Failed to load profile");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ── Save helpers ──────────────────────────────────────────────────────────
  Future<void> _save(Future<void> Function() fn) async {
    setState(() => isLoading = true);
    try {
      await fn();
      await loadProfile();
    } catch (_) {
      if (mounted) AppAlert.error(context, "Failed to save");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveBasic() => _save(() async {
    await subscription_AuthService.saveAccount(
      UserAccount(
        userId: await _userId(),
        city: cityCtrl.text,
        languagePreference: language,
      ),
    );
    AppAlert.success(context, "Basic profile saved");
  });

  Future<void> savePersonal() => _save(() async {
    await subscription_AuthService.saveAccount(
      UserAccount(
        userId: await _userId(),
        gender: gender,
        ageGroup: mapAgeGroup(ageGroup),
        area: areaCtrl.text,
        city: cityCtrl.text,
      ),
    );
    AppAlert.success(context, "Personal profile saved");
  });

  Future<void> saveEducation() => _save(() async {
    await subscription_AuthService.saveAccount(
      UserAccount(
        userId: await _userId(),
        educationLevel: educationLevel,
        fieldOfStudy: educationField,
      ),
    );
    AppAlert.success(context, "Education saved");
  });

  Future<void> saveOccupation() => _save(() async {
    await subscription_AuthService.saveAccount(
      UserAccount(
        userId: await _userId(),
        occupationType: mapOccupation(occupation),
        occupationSubField: subType,
      ),
    );
    AppAlert.success(context, "Occupation saved");
  });

  Future<void> saveInterests() => _save(() async {
    await subscription_AuthService.saveAccount(
      UserAccount(
        userId: await _userId(),
        interests: selectedInterests.toList(),
      ),
    );
    AppAlert.success(context, "Interests saved");
  });

  String mapAgeGroup(String ui) {
    switch (ui) {
      case "18–25":
        return "AGE_18_25";
      case "26–35":
        return "AGE_26_35";
      case "36–45":
        return "AGE_36_45";
      case "45+":
        return "AGE_45_PLUS";
      default:
        return "AGE_26_35";
    }
  }

  String mapOccupation(String ui) {
    switch (ui) {
      case "Student":
        return "STUDENT";
      case "Employed":
        return "EMPLOYED";
      case "Freelancer":
        return "FREELANCER";
      case "Entrepreneur":
        return "ENTREPRENEUR";
      case "Homemaker":
        return "HOMEMAKER";
      default:
        return "JOB_SEEKER";
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _T.ink,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Profile Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _T.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _T.border),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _T.accent,
                strokeWidth: 2,
              ),
            )
          : Column(
              children: [
                _completionBanner(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    children: [
                      _section(
                        type: ProfileSectionType.basic,
                        title: "Basic Info",
                        subtitle: nameCtrl.text.isNotEmpty
                            ? nameCtrl.text
                            : "Name, email, phone",
                        icon: Icons.person_outline_rounded,
                        child: _basicForm(),
                      ),
                      SizedBox(height: 10.h),
                      _section(
                        type: ProfileSectionType.personal,
                        title: "Personal",
                        subtitle: "Gender, city, age group",
                        icon: Icons.badge_outlined,
                        child: _personalForm(),
                      ),
                      SizedBox(height: 10.h),
                      _section(
                        type: ProfileSectionType.education,
                        title: "Education",
                        subtitle: "Level & field of study",
                        icon: Icons.school_outlined,
                        child: _educationForm(),
                      ),
                      SizedBox(height: 10.h),
                      _section(
                        type: ProfileSectionType.occupation,
                        title: "Occupation",
                        subtitle: "What you do",
                        icon: Icons.work_outline_rounded,
                        child: _occupationForm(),
                      ),
                      SizedBox(height: 10.h),
                      _section(
                        type: ProfileSectionType.interests,
                        title: "Interests",
                        subtitle: "${selectedInterests.length} selected",
                        icon: Icons.favorite_outline_rounded,
                        child: _interestsForm(),
                      ),
                      SizedBox(height: 24.h),
                      _deleteAccountTile(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
                if (completion < 100) _rewardBanner(),
              ],
            ),
    );
  }

  // ── Completion Banner ─────────────────────────────────────────────────────
  Widget _completionBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: _T.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "$completion% complete",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _T.ink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (completion == 100)
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: _T.accent,
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: completion / 100,
                    backgroundColor: _T.border,
                    color: completion == 100
                        ? const Color(0xFF16A34A)
                        : _T.accent,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            completion < 100
                ? "Fill all sections\nto earn ₹50"
                : "Profile\ncomplete!",
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: _T.muted, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Section Accordion ─────────────────────────────────────────────────────
  Widget _section({
    required ProfileSectionType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final isOpen = _expanded == type;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isOpen ? _T.accent.withOpacity(0.35) : _T.border,
          width: isOpen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = isOpen ? null : type),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(14.r),
              bottom: Radius.circular(isOpen ? 0 : 14.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: isOpen ? _T.accent : _T.muted),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: _T.h2),
                        SizedBox(height: 2.h),
                        Text(subtitle, style: _T.body.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: _T.muted,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) ...[
            Divider(height: 1, color: _T.border),
            Padding(padding: EdgeInsets.all(16.w), child: child),
          ],
        ],
      ),
    );
  }

  // ── Forms ─────────────────────────────────────────────────────────────────
  Widget _basicForm() => Column(
    children: [
      _field(
        ctrl: nameCtrl,
        hint: "Full Name",
        icon: Icons.person_outline_rounded,
      ),
      SizedBox(height: 12.h),
      _field(
        ctrl: emailCtrl,
        hint: "Email Address",
        icon: Icons.alternate_email_rounded,
        type: TextInputType.emailAddress,
      ),
      SizedBox(height: 12.h),
      _field(
        ctrl: phonenumberCtrl,
        hint: "Phone Number",
        icon: Icons.phone_outlined,
        type: TextInputType.phone,
      ),
      SizedBox(height: 16.h),
      _saveBtn(saveBasic),
    ],
  );

  Widget _personalForm() => Column(
    children: [
      _dropdown(
        hint: "Gender",
        value: gender,
        items: genderOptions,
        icon: Icons.wc_outlined,
        onChanged: (v) => setState(() => gender = v!),
      ),
      SizedBox(height: 12.h),
      _field(ctrl: cityCtrl, hint: "City", icon: Icons.location_city_outlined),
      SizedBox(height: 12.h),
      _dropdown(
        hint: "Age Group",
        value: ageGroup,
        items: const ["18–25", "26–35", "36–45", "45+"],
        icon: Icons.cake_outlined,
        onChanged: (v) => setState(() => ageGroup = v!),
      ),
      SizedBox(height: 12.h),
      _field(ctrl: areaCtrl, hint: "Area / Locality", icon: Icons.map_outlined),
      SizedBox(height: 16.h),
      _saveBtn(savePersonal),
    ],
  );

  Widget _educationForm() => Column(
    children: [
      _dropdown(
        hint: "Education Level",
        value: educationLevel,
        items: educationLevelItems,
        icon: Icons.school_outlined,
        onChanged: (v) => setState(() => educationLevel = v!),
      ),
      SizedBox(height: 12.h),
      _dropdown(
        hint: "Field of Study",
        value: educationField,
        items: educationFieldItems,
        icon: Icons.menu_book_outlined,
        onChanged: (v) => setState(() => educationField = v!),
      ),
      SizedBox(height: 16.h),
      _saveBtn(saveEducation),
    ],
  );

  Widget _occupationForm() => Column(
    children: [
      _dropdown(
        hint: "Occupation",
        value: occupation,
        items: occupationOptions.keys.toList(),
        icon: Icons.work_outline_rounded,
        onChanged: (v) => setState(() {
          occupation = v!;
          subType = "";
        }),
      ),
      SizedBox(height: 12.h),
      _dropdown(
        hint: "Sub Category",
        value: subType.isEmpty ? null : subType,
        items: occupationOptions[occupation] ?? [],
        icon: Icons.category_outlined,
        onChanged: (v) => setState(() => subType = v!),
      ),
      SizedBox(height: 16.h),
      _saveBtn(saveOccupation),
    ],
  );

  Widget _interestsForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Pick your interests",
        style: _T.label.copyWith(color: _T.ink, fontSize: 11),
      ),
      SizedBox(height: 12.h),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: interests.map((e) {
          final selected = selectedInterests.contains(e);
          return GestureDetector(
            onTap: () => setState(() {
              selected ? selectedInterests.remove(e) : selectedInterests.add(e);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: selected ? _T.accent : _T.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: selected ? _T.accent : _T.border),
              ),
              child: Text(
                e.replaceAll("_", " "),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : _T.sub,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      SizedBox(height: 16.h),
      _saveBtn(saveInterests),
    ],
  );

  // ── Delete Account ────────────────────────────────────────────────────────
  Widget _deleteAccountTile() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const deleteAccountScreen()),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _T.dangerLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _T.danger.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_outline_rounded, size: 18, color: _T.danger),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Delete Account",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _T.danger,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Permanently remove your account",
                    style: _T.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: _T.danger),
          ],
        ),
      ),
    );
  }

  // ── Reward Banner ─────────────────────────────────────────────────────────
  Widget _rewardBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border(top: BorderSide(color: _T.amber.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _T.amber.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: _T.amber,
              size: 20,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Complete your profile & earn ₹50",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "${100 - completion}% left to go",
                  style: _T.body.copyWith(
                    fontSize: 11,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable field widgets ────────────────────────────────────────────────
  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: TextStyle(fontSize: 14.sp, color: _T.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _T.muted, fontSize: 13.sp),
        prefixIcon: Icon(icon, size: 17, color: _T.muted),
        filled: true,
        fillColor: _T.bg,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _T.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _T.accent, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required List<String> items,
    String? value,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: TextStyle(fontSize: 14.sp, color: _T.ink),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.unfold_more_rounded, size: 16, color: _T.muted),
      dropdownColor: _T.surface,
      borderRadius: BorderRadius.circular(10.r),
      style: const TextStyle(color: _T.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _T.muted, fontSize: 13.sp),
        prefixIcon: Icon(icon, size: 17, color: _T.muted),
        filled: true,
        fillColor: _T.bg,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _T.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _T.accent, width: 1.5),
        ),
      ),
    );
  }

  Widget _saveBtn(VoidCallback onPressed) => SizedBox(
    width: double.infinity,
    height: 44.h,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _T.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(
        "Save",
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
