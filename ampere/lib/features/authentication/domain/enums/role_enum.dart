/// Role enum representing user roles in the system
enum Role {
  admin,
  manager,
  user,
  supervisor,
  technicien,
}

/// Extension with handy helpers for Role enum
extension RoleExtension on Role {
  String get value {
    switch (this) {
      case Role.admin:
        return 'ROLE_ADMIN';
      case Role.manager:
        return 'ROLE_MANAGER';
      case Role.user:
        return 'ROLE_USER';
      case Role.supervisor:
        return 'ROLE_SUPERVISOR';
      case Role.technicien:
        return 'ROLE_TECHNICIEN';
    }
  }
}

/// Extension for parsing string values into Role
extension RoleParser on Role {
  static Role? fromString(String? value) {
    if (value == null) return null;

    switch (value.toUpperCase()) {
      case 'ROLE_ADMIN':
        return Role.admin;
      case 'ROLE_MANAGER':
        return Role.manager;
      case 'ROLE_USER':
        return Role.user;
      case 'ROLE_SUPERVISOR':
        return Role.supervisor;
      case 'ROLE_TECHNICIEN':
        return Role.technicien;
      default:
        return null;
    }
  }
}

