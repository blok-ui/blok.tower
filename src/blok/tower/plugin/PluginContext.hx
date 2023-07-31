package blok.tower.plugin;

import blok.tower.cli.BuildCommandFactory;

class PluginContext {
  public final onBuildClient = new Event<BuildCommandFactory>();
}
