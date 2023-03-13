class LocationDataParams {
  double? lat, lng, zoomLevel;

  String? placeName, completeAddress, name, tag, zipCode,addressListId;

  num? deliveryCharges;

  LocationDataParams(
      {this.placeName,
        this.lat,
        this.lng,
        this.completeAddress,
        this.name,
        this.tag,
        this.zipCode,
        this.zoomLevel,
        this.deliveryCharges,
        this.addressListId});
}