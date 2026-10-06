# Scope and constraints

Source: Activity 5, Parts D and F, draft v1.1.

## In scope

- Flutter Web and Android client for Guest, Consumer, and Vendor use.
- Single still-image camera capture or existing-image selection, with JPEG/PNG and 5 MB client/server validation.
- Django image preprocessing and internal MobileNetV3 classification returning `Fresh` or `Not Fresh` with confidence.
- Temporary Guest result with no database write; automatic authenticated scan history through Django ORM and PostgreSQL.
- Signed-in user's own History list/detail/delete and Profile view/display-name update.
- A decision-support disclaimer on every classification result.
- Google OAuth 2.0/OpenID Connect sign-in for protected functions.

## Out of scope

Continuous video-stream ML inference, multi-fish bounding-box detection, external ML API calls, custom password registration, guest history saving, retroactive saving after sign-in, offline ML inference, and offline history caching. The source PDF treats these as this-semester exclusions.

## Architecture and deployment

Flutter (Dart, Riverpod, Dio) communicates with Django REST Framework over HTTPS. The internal MobileNetV3 model runs in the Django application tier. Django ORM alone accesses PostgreSQL; Flutter has no database credentials or direct database connection. The deployment plan names Vercel for Flutter Web, Render Web Service for Django/ML, Render PostgreSQL for data, and an Android APK on user devices. Google is the only external authentication service.

## Targets and assumptions

- Binary labels: `Fresh` and `Not Fresh`; confidence is returned with the result.
- Target classification response: under 3 seconds under the source document's stated standard mobile-network condition. This is a **target**, not a measured result; the test environment needs to be specified before verification.
- Target model accuracy: above 85% on a validation dataset. Dataset composition and evaluation protocol remain to be documented.
- Classification and History retrieval need network access to Django. Network errors should show a clear retry action without claiming a result was produced or saved.
- User-supplied market observations and feedback cited in the worksheet need source records if they are to be presented as collected evidence.
