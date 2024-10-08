// utils
import 'package:flutter/material.dart';

// widgets
import 'package:babysitterapp/widgets/auth/social_icon.dart';
import 'package:babysitterapp/widgets/auth/divider.dart';

class SocialSignUp extends StatelessWidget {
  const SocialSignUp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SocalIcon(
              iconSrc: 'assets/icons/google-plus.svg',
              press: () {},
            ),
            // SocalIcon(
            //   iconSrc: "assets/icons/twitter.svg",
            //   press: () {},
            // ),
            SocalIcon(
              iconSrc: 'assets/icons/facebook.svg',
              press: () {},
            ),
          ],
        ),
      ],
    );
  }
}
