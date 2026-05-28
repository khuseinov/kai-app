import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../atoms/atoms.dart';
import '../primitives/primitives.dart';

/// v3 compose island — the pill-shaped chat input bar.
///
/// Ports v2 `ComposeIsland` (pill variant only; the dead `.sheet` variant
/// was dropped per the design-system audit).
///
/// Layout (canon: `new-design/room.html .compose-island`):
/// ```
/// ┌──────────────────────────────────────────────────────────┐
/// │  text field…                             [mic]  [send]  │
/// └──────────────────────────────────────────────────────────┘
/// ```
///
/// - Outer pill: `surface` bg + 1px `line` border + `KaiRadius.brPill`.
///   Padding: 5/5/5/16 (canon).
/// - [KaiInput.pill] for the text field — its own border/fill is suppressed
///   to avoid double-bordering; we pass a `_NoBorderInput` wrapper instead.
/// - [KaiIconButton.transparent] for mic (ink3, 30×30 effective tap target).
/// - [KaiSendButton] for send — 30×30, icon 12.
///
/// **Send state derivation** (matches v2 logic):
/// - Caller can pass [KaiSendState.sending] / [KaiSendState.streaming] to lock
///   the animated states explicitly.
/// - Otherwise: `ready` when controller has text, `disabled` when empty.
///
/// This widget is purely presentational — it owns no Riverpod or state logic.
class KaiComposeIsland extends StatelessWidget {
  const KaiComposeIsland({
    required this.controller,
    required this.onSend,
    this.onMicTap,
    this.sendState = KaiSendState.ready,
    this.placeholder = 'Сообщение Kai…',
    super.key,
  });

  /// Buffer for the user's draft message.
  final TextEditingController controller;

  /// Fires when the send button is tapped in a [KaiSendState.ready] state.
  final VoidCallback onSend;

  /// Optional mic tap callback. When null, the mic button is omitted.
  final VoidCallback? onMicTap;

  /// Explicit send state. When [KaiSendState.sending] or
  /// [KaiSendState.streaming], those states are shown regardless of text
  /// content. Otherwise the effective state is derived from whether the
  /// controller has text.
  final KaiSendState sendState;

  /// Placeholder shown when [controller.text] is empty.
  final String placeholder;

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Derives the effective [KaiSendState] from caller intent + controller text.
  KaiSendState _effectiveSendState(String text) {
    // Animated/locked states are passed through unchanged.
    if (sendState == KaiSendState.sending ||
        sendState == KaiSendState.streaming) {
      return sendState;
    }
    return text.isNotEmpty ? KaiSendState.ready : KaiSendState.disabled;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    // Canon: room.html .compose-island — padding 5/5/5/16, gap 4.
    const paddingLeft = 16.0; // canon: s4
    const paddingVH = 5.0; // canon: vertical + right inset
    const gap = 4.0; // canon: gap between children
    const buttonSize = 30.0; // canon: mic/send 30×30
    const sendIconSize = 12.0; // canon: arrow-up glyph inside send

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: KaiRadius.brPill,
      ),
      padding: const EdgeInsets.fromLTRB(
        paddingLeft,
        paddingVH,
        paddingVH,
        paddingVH,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expanded text field — bare TextField (no internal fill/border) to
          // avoid double-pill styling; the outer Container is the visual pill.
          Expanded(
            child: _ComposeField(
              controller: controller,
              placeholder: placeholder,
            ),
          ),
          // Mic affordance — only rendered when a callback is wired.
          if (onMicTap != null) ...[
            const SizedBox(width: gap),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: KaiIconButton.transparent(
                onPressed: onMicTap,
                icon: KaiIconName.mic,
                size: 14, // canon: mic glyph 14px inside 30×30 tap target
                key: const ValueKey<String>('compose_mic_button'),
              ),
            ),
          ],
          const SizedBox(width: gap),
          // Send button — rebuilt when controller text changes.
          ListenableBuilder(
            listenable: controller,
            builder: (_, __) {
              final effective = _effectiveSendState(controller.text);
              return KaiSendButton(
                state: effective,
                onPressed: effective == KaiSendState.disabled ? null : onSend,
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

// ---------------------------------------------------------------------------
// Internal: bare text field (no fill/border — outer pill is the chrome)
// ---------------------------------------------------------------------------

/// Bare [TextField] for the compose pill.
///
/// Intentionally does NOT use [KaiInput] directly because [KaiInput.pill]
/// renders its own surface-2 fill + outline border, which would create a
/// double-pill visual inside our outer Container. Instead we use a plain
/// [TextField] with no decoration chrome, matching the v2 `_ComposeField`
/// approach.
///
/// Canon styles from `room.html .compose-island input`:
/// ```css
/// font: 400 13.5px Manrope; color: var(--ink-1); letter-spacing: -0.005em
/// ```
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

    // canon: room.html `.compose-island input { font: 400 13.5px Manrope; }`
    const fontSize = 13.5; // canon: literal compose-island font size
    final inputStyle = TextStyle(
      fontFamily: 'Manrope',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: c.ink1,
      letterSpacing: fontSize * -0.005, // canon: -0.005em
    );
    final hintStyle = inputStyle.copyWith(color: c.ink4);

    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      style: inputStyle,
      cursorColor: c.accent,
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
