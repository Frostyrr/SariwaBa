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
    'Getting Started',
    'Image Upload and Camera',
    'Results',
    'Supported Fish and Image Requirements',
    'Accounts and Saved Scans',
    'Privacy',
    'Troubleshooting',
  ];

  static const List<FaqItemModel> items = [
    // -------------------------------------------------------------------------
    // Getting Started
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'gs_1',
      category: 'Getting Started',
      question: 'What is SariwaBa? and how does it evaluate fish freshness?',
      answer:
          'SariwaBa? checks a photo of a Tilapia eye or exposed gills and returns Fresh or Not Fresh with a confidence score.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'gs_2',
      category: 'Getting Started',
      question: 'Can I check fish without creating an account?',
      answer:
          'Yes. Guests can check photos and keep their latest 10 scans on this device. Sign in with Google to save future scans to your account.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'gs_3',
      category: 'Getting Started',
      question: 'Do I need an internet connection to use the app?',
      answer:
          'You need an internet connection to check photos and load scans saved to your account.',
      isHomepageFeatured: true,
    ),

    // -------------------------------------------------------------------------
    // Image Upload and Camera
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'img_1',
      category: 'Image Upload and Camera',
      question: 'What kind of photo gives the best results?',
      answer:
          'Take a clear, steady photo in bright, even lighting (like natural daylight or a well-lit market stall). Avoid strong flash glare, heavy shadows, or blurry shots. Make sure the eye or open gills fill most of the frame for the most accurate check.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'img_2',
      category: 'Image Upload and Camera',
      question: 'What image formats and file size limits are supported?',
      answer:
          'SariwaBa? supports JPEG, PNG, and HEIC image formats. The maximum allowed file size is 5 MB per image. Resolution must be between 32x32 and 4096x4096 pixels.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'img_3',
      category: 'Image Upload and Camera',
      question: 'How should I position the camera for eye vs. gill inspections?',
      answer:
          'For an eye photo, face the fish head directly and include the whole eye. For a gill photo, lift the gill cover so the gills are visible. Avoid glare and shadows.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Results
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'res_1',
      category: 'Results',
      question: 'What does the Confidence score mean?',
      answer:
          'Confidence shows how strongly the checker favors its result for your photo. It is not a freshness grade or a guarantee that the fish is safe to eat.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'res_2',
      category: 'Results',
      question: 'Can SariwaBa? tell me if fish is safe to eat?',
      answer:
          'No. A photo cannot confirm that a fish is safe to eat. SariwaBa? provides a visual check only.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'res_3',
      category: 'Results',
      question: 'What should I do if the AI classifies a fish as "Not Fresh"?',
      answer:
          'The checker labeled your photo Not Fresh. If the photo is blurry or poorly lit, try a clearer one. The result does not identify specific changes in the eyes or gills.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Supported Fish and Image Requirements
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'sup_1',
      category: 'Supported Fish and Image Requirements',
      question: 'Which fish species does SariwaBa? support?',
      answer:
          'SariwaBa? is designed for Nile Tilapia. Results for other fish may be unreliable.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'sup_2',
      category: 'Supported Fish and Image Requirements',
      question: 'Can I upload whole fish, fillets, or cooked fish?',
      answer:
          'Use a close-up of a raw Tilapia eye or exposed gills. Fillets, cooked fish, and unrelated photos are not supported and may give unreliable results.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Accounts and Saved Scans
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'acc_1',
      category: 'Accounts and Saved Scans',
      question: 'How do I save my scans?',
      answer:
          'Sign in with Google before scanning. Saved results appear in History with the photo, selected fish part, confidence score, and date.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'acc_2',
      category: 'Accounts and Saved Scans',
      question: 'How can I delete my scan history or delete my account?',
      answer:
          'Open your profile menu and choose Account Settings. Use Clear Scan History to remove saved scans, or Delete Account to remove your account. These actions cannot be undone.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Privacy
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'priv_1',
      category: 'Privacy',
      question: 'How does SariwaBa? protect my photos and privacy?',
      answer:
          'Signed-in scans are saved to your account. Guest scan history stays on your device. You can remove your saved scans in History or Account Settings.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'priv_2',
      category: 'Privacy',
      question: 'How do I keep my account safe?',
      answer:
          'You sign in through Google instead of creating a SariwaBa? password. Sign out when using a shared device.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Troubleshooting
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'troub_1',
      category: 'Troubleshooting',
      question: 'Why did my image upload get rejected?',
      answer:
          'Try a JPG, PNG, or HEIC photo up to 5 MB. If it still fails, take a new photo or save another copy and try again.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'troub_2',
      category: 'Troubleshooting',
      question: 'The app says "Model Unavailable". What should I do?',
      answer:
          'The photo checker is temporarily unavailable. Wait a moment and try again. If it keeps happening, contact the app administrator.',
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
