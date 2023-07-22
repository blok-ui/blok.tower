package blok.tower.content;

import blok.ui.Child;

class ContentFactory {
  final factories:Map<String, (
    content:Content,
    create:(content:Content)->Child
  )->Child>;
  
  public function new(factories) {
    this.factories = factories;
  }

  public function has(content:Content) {
    return factories.exists(content.type);
  }

  public function create(content:Content, create:(content:Content)->Child) {
    var factory = factories.get(content.type);
    if (factory == null) {
      throw 'No factory found for ${content.type}';
    }
    return factory(content, create);
  }
}
