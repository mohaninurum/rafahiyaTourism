import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rafahiyatourism/const/color.dart';
import '../../../utils/model/auth/auth_user_model.dart';
import 'create_user_wallet.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
            AppStrings.getString('allUsers', currentLocale),
            style: GoogleFonts.poppins()
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(currentLocale: currentLocale),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  '${AppStrings.getString('error', currentLocale)}: ${snapshot.error}'
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(AppStrings.getString('noUsersFound', currentLocale)),
            );
          }

          // Filter users based on search query
          final users = snapshot.data!.docs
              .map((doc) => AuthUserModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
              .where((user) =>
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          if (users.isEmpty) {
            return Center(
              child: Text(AppStrings.getString('noMatchingUsersFound', currentLocale)),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(context, user, currentLocale);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AuthUserModel user, String currentLocale) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.mainColor,
          backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
              ? NetworkImage(user.profileImage!)
              : null,
          child: user.profileImage == null || user.profileImage!.isEmpty
              ? Text(
            user.fullName.isNotEmpty ? user.fullName[0] : '?',
            style: GoogleFonts.poppins(
                color: AppColors.whiteColor
            ),
          )
              : null,
        ),
        title: Text(user.fullName, style: GoogleFonts.poppins()),
        subtitle: Text(user.email, style: GoogleFonts.poppins()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateUserWallet(
                image: user.profileImage!,
                email: user.email,
                userId: user.id ?? '',
                userName: user.fullName,
                userPhone: user.mobileNumber,
                userCity: user.city,
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate {
  final String currentLocale;

  UserSearchDelegate({required this.currentLocale});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.black),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildSearchResults(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildSearchResults(query),
    );
  }

  Widget _buildSearchResults(String searchQuery) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
                '${AppStrings.getString('error', currentLocale)}: ${snapshot.error}'
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(AppStrings.getString('noUsersFound', currentLocale)),
          );
        }

        final users = snapshot.data!.docs
            .map((doc) => AuthUserModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
            .where((user) =>
        user.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        if (users.isEmpty) {
          return Center(
            child: Text(AppStrings.getString('noMatchingUsersFound', currentLocale)),
          );
        }

        return Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.mainColor,
                    backgroundImage: user.profileImage != null &&
                        user.profileImage!.isNotEmpty
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null || user.profileImage!.isEmpty
                        ? Text(
                      user.fullName.isNotEmpty ? user.fullName[0] : '?',
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                      ),
                    )
                        : null,
                  ),
                  title: Text(user.fullName, style: GoogleFonts.poppins()),
                  subtitle: Text(user.email, style: GoogleFonts.poppins()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateUserWallet(
                          image: user.profileImage!,
                          email: user.email,
                          userId: user.id ?? '',
                          userName: user.fullName,
                          userPhone: user.mobileNumber,
                          userCity: user.city,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}