import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_store.dart';
import '../../../core/theme/app_monochrome.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/auth_api.dart';
import '../data/sessao_autenticacao.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final AuthApi _authApi = AuthApi();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _loading = false;
  bool? _apiOnline;
  bool _registerMode = false;

  late final AnimationController _intro;
  late final Animation<double> _introOpacity;
  late final Animation<Offset> _introSlide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _introOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
    );
    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));
    _intro.forward();
    _runHealthcheck();
  }

  @override
  void dispose() {
    _intro.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassBackground.seaBackdrop,
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: FadeTransition(
                opacity: _introOpacity,
                child: SlideTransition(
                  position: _introSlide,
                  child: GlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _brandMark(),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Chat VeigaGustavo',
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.6,
                                      height: 1.05,
                                      color: AppMonochrome.ink,
                                      shadows: <Shadow>[
                                        Shadow(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          blurRadius: 28,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Conversas em tempo real, com acesso seguro.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.35,
                                      fontWeight: FontWeight.w400,
                                      color: AppMonochrome.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _statusChip(),
                        const SizedBox(height: 22),
                        if (_registerMode) ...[
                          _field(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            label: 'Nome completo',
                            hint: 'Nome e apelido',
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _emailFocus.requestFocus(),
                            autofillHints: const <String>[AutofillHints.name],
                          ),
                          const SizedBox(height: 14),
                        ],
                        _field(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: 'E-mail corporativo',
                          hint: 'nome@empresa.com',
                          icon: Icons.alternate_email_rounded,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: 'Senha',
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) =>
                              _registerMode ? _register() : _login(),
                          autofillHints: const <String>[AutofillHints.password],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() {
                                      _registerMode = !_registerMode;
                                    }),
                            style: TextButton.styleFrom(
                              foregroundColor: AppMonochrome.inkMuted,
                            ),
                            child: Text(
                              _registerMode
                                  ? 'Já tenho conta — entrar'
                                  : 'Criar conta',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _primaryButton(),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppMonochrome.lineLight,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'precisa de ajuda?',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w600,
                                  color: AppMonochrome.inkSubtle.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppMonochrome.lineLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: <Widget>[
                            _linkButton(
                              label: 'Esqueci a senha',
                              onTap: _solicitarRedefinicao,
                            ),
                            Text(
                              '·',
                              style: TextStyle(
                                color: AppMonochrome.inkSubtle.withValues(alpha: 0.45),
                                fontSize: 18,
                                height: 1,
                              ),
                            ),
                            _linkButton(
                              label: 'Redefinir com token',
                              onTap: _redefinirSenha,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandMark() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const AppLogo(size: 44),
    );
  }

  Widget _statusChip() {
    final bool? online = _apiOnline;
    final Color dotColor;
    final String text;
    if (online == null) {
      dotColor = AppMonochrome.inkSubtle;
      text = 'A contactar o servidor…';
    } else if (online) {
      dotColor = AppMonochrome.white;
      text = 'Servidor disponível';
    } else {
      dotColor = AppMonochrome.inkMuted;
      text = 'Sem ligação com o servidor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppMonochrome.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppMonochrome.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      obscuringCharacter: '•',
      style: const TextStyle(
        color: AppMonochrome.ink,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppMonochrome.white,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(
          color: AppMonochrome.inkMuted,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: AppMonochrome.inkSubtle.withValues(alpha: 0.85),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            icon,
            color: AppMonochrome.inkMuted,
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppMonochrome.line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppMonochrome.white, width: 1.35),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppMonochrome.line, width: 1),
        ),
      ),
    );
  }

  Widget _primaryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loading
            ? null
            : () {
                if (_registerMode) {
                  _register();
                } else {
                  _login();
                }
              },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withValues(alpha: 0.55),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.07),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppMonochrome.white,
                    ),
                  )
                : Text(
                    _registerMode ? 'Registar' : 'Entrar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: AppMonochrome.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _linkButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _loading ? null : onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppMonochrome.white,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  Future<void> _runHealthcheck() async {
    try {
      final bool ok = await _authApi.healthcheck();
      if (!mounted) {
        return;
      }
      setState(() => _apiOnline = ok);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _apiOnline = false);
    }
  }

  void _applySession(SessaoAutenticacao sessao) {
    final SessionStore s = SessionStore.instance;
    s.tokenAcesso = sessao.tokenAcesso;
    s.esquemaAutorizacao = sessao.esquemaAutorizacao;
    s.expiraAproximadaEmSegundos = sessao.expiraAproximadaEmSegundos;
    s.nivelPapelAcesso = sessao.nivelPapelAcesso;
    s.permissoesAcessoEfetivas = sessao.permissoesAcessoEfetivas;
    s.nomeCompletoTitular = sessao.nomeCompletoTitular;
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Indica o e-mail e a palavra-passe.');
      return;
    }

    setState(() => _loading = true);
    try {
      final SessaoAutenticacao sessao = await _authApi.entrar(
        emailCorporativo: email,
        senhaAcesso: password,
      );
      _applySession(sessao);
      if (!mounted) {
        return;
      }
      context.go('/chat');
    } catch (error) {
      _showMessage(_authApi.getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _register() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Preenche o nome completo, o e-mail e a palavra-passe.');
      return;
    }

    setState(() => _loading = true);
    try {
      final SessaoAutenticacao sessao = await _authApi.registrar(
        emailCorporativo: email,
        senhaAcesso: password,
        nomeCompletoTitular: name,
        nivelPapelAcesso: 'USUARIO_CONVIDADO',
      );
      _applySession(sessao);
      if (!mounted) {
        return;
      }
      context.go('/chat');
    } catch (error) {
      _showMessage(_authApi.getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _solicitarRedefinicao() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Escreve o e-mail no campo acima primeiro.');
      return;
    }
    setState(() => _loading = true);
    try {
      await _authApi.solicitarRedefinicaoSenha(emailCorporativo: email);
      _showMessage('Se existir conta, enviámos instruções para o e-mail.');
    } catch (error) {
      _showMessage(_authApi.getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _redefinirSenha() async {
    final String? token = await _askText(
      title: 'Redefinir palavra-passe',
      hint: 'Cole o token que recebeste',
    );
    if (token == null || token.trim().isEmpty) {
      return;
    }
    final String? novaSenha = await _askText(
      title: 'Nova palavra-passe',
      hint: 'Mínimo de 6 caracteres',
      obscure: true,
    );
    if (novaSenha == null || novaSenha.trim().length < 6) {
      _showMessage('A nova palavra-passe precisa de pelo menos 6 caracteres.');
      return;
    }
    setState(() => _loading = true);
    try {
      await _authApi.redefinirSenha(
        tokenRedefinicao: token.trim(),
        novaSenhaAcesso: novaSenha.trim(),
      );
      _showMessage('Palavra-passe atualizada. Já podes entrar.');
    } catch (error) {
      _showMessage(_authApi.getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<String?> _askText({
    required String title,
    required String hint,
    bool obscure = false,
  }) async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppMonochrome.bgElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppMonochrome.line),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppMonochrome.ink,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(color: AppMonochrome.ink),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: AppMonochrome.inkSubtle.withValues(alpha: 0.65),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppMonochrome.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppMonochrome.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppMonochrome.white, width: 1.35),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: AppMonochrome.inkMuted),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(controller.text),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    return result;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppMonochrome.line),
        ),
        backgroundColor: AppMonochrome.bgElevated,
        content: Text(
          message,
          style: const TextStyle(
            color: AppMonochrome.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
