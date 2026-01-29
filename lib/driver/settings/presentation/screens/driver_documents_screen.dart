import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komiut/core/widgets/buttons/app_button.dart';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  // Mock data for documents
  final List<DocumentItem> _documents = [
    DocumentItem(
      id: '1',
      title: 'Driving License',
      status: DocumentStatus.expiring,
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      description: 'Class BCE',
    ),
    DocumentItem(
      id: '2',
      title: 'PSV Badge',
      status: DocumentStatus.valid,
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      description: 'NTSA Badge',
    ),
    DocumentItem(
      id: '3',
      title: 'Good Conduct',
      status: DocumentStatus.expired,
      expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Police Clearance',
    ),
    DocumentItem(
      id: '4',
      title: 'National ID',
      status: DocumentStatus.valid,
      expiryDate: null, // ID doesn't expire typically in this context
      description: 'Front & Back',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: _documents.map((doc) => _buildDocumentCard(doc, theme)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadOptions,
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload New'),
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Document', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildUploadOption(
              icon: Icons.camera_alt_rounded,
              title: 'Take Photo',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _buildUploadOption(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: AppTextStyles.body1),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null && mounted) {
        _showDocumentDetailsDialog(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showDocumentDetailsDialog(XFile image) {
    final titleController = TextEditingController();
    DateTime? selectedDate;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Document Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  hintText: 'e.g. Insurance Certificate',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    selectedDate != null 
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Select Date',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            AppButton.text(
              onPressed: () => Navigator.pop(context),
              label: 'Cancel',
            ),
            AppButton.primary(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  _uploadDocument(titleController.text, selectedDate!);
                  Navigator.pop(context);
                }
              },
              label: 'Upload',
              size: ButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  void _uploadDocument(String title, DateTime expiry) {
    // Simulate upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Uploading document...'),
        duration: Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _documents.insert(0, DocumentItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            description: 'Uploaded just now',
            status: DocumentStatus.pending,
            expiryDate: expiry,
          ));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully! pending review.')),
        );
      }
    });
  }

  Widget _buildDocumentCard(DocumentItem doc, ThemeData theme) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (doc.status) {
      case DocumentStatus.valid:
        statusColor = AppColors.success;
        statusText = 'Verified';
        statusIcon = Icons.check_circle_rounded;
        break;
      case DocumentStatus.expiring:
        statusColor = AppColors.warning;
        statusText = 'Expiring Soon';
        statusIcon = Icons.access_time_filled_rounded;
        break;
      case DocumentStatus.expired:
        statusColor = theme.colorScheme.error;
        statusText = 'Expired';
        statusIcon = Icons.error_rounded;
        break;
      case DocumentStatus.pending:
        statusColor = theme.colorScheme.primary;
        statusText = 'Pending Review';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case DocumentStatus.missing:
        statusColor = theme.colorScheme.onSurfaceVariant;
        statusText = 'Missing';
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: AppTextStyles.heading4.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.description,
                      style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTextStyles.overline.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (doc.expiryDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRY DATE',
                      style: AppTextStyles.overline.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(doc.expiryDate!),
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: doc.status == DocumentStatus.expired || doc.status == DocumentStatus.expiring
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                )
              else
                const Text(''),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum DocumentStatus {
  valid,
  expiring,
  expired,
  pending,
  missing,
}

class DocumentItem {
  final String id;
  final String title;
  final String description;
  final DocumentStatus status;
  final DateTime? expiryDate;

  DocumentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.expiryDate,
  });
}
