import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Static categories & contacts
  final categories = ['Music', 'Food', 'Outdoor', 'Team Building'];
  final contacts = ['Alice', 'Bob', 'Charlie', 'David'];

  // State variables
  String selectedEventType = 'Public';
  String selectedCategory = 'Music';
  final Set<String> selectedContacts = {};
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isFreeEvent = false;

  // Date Picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Time Picker
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  final List<String> contactList = [
    'Alice Johnson',
    'Bob Smith',
    'Charlie Brown',
    'David Williams',
    'Eve Davis',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Event'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Event Type
            const Text('Event Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Public', 'Private'].map((type) {
                final isSelected = selectedEventType == type;
                return ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                        color: isSelected ? Colors.black : Colors.black54),
                  ),
                  selected: isSelected,
                  backgroundColor: Colors.white,
                  selectedColor: Colors.orange.shade100,
                  onSelected: (_) {
                    setState(() {
                      selectedEventType = type;
                      if (type == 'Public') selectedContacts.clear();
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: isSelected ? Colors.orange : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Contacts (only for Private Event)
            if (selectedEventType == 'Private') ...[
              const Text(
                'Select Contacts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: contactList.map((contact) {
                  final isSelected = selectedContacts.contains(contact);
                  return FilterChip(
                    label: Text(contact),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        if (isSelected) {
                          selectedContacts.remove(contact);
                        } else {
                          selectedContacts.add(contact);
                        }
                      });
                    },
                    selectedColor: Colors.orange.shade100,
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Show selected contacts
            if (selectedContacts.isNotEmpty) ...[
              Text(
                'Selected: ${selectedContacts.join(', ')}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],

            // Category
            const Text('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return ChoiceChip(
                  label: Text(
                    category,
                    style: TextStyle(
                        color: isSelected ? Colors.black : Colors.black54),
                  ),
                  selected: isSelected,
                  backgroundColor: Colors.white,
                  selectedColor: Colors.orange.shade100,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: isSelected ? Colors.orange : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date & Time Pickers
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: selectedDate == null
                          ? 'Select Date'
                          : DateFormat('dd MMM yyyy').format(selectedDate!),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _pickDate,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: selectedTime == null
                          ? 'Select Time'
                          : selectedTime!.format(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.schedule),
                        onPressed: _pickTime,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Location
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Price & Free Event toggle
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    enabled: !isFreeEvent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Free Event'),
                    value: isFreeEvent,
                    onChanged: (val) {
                      setState(() {
                        isFreeEvent = val;
                      });
                    },
                    activeThumbColor: const Color(0xFFFF6A5C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Image URL
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tags
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'e.g., Outdoor, Team Building, Free',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Event',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
