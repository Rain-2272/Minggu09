import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

const Color primaryBlue = Color(0xFF70B7F0);
const Color darkBlue = Color(0xFF398BCB);
const Color lightBlue = Color(0xFFEAF5FF);
const Color backgroundBlue = Color(0xFFF5F9FE);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Bergambar',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const NotesPage(),
    );
  }
}

// MODEL CATATAN
class Note {
  final String title;
  final String content;
  final Uint8List? image;
  final DateTime date;

  Note({
    required this.title,
    required this.content,
    this.image,
    required this.date,
  });
}

// HALAMAN UTAMA
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> notes = [];

  void addNote(Note note) {
    setState(() {
      notes.insert(0, note);
    });
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil dihapus.')));
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  void openAddNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddNoteSheet(onSave: addNote),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Catatan Bergambar',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
        leading: const Icon(Icons.menu_book_rounded),
      ),

      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF83C5F4), Color(0xFF398BCB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CATATAN HARIAN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Simpan Ceritamu!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Abadikan momen dan simpan semua ceritamu dalam satu tempat.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Mulai menulis  →',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.auto_stories_rounded,
                  size: 75,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // JUDUL DAFTAR CATATAN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Catatan Saya',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273B50),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${notes.length} Catatan',
                    style: const TextStyle(
                      color: darkBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // DAFTAR CATATAN
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(27),
                            decoration: const BoxDecoration(
                              color: lightBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.note_add_rounded,
                              size: 65,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Belum Ada Catatan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF273B50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Yuk, buat catatan pertamamu dan tambahkan foto kenangan!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(17, 0, 17, 100),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];

                      return Card(
                        elevation: 3,
                        shadowColor: primaryBlue.withOpacity(0.15),
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 18),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                          side: const BorderSide(color: Color(0xFFDCEEFF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FOTO CATATAN - TAMPIL UTUH
                            if (note.image != null)
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  maxHeight: 350,
                                ),
                                color: lightBlue,
                                padding: const EdgeInsets.all(8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(
                                    note.image!,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                17,
                                14,
                                17,
                                17,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title,
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF273B50),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus catatan',
                                        onPressed: () => deleteNote(index),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Text(
                                    note.content,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Color(0xFF526477),
                                    ),
                                  ),

                                  const SizedBox(height: 15),
                                  const Divider(color: Color(0xFFEAF1F8)),
                                  const SizedBox(height: 7),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: darkBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          formatDate(note.date),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        note.image == null
                                            ? Icons.image_not_supported_outlined
                                            : Icons.image_rounded,
                                        color: darkBlue,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        note.image == null
                                            ? 'Tanpa foto'
                                            : '1 Foto',
                                        style: const TextStyle(
                                          color: darkBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddNote,
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Buat Catatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// FORM TAMBAH CATATAN
class AddNoteSheet extends StatefulWidget {
  final ValueChanged<Note> onSave;

  const AddNoteSheet({super.key, required this.onSave});

  @override
  State<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<AddNoteSheet> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final picker = ImagePicker();

  Uint8List? selectedImage;
  bool isProcessing = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> chooseImage(ImageSource source) async {
    if (isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final file = await picker.pickImage(source: source, imageQuality: 90);

      if (file != null) {
        final bytes = await file.readAsBytes();

        if (!mounted) return;

        setState(() {
          selectedImage = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        showMessage('Gagal mengambil gambar. Periksa izin perangkat. $e');
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Future<void> openCamera() async {
    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        selectedImage = result;
      });
    }
  }

  void saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      showMessage('Judul dan isi catatan wajib diisi.');
      return;
    }

    widget.onSave(
      Note(
        title: title,
        content: content,
        image: selectedImage,
        date: DateTime.now(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          21,
          22,
          21,
          MediaQuery.of(context).viewInsets.bottom + 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Buat Catatan Baru',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF273B50),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Tuliskan ceritamu dan tambahkan foto.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),

            const SizedBox(height: 22),

            const Text(
              'Judul Catatan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul catatan',
                prefixIcon: const Icon(Icons.title_rounded, color: darkBlue),
                filled: true,
                fillColor: lightBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 19),

            const Text(
              'Isi Catatan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan isi catatan kamu...',
                alignLabelWithHint: true,
                filled: true,
                fillColor: lightBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 21),

            const Text(
              'Foto Catatan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),

            const Text(
              'Tambahkan maksimal satu foto dari kamera atau galeri.',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),

            const SizedBox(height: 12),

            if (selectedImage != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 320),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        selectedImage!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      tooltip: 'Hapus foto',
                      onPressed: () {
                        setState(() => selectedImage = null);
                      },
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFFB8DDFB)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      color: darkBlue,
                      size: 42,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada foto dipilih',
                      style: TextStyle(
                        color: darkBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            if (isProcessing) ...[
              const LinearProgressIndicator(
                color: darkBlue,
                backgroundColor: lightBlue,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Sedang memproses gambar...',
                  style: TextStyle(color: darkBlue, fontSize: 13),
                ),
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => chooseImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkBlue,
                        side: const BorderSide(color: primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: openCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 23),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : saveNote,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Simpan Catatan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HALAMAN KAMERA
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;

  bool loading = true;
  bool takingPhoto = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    CameraController? newController;

    try {
      // Browser menangani izin kamera di Web.
      // Android meminta izin melalui permission_handler.
      if (!kIsWeb) {
        final permission = await Permission.camera.request();

        if (!permission.isGranted) {
          throw Exception(
            permission.isPermanentlyDenied
                ? 'Izin kamera ditolak permanen. Aktifkan melalui pengaturan aplikasi.'
                : 'Izin kamera ditolak. Berikan izin agar kamera dapat digunakan.',
          );
        }
      }

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Kamera tidak ditemukan.');
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      newController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      controller = newController;

      await newController.initialize();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (newController != null) {
        if (identical(controller, newController)) {
          controller = null;
        }
        await newController.dispose();
      }

      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> takePhoto() async {
    final currentController = controller;

    if (currentController == null ||
        !currentController.value.isInitialized ||
        takingPhoto) {
      return;
    }

    setState(() => takingPhoto = true);

    try {
      final photo = await currentController.takePicture();
      final bytes = await photo.readAsBytes();

      if (!mounted) return;

      Navigator.pop(context, bytes);
    } catch (e) {
      if (!mounted) return;

      setState(() => takingPhoto = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  @override
  void dispose() {
    // Controller selalu dibuang ketika halaman kamera ditutup.
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ambil Foto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: loading
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: darkBlue),
                    SizedBox(height: 15),
                    Text('Sedang menyiapkan kamera...'),
                  ],
                )
              : errorMessage != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.no_photography_outlined,
                      size: 65,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 15),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: initializeCamera,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                    if (!kIsWeb)
                      TextButton(
                        onPressed: openAppSettings,
                        child: const Text('Buka Pengaturan Izin'),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Posisikan objek di depan kamera',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (controller != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: controller!.value.aspectRatio,
                          child: CameraPreview(controller!),
                        ),
                      ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: takingPhoto ? null : takePhoto,
                        icon: takingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt),
                        label: Text(
                          takingPhoto ? 'Memproses Foto...' : 'Ambil Foto',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
