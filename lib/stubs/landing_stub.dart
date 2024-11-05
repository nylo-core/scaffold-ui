/// LandingPage stub
String stubLandingPage() => '''
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/pages/login_page.dart';
import '/resources/pages/register_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/extensions.dart';

class LandingPage extends NyStatefulWidget {
  static RouteView path = ("/landing", (_) => LandingPage());

  LandingPage() : super(child: () => _LandingPageState());
}

class _LandingPageState extends NyState<LandingPage> {

  @override
  Widget view(BuildContext context) {
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black26,
                Colors.black87
              ],
            ),
          ),
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(opacity: 0.3,
                    child: ImageCarousel(images: [
                      "sonoran_desert_1.jpg",
                      "sonoran_desert_2.png",
                      "sonoran_desert_3.jpg",
                    ], duration: Duration(seconds: 5))
                ),
              ),

              Positioned.fill(
                child: SafeArea(
                  minimum: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sonoran")
                          .fontWeightBold()
                          .alignCenter()
                          .setColor(context, (color) => Colors.white)
                          .setFontSize(40)
                          .paddingOnly(bottom: 25),

                      ClipRect(
                        child: BackdropFilter(
                          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                            decoration: new BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("Start your journey", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center).paddingOnly(bottom: 5),
                                Text("Built to help you create amazing things! Join our community.", style: TextStyle(fontSize: 16, color: Colors.white), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis).paddingOnly(bottom: 25),

                                Button.transparency(text: "Get Started", onPressed: () {
                                  routeTo(RegisterPage.path);
                                }),

                                NyRichText(
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                  children: [
                                    Text("Already have an account? ", style: TextStyle(color: Colors.white)),
                                    Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],).onTap(() {
                                  routeTo(LoginPage.path);
                                }).paddingOnly(top: 20),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}

/// Image Carousel
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final Duration duration;

  ImageCarousel({
    required this.images,
    this.duration = const Duration(seconds: 5),
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late int _currentIndex;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _timer = Timer.periodic(widget.duration + Duration(seconds: 1), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (listEquals([
      "sonoran_desert_1.jpg",
      "sonoran_desert_2.png",
      "sonoran_desert_3.jpg",
    ], widget.images)) {
      return AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: Image.asset(
          'packages/scaffold_ui/images/\${widget.images[_currentIndex]}',
          key: ValueKey<String>(widget.images[_currentIndex]),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      );
    }

    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: Image.asset(
        'public/assets/images/\${widget.images[_currentIndex]}',
        key: ValueKey<String>(widget.images[_currentIndex]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

''';
