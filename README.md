Primitives
==========

Draw primitives use opengles or graphics

@"Draw at point with color. Also, width. As OpenGL, points[] with amount or point0, ...,nil is enable",
@"Point",
@"Draw line from point to point, or lines by points[] with amount or point0,...,nil. A ll with color. Also width, cap, join, solidOrDotted, joinOrSeg.",
@"Line",
@"Draw or fill, from point to point, or at center with startAngle and endAngle. All with radius and color. Also width, cap, join, solidOrDotted for draw.",
@"Arc",
@"Draw with kBezier{s,e,c1,c2} and color, Also width, cap, join, solidOrDotted. C ur?? when c2 is nil.",
@"Bezier",
@"Draw or fill, rect or rects by rects[] with amount or rect0,...nil. All with color. Al so width, cap, join, solidOrDotted for draw. Besides, round rect with corner radius.", @"Rect",
@"Draw or fill, ellipse or ellipses by rects[] with amount or rect0,...nil. All with col or. Also width, cap, join, solidOrDotted for draw.",
@"Ellipse",
@"Draw or fill, polygon by points[] with amount and color. Also width, cap, join, s olidOrDotted for draw, pathMode for fill. Besides, regular polygon with sideAmoun t center radius angle and others.",
@"Polygon",
@"Draw or fill, regular star with pointAmount center angle and color. Also width, c ap, join, solidOrDotted for draw, pathMode for fill.",
@"Star",
@"Draw or fill, at center with radius startAngle endAngle clockwise and color. Also
width, cap, join, solidOrDotted for draw",
@"Fan",
@"Fill by colors[] with amount or color0,...,nil or components[] with amount. All w ith style.",
@"Gradient",
@"Draw by image or image name at position or fill in rect with fillStype. Also with alpha flip rotate scaleX and scaleY",
@"Image",
@"Draw at position or in rect",
@"PDF",
@"Draw text or glyphs with amount in rect. Also with color font size strokeColor an d pathMode",
@"Text",
nil
