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

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get personalization => 'Personalization';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get resetApp => 'Delete All Tasks';

  @override
  String get resetAppConfirmTitle => 'Delete all active tasks?';

  @override
  String get resetAppConfirmContent =>
      'This will move all your active tasks to the trash bin.';

  @override
  String get reset => 'Delete';

  @override
  String get trashBin => 'Trash Bin';

  @override
  String get trashEmpty => 'Your trash is empty';

  @override
  String get emptyTrash => 'Empty Trash';

  @override
  String get emptyTrashConfirmTitle => 'Empty trash bin?';

  @override
  String get emptyTrashConfirmContent =>
      'This will permanently delete all items in the trash. This action cannot be undone.';

  @override
  String get restoreTaskTitle => 'Restore Task?';

  @override
  String get restoreTaskContent =>
      'Do you want to move this task back to your active list?';

  @override
  String get restore => 'Restore';

  @override
  String get permanentDelete => 'Delete Permanently';

  @override
  String get deletedAtPrefix => 'Deleted on';

  @override
  String get search => 'Search...';

  @override
  String get noResults => 'No matching tasks found';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get exportData => 'Export Tasks';

  @override
  String get importData => 'Restore Tasks';

  @override
  String get importConfirmTitle => 'Restore Tasks?';

  @override
  String importConfirmContent(int count) {
    return 'This will merge $count tasks from the backup into your current list. Continue?';
  }

  @override
  String get importSuccess => 'Data restored successfully';

  @override
  String get exportSuccess => 'Data exported successfully';

  @override
  String get invalidFile => 'Invalid backup file';
}
