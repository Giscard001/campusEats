import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/staff_scan/data/repositories/scanner_repository_impl.dart';
import 'package:campuseats/features/staff_scan/presentation/bloc/scanner_bloc.dart';
import 'package:campuseats/features/staff_scan/presentation/pages/scan_result_sheet.dart';

class StaffScannerPage extends StatelessWidget {
  const StaffScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScannerBloc(sl<ScannerRepository>()),
      child: const _StaffScannerView(),
    );
  }
}

class _StaffScannerView extends StatefulWidget {
  const _StaffScannerView();

  @override
  State<_StaffScannerView> createState() => _StaffScannerViewState();
}

class _StaffScannerViewState extends State<_StaffScannerView> {
  late final MobileScannerController _scannerController;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _showResultSheet(BuildContext context, ScannerState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanResultSheet(
        result: state.result!,
        isServing: state.status == ScannerStateStatus.serving,
        onValidateServed: () {
          if (state.result?.order != null) {
            context.read<ScannerBloc>().add(MarkServedRequested(state.result!.order!.id));
          }
        },
        onDismiss: () {
          Navigator.of(context).pop();
          context.read<ScannerBloc>().add(const ResetScanner());
        },
      ),
    ).whenComplete(() {
      context.read<ScannerBloc>().add(const ResetScanner());
    });
  }

  void _manualMatriculePrompt(BuildContext context) {
    final textController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Saisie manuelle du matricule'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'Ex: STU001',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final val = textController.text.trim();
              if (val.isNotEmpty) {
                Navigator.of(ctx).pop();
                context.read<ScannerBloc>().add(QrDetected('CAMPUS-USER-$val'));
              }
            },
            child: const Text('Vérifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScannerBloc, ScannerState>(
      listenWhen: (prev, curr) =>
          (curr.status == ScannerStateStatus.resultReady && prev.status != ScannerStateStatus.resultReady) ||
          (curr.status == ScannerStateStatus.servedSuccess && prev.status != ScannerStateStatus.servedSuccess),
      listener: (context, state) {
        if (state.status == ScannerStateStatus.resultReady && state.result != null) {
          _showResultSheet(context, state);
        } else if (state.status == ScannerStateStatus.servedSuccess) {
          Navigator.of(context, rootNavigator: true).pop(); // dismiss sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Repas validé et distribué avec succès !'),
              backgroundColor: AppColors.statusServed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ScannerBloc>().add(const ResetScanner());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Scanner cantine', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
                onPressed: () async {
                  await _scannerController.toggleTorch();
                  setState(() => _isTorchOn = !_isTorchOn);
                },
              ),
              IconButton(
                icon: const Icon(Icons.flip_camera_android_rounded, color: Colors.white),
                onPressed: () => _scannerController.switchCamera(),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera Viewfinder
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final rawValue = barcode.rawValue;
                    if (rawValue != null && rawValue.isNotEmpty) {
                      context.read<ScannerBloc>().add(QrDetected(rawValue));
                      break;
                    }
                  }
                },
              ),

              // 2. Viewfinder Overlay Cutout
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: state.status == ScannerStateStatus.verifying ? AppColors.secondary : AppColors.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // 3. Status indication banner
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.status == ScannerStateStatus.verifying) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        const Text('Vérification en cours...', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ] else ...[
                        const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text('Pointez vers le QR code de l\'étudiant', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
              ),

              // 4. Manual fallback button at bottom
              Positioned(
                bottom: 30,
                left: 32,
                right: 32,
                child: AppButton(
                  text: 'Saisie manuelle du matricule',
                  variant: ButtonVariant.secondary,
                  icon: const Icon(Icons.keyboard_outlined, size: 18),
                  onPressed: () => _manualMatriculePrompt(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
