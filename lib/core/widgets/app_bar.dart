import 'package:flutter/material.dart';

class VKUAppBar extends AppBar {
  VKUAppBar({
    super.key,
    required super.title,
    super.actions,
    super.leading,
    bool centerTitle = true,
  }) : super(
          centerTitle: centerTitle,
        );
}


