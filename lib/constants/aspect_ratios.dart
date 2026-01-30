import 'package:imgify/models/aspect_ratio.dart';

class AspectRatioConstants {
  // Common aspect ratios for image resizing
  static final List<MyAspectRatio> commonRatios = [
    MyAspectRatio(name: '1:1 (Square)', ratio: 1.0),
    MyAspectRatio(name: '4:3 (Standard)', ratio: 4 / 3),
    MyAspectRatio(name: '3:4 (Portrait)', ratio: 3 / 4),
    MyAspectRatio(name: '16:9 (Widescreen)', ratio: 16 / 9),
    MyAspectRatio(name: '9:16 (Story)', ratio: 9 / 16),
    MyAspectRatio(name: '21:9 (Ultrawide)', ratio: 21 / 9),
    MyAspectRatio(name: '3:2 (Photo)', ratio: 3 / 2),
    MyAspectRatio(name: '2:3 (Photo Portrait)', ratio: 2 / 3),
  ];

  // Individual aspect ratios for direct access
  static final MyAspectRatio square =
      MyAspectRatio(name: '1:1 (Square)', ratio: 1.0);
  static final MyAspectRatio standard =
      MyAspectRatio(name: '4:3 (Standard)', ratio: 4 / 3);
  static final MyAspectRatio portrait =
      MyAspectRatio(name: '3:4 (Portrait)', ratio: 3 / 4);
  static final MyAspectRatio widescreen =
      MyAspectRatio(name: '16:9 (Widescreen)', ratio: 16 / 9);
  static final MyAspectRatio story =
      MyAspectRatio(name: '9:16 (Story)', ratio: 9 / 16);
  static final MyAspectRatio ultrawide =
      MyAspectRatio(name: '21:9 (Ultrawide)', ratio: 21 / 9);
  static final MyAspectRatio photo =
      MyAspectRatio(name: '3:2 (Photo)', ratio: 3 / 2);
  static final MyAspectRatio photoPortrait =
      MyAspectRatio(name: '2:3 (Photo Portrait)', ratio: 2 / 3);
}
