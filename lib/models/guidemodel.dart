class GuideModel {
  final String idFE;
  final String title;
  final String? type;

  final String? definition;
  final String? symptoms;
  final String? measurement;
  final String? cause;
  final String? spreadRisk;
  final String? humidity;
  final String? severity;

  final String? content;
  final String? url;

  GuideModel({
    required this.idFE,
    required this.title,
    this.type,

    this.definition,
    this.symptoms,
    this.measurement,
    this.cause,
    this.spreadRisk,
    this.humidity,
    this.severity,

    this.content,
    this.url,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      idFE: json['idFE'] ?? '',
      title: json['title'] ?? '',
      type: json['type'],

      definition: json['definition'],
      symptoms: json['symptoms'],
      measurement: json['measurement'],
      cause: json['cause'],
      spreadRisk: json['spreadRisk'],
      humidity: json['humidity'],
      severity: json['severity'],

      content: json['content'],
      url: json['url'],
    );
  }
}
