import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:tadpool_app/app_loc.dart';
import 'package:tadpool_app/store/user_profile.dart';
import 'package:tadpool_app/widgets/common/date_picker_field.dart';
import 'package:tadpool_app/widgets/common/manual_entry_field.dart';
import 'package:tadpool_app/widgets/common/radio_button_field.dart';
import 'package:tadpool_app/widgets/common/range_slider.dart';
import 'package:tadpool_app/widgets/common/slider.dart';
import 'package:tadpool_app/widgets/create_profile_screen/base_profile_slide.dart';
import 'package:tadpool_app/widgets/create_profile_screen/form_divider.dart';
import 'package:tadpool_app/widgets/create_profile_screen/form_group.dart';
import 'package:tadpool_app/widgets/create_profile_screen/form_title.dart';

class ProfileSlide1 extends BaseProfileSlide {
  ProfileSlide1({super.key, 
    required UserProfile userProfile,
    required AppLoc loc,
    GlobalKey<FormState>? formKey,
  }) : super(
          body: Builder(
            builder: (context) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormGroup(
                            children: [
                              FormTitle(loc.tr('cp_basic_info')),
                              Observer(
                                builder: (_) => ManualEntryField(
                                  hintText: loc.tr('cp_name_hint') ?? '',
                                  labelText: '${loc.tr('cp_name') ?? ''} *',
                                  initialValue: userProfile.name,
                                  onChanged: (value) =>
                                      userProfile.name = value,
                                  onSaved: (value) =>
                                      userProfile.name = value,
                                  keyboardType: TextInputType.name,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This field is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Observer(
                                builder: (_) => DatepickerField(
                                  labelText: '${loc.tr('cp_age') ?? ''} *',
                                  valueText: userProfile.status.age != null
                                      ? '${userProfile.status.age} ${loc.tr("cp_years_old") ?? ""}'
                                      : null,
                                  hintText: loc.tr('cp_age_hint') ?? '',
                                  initialDate:
                                      userProfile.status.birthDate ??
                                      DateTime.now(),
                                  onDateSelected: (date) =>
                                      userProfile.status.birthDate = date,
                                  validator: () {
                                    if (userProfile.status.birthDate == null) {
                                      return 'Please select a birthdate';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Observer(
                                builder: (_) => CustomRangeSlider(
                                  labelText:
                                      '${loc.tr('cp_age_seeking') ?? ''} *',
                                  min: 18,
                                  max: 80,
                                  divisions: 62,
                                  value:
                                      userProfile.status.ageRangeSeeking != null
                                      ? RangeValues(
                                              userProfile.status
                                                  .ageRangeSeeking!.first,
                                              userProfile
                                                  .status.ageRangeSeeking!.last)
                                      : const RangeValues(25, 65),
                                  onChanged: (values) =>
                                      userProfile.status.ageRangeSeeking =
                                          ObservableList.of(
                                              [values.start, values.end]),
                                  validator: () {
                                    if (userProfile.status.ageRangeSeeking ==
                                        null) {
                                      return 'Please select an age range';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const FormDivider(),
                          FormGroup(
                            children: [
                              FormTitle(loc.tr('cp_location')),
                              Observer(
                                builder: (_) => CustomSlider(
                                  labelText:
                                      '${loc.tr('cp_distance_range') ?? ''} *',
                                  min: 0,
                                  max: 25,
                                  divisions: 5,
                                  value: userProfile.status.distance ?? 0.0,
                                  onChanged: (value) =>
                                      userProfile.status.distance = value,
                                ),
                              ),
                              Observer(
                                builder: (_) => RadioButtonField(
                                  labelText: '${loc.tr('cp_relocate') ?? ''} *',
                                  values: ['yes', 'no', 'maybe'],
                                  labels: [
                                    loc.tr('yes')?.toUpperCase() ?? 'YES',
                                    loc.tr('no')?.toUpperCase() ?? 'NO',
                                    loc.tr('maybe')?.toUpperCase() ?? 'MAYBE',
                                  ],
                                  selectedValue:
                                      userProfile.status.isWillingToRelocate,
                                  onSelect: (value) => userProfile
                                      .status.isWillingToRelocate = value,
                                  validator: () {
                                    if (userProfile
                                                .status.isWillingToRelocate ==
                                            null ||
                                        userProfile.status.isWillingToRelocate!
                                            .isEmpty) {
                                      return 'Please select an option';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Observer(
                                builder: (_) => RadioButtonField(
                                  labelText:
                                      '${loc.tr('cp_car') ?? ''} *',
                                  values: ['yes', 'no'],
                                  labels: [
                                    loc.tr('yes')?.toUpperCase() ?? 'YES',
                                    loc.tr('no')?.toUpperCase() ?? 'NO',
                                  ],
                                  selectedValue:
                                      userProfile.status.isOwnsCar == null
                                          ? ''
                                          : userProfile.status.isOwnsCar!
                                              ? 'yes'
                                              : 'no',
                                  onSelect: (value) => userProfile
                                      .status.isOwnsCar = value == 'yes',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}
