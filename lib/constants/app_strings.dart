
class AppStrings {
  AppStrings._();

  static const appName = 'Slate';
  static const editTodo = 'Edit Task';
  static const addTodo = 'Add Task';
}

class BtnStrings {
  BtnStrings._();

  static const save = 'Save';
  static const update = 'Update';
  static const add = 'Add';
  static const delete = 'Delete';
   static const cancel = 'Cancel';
}

class LabelStrings {
  LabelStrings._();

  static const title = 'Title';
  static const description = 'Description';
  static const status = 'Status';
   static const repeat = 'Repeat';
   static const frequency = 'Frequency';
  static const endDate = 'End date';
  static const dueDate = 'Due date';
  static const clearDueDate = 'Clear due date';
  static const photo = 'Photo';
  static const addDescription = 'Add description';
}

class MsgStrings {
  MsgStrings._();

  static const noTasks = 'No tasks';
  static const emptyTitle = 'Please enter a title';
  static const noEndDate = 'No end date';
  static const noDueDate = 'No due date';
  static const completedOnPrefix = 'Completed on';
}

class FilterStrings {
  FilterStrings._();

  static const all = 'All';
  static const progress = 'Progress';
  static const completed = 'Completed';
  static const daily = 'Daily';
  static const selectAll = 'Select all';
}

class DialogStrings {
  DialogStrings._();

  static const clearCompletedTitle = 'Clear completed tasks?';

  static String clearCompletedContent(int count) =>
      'Delete $count visible tasks?';
}

class TooltipStrings {
  TooltipStrings._();

  static const clearVisible = 'Clear visible';
}

class TodoTileStrings {
  TodoTileStrings._();

  static const more = 'more';
  static const less = 'less';
}

class ImagePickerStrings {
  ImagePickerStrings._();

  static const camera = 'Camera';
  static const gallery = 'Gallery';
}

class ErrorStrings {
  ErrorStrings._();

  static const genericStartup =
      'Something went wrong. Please restart the app.';
}

class SectionStrings {
  SectionStrings._();

  static const showLess = 'Show less';

  static String showMore(int remaining) => 'Show $remaining more';
}
