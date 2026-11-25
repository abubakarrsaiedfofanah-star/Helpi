import 'package:flutter/material.dart';

const caseCategoryLabels = <String, String>{
  'ORPHAN': 'Orphan',
  'WIDOW': 'Widow',
  'WAR_SURVIVOR': 'War survivor',
  'DISABILITY': 'Person with a disability',
  'ELDERLY': 'Older adult',
  'DISPLACED_PERSON': 'Refugee or displaced person',
  'SINGLE_PARENT': 'Single parent',
  'UNEMPLOYED': 'Unemployed person',
  'LOW_INCOME_FAMILY': 'Low-income family',
  'CAREGIVER': 'Caregiver',
  'CHRONIC_ILLNESS': 'Person with a chronic illness',
  'HOMELESS': 'Person without stable housing',
  'TRAFFICKING_SURVIVOR': 'Survivor of trafficking or abuse',
  'OTHER': 'Other',
};

const legacyCaseCategoryLabels = <String, String>{
  'WAR_VICTIM': 'War survivor',
  'JOBLESS': 'Unemployed person',
  'HARDSHIP': 'Other',
};

String caseCategoryLabel(String value) =>
    caseCategoryLabels[value] ??
    legacyCaseCategoryLabels[value] ??
    value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');

IconData caseCategoryIcon(String value) => switch (value) {
      'ORPHAN' => Icons.child_care_outlined,
      'WIDOW' => Icons.person_outline,
      'WAR_SURVIVOR' => Icons.shield_outlined,
      'DISABILITY' => Icons.accessible_forward_outlined,
      'ELDERLY' => Icons.elderly_outlined,
      'DISPLACED_PERSON' => Icons.flight_takeoff_outlined,
      'SINGLE_PARENT' => Icons.family_restroom_outlined,
      'UNEMPLOYED' => Icons.work_off_outlined,
      'LOW_INCOME_FAMILY' => Icons.groups_outlined,
      'CAREGIVER' => Icons.volunteer_activism_outlined,
      'CHRONIC_ILLNESS' => Icons.health_and_safety_outlined,
      'HOMELESS' => Icons.home_outlined,
      'TRAFFICKING_SURVIVOR' => Icons.support_outlined,
      _ => Icons.groups_outlined,
    };
