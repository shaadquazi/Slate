// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Slate';

  @override
  String get editTodo => 'Edit Task';

  @override
  String get addTodo => 'Add Task';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get status => 'Status';

  @override
  String get repeat => 'Repeat';

  @override
  String get frequency => 'Frequency';

  @override
  String get endDate => 'End date';

  @override
  String get dueDate => 'Due date';

  @override
  String get clearDueDate => 'Clear due date';

  @override
  String get photo => 'Photo';

  @override
  String get addDescription => 'Add description';

  @override
  String get schedule => 'Schedule';

  @override
  String get due => 'Due';

  @override
  String get noTasks => 'No tasks';

  @override
  String get emptyTitle => 'Please enter a title';

  @override
  String get noEndDate => 'No end date';

  @override
  String get noDueDate => 'No due date';

  @override
  String get completedOnPrefix => 'Completed on';

  @override
  String get notSet => 'Not set';

  @override
  String get pending => 'Pending';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get none => 'None';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get all => 'All';

  @override
  String get selectAll => 'Select all';

  @override
  String get clearCompletedTitle => 'Clear completed tasks?';

  @override
  String clearCompletedContent(int count) {
    return 'Delete $count visible tasks?';
  }

  @override
  String get clearVisible => 'Clear visible';

  @override
  String get more => 'more';

  @override
  String get less => 'less';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get genericStartup => 'Something went wrong. Please restart the app.';

  @override
  String get showLess => 'Show less';

  @override
  String showMore(int count) {
    return 'Show $count more';
  }
}
