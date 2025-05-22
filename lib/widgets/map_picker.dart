import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPicker extends StatefulWidget {
  final LatLng? initial;
  final ValueChanged<LatLng> onPicked;

  const MapPicker({this.initial, required this.onPicked, Key? key})
    : super(key: key);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late GoogleMapController _controller;
  LatLng? _picked;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // ← Tambahkan ini
  }

  Future<void> _requestLocationPermission() async {
    // import 'package:permission_handler/permission_handler.dart';
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      // Kamu bisa tampilkan dialog atau SnackBar
      // untuk memberitahu user bahwa izin lokasi wajib
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi diperlukan untuk centering peta.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        myLocationEnabled: true, // Opsi tampilkan tombol lokasi
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: widget.initial ?? LatLng(0, 0),
          zoom: 5,
        ),
        onMapCreated: (c) => _controller = c,
        onTap: (pos) {
          setState(() => _picked = pos);
          widget.onPicked(pos);
        },
        markers:
            _picked != null
                ? {Marker(markerId: MarkerId('picked'), position: _picked!)}
                : {},
      ),
    );
  }
}
