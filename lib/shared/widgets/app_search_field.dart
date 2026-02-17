import 'package:flutter/material.dart';

class AppSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool useGlass;
  final TextEditingController? controller;
  final bool autofocus;
  final String? initialValue;
  final bool showClearButton;

  const AppSearchField({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onFilterTap,
    this.useGlass = false,
    this.controller,
    this.autofocus = false,
    this.initialValue,
    this.showClearButton = true,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = widget.initialValue!.isNotEmpty;
    }
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _isFocused 
              ? Colors.white
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: _isFocused
                ? const Color(0xFF1A237E)
                : const Color(0xFF1A237E).withOpacity(0.12),
            width: _isFocused ? 1.5 : 1.0,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: _isFocused ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused 
                    ? const Color(0xFF1A237E)
                    : const Color(0xFF1A237E).withOpacity(0.4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(
                  color: Color(0xFF1A237E),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: const Color(0xFF1A237E).withOpacity(0.35),
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  // This removes the underline completely
                  filled: false,
                ),
              ),
            ),
            
            if (widget.showClearButton && _hasText) ...[
              const SizedBox(width: 8),
              AnimatedScale(
                scale: _hasText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: GestureDetector(
                  onTap: _clearText,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF1A237E).withOpacity(0.5),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
            
            if (widget.onFilterTap != null) ...[
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onFilterTap,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: const Color(0xFF1A237E),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}