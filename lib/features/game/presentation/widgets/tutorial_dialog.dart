import 'package:flutter/material.dart';

/// Tutorial dialog - o'yinni qanday o'ynashni ko'rsatadi
class TutorialDialog extends StatelessWidget {
  const TutorialDialog({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4B0082),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.help_outline, color: Color(0xFFFFD700), size: 32),
                  SizedBox(width: 12),
                  Text(
                    'QANDAY O\'YNASH?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Step 1
              _buildStep(
                number: '1',
                icon: Icons.touch_app,
                title: 'Toshni Tanlang',
                description: 'Ekrandagi rangli toshni bosing',
                color: const Color(0xFF00BFFF),
              ),
              
              const SizedBox(height: 16),
              
              // Step 2
              _buildStep(
                number: '2',
                icon: Icons.swap_horiz,
                title: 'Qo\'shni Toshni Bosing',
                description: 'Yuqori, pastki, chap yoki o\'ng tomondagi toshni bosing',
                color: const Color(0xFF00FF00),
              ),
              
              const SizedBox(height: 16),
              
              // Step 3
              _buildStep(
                number: '3',
                icon: Icons.star,
                title: '3 ta Bir Xil',
                description: '3 yoki undan ko\'p bir xil toshlarni birlashtiring',
                color: const Color(0xFFFFD700),
              ),
              
              const SizedBox(height: 16),
              
              // Step 4
              _buildStep(
                number: '4',
                icon: Icons.emoji_events,
                title: 'Maqsadga Yeting',
                description: 'Maqsad ballni to\'plang va 3 yulduz oling!',
                color: const Color(0xFFFF8C00),
              ),
              
              const SizedBox(height: 24),
              
              // Powers info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.flash_on, color: Color(0xFFFFD700), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ZEUS QOBILIYLARI:',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPowerInfo('⚡', 'Chaqmoq', '3⚡', 'Ustunni tozalaydi'),
                    _buildPowerInfo('🔗', 'Zanjir', '5⚡', '5-8 ta tasodifiy'),
                    _buildPowerInfo('✈️', 'Qanotlar', '4⚡', '3×3 portlash'),
                    _buildPowerInfo('🔥', 'G\'azab', '10⚡', 'Yarmini tozalaydi'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'TUSHUNDIM, BOSHLAYMIZ!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
  
  Widget _buildStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPowerInfo(String emoji, String name, String cost, String effect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$name ($cost)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            effect,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}