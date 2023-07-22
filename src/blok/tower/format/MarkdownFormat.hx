package blok.tower.format;

using Markdown;
using Reflect;
using StringTools;
using blok.tower.content.ContentGenerator;

typedef MarkdownContent = {
  excerpt:Dynamic,
  content:Dynamic
};

class MarkdownFormat<T:MarkdownContent> implements Format<T> {
  final format:Format<T>;
  final sep:String = '---';

  public function new(format) {
    this.format = format;
  }

  public function parse(content:String):Task<T> {
    return new Task(activate -> {
      if (content.startsWith(sep)) {
        var raw = content.substr(sep.length);
        var index = raw.indexOf(sep);
        var matter = raw.substring(0, index);
        var content = raw.substring(index + sep.length);
        var excerpt = if (content.length > 200) 
          content.substring(0, 200) + '...'
        else
          content;
        
        format.parse(matter).handle(res -> switch res {
          case Error(error): 
            activate(Error(error));
          case Ok(data):
            data.setField('excerpt', excerpt.markdownToHtml().toContent().toJson());
            data.setField('content', content.markdownToHtml().toContent().toJson());
            activate(Ok(data));
        });
      } else {
        activate(Error(new Error(InternalError, 'Could not parse data')));
      }
    });
  }
}
