# Role-permission matrix

Source: Activity 5, Part C, draft v1.1. Backend permissions must enforce these boundaries even when the Flutter UI hides a route.

| Action | Guest | Consumer | Vendor |
| --- | --- | --- | --- |
| Open public screens | Yes | Yes | Yes |
| Capture or select one fish image | Yes | Yes | Yes |
| Request classification and view result | Yes; temporary only | Yes | Yes |
| Save a classification to History | No | Automatic after successful authenticated scan | Automatic after successful authenticated scan |
| View own History and scan detail | No | Yes | Yes |
| Delete own History record | No | Yes | Yes |
| View/update own Profile | No | Yes | Yes |
| Access another user's records or Django administration | No | No | No |

Guest classification may call the permitted classification API without a Google token. History and Profile require a verified Google identity; Django must filter records by the authenticated user and check ownership for detail and delete requests. Signing in later does not save an earlier guest scan.

System administration is outside the ordinary Flutter user interface and is not a Consumer/Vendor permission. There is no Quality Inspector role in the current project scope.
