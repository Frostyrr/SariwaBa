class FaqItemModel {
  final String id;
  final String category;
  final String question;
  final String answer;
  final bool isHomepageFeatured;

  const FaqItemModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.isHomepageFeatured = false,
  });
}

class FaqData {
  const FaqData._();

  static const List<String> categories = [
    'All',
    'Basics',
    'Photos',
    'Results',
    'Account',
    'Privacy',
    'Troubleshooting',
  ];

  static const List<FaqItemModel> items = [
    FaqItemModel(
      id: 'gs_1',
      category: 'Basics',
      question: 'How does SariwaBa evaluate fish freshness?',
      answer:
          'Snap or upload a close-up of a fish eye or exposed gill to get a Fresh or Not Fresh result with a confidence score.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'gs_2',
      category: 'Basics',
      question: 'Can I scan without an account?',
      answer:
          'Yes. Guest mode saves your latest 10 scans on this device. Sign in with Google to sync across devices.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'gs_3',
      category: 'Basics',
      question: 'Do I need an internet connection?',
      answer: 'Yes — scanning photos and syncing history require internet access.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'img_1',
      category: 'Photos',
      question: 'What photo gives the clearest reading?',
      answer:
          'Shoot in bright, even light without flash glare, keeping the eye or exposed red gill sharp and centered.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'img_2',
      category: 'Photos',
      question: 'Which image formats are supported?',
      answer: 'JPG, PNG, and HEIC photos up to 10 MB.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'res_1',
      category: 'Results',
      question: 'What does the confidence score mean?',
      answer:
          'It shows how strongly the visual check matches Fresh or Not Fresh. It is not a food-safety guarantee.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'res_2',
      category: 'Results',
      question: 'Does Fresh guarantee the fish is safe to eat?',
      answer:
          'No. Photos only check visual appearance — always verify smell and firmness yourself.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'acc_1',
      category: 'Account',
      question: 'How do I delete my scans or account?',
      answer:
          'Open Settings and choose Clear History or Delete Account.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'priv_1',
      category: 'Privacy',
      question: 'Where are my photos stored?',
      answer:
          'Signed-in scans save to your account; guest scans stay on your device. You can delete them anytime.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'troub_1',
      category: 'Troubleshooting',
      question: 'Why was my photo rejected?',
      answer:
          'Make sure the photo clearly shows a raw Tilapia eye or exposed gill in focus, and matches the selected region.',
      isHomepageFeatured: false,
    ),
  ];

  static List<FaqItemModel> get homepageFaqs =>
      items.where((item) => item.isHomepageFeatured).toList();

  static List<FaqItemModel> forCategory(String category) {
    if (category == 'All') return items;
    return items.where((item) => item.category == category).toList();
  }
}
