import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int _sampleRate = 22050;

void _writeWav(String path, List<double> samples) {
  final numSamples = samples.length;
  final dataSize = numSamples * 2; // 16-bit mono
  final bytes = ByteData(44 + dataSize);

  void writeAscii(int offset, String value) {
    for (int i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  writeAscii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little); // PCM header size
  bytes.setUint16(20, 1, Endian.little); // PCM format
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, _sampleRate, Endian.little);
  bytes.setUint32(28, _sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  writeAscii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);

  for (int i = 0; i < numSamples; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    final intVal = (clamped * 32767).round();
    bytes.setInt16(44 + i * 2, intVal, Endian.little);
  }

  File(path).writeAsBytesSync(bytes.buffer.asUint8List());
}

List<double> _generatePop() {
  const duration = 0.14;
  final count = (_sampleRate * duration).round();
  final samples = List<double>.filled(count, 0.0);
  double phase = 0.0;
  for (int i = 0; i < count; i++) {
    final t = i / _sampleRate;
    final progress = i / count;
    final freq = 420.0 + 520.0 * math.pow(progress, 0.6);
    phase += 2 * math.pi * freq / _sampleRate;
    final env = math.sin(math.pi * progress) * math.exp(-t * 14.0);
    samples[i] = math.sin(phase) * env * 0.75;
  }
  return samples;
}

List<double> _generateSparkle() {
  const duration = 0.42;
  final count = (_sampleRate * duration).round();
  final samples = List<double>.filled(count, 0.0);
  const notes = [880.0, 1108.73, 1318.51, 1760.0];
  for (int n = 0; n < notes.length; n++) {
    final startIdx = (n * 0.075 * _sampleRate).round();
    final freq = notes[n];
    for (int i = startIdx; i < count; i++) {
      final localT = (i - startIdx) / _sampleRate;
      final env = math.exp(-localT * 11.0);
      final s = (math.sin(2 * math.pi * freq * localT) +
              0.35 * math.sin(2 * math.pi * freq * 2 * localT)) *
          env *
          0.32;
      samples[i] += s;
    }
  }
  return samples;
}

List<double> _generateThemeSwitch() {
  const duration = 0.28;
  final count = (_sampleRate * duration).round();
  final samples = List<double>.filled(count, 0.0);
  const notes = [523.25, 659.25, 783.99];
  for (int n = 0; n < notes.length; n++) {
    final startIdx = (n * 0.06 * _sampleRate).round();
    final freq = notes[n];
    for (int i = startIdx; i < count; i++) {
      final localT = (i - startIdx) / _sampleRate;
      final env = math.exp(-localT * 12.0);
      samples[i] += math.sin(2 * math.pi * freq * localT) * env * 0.35;
    }
  }
  return samples;
}

List<double> _generateErase() {
  const duration = 0.16;
  final count = (_sampleRate * duration).round();
  final samples = List<double>.filled(count, 0.0);
  double phase = 0.0;
  for (int i = 0; i < count; i++) {
    final progress = i / count;
    final freq = 520.0 - 260.0 * progress;
    phase += 2 * math.pi * freq / _sampleRate;
    final env = (1.0 - progress) * math.sin(math.pi * progress);
    samples[i] = math.sin(phase) * env * 0.65;
  }
  return samples;
}

void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  _writeWav('${outDir.path}/pop.wav', _generatePop());
  _writeWav('${outDir.path}/sparkle.wav', _generateSparkle());
  _writeWav('${outDir.path}/theme_switch.wav', _generateThemeSwitch());
  _writeWav('${outDir.path}/erase.wav', _generateErase());
  stdout.writeln('Generated 4 PCM 16-bit WAV files in assets/audio/');
}
