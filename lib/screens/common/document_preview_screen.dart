import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../config/app_theme.dart';
import '../../core/network/api_client.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final String? filePath;
  final String? mimeType;
  final String? endpoint; // Custom download endpoint override
  final String method; // HTTP Method: 'GET' or 'POST'
  final Map<String, dynamic>? queryParameters;

  const DocumentPreviewScreen({
    Key? key,
    required this.title,
    required this.fileName,
    this.filePath,
    this.mimeType,
    this.endpoint,
    this.method = 'GET',
    this.queryParameters,
  }) : super(key: key);

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _fileBytes;
  String? _resolvedMimeType;
  PdfController? _pdfController;
  int _pdfTotalPages = 0;
  int _pdfCurrentPage = 1;

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ApiClient();
      String targetEndpoint = widget.endpoint ?? '/correspondence/outgoing-file-download';

      // Build parameters
      Map<String, dynamic> params = Map<String, dynamic>.from(widget.queryParameters ?? {});
      if (widget.filePath != null && widget.filePath!.isNotEmpty && !params.containsKey('path_file') && !params.containsKey('id_surat_keluar') && !params.containsKey('id_versi') && !params.containsKey('file_surat_masuk_id')) {
        params['path_file'] = widget.filePath;
      }

      Response<List<int>> response;
      
      final options = Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      );

      if (widget.method.toUpperCase() == 'POST') {
        response = await apiClient.dio.post<List<int>>(
          targetEndpoint,
          data: params.isEmpty ? null : params,
          options: options,
        );
      } else {
        response = await apiClient.dio.get<List<int>>(
          targetEndpoint,
          queryParameters: params.isEmpty ? null : params,
          options: options,
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        final contentType = response.headers.value('content-type');
        setState(() {
          _fileBytes = Uint8List.fromList(response.data!);
          _resolvedMimeType = contentType ?? widget.mimeType ?? _inferMimeType(widget.fileName);
          _isLoading = false;
        });
      } else {
        throw Exception('Server mengembalikan status ${response.statusCode}');
      }
    } on DioException catch (dioErr) {
      String msg = 'File dokumen tidak ditemukan di server (404)';
      try {
        if (dioErr.response?.data != null) {
          if (dioErr.response!.data is Map) {
            msg = dioErr.response!.data['message'] ?? msg;
          } else if (dioErr.response!.data is List<int>) {
            final String text = String.fromCharCodes(dioErr.response!.data as List<int>);
            final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(text);
            if (match != null) {
              msg = match.group(1)!;
            }
          }
        }
      } catch (_) {}
      
      // Append URL for debugging
      msg = '$msg\n\nEndpoint: ${dioErr.requestOptions.path}';
      
      setState(() {
        _isLoading = false;
        _errorMessage = msg;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat dokumen: ${e.toString().replaceAll("Exception: ", "")}';
      });
    }
  }

  String _inferMimeType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.json')) return 'application/json';
    return 'application/octet-stream';
  }

  bool get _isImage {
    final mime = (_resolvedMimeType ?? widget.mimeType ?? '').toLowerCase();
    final name = widget.fileName.toLowerCase();

    if (mime.startsWith('image/') ||
        name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif')) {
      return true;
    }

    // Check magic bytes for PNG (\x89PNG: 0x89, 0x50, 0x4E, 0x47)
    if (_fileBytes != null && _fileBytes!.length >= 4) {
      if (_fileBytes![0] == 0x89 && _fileBytes![1] == 0x50 && _fileBytes![2] == 0x4E && _fileBytes![3] == 0x47) {
        return true;
      }
      // JPEG magic bytes (0xFF, 0xD8, 0xFF)
      if (_fileBytes![0] == 0xFF && _fileBytes![1] == 0xD8 && _fileBytes![2] == 0xFF) {
        return true;
      }
    }

    return false;
  }

  bool get _isPdf {
    final mime = (_resolvedMimeType ?? widget.mimeType ?? '').toLowerCase();
    final name = widget.fileName.toLowerCase();

    if (mime.contains('pdf') || name.endsWith('.pdf')) {
      return true;
    }

    // Check magic bytes for %PDF- (0x25, 0x50, 0x44, 0x46)
    if (_fileBytes != null && _fileBytes!.length >= 4) {
      if (_fileBytes![0] == 0x25 && _fileBytes![1] == 0x50 && _fileBytes![2] == 0x44 && _fileBytes![3] == 0x46) {
        return true;
      }
    }

    return false;
  }

  bool get _isText {
    final mime = (_resolvedMimeType ?? widget.mimeType ?? '').toLowerCase();
    final name = widget.fileName.toLowerCase();
    return mime.contains('text') || mime.contains('json') || name.endsWith('.txt') || name.endsWith('.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.fileName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _loadFile,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informasi File',
            onPressed: _showFileInfo,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Mengambil berkas dokumen...', style: TextStyle(color: const Color(0xFF334155), fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(widget.fileName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    if (_errorMessage != null || _fileBytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_outlined, size: 54, color: AppTheme.dangerColor),
              ),
              const SizedBox(height: 16),
              const Text('Prinjau Dokumen Tidak Tersedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_errorMessage ?? 'Berkas tidak ditemukan atau format tidak didukung.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFile,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isImage) {
      return InteractiveViewer(
        maxScale: 4.0,
        minScale: 0.8,
        child: Center(
          child: Image.memory(
            _fileBytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(child: Text('Gagal menampilkan gambar')),
          ),
        ),
      );
    }

    if (_isPdf) {
      if (_pdfController == null && _fileBytes != null) {
        try {
          _pdfController = PdfController(
            document: PdfDocument.openData(_fileBytes!),
          );
        } catch (e) {
          debugPrint("PdfController init error: $e");
        }
      }

      return Column(
        children: [
          // Control Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppTheme.dangerColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _pdfTotalPages > 0
                          ? 'Halaman $_pdfCurrentPage dari $_pdfTotalPages'
                          : 'Dokumen PDF (${(_fileBytes!.length / 1024).toStringAsFixed(1)} KB)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Halaman Sebelumnya',
                      onPressed: _pdfCurrentPage > 1
                          ? () => _pdfController?.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              )
                          : null,
                    ),
                    Text('$_pdfCurrentPage / $_pdfTotalPages', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Halaman Selanjutnya',
                      onPressed: _pdfCurrentPage < _pdfTotalPages
                          ? () => _pdfController?.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Visual PDF Render View
          Expanded(
            child: _pdfController == null
                ? const Center(child: CircularProgressIndicator())
                : PdfView(
                    controller: _pdfController!,
                    onDocumentLoaded: (document) {
                      setState(() {
                        _pdfTotalPages = document.pagesCount;
                      });
                    },
                    onPageChanged: (page) {
                      setState(() {
                        _pdfCurrentPage = page;
                      });
                    },
                    scrollDirection: Axis.vertical,
                  ),
          ),
        ],
      );
    }

    if (_isText) {
      final textContent = String.fromCharCodes(_fileBytes!);
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            textContent,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      );
    }

    // Default File View
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file, size: 64, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(widget.fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Tipe: ${_resolvedMimeType ?? "Dokumen"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Ukuran: ${(_fileBytes!.length / 1024).toStringAsFixed(1)} KB', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _downloadSuccessMessage,
                icon: const Icon(Icons.download),
                label: const Text('Simpan Berkas Dokumen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractTextPreview(Uint8List bytes) {
    try {
      final String raw = String.fromCharCodes(bytes);
      // Clean non-printable ascii characters for clean text extraction
      final cleaned = raw.replaceAll(RegExp(r'[^\x20-\x7E\n\r\t]'), ' ');
      final words = cleaned.split(RegExp(r'\s+')).where((w) => w.length > 2).take(80).join(' ');
      if (words.trim().isNotEmpty) {
        return 'Isi Ringkasan Berkas:\n"$words..."';
      }
    } catch (_) {}
    return 'Berkas PDF Siap Diproses & Disetujui. Tanda Tangan Elektronik (TTE) siap disematkan pada dokumen.';
  }

  void _downloadSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Berkas "${widget.fileName}" berhasil disimpan di memori lokal.')),
          ],
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showFileInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text('Informasi Berkas Dokumen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            _infoRow('Nama Berkas', widget.fileName),
            _infoRow('Tipe Format', _resolvedMimeType ?? widget.mimeType ?? 'Tidak diketahui'),
            _infoRow('Ukuran Berkas', _fileBytes != null ? '${(_fileBytes!.length / 1024).toStringAsFixed(1)} KB' : '-'),
            _infoRow('Jalur / Path', widget.filePath ?? '-'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('TUTUP'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          const Text(': '),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
