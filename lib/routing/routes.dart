enum MaryAppRoutes {
  root('/', 'root'),
  home('/home', 'home'),
  voiceChat('voice-chat', 'voice-chat'),
  chat('text-chat', 'text-chat');

  final String path;
  final String name;

  const MaryAppRoutes(this.path, this.name);
}
