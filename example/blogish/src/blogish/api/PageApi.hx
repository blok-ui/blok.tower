package blogish.api;

import blogish.data.*;
import blok.tower.cache.Cache;
import blok.tower.routing.JsonRpcRoute;

using Kit;
using Lambda;

class PageApi implements JsonRpcRoute<'/api/pages'> {
  final repository:Repository;
  final cache:Cache<Dynamic>;

  public function new(repository, cache) {
    this.repository = repository;
    this.cache = cache;
  }
  
  public function getPage(slug:String):Task<Post> {
    var cacheId = 'page:$slug';
    return cache.get(cacheId).next(value -> switch value {
      case Some(page): 
        Task.resolve((page:Post));
      case None: repository.getPages().next(pages -> {
        var page = pages.find(page -> page.slug == slug);
        if (page == null) return new Error(NotFound, 'No page exists for $slug');
        var post = Post.fromJson(page);
        cache.set(cacheId, post);
        return post;
      });
    });
  }
}
