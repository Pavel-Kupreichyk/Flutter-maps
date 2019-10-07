class Place {
  final String userId;
  final String userName;
  final String imageUrl;
  final String name;
  final String about;
  final double lat;
  final double lng;

  Place(this.userId,this.userName, this.name, this.imageUrl, this.about, this.lat, this.lng);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Place &&
              runtimeType == other.runtimeType &&
              userId == other.userId &&
              userName == other.userName &&
              imageUrl == other.imageUrl &&
              name == other.name &&
              about == other.about &&
              lat == other.lat &&
              lng == other.lng;

  @override
  int get hashCode =>
      userId.hashCode ^
      userName.hashCode ^
      imageUrl.hashCode ^
      name.hashCode ^
      about.hashCode ^
      lat.hashCode ^
      lng.hashCode;


}