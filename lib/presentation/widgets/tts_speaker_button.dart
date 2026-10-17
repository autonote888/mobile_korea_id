import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/audio_tts_service.dart';

/// Interactive TTS Speaker Button with animated sound waves when audio is active.
class TtsSpeakerButton extends StatefulWidget {
  final String text;
  final bool isKorean;
  final double size;
  final Color? color;
  final Color? activeColor;
  final String? tooltip;

  const TtsSpeakerButton({
    super.key,
    required this.text,
    this.isKorean = true,
    this.size = 20,
    this.color,
    this.activeColor,
    this.tooltip,
  });

  @override
  State<TtsSpeakerButton> createState() => _TtsSpeakerButtonState();
}

class _TtsSpeakerButtonState extends State<TtsSpeakerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    AudioTtsService.instance.addListener(_onTtsStateChanged);
  }

  void _onTtsStateChanged() {
    final tts = AudioTtsService.instance;
    final isCurrentPlaying = tts.isSpeaking && tts.currentText == widget.text;
    if (isCurrentPlaying && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!isCurrentPlaying && _animController.isAnimating) {
      _animController.stop();
      _animController.reset();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AudioTtsService.instance.removeListener(_onTtsStateChanged);
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isKorean) {
      AudioTtsService.instance.speakKorean(widget.text);
    } else {
      AudioTtsService.instance.speakEnglish(widget.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tts = AudioTtsService.instance;
    final isCurrentPlaying = tts.isSpeaking && tts.currentText == widget.text;
    final primaryColor = widget.activeColor ?? AppTheme.primaryIndigo;
    final normalColor = widget.color ?? (Theme.of(context).brightness == Brightness.dark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight);

    return Tooltip(
      message: widget.tooltip ?? (widget.isKorean ? 'Dengarkan Pengucapan (ko-KR)' : 'Listen Pronunciation (en-US)'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          splashColor: primaryColor.withValues(alpha: 0.15),
          highlightColor: primaryColor.withValues(alpha: 0.08),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = isCurrentPlaying ? _scaleAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrentPlaying
                        ? primaryColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    border: isCurrentPlaying
                        ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5)
                        : null,
                  ),
                  child: Icon(
                    isCurrentPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                    size: widget.size,
                    color: isCurrentPlaying ? primaryColor : normalColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
