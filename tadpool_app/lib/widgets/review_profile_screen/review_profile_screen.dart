import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tadpool_app/app_loc.dart';
import 'package:tadpool_app/constants/style_constants.dart' as kStyle;
import 'package:tadpool_app/params/create_profile_params.dart';
import 'package:tadpool_app/services/user_profile_service.dart';
import 'package:tadpool_app/store/user_profile.dart';
import 'package:tadpool_app/store/user_store.dart';
import 'package:tadpool_app/utils/form_util.dart';
import 'package:tadpool_app/widgets/common/app_bar_button.dart';
import 'package:tadpool_app/widgets/common/primary_button.dart';
import 'package:tadpool_app/widgets/create_profile_screen/form_divider.dart';
import 'package:tadpool_app/widgets/photo_verification_screen.dart';
import 'package:tadpool_app/widgets/review_profile_screen/review_grid_text_item.dart';
import 'package:tadpool_app/widgets/review_profile_screen/review_profile.group.dart';

class ReviewProfileScreen extends StatefulWidget {
  final void Function(int index)? onEdit;
  final CreateProfileParams params;

  const ReviewProfileScreen({
    super.key,
    required this.params,
    this.onEdit,
  });
  static const routeName = "review_profile";

  @override
  _ReviewProfileScreen createState() => _ReviewProfileScreen();
}
class _ReviewProfileScreen extends State<ReviewProfileScreen> {
  bool isLoading = false;

