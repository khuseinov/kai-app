import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/room/presentation/widgets/kai_send_button.dart';

// ---------------------------------------------------------------------------
// KaiComposeIsland
// ---------------------------------------------------------------------------

/// v3 compose island — the pill-shaped chat input bar.
///
/// Composable affordances — each optional button is shown iff its callback is
/// provided. This expresses both compose "variants" (full · `+`/mic/voice) as
/// call-site configuration of one widget.
///
/// Layout (Variant-1 "swap", canon `room.html .compose-island` + the
/// 2026-05-30 redesign spec):
/// ```
/// empty    │ (+)  Спросить Kai…        (voice) (mic)  │
/// typing   │ (+)  рейс в Токио|        (voice) (send) │
/// streaming│ Kai отвечает…                    (stop)  │
/// offline  │ (+)  ⚬ оффлайн — отправлю позже          │ (empty)
///          │ (+)  текст…                    (в очередь)│ (typing)
/// ```
///
/// - `voice` (voice-Kai → full voice mode) is the persistent inner-right button;
///   the far-right slot swaps `mic` (dictation, empty) ⇄ `send` (text).
/// - When [onMicTap] is null the far-right slot is always `send` (disabled when
///   empty) — the room.html canon behaviour.
/// - `streaming` ([sendState] == [KaiSendState.streaming]) collapses to
///   "Kai отвечает…" + a stop button (canon room.html frame 3).
/// - `offline` keeps the field live (O-A "calm queue"): a warning-amber dot +
///   hint, and `send` → an amber "queue" affordance. Warning token, never coral.
///
/// Pure-presentational — owns no Riverpod or state logic.
class KaiComposeIsland extends StatelessWidget {
  const KaiComposeIsland({
    required this.controller,
    required this.onSend,
    this.onAddTap,
    this.onMicTap,
    this.onVoiceTap,
    this.onStop,
    this.sendState = KaiSendState.ready,
    this.offline = false,
    this.dictating = false,
    this.onQueue,
    this.placeholder = 'Спросить Kai…',
    super.key,
  });

  final bool dictating;

  /// Buffer for the user's draft message.
  final TextEditingController controller;

  /// Fires when the send button is tapped while there is text.
  final VoidCallback onSend;

  /// "+" add/attach + travel menu. Null hides the button.
  final VoidCallback? onAddTap;

  /// Dictation (speech→text). Null hides the mic → far-right slot is always send.
  final VoidCallback? onMicTap;

  /// Enter the full voice mode (voice-Kai). Null hides the button.
  final VoidCallback? onVoiceTap;

  /// Stop the streaming response. Used when [sendState] == streaming.
  final VoidCallback? onStop;

  /// Explicit send state. [KaiSendState.streaming] collapses the pill to the
  /// "Kai отвечает…" + stop frame. Otherwise the active state is derived from
  /// text presence.
  final KaiSendState sendState;

  /// O-A offline state — field stays live, send becomes an amber queue action.
  final bool offline;

  /// Offline queue action. Defaults to [onSend] when null.
  final VoidCallback? onQueue;

  /// Placeholder shown when the field is empty.
  final String placeholder;



  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final streaming = sendState == KaiSendState.streaming;
    final switchDuration =
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
            ? Duration.zero
            : KaiMotion.standard;

    final scale = context.scale;
    final textScale = context.textScale;

