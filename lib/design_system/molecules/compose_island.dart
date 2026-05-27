import 'package:flutter/material.dart';

import '../atoms/kai_button.dart';
import '../atoms/kai_button_send.dart';
import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Lifecycle of the compose island.
///
/// - [idle] — default; send button is disabled when the field is empty and
///   ready when it has text.
/// - [recording] — user is dictating via mic; field may still hold text, in
///   which case send remains active.
/// - [sending] — request in flight; send button shows pulsing tide.
/// - [streaming] — response streaming in; send button keeps pulsing.
/// - [disabled] — compose is blocked (offline or rate-limited); send is always disabled.
enum ComposeState { idle, recording, sending, streaming, disabled }

/// Layout variant of the compose island.
///
/// - [pill] — bottom-of-chat pill, surface bg + 1px line border, radius 999.
///   Padding `5/5/5/16`, button size 30, gap 4. HTML canon: `room.html .compose-island`.
/// - [sheet] — compose-sheet inside frame04, surface-2 bg, radius 24.
///   Padding `6/6/6/16`, button size 32, gap 6. HTML canon: `room.html .compose-row`.
enum ComposeIslandVariant { pill, sheet }

/// Pill-shaped composer used at the bottom of every conversation surface.
///
/// Layout matches `new-design/components.html § compose-sheet`:
///
/// ```
/// ┌──────────────────────────────────────────────────────────┐
/// │  [mic]  text field…                              [send]  │
/// └──────────────────────────────────────────────────────────┘
/// ```
///
/// The outer container is a surface-2 pill; the mic and send buttons hug the
/// pill's left/right edges with matching radii so they never overflow.
///
/// `ListenableBuilder` listens to the [controller] so the send button reacts
/// to typing without forcing the caller to rebuild.
class ComposeIsland extends StatelessWidget {
  const ComposeIsland({
    required this.controller,
    required this.onSend,
    this.onMicToggle,
    this.state = ComposeState.idle,
    this.placeholder = 'Сообщение Kai…',
    this.showMic = true,
    this.variant = ComposeIslandVariant.pill,
    super.key,
  });

  /// Buffer for the user's draft message.
  final TextEditingController controller;

  /// Fires when the send button is tapped in a ready state.
  final VoidCallback onSend;

  /// Optional mic toggle. When null, the mic button is omitted entirely.
  final VoidCallback? onMicToggle;

  /// Compose lifecycle state. Drives the send-button derivation.
  final ComposeState state;

  /// Placeholder shown when [controller.text] is empty.
  final String placeholder;

  /// Whether to render the mic affordance on the left side.
  final bool showMic;

  /// Layout variant. [ComposeIslandVariant.pill] (default) — bottom-of-chat pill.
  /// [ComposeIslandVariant.sheet] — full-width compose row inside a sheet.
  final ComposeIslandVariant variant;

  /// Maps [state] + current text to the send-button lifecycle state.
  KaiSendState _sendStateFrom(String text) {
    final hasText = text.isNotEmpty;
    switch (state) {
      case ComposeState.idle:
        return hasText ? KaiSendState.ready : KaiSendState.disabled;
      case ComposeState.recording:
        return hasText ? KaiSendState.ready : KaiSendState.disabled;
      case ComposeState.sending:
        return KaiSendState.sending;
      case ComposeState.streaming:
        return KaiSendState.streaming;
      case ComposeState.disabled:
        return KaiSendState.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;

    // Canon sizes from room.html:
    // pill → .mic/.send 30×30, padding 5/5/5/16, gap 4
    // sheet → .send 32×32, padding 6/6/6/16, gap 6
    final isPill = variant == ComposeIslandVariant.pill;
    final buttonSize = isPill ? 30.0 : 32.0;
    final sendIconSize = isPill ? 12.0 : 16.0;
    final gap = isPill ? 4.0 : 6.0;
    final padding = isPill
        ? const EdgeInsets.fromLTRB(16, 5, 5, 5)
        : const EdgeInsets.fromLTRB(16, 6, 6, 6);

    // Decoration: pill → surface + 1px line border + brPill.
    //             sheet → surface-2 + radius 24 (no border).
    final decoration = isPill
        ? BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.line, width: 1),
            borderRadius: KaiRadius.brPill,
          )
        : BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(24),
          );

    // sheet aligns children to bottom (textarea grows up), pill centers.
    final crossAxis =
        isPill ? CrossAxisAlignment.center : CrossAxisAlignment.end;

    return Container(
      decoration: decoration,
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxis,
        children: [
          if (showMic && onMicToggle != null) ...[
            _MicSlot(
              onTap: onMicToggle!,
              active: state == ComposeState.recording,
              size: buttonSize,
            ),
            SizedBox(width: gap),
          ],
          Expanded(
            child: _ComposeField(
              controller: controller,
              placeholder: placeholder,
            ),
          ),
          SizedBox(width: gap),
          ListenableBuilder(
            listenable: controller,
            builder: (_, __) {
              final sendState = _sendStateFrom(controller.text);
              // Defensive double-gate: KaiButtonSend already ignores taps
              // outside [KaiSendState.ready], but we also drop the callback
              // at the molecule level so the intent ("disabled means no
              // send") is explicit and the inner GestureDetector won't even
              // attach a handler.
              return KaiButtonSend(
                state: sendState,
                onPressed: sendState == KaiSendState.disabled ? null : onSend,
                size: buttonSize,
                iconSize: sendIconSize,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Internal mic affordance — transparent icon (ink-3) when idle, accent-wash
/// pill when [active] (i.e. recording).
///
/// HTML canon: `room.html .compose-island .mic { background: transparent; color: var(--ink-3); }`
/// Active (recording) mode wraps in accent-wash pill so the live state is visible.
class _MicSlot extends StatelessWidget {
  const _MicSlot({
    required this.onTap,
    required this.active,
    required this.size,
  });

  final VoidCallback onTap;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    // iconTransparent: no surface-2 pill background — just the ink-3 icon.
    // Active state: wrap in accent-wash pill to signal recording is live.
    final child = KaiButton.iconTransparent(
      onPressed: onTap,
      icon: KaiIconName.mic,
      size: 14,
      key: const ValueKey<String>('compose_mic_button'),
    );
    if (!active) return SizedBox(height: size, child: child);
    return SizedBox(
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: c.accentWash,
          borderRadius: KaiRadius.brPill,
        ),
        child: child,
      ),
    );
  }
}

/// Inline text input wired to the compose pill. Uses bare [TextField] so the
/// pill radius lives on the outer container (the atom-level [KaiTextField]
/// has its own surface bg + radius which would double up here).
class _ComposeField extends StatelessWidget {
  const _ComposeField({
    required this.controller,
    required this.placeholder,
  });

  final TextEditingController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    // Canon: room.html `.compose-island input { font: 400 13.5px var(--font-sans);
    //   color: var(--ink-1); letter-spacing: -0.005em; }`
    // Canon placeholder: `color: var(--ink-4)`.
    final inputStyle = TextStyle(
      fontFamily: 'Manrope',
      fontSize: 13.5,
      fontWeight: FontWeight.w400,
      color: c.ink1,
      letterSpacing: -0.005 * 13.5,
    );
    final placeholderStyle = inputStyle.copyWith(color: c.ink4);

    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      style: inputStyle,
      cursorColor: c.accent,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        // Canon: HTML input has no internal padding — outer pill handles spacing.
        // isDense suppresses Material's default padding injection.
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintText: placeholder,
        hintStyle: placeholderStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
