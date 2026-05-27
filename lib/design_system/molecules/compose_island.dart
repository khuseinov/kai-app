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
    const buttonSize = 32.0;

    return Container(
      // Pill container. Padding 6×8 keeps mic + send hug-edge with the
      // outer radius (999) — radii match, no overflow.
      // Canon: room.html elevated compose-island uses --surface (pure
      // white) + 1px --line border. Pure #FFFFFF is reserved for elevated
      // content like this island (see new-design/CLAUDE.md § Color).
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line, width: 1),
        borderRadius: KaiRadius.brPill,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: KaiSpace.s1 + 2, // 6
        horizontal: KaiSpace.s2, // 8
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showMic && onMicToggle != null) ...[
            _MicSlot(
              onTap: onMicToggle!,
              active: state == ComposeState.recording,
              size: buttonSize,
            ),
            const SizedBox(width: KaiSpace.s2),
          ],
          Expanded(
            child: _ComposeField(
              controller: controller,
              placeholder: placeholder,
            ),
          ),
          const SizedBox(width: KaiSpace.s2),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Internal mic affordance — uses [KaiButton.icon] when idle and an
/// accent-washed variant when [active] (i.e. recording).
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
    // When active, paint a tide-tinted pill so it reads "live" without
    // needing a separate atom. The base KaiButton.icon already renders a
    // pill — we wrap it in a Container only when recording.
    final child = KaiButton.icon(
      onPressed: onTap,
      icon: KaiIconName.mic,
      size: 18,
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
    final bodyStyle = KaiType.body(color: c.ink1);
    final placeholderStyle = KaiType.body(color: c.ink4);

    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      style: bodyStyle,
      cursorColor: c.accent,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KaiSpace.s2,
          vertical: KaiSpace.s2,
        ),
        hintText: placeholder,
        hintStyle: placeholderStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
