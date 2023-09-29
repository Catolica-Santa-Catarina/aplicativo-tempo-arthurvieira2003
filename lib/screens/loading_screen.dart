import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<void> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      log(position.toString());
    } catch (e) {
      // Lidar com diferentes cenários de permissão ou erro
      if (e is PermissionDeniedException) {
        // Permissão negada pelo usuário
        log('Permissão negada pelo usuário.');
      } else if (e is LocationServiceDisabledException) {
        // Serviço de localização desabilitado
        log('O serviço de localização está desabilitado.');
      } else {
        // Outros erros
        log('Erro ao obter a localização: $e');
      }
    }
  }

  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Serviço de localização desabilitado. Não será possível continuar
      return Future.error('O serviço de localização está desabilitado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Sem permissão para acessar a localização
        return Future.error('Sem permissão para acesso à localização');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissões negadas para sempre
      return Future.error(
          'A permissão para acesso à localização foi negada para sempre. Não é possível pedir permissão.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Verifica permissão antes de obter a localização
            await checkLocationPermission();
            // Obtém a localização atual
            getLocation();
          },
          child: const Text('Obter Localização'),
        ),
      ),
    );
  }
}
