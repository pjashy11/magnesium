
import 'package:flutter/material.dart';

class IntelScreen extends StatelessWidget {
  const IntelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PERFORMANCE INTEL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMissionHeader(),
            _buildAboutSection(),
            _buildScienceSection(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF02B3A9).withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OUR MISSION',
              style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
          const SizedBox(height: 16),
          const Text('OPTIMIZE.\nRECOVER.\nDOMINATE.',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 0.9, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          Text(
            'At Magnesium Athletes, we believe every competitor deserves elite care. Our mission is to enhance performance, facilitate rapid recovery, and prioritize holistic well-being through scientifically formulated transdermal fuel.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.6), fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 40, height: 2, color: const Color(0xFFF19842)),
              const SizedBox(width: 12),
              const Text('THE ORIGIN STORY',
                  style: TextStyle(color: Color(0xFFF19842), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('BORN IN THE TRENCHES',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          _richTextBody(
            'Born from the shared passion of a dedicated Cross-Fit/Boxing enthusiast and a natural skin care expert, Magnesium Athletes was created to revolutionize recovery. We set out to banish gritty skin, alleviate muscle aches, and quell inflammation—all while keeping athletes remarkably clean and fresh.',
          ),
          const SizedBox(height: 16),
          _richTextBody(
            'Our journey began with extensive research into the healing powers of natural ingredients. We focus on ridding the skin of viruses and bacteria found in sweat and gym environments, ensuring that your recovery doesn\'t just feel good—it protects your body.',
          ),
        ],
      ),
    );
  }

  Widget _buildScienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text('MOLECULAR BREAKDOWN',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text('HOW OUR ACTIVE RECOVERY FORMULA WORKS',
              style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 1,
          childAspectRatio: 2.2,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          mainAxisSpacing: 16,
          children: [
            _buildIngredientCard(
              'MAGNESIUM SALTS',
              'Sulfate & Chloride variants. Relaxes muscles, reduces cramps, and flushes toxins at the cellular level.',
              Icons.bolt,
              const Color(0xFF02B3A9),
            ),
            _buildIngredientCard(
              'MSM (BIO-SULFUR)',
              'Crucial for collagen and keratin. Supports cartilage health, reduces joint pain, and improves skin elasticity.',
              Icons.layers_outlined,
              const Color(0xFFF19842),
            ),
            _buildIngredientCard(
              'ARNICA MONTANA',
              'Speeds up healing of bruises and strains. High-potency anti-inflammatory properties for rapid pain relief.',
              Icons.health_and_safety_outlined,
              const Color(0xFF02B3A9),
            ),
            _buildIngredientCard(
              'TEA TREE & ESSENTIAL OILS',
              'Antifungal and antibacterial shield. Prevents gym-acquired infections and keeps skin hydrated.',
              Icons.eco_outlined,
              const Color(0xFFF19842),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Text(desc, style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.5), fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _richTextBody(String text) {
    return Text(
      text,
      style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.7), fontSize: 16, height: 1.6, fontWeight: FontWeight.w400),
    );
  }
}