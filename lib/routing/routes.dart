
enum MaryAppRoutes {
  root('/', 'root'),
  login('login', 'login'),
  register('register', 'register'),
  forgotPwd('forgot-pwd', 'forgot-pwd'),
  resetPwd('reset-pwd', 'reset-pwd'),
  home('/home', 'home'),
  meldRxLogin('meldrx', 'meldrx'),
  voiceChat('voice-chat', 'voice-chat'),
  chat('text-chat', 'text-chat'),
  previousChat('previous-chat/:title/:conversation_id', 'previous-chat');

  final String path;
  final String name;

  const MaryAppRoutes(this.path, this.name);
}
