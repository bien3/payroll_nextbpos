import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

final menuTree = TreeNode.root()
  ..addAll(
    [
      TreeNode(key: "Dashboard", data: Icons.dashboard),
      TreeNode(key: "Overtime", data: Icons.access_time_filled_outlined)
        ..addAll([
          TreeNode(key: "Regular OT"),
          TreeNode(key: "Rest day OT"),
          TreeNode(key: "Regular Holiday OT"),
          TreeNode(key: "Special Holiday OT"),
        ]),
      TreeNode(key: "Holiday", data: Icons.calendar_month_outlined)
        ..addAll([
          TreeNode(key: "Regular"),
          TreeNode(key: "Special"),
        ]),
      TreeNode(key: "Logs", data: Icons.analytics),
      TreeNode(key: "Calendar", data: Icons.edit_calendar_outlined),
      TreeNode(key: "Payroll", data: Icons.payments),
      // TreeNode(
      //   key: 'Account List', // Logout menu item
      //   data:
      //       Icons.person_add_alt_1, // You can use appropriate logout icon here
      // ),
    ],
  );
