import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('About Us')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.systemGrey4,
                  border: Border.all(
                    color: CupertinoColors.systemGrey2,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.person,
                    size: 60,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const Text(
                'Katyusha',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'I’m Mak, the sole developer behind Katyusha. I created this app for my sister, ET, to help her track and manage her academic journey with ease and elegance. My goal was to craft a tool that’s both functional and beautiful, inspired by Apple’s design philosophy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Contact Information
              const Text(
                'Contact Me',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Phone: +251934918291',
                style: TextStyle(fontSize: 16, color: CupertinoColors.black),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // GitHub
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.code,
                      color: CupertinoColors.activeBlue,
                      size: 30,
                    ),
                    onPressed:
                        () => _launchUrl('https://github.com/codenati22'),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.send,
                      color: CupertinoColors.activeBlue,
                      size: 30,
                    ),
                    onPressed:
                        () =>
                            _launchUrl('https://t.me/n_a_t_n_a_e_l_g_i_r_m_a'),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.business,
                      color: CupertinoColors.activeBlue,
                      size: 30,
                    ),
                    onPressed:
                        () => _launchUrl(
                          'https://www.linkedin.com/in/natnael-girma-707a1a326?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app',
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                '© 2025 Natnael Girma. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
