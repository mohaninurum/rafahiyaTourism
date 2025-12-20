
class Document {
  final String id;
  final String userId;
  final String name;
  final Map<String, dynamic> documents;
  final List<String> uploadedFiles;
  final String uploadDate;
  final String? dob;
  final String? issuingCountry;
  final String? packageId;
  final String? packageName;

  Document({
    required this.id,
    required this.userId,
    required this.name,
    required this.documents,
    required this.uploadedFiles,
    required this.uploadDate,
    this.dob,
    this.issuingCountry,
    this.packageId,
    this.packageName,
  });

  factory Document.fromFirestore(Map<String, dynamic> data, String id) {
    return Document(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      documents: data['documents'] != null
          ? Map<String, dynamic>.from(data['documents'])
          : {},
      uploadedFiles: data['uploadedFiles'] != null
          ? List<String>.from(data['uploadedFiles'])
          : [],
      uploadDate: data['uploadDate'] ?? '',
      dob: data['dob'],
      issuingCountry: data['issuingCountry'],
      packageId: data['packageId'],
      packageName: data['packageName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'documents': documents,
      'uploadedFiles': uploadedFiles,
      'uploadDate': uploadDate,
      'dob': dob,
      'issuingCountry': issuingCountry,
      'packageId': packageId,
      'packageName': packageName,
    };
  }

  Document copyWith({
    String? id,
    String? userId,
    String? name,
    Map<String, dynamic>? documents,
    List<String>? uploadedFiles,
    String? uploadDate,
    String? dob,
    String? issuingCountry,
    String? packageId,
    String? packageName,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      documents: documents ?? this.documents,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      uploadDate: uploadDate ?? this.uploadDate,
      dob: dob ?? this.dob,
      issuingCountry: issuingCountry ?? this.issuingCountry,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
    );
  }

  // Helper methods to manage individual documents
  bool hasDocumentType(String documentType) {
    return documents.containsKey(documentType);
  }

  Map<String, dynamic>? getDocumentData(String documentType) {
    return documents[documentType];
  }

  void addDocumentData(String documentType, Map<String, dynamic> data, String fileUrl) {
    documents[documentType] = data;
    if (!uploadedFiles.contains(fileUrl)) {
      uploadedFiles.add(fileUrl);
    }
  }

  void removeDocumentData(String documentType) {
    documents.remove(documentType);
  }
}