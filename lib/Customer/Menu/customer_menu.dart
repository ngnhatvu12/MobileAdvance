import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND TOÀN MÀN HÌNH
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [blue, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(LucideIcons.bell, color: Colors.white, size: 40),
                          CircleAvatar(
                          backgroundColor: Colors.blue.shade300,
                          radius: 30,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue.shade300,
                            radius: 25,                       
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/icons/workout.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        "YOUR HEALTH",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                      ),
                      Text(
                        "OUR HAPPINESS",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // PHẦN DƯỚI: CONTAINER TRẮNG BO GÓC
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 cột
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.2),
                              ),
                              child: Icon(menuItems[index]["icon"], color: Colors.blue, size: 28),
                            ),
                            SizedBox(height: 5),
                            Text(
                              menuItems[index]["title"],
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// DANH SÁCH ICON + TEXT MENU
List<Map<String, dynamic>> menuItems = [
  {"title": "Home", "icon": LucideIcons.home},
  {"title": "Contacts", "icon": LucideIcons.contact},
  {"title": "Workouts", "icon": LucideIcons.activity},
  {"title": "Exercises", "icon": LucideIcons.dumbbell},
  {"title": "Nutrition", "icon": LucideIcons.utensils},
  {"title": "Programs", "icon": LucideIcons.bookOpen},
  {"title": "Packages", "icon": LucideIcons.box},
  {"title": "Financials", "icon": LucideIcons.dollarSign},
  {"title": "Habits", "icon": LucideIcons.repeat},
  {"title": "Resources", "icon": LucideIcons.folderOpen},
  {"title": "Calendar", "icon": LucideIcons.calendar},
  {"title": "Event", "icon": LucideIcons.ticket},
  {"title": "Chat", "icon": LucideIcons.messageCircle},
  {"title": "Files", "icon": LucideIcons.fileText},
  {"title": "Settings", "icon": LucideIcons.settings},
  {"title": "Support", "icon": LucideIcons.helpCircle},
];
