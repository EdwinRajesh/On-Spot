// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color
                spreadRadius: 2, // Spread radius
                blurRadius: 4, // Blur radius
                offset: Offset(0, 2), // Offset in the y direction
              ),
            ],
          ),
          child: AppBar(
            title: Text(
              'FAQ',
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WE ARE HERE TO HELP',
                style: textTheme.headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ExpansionTile(
                title: Text(
                  'How do I use On-Spot Mechanic app?',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'To use the On-Spot Mechanic app, simply open the app and follow the instructions to request assistance. The app will connect you with the nearest available mechanic.',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'What types of emergency services does the app provide?',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'The app provides access to a variety of emergency services, including aN AI chatbot, real time chat with mechanic and FAQs which helps in detecting the problem. You can request assistance for any type of emergency.',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'How do I pay for the emergency services?',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'The app has an inbuilt payment gateway which accepts a variety of payment methods, including credit card, debit card, and google pay.',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'How do I know the mechanic is on his way?',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'The app will provide real-time updates on the location and estimated arrival time of the mechanic.',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'What if I need to cancel an emergency request?',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Sorry, since this is an emergency app, we are not currently providing any cancellation policy for any request sent.',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'How do I provide feedback on the app?',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'You can provide feedback on the app by contacting our customer support team. Your feedback helps us improve the app and provide better service to our users.',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'What are the privacy and security features of the app?',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'The app uses the latest encryption and security protocols to protect your personal and payment information.',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
