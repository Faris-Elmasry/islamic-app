/// Qibla Feature - Barrel Export File
///
/// Provides a single entry point for the Qibla feature.
/// Follows clean architecture with proper module organization.

// Domain Layer - Entities
export 'domain/entities/qibla_direction.dart';
export 'domain/entities/location_data.dart';

// Domain Layer - Repository Interface
export 'domain/repositories/i_qibla_repository.dart';

// Data Layer - Repository Implementation
export 'data/repositories/qibla_repository.dart';

// Data Layer - Services
export 'data/services/compass_service.dart';

// Presentation Layer - Providers
export 'presentation/providers/qibla_provider.dart';

// Presentation Layer - Theme
export 'presentation/theme/qibla_theme.dart';

// Presentation Layer - Widgets
export 'presentation/widgets/animated_compass.dart';
export 'presentation/widgets/qibla_info_widgets.dart';

// Presentation Layer - Pages
export 'presentation/pages/qibla_compass_page.dart';
