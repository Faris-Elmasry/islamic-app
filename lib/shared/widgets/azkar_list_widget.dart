import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/data/models/azkar_model.dart';

/// Reusable widget for displaying azkar list
class AzkarListWidget extends StatefulWidget {
  final AzkarCategory category;
  final String backgroundImage;
  final Color? backgroundColor;

  const AzkarListWidget({
    super.key,
    required this.category,
    required this.backgroundImage,
    this.backgroundColor,
  });

  @override
  State<AzkarListWidget> createState() => _AzkarListWidgetState();
}

class _AzkarListWidgetState extends State<AzkarListWidget> {
  late List<int> _remainingCounts;
  late List<bool> _completed;

  @override
  void initState() {
    super.initState();
    _initializeCounts();
  }

  void _initializeCounts() {
    _remainingCounts = widget.category.items.map((item) => item.count).toList();
    _completed = List.filled(widget.category.items.length, false);
  }

  @override
  void didUpdateWidget(AzkarListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _initializeCounts();
    }
  }

  void _decrementCount(int index) {
    if (_remainingCounts[index] > 0) {
      setState(() {
        _remainingCounts[index]--;
        if (_remainingCounts[index] == 0) {
          _completed[index] = true;
        }
      });
    }
  }

  void _resetCount(int index) {
    setState(() {
      _remainingCounts[index] = widget.category.items[index].count;
      _completed[index] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.items.length,
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          final remainingCount = _remainingCounts[index];
          final isCompleted = _completed[index];

          return GestureDetector(
            onTap: () => _decrementCount(index),
            onLongPress: () => _resetCount(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.85)
                    : Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Zikr text
                    Text(
                      item.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        height: 1.8,
                        color: isCompleted ? Colors.white : Colors.black87,
                      ),
                    ),

                    // Description/Bless if available
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.white.withOpacity(0.2)
                              : Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.description!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: isCompleted
                                ? Colors.white70
                                : Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Counter row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Counter badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.white
                                : Colors.teal.shade600,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.touch_app,
                                size: 18,
                                color:
                                    isCompleted ? Colors.green : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCompleted
                                    ? 'تم'
                                    : '$remainingCount / ${item.count}',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isCompleted ? Colors.green : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Loading state widget for azkar
class AzkarLoadingWidget extends StatelessWidget {
  const AzkarLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.teal),
          SizedBox(height: 16),
          Text(
            'جاري التحميل...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget for azkar
class AzkarErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const AzkarErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}
