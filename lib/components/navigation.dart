import 'package:flutter/material.dart';
import 'package:untitled/features/meditation/meditation.dart';
import 'package:untitled/features/sleep/sleep.dart';
import 'package:untitled/screens/main/main_page.dart';
import 'package:untitled/screens/main/settings.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final ValueChanged<int> onItemSelected;
  final int currentIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.onItemSelected,
    required this.currentIndex,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: widget.currentIndex == 0
              ? Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(255, 6, 3, 172).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const ImageIcon(
                    AssetImage('android/assets/logo/1.png'),
                    size: 24,
                    color: Color.fromARGB(255, 6, 3, 172),
                  ),
                )
              : const ImageIcon(
                  AssetImage('android/assets/logo/1.png'),
                  size: 24,
                ),
          label: 'Acasă',
        ),
        BottomNavigationBarItem(
          icon: widget.currentIndex == 1
              ? Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 3, 2, 95).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const ImageIcon(
                    AssetImage('android/assets/logo/2_1.png'),
                    size: 24,
                    color: Color.fromARGB(255, 3, 2, 95),
                  ),
                )
              : const ImageIcon(
                  AssetImage('android/assets/logo/2_1.png'),
                  size: 24,
                ),
          label: 'Meditație',
        ),
        BottomNavigationBarItem(
          icon: widget.currentIndex == 2
              ? Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 3, 2, 95).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const ImageIcon(
                    AssetImage('android/assets/logo/5.png'),
                    size: 24,
                    color: Color.fromARGB(255, 3, 2, 95),
                  ),
                )
              : const ImageIcon(
                  AssetImage('android/assets/logo/5.png'),
                  size: 24,
                ),
          label: 'Somn',
        ),
        BottomNavigationBarItem(
          icon: widget.currentIndex == 3
              ? Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 3, 2, 95).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const ImageIcon(
                    AssetImage('android/assets/logo/4.png'),
                    size: 24,
                    color: Color.fromARGB(255, 3, 2, 95),
                  ),
                )
              : const ImageIcon(
                  AssetImage('android/assets/logo/4.png'),
                  size: 24,
                ),
          label: 'Setări',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: const Color.fromARGB(255, 201, 202, 207),
      unselectedItemColor: const Color.fromARGB(255, 61, 60, 60),
      onTap: (index) {
        widget.onItemSelected(index);
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainPage(userName: ''),
              ),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MeditationPage()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SleepPage()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
            break;
          default:
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
    );
  }
}
