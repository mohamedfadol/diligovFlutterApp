
class Business {

 final int? businessId;
 final String? businessName;
 final String? businessDetails;
 final String? registrationNumber;
 final int? capital;
 final String? logo;
 final String? country;
 final String? state;
 final String? city;
 final String? zipCode ;
 final String? mobile;
 final String? fax;
 final String? alternateNumber ;
 final String? email;
 final String? website;
 final String? postCode;
 final int? isActive;


  Business({
    this.businessId,
    this.businessName,
    this.businessDetails,
    this.logo,
    this.registrationNumber,
    this.capital,
    this.country,
    this.state,
    this.city,
    this.zipCode,
    this.mobile,
    this.fax,
    this.alternateNumber,
    this.email,
    this.website,
    this.postCode,
    this.isActive
  });

  // create new converter
  factory Business.fromJson(Map<String, dynamic> json) =>
      Business(
        businessId: json['id'],
        businessName: json['name'],
        businessDetails: json['business_details'],
        logo: json['logo'],
        registrationNumber: json['registration_number'],
        capital: json['capital'],
        country: json['country'],
        state: json['state'],
        city: json['city'],
        zipCode: json['zip_code'],
        mobile: json['mobile'],
        fax: json['fax'],
        postCode: json['post_code'],
        alternateNumber: json['alternate_number'],
        email: json['email'],
        website: json['website'],
        isActive: json['is_active']
      );

}