# Market visit 01 YOLO pilot export

The images are clean copies. Labels use normalized YOLO coordinates with class 0
for fish and class 1 for eye. The annotated Photoshop layer bounds were checked
on visual overlays. Boxes reaching outside the canvas were clipped. One exact
duplicate box was omitted. For IMG_8222 and IMG_8224, rectangle coordinates
were recovered from the colored strokes in the marked JPEG exports and paired
with their aligned clean JPEGs. Those boxes use the visible stroke bounds.

Treat this as a single capture batch for label review and pilot training. Review
annotation completeness on the full images before training. Use separate capture
sessions for validation and final testing.

The current marked and clean export folders have the same 14 filenames. Of
those, 13 align. The two files named IMG_8185 show different tray photos, so
the clean copy needs its own boxes or a matching marked export.
