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
    'Classification Results',
    'Supported Fish and Image Requirements',
    'Accounts and Classification History',
    'Privacy and Data Handling',
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
          'SariwaBa? is an AI-powered fish freshness inspection platform. It leverages computer vision and a lightweight MobileNetV3 deep learning model to inspect key organoleptic freshness markers in fish eyes and gills, providing a rapid visual assessment within milliseconds.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'gs_2',
      category: 'Getting Started',
      question: 'Can I check fish without creating an account?',
      answer:
          'Yes! You can try the freshness checker right away in Guest mode without signing up. Guest scans are processed using the exact same AI model. If you create a free account, you can also save your scan history, view past checks anytime, and access them across all your devices.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'gs_3',
      category: 'Getting Started',
      question: 'Do I need an internet connection to use the app?',
      answer:
          'You can take photos and browse your saved history offline. However, you need an active internet connection (Wi-Fi or cellular data) to run a new freshness check with our server-side AI model.',
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
          'For Eye checks, hold your camera perpendicular to the fish head, roughly 15–25 cm away, centering the eyeball in the reticle. For Gill checks, lift the operculum (gill cover) slightly so the red branchial filaments are clearly visible without casting a shadow.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Classification Results
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'res_1',
      category: 'Classification Results',
      question: 'What does the Confidence score mean?',
      answer:
          'The confidence score shows how certain the AI is based on what it sees in the photo—such as cornea clarity, color saturation, and gill texture. It is a quick visual guide to help you choose fresh fish, but it is not a laboratory test or health guarantee.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'res_2',
      category: 'Classification Results',
      question: 'Is SariwaBa? a guarantee of food safety or edible suitability?',
      answer:
          'No. SariwaBa? provides a preliminary visual assessment based on external optical characteristics. It cannot detect internal bacterial contamination, chemical preservatives (such as formalin), histamine levels, or toxic pathogens. Always rely on multi-sensory organoleptic checks (smell, firmness) and practice safe cooking practices.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'res_3',
      category: 'Classification Results',
      question: 'What should I do if the AI classifies a fish as "Not Fresh"?',
      answer:
          'When a fish receives a "Not Fresh" classification, its external markers—such as milky eyes or dull, brownish gills—strongly suggest post-mortem decay. We advise selecting another fish or verifying texture and odor before purchasing or consuming.',
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
          'SariwaBa? is specifically trained for Nile Tilapia (Oreochromis niloticus). By focusing on Tilapia, our system accurately reads the natural signs of freshness in its eyes and gills without getting confused by anatomical variations in other fish species.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'sup_2',
      category: 'Supported Fish and Image Requirements',
      question: 'Can I upload whole fish, fillets, or cooked fish?',
      answer:
          'No. The AI model is trained specifically on whole fresh/raw Tilapia heads displaying intact eyes or exposed gills. Uploading fillets, cut slices, cooked dishes, or non-fish subjects will lead to validation rejections or unreliable predictions.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Accounts and Classification History
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'acc_1',
      category: 'Accounts and Classification History',
      question: 'How do I save and sync my classification scans?',
      answer:
          'Sign in with your Google account. Every time you classify a fish while logged in, your scan result, confidence score, anatomical region, and timestamp are automatically saved to your cloud profile and synced across your devices.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'acc_2',
      category: 'Accounts and Classification History',
      question: 'How can I delete my scan history or delete my account?',
      answer:
          'In the dashboard, click on your profile picture at the bottom-left of the sidebar and select "Account Settings". Under Privacy & Data, you can delete your entire classification history. Under Danger Zone, you can permanently delete your SariwaBa? account.',
      isHomepageFeatured: false,
    ),

    // -------------------------------------------------------------------------
    // Privacy and Data Handling
    // -------------------------------------------------------------------------
    FaqItemModel(
      id: 'priv_1',
      category: 'Privacy and Data Handling',
      question: 'How does SariwaBa? protect my photos and privacy?',
      answer:
          'Your photos are transmitted over encrypted TLS connections. We never sell, share, or monetize your images. Scans performed in Guest mode are not saved on our servers. Authenticated scans are strictly access-controlled and visible only to you and authorized inspectors.',
      isHomepageFeatured: true,
    ),
    FaqItemModel(
      id: 'priv_2',
      category: 'Privacy and Data Handling',
      question: 'Are my audit logs and credentials protected?',
      answer:
          'Yes. All system audit logs are strictly append-only, access-controlled, and protected against unauthorized tampering or administrative deletion. We never store passwords, raw Google OAuth tokens, or sensitive credentials in database logs.',
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
          'Uploads may be rejected if: (1) The file is not a supported image format (JPEG, PNG, HEIC); (2) The file exceeds the 5 MB limit; (3) The dimensions are smaller than 32x32 px or larger than 4096x4096 px; or (4) The image file stream was corrupted. Try taking a fresh photo or re-saving your image.',
      isHomepageFeatured: false,
    ),
    FaqItemModel(
      id: 'troub_2',
      category: 'Troubleshooting',
      question: 'The app says "Model Unavailable". What should I do?',
      answer:
          'This happens when the backend server is temporarily starting up or warming the PyTorch model checkpoint. Wait 5–10 seconds and tap "Try Again". If the issue persists, verify that the backend Docker container is healthy.',
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
