import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tadpool_app/app_loc.dart';
import 'package:tadpool_app/constants/style_constants.dart' as kStyle;
import 'package:tadpool_app/params/create_profile_params.dart';
import 'package:tadpool_app/store/user_profile.dart';
import 'package:tadpool_app/utils/validators.dart';

import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_1.dart';
import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_2.dart';
import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_3.dart';
import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_4.dart';
import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_5.dart';
import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_6.dart';
import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_7.dart';
import 'package:tadpool_app/widgets/create_profile_screen/profile_slide_8.dart';
import 'package:tadpool_app/widgets/review_profile_screen/review_profile_screen.dart';

final GlobalKey<_CreateProfileScreenState> createProfileKey =
    GlobalKey<_CreateProfileScreenState>();

class CreateProfileScreen extends StatefulWidget {
  static final routeName = 'create_profile';

  const CreateProfileScreen({super.key});

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;

  final _formKeys = List.generate(8, (_) => GlobalKey<FormState>());
  late UserProfile _profile;
  late AppLoc _loc;
  late List<Widget> _slides;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profile = context.read<UserProfile>();
    _loc = AppLoc.of(context)!;

    _slides = [
      ProfileSlide1(userProfile: _profile, loc: _loc, formKey: _formKeys[0]),
      ProfileSlide2(userProfile: _profile, loc: _loc, formKey: _formKeys[1]),
      ProfileSlide3(userProfile: _profile, loc: _loc),
      ProfileSlide4(userProfile: _profile, loc: _loc),
      ProfileSlide5(userProfile: _profile, loc: _loc),
      ProfileSlide6(userProfile: _profile, loc: _loc),
      ProfileSlide7(userProfile: _profile, loc: _loc),
      ProfileSlide8(userProfile: _profile, loc: _loc),
    ];
  }

  void jumpToSlide(int index) {
    if (index >= 0 && index < _slides.length) {
      setState(() => _currentIndex = index);
      _pageController.jumpToPage(index);
    }
  }

  void _handleNext() {
    if (_formKeys[_currentIndex].currentState != null) {
      if (_formKeys[_currentIndex].currentState!.validate()) {

        _formKeys[_currentIndex].currentState!.save();
        if (_currentIndex < _slides.length - 1) {
          _pageController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        } else {
          _handleDone();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete all required fields.')),
        );
      }
    } else {
      if (_currentIndex < _slides.length - 1) {
        _pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      } else {
        _handleDone();
      }
    }
    // print('➡️ _handleNext called. currentIndex=$_currentIndex');
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

void _handleDone() {
    if (Validators.userProfileValidator(_profile)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewProfileScreen(
            params: CreateProfileParams(_profile),
            onEdit: (index) {
              Navigator.pop(context);
              jumpToSlide(index);
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: createProfileKey,
      appBar: AppBar(
        title:
            Text(_loc.tr('cp_title')!.toUpperCase(), style: kStyle.appBarText),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _slides.length,
            minHeight: 8.0,
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(kStyle.primaryGreen),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: ClampingScrollPhysics(),
              onPageChanged: (index) {
                // print('📌 onPageChanged: $index');
                setState(() => _currentIndex = index);
              },
              itemCount: _slides.length,
              itemBuilder: (_, index) => _slides[index],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  ElevatedButton.icon(
                    onPressed: _handleBack,
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text('Back', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4D7731),
                    ),
                  )
                else
                  SizedBox(width: 100),
                ElevatedButton.icon(
                  onPressed: _handleNext,
                  icon: Icon(
                    _currentIndex == _slides.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  label: Text(
                    _currentIndex == _slides.length - 1 ? 'Done' : 'Next',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4D7731),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
