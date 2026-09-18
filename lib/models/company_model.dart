class CompanyModel {

  String name;
  String? logo ;

  CompanyModel({
    required this.name,
    this.logo,
  });

  factory CompanyModel.fromJson (Map<String,dynamic> json){
    return CompanyModel(
        name: json['name']?.toString()??'',
        logo: json['logo_path']?.toString()??''
    );
  }
}
