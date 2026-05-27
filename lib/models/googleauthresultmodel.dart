class GoogleAuthResult {
  final String idToken;
  final String? name;
  final String? email;
  final String? photoUrl;

  GoogleAuthResult({
    required this.idToken,
    this.name,
    this.email,
    this.photoUrl,
  });
}
