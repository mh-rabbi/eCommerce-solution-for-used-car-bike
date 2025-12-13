import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 35),
              // Image placeholder
              Container(
                width: 360,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF06A4B4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 150,
                  color: Color(0xFF06A4B4),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Welcome To Vehicle Marketplace',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF06A4B4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Buy/Sell Cars And Bikes Easily!',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Explore great deals on cars and bikes, list your vehicle with ease, and connect with reliable buyers and sellers.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF031CE2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

