import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectplace;
  LocationInput(this.onSelectplace);
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  void _showPreview(double lat, double lon) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitude: lat,
      longitude: lon,
    );
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  //getting the coordinates of the location
  Future<void> _getCurrentUserLocation() async {
    try {
      final locData = await Location().getLocation();
      _showPreview(locData.latitude!, locData.longitude!);

      widget.onSelectplace(locData.latitude, locData.longitude);
    } catch (error) {
      return;
    }
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      //creting the new route on fly
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      //..
    }
    _showPreview(selectedLocation!.latitude, selectedLocation.longitude);
    widget.onSelectplace(selectedLocation.latitude, selectedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(
            width: 1,
            color: Colors.grey,
          )),
          child: _previewImageUrl!.isEmpty
              ? Text(
                  'No Location Chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ignore: deprecated_member_use
            FlatButton.icon(
              onPressed: _getCurrentUserLocation,
              icon: Icon(Icons.location_on),
              label: Text('Current location'),
              textColor: Theme.of(context).primaryColor,
            ),
            // ignore: deprecated_member_use
            FlatButton.icon(
              onPressed: _selectOnMap,
              icon: Icon(Icons.map),
              label: Text('Select On map'),
              textColor: Theme.of(context).primaryColor,
            )
          ],
        )
      ],
    );
  }
}
