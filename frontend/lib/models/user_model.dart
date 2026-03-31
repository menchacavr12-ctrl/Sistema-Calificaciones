class UserModel {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? profilePicture;
  final String role;
  final String status;
  final bool isVerified;
  final String? numeroControl;
  final int? semestre;
  final String? grupo;
  final String? especialidad;
  final String? departamento;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.profilePicture,
    required this.role,
    required this.status,
    required this.isVerified,
    this.numeroControl,
    this.semestre,
    this.grupo,
    this.especialidad,
    this.departamento,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      role: json['role'] ?? 'alumno',
      status: json['status'] ?? 'activo',
      isVerified: json['is_verified'] ?? false,
      numeroControl: json['numero_control'],
      semestre: json['semestre'],
      grupo: json['grupo'],
      especialidad: json['especialidad'],
      departamento: json['departamento'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'full_name': fullName,
    'profile_picture': profilePicture,
    'role': role,
    'status': status,
    'is_verified': isVerified,
    'numero_control': numeroControl,
    'semestre': semestre,
    'grupo': grupo,
    'especialidad': especialidad,
    'departamento': departamento,
  };

  String get displayName => fullName ?? username;
  bool get isAlumno => role == 'alumno';
  bool get isMaestro => role == 'maestro';
  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isSuperAdmin => role == 'super_admin';
}