  void _onFinishCreating(BuildContext context, UserProfile userProfile) async {
    try {
      setState(() {
        isLoading = true;
      });

      await UserProfileService.createUserProfile(
        context: context, 
        userProfile: userProfile,
);

      setState(() {
        isLoading = false;
      });

      //Display messages
      final snackBar = SnackBar(content: Text("Profile is created"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.of(context).pushNamed(PhotoVerificationScreen.routeName);
    } catch (e) {

      setState(() {
        isLoading = false;
      });

      final snackBar = SnackBar(content: Text("Profile can't be created"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = widget.params.user;
    final loc = AppLoc.of(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppBarButton(
                AppLoc.of(context)!.tr('back'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                'REVIEW PROFILE',
                style: kStyle.appBarText,
              ),
              Container(
                width: 69.0,
              )
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          titleSpacing: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: isLoading ? 
            [
              const Center(
              heightFactor: 5,
              child: CircularProgressIndicator(),
            )
            ] :
            [
              Padding(
                padding: const EdgeInsets.only(bottom: 90.0),
                      child: _buildList(context, widget.params.user)
              ),
              Positioned(
                child: PrimaryButton(
                  AppLoc.of(context)!.tr('rp_finish_btn')!.toUpperCase(),
                      onPressed: () =>
                          _onFinishCreating(context, widget.params.user),
                ),
                bottom: 20.0,
                right: 16.0,
                left: 16.0,
              )
            ],
        ));
  }

  ListView _buildList(BuildContext context, UserProfile userProfile) {
    final int? ageRangeStart =
        userProfile.status.ageRangeSeeking?.first?.toInt();
    final int? ageRangeEnd = userProfile.status.ageRangeSeeking?.last?.toInt();
    final String ageRange = '$ageRangeStart to $ageRangeEnd';

    final String heightMine =
        FormUtil.convertHeightLabel(userProfile.appearance.heightMine, 0);
    final String heightPartner =
        "${FormUtil.convertHeightLabel(userProfile.appearance.heightPartner?.first, 0)} to ${FormUtil.convertHeightLabel(userProfile.appearance.heightPartner?.last, 0)}";

    final numOfKidsMin =
        userProfile.status.numOfKidsPartner?.first?.round()?.toString();
    final numOfKidsMax =
        userProfile.status.numOfKidsPartner?.last?.round()?.toString();
    final numOfKidsPartner = "$numOfKidsMin to $numOfKidsMax kids";

    final loc = AppLoc.of(context)!;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      children: <Widget>[
        ReviewProfileGroup(
            title: AppLoc.of(context)!.tr('cp_basic_info'),
            items: [
              ReviewGridTextItem(
                label: loc.tr('cp_name'),
                bodyText: userProfile.name,
                onEdit: () => widget.onEdit?.call(0),
              ),
              ReviewGridTextItem(
                label: loc.tr('cp_age'),
                bodyText: userProfile.status.age.toString(),
                onEdit: () => widget.onEdit?.call(0),
              ),
              ReviewGridTextItem(
                label: loc.tr('cp_age_seeking'),
                bodyText: ageRange,
                bodyList: userProfile.status.ageRangeSeeking
                    ?.map((e) => e.toStringAsFixed(0))
                    .toList(),
                onEdit: () => widget.onEdit?.call(0),
              ),
            ]),
        FormDivider(),
        ReviewProfileGroup(title: AppLoc.of(context)!.tr('cp_location'), items: [
          ReviewGridTextItem(
            label: loc.tr('cp_distance_range'),
            bodyText: "Up to ${userProfile.status.distance?.toString()} km",
                onEdit: () => widget.onEdit?.call(0),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_relocate'),
            bodyText: userProfile.status.isWillingToRelocate,
                onEdit: () => widget.onEdit?.call(0),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_car'),
            bodyText: userProfile.status.isOwnsCar != null &&
                    userProfile.status.isOwnsCar!
                ? "Yes"
                : "No",
                onEdit: () => widget.onEdit?.call(0),
          )
        ]),
        FormDivider(),
        ReviewProfileGroup(
          title: loc.tr('cp_current_status'),
          items: [
            ReviewGridTextItem(
              label: loc.tr('cp_iam'),
              bodyText: userProfile.status.relationshipStatusMine,
              onEdit: () => widget.onEdit?.call(1),
            ),
            ReviewGridTextItem(
              label: loc.tr('cp_looking'),
              bodyList: userProfile.status.relationshipStatusPartner,
              onEdit: () => widget.onEdit?.call(1),
            )
          ],
        ),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_num_of_kids'),
            bodyText: userProfile.status.numOfKidsMine?.round()?.toString(),
            onEdit: () => widget.onEdit?.call(1),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_type_of_kids'),
            bodyList: userProfile.status.typeOfKidsMine,
            onEdit: () => widget.onEdit?.call(1),
          ),
        ], title: loc.tr('cp_kids_have')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_num_of_kids'),
            bodyText: numOfKidsPartner,
            onEdit: () => widget.onEdit?.call(1),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_type_of_kids'),
            bodyList: userProfile.status.typeOfKidsPartner,
            onEdit: () => widget.onEdit?.call(1),
          ),
        ], title: loc.tr('cp_kids_want')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.status.sexualOrientationMine,
            onEdit: () => widget.onEdit?.call(1),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.status.sexualOrientationPartner,
            onEdit: () => widget.onEdit?.call(1),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_sexual_interests'),
            bodyList: userProfile.interests.sexualPreferenceMine,
            onEdit: () => widget.onEdit?.call(1),
          ),
        ], title: loc.tr('cp_sexual_orientation')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyText: userProfile.status.ethnicityMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.status.ethnicityPartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_ethnicity')),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.appearance.bodyTypeMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.appearance.bodyTypePartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_body_type')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyText: heightMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyText: heightPartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_height')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyText: userProfile.appearance.eyesMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.appearance.eyesPartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_eyes')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyText: userProfile.appearance.hairColourMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.appearance.hairColourPartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_hair_color')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.appearance.hairTypeMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.appearance.hairTypePartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_hair_type')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.appearance.facialHairMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.appearance.facialHairPartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_facial_hair')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.appearance.tattoosMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.appearance.tattoosPartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_tattoos')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.appearance.piercingsMine,
            onEdit: () => widget.onEdit?.call(2),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.appearance.piercingsPartner,
            onEdit: () => widget.onEdit?.call(2),
          ),
        ], title: loc.tr('cp_piercings')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.status.eduLevelMine,
            onEdit: () => widget.onEdit?.call(3),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.status.eduLevelPartner,
            onEdit: () => widget.onEdit?.call(3),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_job'),
            bodyText: userProfile.status.job ?? " ",
            onEdit: () => widget.onEdit?.call(3),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_languages'),
            bodyText: userProfile.status.languages ?? " ",
            onEdit: () => widget.onEdit?.call(3),
          ),
        ], title: loc.tr('cp_edu_level')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyText: userProfile.beliefs.religionMine,
              onEdit: () => widget.onEdit?.call(3)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.beliefs.religionPartner,
              onEdit: () => widget.onEdit?.call(3)
          ),
        ], title: loc.tr('cp_religion')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyText: userProfile.beliefs.politicsMine,
              onEdit: () => widget.onEdit?.call(3)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.beliefs.politicsPartner,
              onEdit: () => widget.onEdit?.call(3)
          ),
        ], title: loc.tr('cp_politics')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyText: userProfile.personality.myerBriggsMine,
            onEdit: () => widget.onEdit?.call(3),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.personality.myerBriggsPartner,
            onEdit: () => widget.onEdit?.call(3),
          ),
        ], title: loc.tr('cp_mb')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.personality.personalityTypeMine,
            onEdit: () => widget.onEdit?.call(3),
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.personality.personalityTypePartner,
            onEdit: () => widget.onEdit?.call(3),
          ),
        ], title: loc.tr('cp_pt')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_indoor_hobby'),
            bodyList: userProfile.hobbiesCollecting.indoorHobbiesMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
          ReviewGridTextItem(
              label: loc.tr('cp_outdoor_hobby'),
              bodyList: userProfile.hobbiesCollecting.outdoorHobbiesMine,
              onEdit: () => widget.onEdit?.call(4)),
          ReviewGridTextItem(
            label: loc.tr('cp_indoor_collecting'),
            bodyList: userProfile.hobbiesCollecting.indoorCollectingMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_outdoor_collecting'),
            bodyList: userProfile.hobbiesCollecting.outdoorCollectingMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_competitive'),
            bodyList: userProfile.hobbiesCollecting.competitiveHobbiesMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_sport'),
            bodyList: userProfile.interests.sportsMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
        ], title: loc.tr('cp_activities')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_travel_type'),
            bodyList: userProfile.interests.sportsMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_destination'),
            bodyList: userProfile.travel.favDestinationMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_international'),
            bodyText: userProfile.travel.internationalTravelMine,
              onEdit: () => widget.onEdit?.call(4)
          ),
        ], title: loc.tr('cp_travel')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_music'),
            bodyList: userProfile.interests.musicMine,
              onEdit: () => widget.onEdit?.call(5)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_movie'),
            bodyList: userProfile.interests.moviesMine,
              onEdit: () => widget.onEdit?.call(5)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_book'),
            bodyList: userProfile.interests.booksMine,
              onEdit: () => widget.onEdit?.call(5)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_clothes'),
            bodyList: userProfile.appearance.clothingStyleMine,
              onEdit: () => widget.onEdit?.call(5)
          ),
        ], title: loc.tr('cp_culture')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_ihave'),
            bodyList: userProfile.status.pets,
              onEdit: () => widget.onEdit?.call(5)
          ),
        ], title: loc.tr('cp_pets')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.habits.smokingMine,
              onEdit: () => widget.onEdit?.call(5)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.habits.smokingPartner,
              onEdit: () => widget.onEdit?.call(6)
          ),
        ], title: loc.tr('cp_smoking')),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.habits.weedMine,
              onEdit: () => widget.onEdit?.call(6)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.habits.weedPartner,
              onEdit: () => widget.onEdit?.call(6)
          ),
        ], title: loc.tr('cp_420')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_iam'),
            bodyList: userProfile.habits.drinkingMine,
              onEdit: () => widget.onEdit?.call(6)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_looking'),
            bodyList: userProfile.habits.drinkingPartner,
              onEdit: () => widget.onEdit?.call(6)
          ),
        ], title: loc.tr('cp_drinking')),
        FormDivider(),
        ReviewProfileGroup(items: [
          ReviewGridTextItem(
            label: loc.tr('cp_types_of_food'),
            bodyList: userProfile.interests.foodMine,
              onEdit: () => widget.onEdit?.call(7)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_favorite_food'),
            bodyText: userProfile.interests.favoriteFood ?? " ",
              onEdit: () => widget.onEdit?.call(7)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_hotdrink'),
            bodyText: userProfile.interests.favoriteHotDrink ?? " ",
              onEdit: () => widget.onEdit?.call(7)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_colddrink'),
            bodyText: userProfile.interests.favoriteColdDrink ?? " ",
              onEdit: () => widget.onEdit?.call(7)
          ),
          ReviewGridTextItem(
            label: loc.tr('cp_dessert'),
            bodyText: userProfile.interests.favoriteDessert ?? " ",
              onEdit: () => widget.onEdit?.call(7)
          ),
        ], title: loc.tr('cp_food')),
      ],
    );
  }
}
