class BusinessLocation {
  final int? businessLocationId;
  final int? businessId;
  final String? locationId;
  final String? businessName;
  final String? landMark;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode ;
  final String? mobile;
  final String? fax ;
  final String? alternateNumber ;
  final String? email;
  final String? website;

  BusinessLocation(
      {this.businessLocationId,
        this.businessId,
      this.locationId,
      this.businessName,
      this.landMark,
      this.country,
      this.state,
      this.city,
      this.zipCode,
      this.mobile,
      this.fax,
      this.alternateNumber,
      this.email,
      this.website});

  factory BusinessLocation.fromJson(Map<String, dynamic> json) =>
      BusinessLocation(
        businessLocationId: json['id'],
        businessId: json['business_id'],
        locationId: json['location_id'],
        businessName: json['business_name'],
        landMark: json['landmark'],
        country: json['country'],
        state: json['state'],
        city: json['city'],
        zipCode: json['zip_code'],
        mobile: json['mobile'],
        fax: json['fax'],
        alternateNumber: json['alternate_number'],
        email: json['email'],
        website: json['website']
      );

  Map<String,dynamic> toJson() => {
    'id': businessLocationId,
    'business_id': businessId,
    'location_id': locationId,
    'business_name': businessName,
    'landmark': landMark,
    'country': country,
    'state': state,
    'city': city,
    'zip_code': zipCode,
    'mobile': mobile,
    'fax': fax,
    'alternate_number': alternateNumber,
    'email': email,
    'website': website
  };
}