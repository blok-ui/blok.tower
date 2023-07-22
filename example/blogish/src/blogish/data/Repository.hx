package blogish.data;

import blok.tower.cache.*;
import blok.tower.file.*;
import blok.tower.format.*;
import blok.tower.asset.data.SourceDirectory;

using Reflect;
using haxe.io.Path;
using Kit;

class Repository {
  final src:SourceDirectory;
  final cache:Cache<Dynamic>;
  final markdown:MarkdownFormat<Dynamic>;

  public function new(src, markdown, cache) {
    this.src = src;
    this.cache = cache;
    this.markdown = markdown;
  }
  
  public function getPosts():Task<Array<Dynamic>> {
    return cache.get('posts').next(maybe -> switch maybe {
      case Some(posts):
        Task.resolve(posts);
      case None:
        src.openDirectory('posts')
          .listFiles()
          .next(files -> files.filter(file -> file.path.extension() == 'md'))
          .next(files -> {
            files.sort((a, b) -> Math.ceil(a.meta.created.getTime() - b.meta.created.getTime()) * -1);
            files;
          })
          .next(files -> Task.parallel(...[ for (file in files) processPostData(file) ]))
          .next(posts -> cache.set('posts', posts).next(_ -> Task.resolve(posts)));
    });
  }
  
  public function getPages():Task<Array<Dynamic>> {
    return cache.get('pages').next(maybe -> switch maybe {
      case Some(pages):
        Task.resolve(pages);
      case None:
        src.openDirectory('pages')
          .listDirectories()
          .next(dirs -> Task.parallel(...dirs.map(processPageData)))
          .next(data -> cache.set('pages', data).next(_ -> Task.resolve(data)));
    });
  }
  
  function processPageData(dir:Directory):Task<Dynamic> {
    return dir.getFile('data.md').next(file -> file.read()
      .next(markdown.parse)
      .next((data:Dynamic) -> {
        data.setField('slug', dir.path.withoutDirectory());
        Task.resolve(data);
      })
    );
  }
  
  function processPostData(file:File):Task<Dynamic> {
    return file
      .read()
      .next(markdown.parse)
      .next((data:Dynamic) -> {
        data.setField('slug', file.meta.name);
        Task.resolve(data);
      });
  }
}
