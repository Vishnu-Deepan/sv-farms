import 'package:flutter/material.dart';
import '../models/plans_model.dart';

// Plan Card Widget
class PlanCard extends StatelessWidget {
  final Plans plan;
  final bool isSelected;
  final VoidCallback onSelect;

  const PlanCard({super.key, required this.plan, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Card(

        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: isSelected ? Colors.blue.shade100 : Colors.white, // Blue theme for selected card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${plan.litres} Litres Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Centering the text
                ),
                SizedBox(height: 8),
                Text(
                  '₹${plan.price}', // Total price for the plan
                  style: TextStyle(fontSize: 18, color: Colors.green.shade700),
                ),
                SizedBox(height: 8),
                Text(
                  '₹${plan.price / plan.litres} per litre', // Price per litre
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                if (plan.discount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Saving ₹${plan.discount}', // Discount info
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  ),
                  child: Text(
                    isSelected ? 'Selected' : 'Select Plan',
                    style: TextStyle(fontSize: 16, color: Colors.white), // Button text color to white
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
