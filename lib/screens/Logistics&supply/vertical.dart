import 'package:flutter/material.dart';
import '../Catering&Services/Caterings.dart';
import '../Food&beverages/RestaurentsScreen/restaurentsnew.dart';
import 'logistics_homepage.dart';

class VerticalsBottomSheet extends StatelessWidget {
  const VerticalsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    final verticals = [
      {
        "name": "Food & Beverages",
        "screen": Restaurents(scrollController: _scrollController),
      },
      {"name": "Catering & Services", "screen": CateringsPage()},
      {"name": "Logistics & Supply", "screen": LogisticsScreen()},
      {"name": "Fresh & Groceries", "screen": CateringsPage()},
    ];
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vertical = verticals[index];
        return ListTile(
          leading: const Icon(Icons.store_mall_directory),
          title: Text(vertical["name"].toString()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pop(context); // close bottom sheet
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => vertical["screen"] as Widget),
            );
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(),
      itemCount: verticals.length,
    );
  }
}

/// Global function to open the bottom sheet
void openVerticalsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const VerticalsBottomSheet(),
  );
}
