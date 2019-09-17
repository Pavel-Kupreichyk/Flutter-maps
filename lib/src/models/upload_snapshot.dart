enum UploadState { progress, pause, failure, success }

class UploadSnapshot {
  final int totalBytes;
  final int transferredBytes;
  final String name;
  final UploadState state;

  UploadSnapshot(this.name, this.state, this.totalBytes, this.transferredBytes);
}
