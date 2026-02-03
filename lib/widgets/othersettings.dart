import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';

class OtherSettings extends StatelessWidget {
  final String settingname;
  final IconData icon;

  OtherSettings({super.key, required this.settingname, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints.maxWidth - 50, // leave space for arrow
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            settingname,
                            style: normalgrey,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: secondaryColor),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Divider(color: secondaryColor),
      ],
    );
  }
}
