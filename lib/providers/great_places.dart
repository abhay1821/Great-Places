import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/place.dart';
import '../helpers/db_helpers.dart';
import '../helpers/location_helper.dart';

class GreatPlaces with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  Future<void> addPlaces(
    String pickedTitle,
    File pickedImage,
    PlaceLocation pickedLocation,
  ) async {
    final address = await LocationHelper.getPlaceAddress(
        pickedLocation.latitude!, pickedLocation.longitude!);
    final updateLocation = PlaceLocation(
        latitude: pickedLocation.latitude,
        longitude: pickedLocation.longitude,
        address: address);
    final newPlace = Place(
      id: DateTime.now().toString(),
      title: pickedTitle,
      location: updateLocation,
      image: pickedImage,
    );
    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert('places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'loc_lat': newPlace.location!.latitude!,
      'loc_lon': newPlace.location!.longitude!,
      'address': newPlace.location!.address!,
    });
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList = await DBHelper.getData('places');
    _items = dataList
        .map(
          (item) => Place(
            id: item['id'],
            title: item['title'],
            location: PlaceLocation(
              latitude: item['loc_lat'],
              longitude: item['loc_lon'],
              address: item['address'],
            ),
            image: File(item['image']),
          ),
        )
        .toList();
    notifyListeners();
  }
}