    // Make compose island physically larger:
    // Base padding: left 20 (was 16), other 6.5 (was 5).
    // Base gap: 6 (was 4).
    // Base button size: 38 (was 30).
    final padLeft = 20.0 * scale;
    final padOther = 6.5 * scale;
    final gap = 6.0 * scale;
    final btnSize = 38.0 * scale;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        // canon: room.html .compose-island border = 0.8px solid line.
        border: Border.all(color: c.line, width: 0.8),
        borderRadius: KaiRadius.brPill,
      ),
      padding: EdgeInsets.fromLTRB(
        padLeft,
        padOther,
        padOther,
        padOther,
      ),
      child: AnimatedSwitcher(
        duration: switchDuration,
        child: streaming
            ? _buildStreaming(c, scale, textScale, gap, btnSize)
            : ListenableBuilder(
                key: const ValueKey<String>('compose_active'),
                listenable: controller,
                builder: (_, __) => _buildActive(c, scale, textScale, gap, btnSize),
              ),
      ),
    );
  }

  // ── Streaming: "Kai отвечает…" + stop (canon room.html frame 3) ────────────
  Widget _buildStreaming(KaiColorTokens c, double scale, double textScale, double gap, double btnSize) {
    return Row(
      key: const ValueKey<String>('compose_streaming'),
      children: [
        Expanded(
          child: Text(
            'Kai отвечает…',
            style: _fieldStyle(c, textScale).copyWith(color: c.ink4),
          ),
        ),
        SizedBox(width: gap),
        KaiSendButton(
          state: KaiSendState.streaming,
          onPressed: onStop,
          size: btnSize,
          iconSize: btnSize * 0.4,
        ),
      ],
    );
  }

  // ── Active (empty / typing / offline) ──────────────────────────────────────
  Widget _buildActive(KaiColorTokens c, double scale, double textScale, double gap, double btnSize) {
    final hasText = controller.text.isNotEmpty;
    final children = <Widget>[];

    // "+" add — leftmost, present whenever wired.
    if (onAddTap != null) {
      children
        ..add(_iconBtn(
            const ValueKey<String>('compose_add_button'),
            KaiIconName.plus,
            onAddTap!,
            c.ink3,
            btnSize,),)
        ..add(SizedBox(width: gap));
    }

    // Field, or the offline-empty hint.
    if (offline && !hasText) {
      children.add(Expanded(child: _offlineHint(c, textScale)));
    } else if (dictating) {
      children.add(Expanded(
        child: Text(
          'Слушаю вас...',
          style: _fieldStyle(c, textScale).copyWith(
            color: c.accent,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),);
    } else {
      children.add(Expanded(
        child: _ComposeField(
          controller: controller,
          placeholder: placeholder,
          style: _fieldStyle(c, textScale),
          hintStyle: _fieldStyle(c, textScale).copyWith(color: c.ink4),
          cursor: c.accent,
        ),
      ),);
    }

    // Trailing cluster.
    if (offline) {
      // O-A: queue affordance appears only with text (nothing to queue empty).
      if (hasText) {
        children
          ..add(SizedBox(width: gap))
          ..add(_iconBtn(
              const ValueKey<String>('compose_queue_button'),
              KaiIconName.clock,
              onQueue ?? onSend,
              c.warning,
              btnSize,),);
      }
    } else {
      // Persistent voice-Kai (inner), then the swap slot (mic ⇄ send).
      if (onVoiceTap != null) {
        children
          ..add(SizedBox(width: gap))
          ..add(_iconBtn(
              const ValueKey<String>('compose_voice_button'),
              KaiIconName.waveform,
              onVoiceTap!,
              c.ink3,
              btnSize,),);
      }
      children
        ..add(SizedBox(width: gap))
        ..add(_trailingSwap(hasText, btnSize));
    }

    return Row(
      key: const ValueKey<String>('compose_active_row'),
      children: children,
    );
  }

  /// Far-right slot: mic (empty) ⇄ send (text). When [onMicTap] is null the
  /// slot is always send (disabled when empty) — the room.html canon.
  Widget _trailingSwap(bool hasText, double btnSize) {
    final showSend = hasText || onMicTap == null;
    final child = showSend
        ? KaiSendButton(
            key: const ValueKey<String>('compose_send'),
            state: hasText ? KaiSendState.ready : KaiSendState.disabled,
            onPressed: hasText ? onSend : null,
            size: btnSize,
            iconSize: btnSize * 0.4,
          )
        : SizedBox(
            key: const ValueKey<String>('compose_mic_button'),
            width: btnSize,
            height: btnSize,
            child: KaiIconButton.toggle(
              active: dictating,
              onPressed: onMicTap,
              icon: KaiIconName.mic,
              iconSize: KaiIconButtonSize.md,
            ),
          );
    return AnimatedSwitcher(duration: KaiMotion.micro, child: child);
  }

  Widget _iconBtn(Key key, KaiIconName icon, VoidCallback onTap, Color color, double btnSize) {
    return SizedBox(
      key: key,
      width: btnSize,
      height: btnSize,
      child: KaiIconButton.bare(
        onPressed: onTap,
        icon: icon,
        color: color,
        size: btnSize * 0.6,
      ),
    );
  }

  Widget _offlineHint(KaiColorTokens c, double textScale) {
    return Row(
      key: const ValueKey<String>('compose_offline_hint'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning-amber dot — calm offline signal, never coral.
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: c.warning, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'оффлайн — отправлю, когда вернётся сеть',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _fieldStyle(c, textScale).copyWith(color: c.ink3),
          ),
        ),
      ],
    );
  }

  // Input font size is increased to 15.0
  TextStyle _fieldStyle(KaiColorTokens c, double textScale) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15.0 * textScale,
        fontWeight: FontWeight.w400,
        color: c.ink1,
        letterSpacing: 15.0 * textScale * -0.005,
      );
}

// ---------------------------------------------------------------------------
// Internal: bare text field (no fill/border — outer pill is the chrome)
// ---------------------------------------------------------------------------

class _ComposeField extends StatelessWidget {
  const _ComposeField({
    required this.controller,
    required this.placeholder,
    required this.style,
    required this.hintStyle,
    required this.cursor,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextStyle style;
  final TextStyle hintStyle;
  final Color cursor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      style: style,
      cursorColor: cursor,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintText: placeholder,
        hintStyle: hintStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
