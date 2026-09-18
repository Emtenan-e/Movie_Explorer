class CastModel {
  String name;
  final String? image;

  CastModel({
    required this.name,
     this.image
});

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
        name: json['name'] as String,
        image: json['profile_path']?.toString() ?? ''
    );
  }

}