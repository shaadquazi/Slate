// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Slate';

  @override
  String get editTodo => 'Editar Tarea';

  @override
  String get addTodo => 'Añadir Tarea';

  @override
  String get save => 'Guardar';

  @override
  String get update => 'Actualizar';

  @override
  String get add => 'Añadir';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get title => 'Título';

  @override
  String get description => 'Descripción';

  @override
  String get status => 'Estado';

  @override
  String get repeat => 'Repetir';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get endDate => 'Fecha de finalización';

  @override
  String get dueDate => 'Fecha de vencimiento';

  @override
  String get clearDueDate => 'Borrar fecha de vencimiento';

  @override
  String get photo => 'Foto';

  @override
  String get addDescription => 'Añadir descripción';

  @override
  String get schedule => 'Horario';

  @override
  String get due => 'Vence';

  @override
  String get noTasks => 'Sin tareas';

  @override
  String get emptyTitle => 'Por favor, introduce un título';

  @override
  String get noEndDate => 'Sin fecha de finalización';

  @override
  String get noDueDate => 'Sin fecha de vencimiento';

  @override
  String get completedOnPrefix => 'Completado el';

  @override
  String get notSet => 'No establecido';

  @override
  String get pending => 'Pendiente';

  @override
  String get inProgress => 'En progreso';

  @override
  String get completed => 'Completado';

  @override
  String get none => 'Ninguno';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get thisYear => 'Este año';

  @override
  String get all => 'Todo';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get clearCompletedTitle => '¿Borrar tareas completadas?';

  @override
  String clearCompletedContent(int count) {
    return '¿Eliminar $count tareas visibles?';
  }

  @override
  String get clearVisible => 'Borrar visibles';

  @override
  String get more => 'más';

  @override
  String get less => 'menos';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get genericStartup =>
      'Algo salió mal. Por favor, reinicia la aplicación.';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String showMore(int count) {
    return 'Mostrar $count más';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get theme => 'Apariencia';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get personalization => 'Personalización';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get resetApp => 'Eliminar todas las tareas';

  @override
  String get resetAppConfirmTitle => '¿Eliminar todas las tareas activas?';

  @override
  String get resetAppConfirmContent =>
      'Esto moverá todas tus tareas activas a la papelera.';

  @override
  String get reset => 'Eliminar';

  @override
  String get trashBin => 'Papelera';

  @override
  String get trashEmpty => 'Tu papelera está vacía';

  @override
  String get emptyTrash => 'Vaciar papelera';

  @override
  String get emptyTrashConfirmTitle => '¿Vaciar papelera?';

  @override
  String get emptyTrashConfirmContent =>
      'Esto eliminará permanentemente todos los elementos de la papelera. Esta acción no se puede deshacer.';

  @override
  String get restoreTaskTitle => '¿Restaurar tarea?';

  @override
  String get restoreTaskContent =>
      '¿Quieres mover esta tarea de nuevo a tu lista activa?';

  @override
  String get restore => 'Restaurar';

  @override
  String get permanentDelete => 'Eliminar permanentemente';

  @override
  String get deletedAtPrefix => 'Eliminado el';

  @override
  String get search => 'Buscar...';

  @override
  String get noResults => 'No se encontraron tareas que coincidan';

  @override
  String get filters => 'Filtros';

  @override
  String get clearFilters => 'Limpiar Filtros';

  @override
  String get filterHelp => 'Guía de filtros';

  @override
  String get filterHelpToday => 'Hoy o tareas atrasadas';

  @override
  String get filterHelpThisWeek => 'Vence este domingo';

  @override
  String get filterHelpIn7Days => 'Próximos 7 días';

  @override
  String get filterHelpThisMonth => 'Vence fin de mes';

  @override
  String get filterHelpThisYear => 'Vence fin de año';

  @override
  String get nextSevenDays => 'Próximos 7 días';

  @override
  String get exportData => 'Exportar tareas';

  @override
  String get importData => 'Restaurar tareas';

  @override
  String get importConfirmTitle => '¿Restaurar tareas?';

  @override
  String importConfirmContent(int count) {
    return 'Esto fusionará $count tareas de la copia de seguridad en tu lista actual. ¿Continuar?';
  }

  @override
  String get importSuccess => 'Datos restaurados con éxito';

  @override
  String get exportSuccess => 'Datos exportados con éxito';

  @override
  String get invalidFile => 'Archivo de copia de seguridad no válido';
}
